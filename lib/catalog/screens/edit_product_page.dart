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
    nameController = TextEditingController(text: p.name);
    brandController = TextEditingController(text: p.brand);
    categoryController = TextEditingController(text: p.category);
    descriptionController = TextEditingController(text: p.description);
    priceController = TextEditingController(text: p.price.toString());
    stockController = TextEditingController(text: p.stock.toString());
    imageController = TextEditingController(text: p.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _field('Name', nameController),
            _field('Brand', brandController),
            _field('Category', categoryController),
            _field('Description', descriptionController),
            _field('Price', priceController, number: true),
            _field('Stock', stockController, number: true),
            _field('Image URL', imageController),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final response = await request.post(
                'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/catalog/update/${widget.product.id}/',
                  {
                    'name': nameController.text,
                    'brand': brandController.text,
                    'category': categoryController.text,
                    'description': descriptionController.text,
                    'price': priceController.text,
                    'stock': stockController.text,
                    'image': imageController.text,
                  },
                );

                if (context.mounted) {
                  if (response['success'] == true) {
                    Navigator.pop(context, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update product')),
                    );
                  }
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
      {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
