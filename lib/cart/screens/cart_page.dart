import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:hoophub_mobile/cart/models/cart_entry.dart';
import 'package:hoophub_mobile/cart/widgets/cart_item_card.dart';
import 'package:hoophub_mobile/catalog/screens/catalog_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final Color primaryColor = const Color(0xFFEE9B00);
  final Color borderColor = const Color(0xFF005F73);

  late Future<List<CartEntry>> _cartFuture;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _cartFuture = fetchCartItems(request);
  }

  Future<List<CartEntry>> fetchCartItems(CookieRequest request) async {
    try {
      final response = await request.get(
        'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/cart/json-flutter/',
      );

      // PERBAIKAN: Cek apakah response benar-benar List sebelum diloop
      if (response is List) {
        List<CartEntry> listItems = [];
        for (var d in response) {
          if (d != null) {
            listItems.add(CartEntry.fromJson(d));
          }
        }
        return listItems;
      } else {
        // Jika response bukan list (misal: {"status": "error"}), return kosong
        return [];
      }
    } catch (e) {
      print("fetch cart error: $e");
      return [];
    }
  }

  void refreshPage() {
    setState(() {
      final request = context.read<CookieRequest>();
      _cartFuture = fetchCartItems(request);
    });
  }

  void _showCheckoutModal(BuildContext context, CookieRequest request) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
              key: formKey,
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
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  
                  final response = await request.post(
                    'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/cart/checkout-flutter/',
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
        title: const Text("My Cart", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: FutureBuilder<List<CartEntry>>(
          future: _cartFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
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
                List<CartEntry> cartItems = snapshot.data!;
                double totalPrice = 0;
                for (var item in cartItems) {
                  totalPrice += item.fields.subtotal;
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: borderColor, width: 2)),
                        ),
                        child: const Text(
                          "Review your cart",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          refreshPage();
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: cartItems.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (_, index) => CartItemCard(
                            cartItem: cartItems[index],
                            onRefresh: refreshPage,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: borderColor, width: 1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, -3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                              Text(
                                "Rp ${totalPrice.toStringAsFixed(0)}",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _showCheckoutModal(context, request),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Checkout", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
            }
          },
        ),
      ),
    );
  }
}