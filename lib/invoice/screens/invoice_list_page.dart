import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:hoophub_mobile/invoice/models/invoice_entry.dart'; 

class InvoiceListPage extends StatefulWidget {
  const InvoiceListPage({super.key});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  
  Future<List<InvoiceEntry>> fetchInvoices(CookieRequest request) async {
    try {
      final response = await request.get(
        'http://localhost:8000/invoice/json/', 
        // 'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/invoice/json-flutter/'
      );

      var data = response;

      List<InvoiceEntry> listInvoices = [];
      for (var d in data) {
        if (d != null) {
          listInvoices.add(InvoiceEntry.fromJson(d));
        }
      }
      return listInvoices;
    } catch (e) {
      print("fetch error: $e");
      return [];
    }
  }

  void refreshPage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      // Kita bungkus body dengan RefreshIndicator agar bisa pull-to-refresh
      body: RefreshIndicator(
        onRefresh: () async {
          refreshPage();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Jarak aman dari atas (Status Bar)
              const SizedBox(height: 40), 

              // --- HEADER SESUAI GAMBAR ---
              const Text(
                "Track your past orders!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const DashedLineSeparator(),
              const SizedBox(height: 32),
              // ----------------------------

              // --- FUTURE BUILDER ---
              FutureBuilder(
                future: fetchInvoices(request),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'You have no orders yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  } else {
                    List<InvoiceEntry> invoices = snapshot.data as List<InvoiceEntry>;
                    
                    // Menampilkan list order card
                    return ListView.builder(
                      // ShrinkWrap true agar ListView bisa berada di dalam SingleChildScrollView
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: invoices.length,
                      itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: OrderCard(entry: invoices[index]),
                      ),
                    );
                  }
                },
              ),
              // Padding bawah agar tidak tertutup navbar
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET UI (OrderCard & DashedLine) SESUAI GAMBAR ---

class OrderCard extends StatelessWidget {
  final InvoiceEntry entry;

  const OrderCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    // Format harga: pastikan ada "Rp"
    String displayPrice = entry.price.toString().startsWith("Rp") 
        ? entry.price.toString() 
        : "Rp${entry.price}";

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0), // Warna abu-abu background kartu
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Header: Invoice ID & Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Invoice ${entry.id}", // ID dari Model
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "2025-12-03 16:35", // Tanggal (Hardcoded / ambil dari model jika ada field date)
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),

          // Tombol-tombol aksi (Edit, Order Again, Delete)
          // Menggunakan Wrap agar aman di layar kecil
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton("Edit Status", const Color(0xFF006064), () {
                 // Tambahkan logika edit status di sini
              }),
              _buildActionButton("Order again", Colors.orange, () {
                 // Tambahkan logika order again
              }),
              _buildActionButton("Delete", const Color(0xFFBF360C), () {
                 // Tambahkan logika delete
              }),
            ],
          ),
          
          const SizedBox(height: 20),

          // Product Card (Kotak Putih)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Produk
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    entry.thumbnail, // Gambar dari Model
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      width: 80, height: 80, color: Colors.grey[300], 
                      child: const Icon(Icons.broken_image)
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Detail Produk
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name, // Nama dari Model
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Detail tambahan (Quantity, Color, Size)
                      const Text("Quantity: 1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      
                      // Menampilkan Size dan Color jika ada di model
                      Text("Size: ${entry.size} | Color: ${entry.color}", 
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      
                      const SizedBox(height: 4),
                      Text("Price: $displayPrice", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      Text("Subtotal: $displayPrice", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Footer: Total & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
               const Text(
                "Total :",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                displayPrice,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Status :",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Pending", // Status (bisa diambil dari model jika ada field status)
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Tombol Kecil
  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

// Widget Garis Putus-Putus
class DashedLineSeparator extends StatelessWidget {
  const DashedLineSeparator({super.key, this.height = 1, this.color = Colors.teal});
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
        );
      },
    );
  }
}