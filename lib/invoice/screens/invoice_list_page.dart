import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:hoophub_mobile/invoice/models/invoice_entry.dart'; 

class InvoiceListPage extends StatefulWidget {
  final VoidCallback? onReorder;
  const InvoiceListPage({super.key, this.onReorder});

  @override
  State<InvoiceListPage> createState() => _InvoiceListPageState();
}

class _InvoiceListPageState extends State<InvoiceListPage> {
  
  // Perubahan: Mengembalikan List<Invoice>
  Future<List<Invoice>> fetchInvoices(CookieRequest request) async {
    try {
      final response = await request.get(
        'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/invoice/json/' 
      );

      // Menggunakan factory fromJson dari InvoiceEntry
      InvoiceEntry data = InvoiceEntry.fromJson(response);
      
      if (data.status == 'success') {
        return data.invoices;
      } else {
        return [];
      }
    } catch (e) {
      print("fetch error: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    FutureBuilder(
                      future: fetchInvoices(request),
                      builder: (context, AsyncSnapshot<List<Invoice>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              children: const [
                                Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No invoice yet.',
                                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                              ],
                            ),
                          );
                        } else {
                          // snapshot.data adalah List<Invoice>
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (_, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
                              child: OrderCard(
                                entry: snapshot.data![index],
                                onDelete: () {
                                  setState(() {});
                                },
                                onReorder: widget.onReorder,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Invoice entry; // Menggunakan Model Invoice
  final VoidCallback onDelete;
  final VoidCallback? onReorder;

  const OrderCard({super.key, required this.entry, required this.onDelete, this.onReorder});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF14919B); // Sesuai gambar Paid
      case 'shipped':
        return const Color(0xFF005F73); // Sesuai gambar Shipped
      case 'cancelled':
        return const Color(0xFFBF360C); // Sesuai gambar Cancelled
      case 'pending':
      default:
        return Colors.orange; // Default untuk Pending
    }
  }

  void _showEditStatusModal(BuildContext context, CookieRequest request) {
    String selectedStatus = entry.status; // Nilai awal sesuai status sekarang
    List<String> statusChoices = ["Pending", "Paid", "Shipping", "Cancelled"];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Agar state dropdown di dalam modal bisa berubah
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFE0E0E0), // Warna abu-abu background modal
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Update Order Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedStatus,
                        isExpanded: true,
                        items: statusChoices.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedStatus = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final response = await request.post(
                            'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/invoice/edit-status-flutter/',
                            jsonEncode({
                              'id': entry.id,
                              'status': selectedStatus,
                            }),
                          );

                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              Navigator.pop(context);
                              onDelete(); // Memicu refresh halaman utama
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Status updated to $selectedStatus"))
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF005F73), // Warna dark teal sesuai gambar
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Save", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil item pertama untuk preview di card (asumsi minimal ada 1 item)
    final firstItem = entry.items.isNotEmpty ? entry.items[0] : null;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Abu-abu muda
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Invoice No & Tanggal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Invoice ${entry.invoiceNo}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.date, 
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),

          // Tombol Aksi
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildActionButton("Edit Status", const Color(0xFF006064), () {
                final request = context.read<CookieRequest>();
                _showEditStatusModal(context, request);
              }),
              _buildActionButton("Order Again", Colors.orange, () async {
                final request = context.read<CookieRequest>();

                // 1. Siapkan data items dari invoice ini
                List<Map<String, dynamic>> itemsToReorder = entry.items.map((item) {
                  return {
                    "productId": item.productId,
                    "quantity": item.quantity,
                  };
                }).toList();

                // 2. Kirim request ke Django
                final response = await request.post(
                  'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/invoice/reorder-flutter/',
                  jsonEncode({"items": itemsToReorder}),
                );

                if (context.mounted) {
                  if (response['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("All items added to cart!"))
                    );
                    onReorder?.call();
                    
                    // Opsional: Arahkan user langsung ke halaman Cart
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response['message'] ?? "Failed to add items"))
                    );
                  }
                }
              }),
              // Di dalam OrderCard
              _buildActionButton("Delete", const Color(0xFFBF360C), () async {
                  // 1. Tampilkan konfirmasi (Dialog) agar tidak sengaja terhapus
                  bool confirm = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: const Color(0xFFE0E0E0), // Latar abu-abu sesuai gambar
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Delete this invoice?",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            // Ikon X di pojok kanan atas
                            GestureDetector(
                              onTap: () => Navigator.pop(context, false),
                              child: const Icon(Icons.close, color: Colors.black),
                            ),
                          ],
                        ),
                        content: const Text(
                          "This action cannot be undone.",
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
                        actions: [
                          // Tombol Cancel (Abu-abu)
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[600],
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Tombol Delete (Oranye Tua/Kemerahan)
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBF360C), // Warna oranye kemerahan sesuai gambar
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ],
                      );
                    },
                  ) ?? false;

                  if (confirm) {
                      final request = context.read<CookieRequest>();
                      
                      // 2. Kirim request hapus ke Django
                      final response = await request.post(
                          'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/invoice/delete-invoice-flutter/',
                          jsonEncode({'id': entry.id}),
                      );

                      if (response['status'] == 'success') {
                          onDelete();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Invoice deleted successfully"))
                          );
                          // 3. Refresh halaman (panggil callback refresh yang ada di Parent)
                          // Kamu bisa menggunakan Provider atau memanggil fungsi refreshPage()
                      } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Failed to delete invoice"))
                          );
                      }
                  }
              }),
            ],
          ),
          
          const SizedBox(height: 20),

          // Product Preview (Hanya menampilkan item pertama)
          // --- GANTI BAGIAN "Product Preview" (Kotak Putih) DENGAN INI ---

          // Kita gunakan Column untuk menampilkan semua item yang ada di list entry.items
          Column(
            children: entry.items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12), // Jarak antar produk
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
                        item.image,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 70, height: 70, color: Colors.grey[300], 
                          child: const Icon(Icons.broken_image, size: 20)
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Detail Produk
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text("Quantity: ${item.quantity}", 
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text("Brand: ${item.brand}", 
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text("Price: Rp${item.price}", 
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            "Subtotal: Rp${item.subtotal}", 
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),


          const SizedBox(height: 20),

          // Footer: Total & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("Rp${entry.totalPrice}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Status :", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(entry.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  entry.status,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}