import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:hoophub_mobile/cart/models/cart_entry.dart';
import 'package:hoophub_mobile/cart/widgets/cart_item_card.dart';
import 'package:hoophub_mobile/screens/menu.dart';
import 'package:hoophub_mobile/catalog/screens/catalog_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Color primaryColor = const Color(0xFFEE9B00);
  final Color borderColor = const Color(0xFF005F73);

  Future<List<CartEntry>> fetchCartItems(CookieRequest request) async {
    try {
      final response = await request.get(
        'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/cart/json-flutter/', 
      );
      var data = response;
      List<CartEntry> listItems = [];
      for (var d in data) {
        if (d != null) {
          listItems.add(CartEntry.fromJson(d));
        }
      }
      return listItems;
    } catch (e) {
      print("fetch cart error: $e");
      return [];
    }
  }

  void refreshPage() {
    setState(() {});
  }

  // === FUNGSI MENAMPILKAN MODAL CHECKOUT (Sesuai Django) ===
  void _showCheckoutModal(BuildContext context, CookieRequest request) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String fullName = "";
    String address = "";
    String city = "";
    String postalCode = "";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Formulir Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Field ini wajib diisi' : null,
                    onSaved: (value) => fullName = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Field ini wajib diisi' : null,
                    onSaved: (value) => address = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Field ini wajib diisi' : null,
                    onSaved: (value) => city = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Postcode', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Field ini wajib diisi' : null,
                    onSaved: (value) => postalCode = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  
                  // Kirim data ke Django
                  final response = await request.post(
                    'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/cart/checkout-flutter/', // Pastikan endpoint ini ada
                    {
                      'full_name': fullName,
                      'address': address,
                      'city': city,
                      'postal_code': postalCode,
                    },
                  );

                  if (context.mounted) {
                    if (response['status'] == 'success') {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Checkout Berhasil!")));
                      refreshPage();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'] ?? "Gagal Checkout")));
                    }
                  }
                }
              },
              child: const Text('Make Invoice', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: fetchCartItems(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Your cart is empty.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => const CatalogPage()),
                      ),
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                      child: const Text("Shop Now", style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              );
            } else {
              List<CartEntry> cartItems = snapshot.data as List<CartEntry>;
              double totalPrice = 0;
              for (var item in cartItems) {
                totalPrice += item.fields.subtotal;
              }

              return Column(
                children: [
                  // === HEADER "Review your cart" ===
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: borderColor, width: 2, style: BorderStyle.solid)), // Flutter gak support native dashed border mudah
                      ),
                      child: const Text(
                        "Review your cart",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // === LIST ITEMS ===
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: cartItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 20),
                      itemBuilder: (_, index) => CartItemCard(
                        cartItem: cartItems[index],
                        onRefresh: refreshPage,
                      ),
                    ),
                  ),

                  // === SUMMARY SECTION ===
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: borderColor, width: 2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end, // Rata Kanan sesuai Django
                      children: [
                        Text(
                          "Total: Rp ${totalPrice.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showCheckoutModal(context, request),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            child: const Text("Checkout", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }
}