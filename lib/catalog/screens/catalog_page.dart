import 'dart:convert'; // Tambahkan ini untuk jsonEncode
import 'package:flutter/material.dart';
import 'package:hoophub_mobile/catalog/models/product.dart';
import 'package:hoophub_mobile/catalog/screens/add_product_page.dart';
import 'package:hoophub_mobile/catalog/screens/edit_product_page.dart';
import 'package:hoophub_mobile/catalog/screens/product_detail.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late Future<List<Product>> _futureProducts;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _futureProducts = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    final request = context.read<CookieRequest>();
    // Pastikan URL ini benar
    final response = await request.get(
      'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/catalog/json/',
    );

    final List<Product> products = [];
    if (response != null) {
      for (final item in response) {
        products.add(Product.fromJson(item as Map<String, dynamic>));
      }
    }
    return products;
  }

  // === FUNGSI TAMBAH KE KERANJANG ===
  Future<void> _addToCart(CookieRequest request, int productId) async {
    try {
      final response = await request.post(
        'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/cart/add-flutter/$productId/',
        {},
      );

      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Berhasil ditambahkan ke keranjang"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Gagal menambahkan"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      }
    }
  }

  // === FUNGSI DELETE PRODUK (BARU) ===
  void _deleteProduct(CookieRequest request, Product p) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Hapus Produk"),
          content: Text("Apakah Anda yakin ingin menghapus '${p.name}'?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog

                // Kirim request delete
                final response = await request.postJson(
                  "https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/catalog/delete-flutter/${p.id}/",
                  jsonEncode({}),
                );

                if (mounted) {
                  if (response['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Produk berhasil dihapus!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Refresh daftar produk
                    setState(() {
                      _futureProducts = _fetchProducts();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response['message'] ?? "Gagal menghapus"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final dynamic rawUsername = request.jsonData['username'];
    final String username =
        rawUsername is String ? rawUsername : (rawUsername ?? '').toString();
    final bool isAdmin = username.toLowerCase() == 'admin';

    // Warna tema
    const Color primaryColor = Color(0xFFEE9B00);

    return Scaffold(
      appBar: AppBar(
        title: const Text('hoophub Catalog'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      // Tombol Add Product (Khusus Admin)
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: primaryColor,
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddProductPage(),
                  ),
                );
                // Refresh jika produk berhasil dibuat
                if (created == true) {
                  setState(() {
                    _futureProducts = _fetchProducts();
                  });
                }
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Product',
                  style: TextStyle(color: Colors.white)),
            )
          : null,

      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No Product'),
            );
          }

          final allProducts = snapshot.data!;
          final filtered = allProducts.where((p) {
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return p.name.toLowerCase().contains(q) ||
                p.brand.toLowerCase().contains(q);
          }).toList();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Find the product!',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Product Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.60,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final p = filtered[index];
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailPage(product: p),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gambar Produk
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                                child: p.imageUrl.isNotEmpty
                                    ? Image.network(
                                        p.imageUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                                child: Icon(Icons.image)),
                                      )
                                    : const Center(child: Icon(Icons.image)),
                              ),
                            ),

                            // Detail Produk
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p.brand,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // === HARGA & TOMBOL ADD TO CART ===
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Rp ${p.price}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: primaryColor,
                                        ),
                                      ),
                                      // Tombol Keranjang
                                      SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                              Icons.add_shopping_cart,
                                              size: 20),
                                          color: primaryColor,
                                          onPressed: () {
                                            _addToCart(request, p.id);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),
                                  Text(
                                    'Stok: ${p.stock}',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.grey),
                                  ),

                                  // === Bagian Admin (Edit & Delete Button) ===
                                  if (isAdmin) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE3F2FD),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Admin',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1565C0)),
                                          ),
                                          // Row untuk Edit dan Delete
                                          Row(
                                            children: [
                                              // Tombol Edit
                                              InkWell(
                                                onTap: () async {
                                                  final refreshed =
                                                      await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          EditProductPage(
                                                        product: p,
                                                      ),
                                                    ),
                                                  );
                                                  if (refreshed == true) {
                                                    setState(() {
                                                      _futureProducts =
                                                          _fetchProducts();
                                                    });
                                                  }
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Icon(
                                                    Icons.edit,
                                                    size: 18,
                                                    color: Color(0xFF1565C0),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Tombol Delete
                                              InkWell(
                                                onTap: () {
                                                  _deleteProduct(request, p);
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: Icon(
                                                    Icons.delete,
                                                    size: 18,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}