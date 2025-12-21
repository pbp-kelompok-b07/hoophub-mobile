import 'dart:convert'; // Wajib ada untuk jsonEncode
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:hoophub_mobile/catalog/models/product.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  // Controller untuk input text
  late TextEditingController nameController;
  late TextEditingController brandController;
  late TextEditingController categoryController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController imageController;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    
    // Mengisi form dengan data produk yang sudah ada
    nameController = TextEditingController(text: p.name);
    brandController = TextEditingController(text: p.brand);
    // Jika di model Product tidak ada category, ganti string kosong atau sesuaikan
    categoryController = TextEditingController(text: "Shoes"); 
    descriptionController = TextEditingController(text: p.description);
    priceController = TextEditingController(text: p.price.toString());
    stockController = TextEditingController(text: p.stock.toString());
    imageController = TextEditingController(text: p.imageUrl);
  }

  @override
  void dispose() {
    // Membersihkan controller agar memori tidak bocor
    nameController.dispose();
    brandController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView( // Menggunakan ScrollView agar tidak overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _field('Name', nameController),
            _field('Brand', brandController),
            _field('Category', categoryController),
            _field('Description', descriptionController, maxLines: 3),
            _field('Price', priceController, number: true),
            _field('Stock', stockController, number: true),
            _field('Image URL', imageController),

            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: const Color(0xFFEE9B00), // Sesuaikan warna tema
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                // 1. Validasi sederhana: Pastikan Harga dan Stok adalah Angka
                if (int.tryParse(priceController.text) == null || 
                    int.tryParse(stockController.text) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Price and Stock must be valid numbers')),
                    );
                    return;
                }

                // 2. Kirim Request ke Django
                final response = await request.postJson(
                  // PENTING: Gunakan URL edit-flutter yang sudah kita buat
                  "https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/catalog/edit-flutter/${widget.product.id}/",
                  
                  // PENTING: Bungkus data dengan jsonEncode
                  jsonEncode(<String, dynamic>{
                    'name': nameController.text,
                    'brand': brandController.text,
                    'category': categoryController.text,
                    'description': descriptionController.text,
                    'price': int.parse(priceController.text), // Kirim sebagai integer
                    'stock': int.parse(stockController.text), // Kirim sebagai integer
                    'image': imageController.text, // Pastikan key ini sama dengan di Django views.py ('image' atau 'image_url')
                  }),
                );

                // 3. Cek Respons
                if (context.mounted) {
                  if (response['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Produk berhasil diubah!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Kembali ke halaman Catalog dan kirim sinyal refresh (true)
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(response['message'] ?? "Gagal mengubah produk"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {bool number = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}