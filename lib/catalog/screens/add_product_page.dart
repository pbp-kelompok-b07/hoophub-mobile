import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  // State variables
  String _category = 'Shoes'; 
  bool _isAvailable = true; // Variable to store the switch state
  bool _submitting = false;

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final categories = ['Shoes', 'Jersey', 'Ball', 'Pants', 'Accessories'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Name', _nameController),
              _buildTextField('Brand', _brandController),
              
              // Dropdown for Category
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                ),
              ),

              _buildTextField('Price', _priceController, isNumber: true),
              _buildTextField('Stock', _stockController, isNumber: true),
              _buildTextField('Image URL', _imageController),
              _buildTextField('Description', _descriptionController, maxLines: 3),

              // === AVAILABLE SWITCH ===
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SwitchListTile(
                  title: const Text('Available'),
                  subtitle: const Text('Is this product ready for sale?'),
                  value: _isAvailable,
                  activeColor: const Color(0xFFEE9B00),
                  onChanged: (bool value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                ),
              ),
              // ========================

              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE9B00),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _submitting ? null : () async {
                    // 1. Validate Form
                    if (_formKey.currentState!.validate()) {
                        
                        setState(() {
                          _submitting = true;
                        });

                        // 2. Send Request to Django
                        final response = await request.postJson(
                          "https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/catalog/create-flutter/",
                          jsonEncode(<String, dynamic>{
                            'name': _nameController.text,
                            'brand': _brandController.text,
                            'category': _category,
                            'price': int.parse(_priceController.text),
                            'stock': int.parse(_stockController.text),
                            'description': _descriptionController.text,
                            'image': _imageController.text, 
                            'is_available': _isAvailable, // Sending the switch status
                          }),
                        );

                        setState(() {
                          _submitting = false;
                        });

                        // 3. Handle Response
                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Produk baru berhasil disimpan!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context, true); // Return success signal
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response['message'] ?? "Gagal menyimpan"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                    }
                  },
                  child: _submitting 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Product', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to avoid code repetition
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label must not empty';
          }
          if (isNumber && int.tryParse(value) == null) {
            return '$label must be number';
          }
          return null;
        },
      ),
    );
  }
}