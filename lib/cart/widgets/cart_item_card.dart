import 'package:flutter/material.dart';
import 'package:hoophub_mobile/cart/models/cart_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class CartItemCard extends StatelessWidget {
  final CartEntry cartItem;
  final VoidCallback onRefresh;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  cartItem.fields.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),

            // === DETAIL PRODUK (Kanan) ===
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.fields.productName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Harga
                  Text(
                    "Rp ${cartItem.fields.price}",
                    style: const TextStyle(fontSize: 14, color: Color(0xFFEE9B00), fontWeight: FontWeight.w600),
                  ),
                  
                  const SizedBox(height: 4),

                  // Quantity & Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Qty: ${cartItem.fields.quantity}", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      Flexible(
                        child: Text(
                          "Total: Rp ${cartItem.fields.subtotal}",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),

                  // Tombol Delete
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final response = await request.post(
                              'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/cart/delete-flutter/',
                              jsonEncode({'id': cartItem.pk}),
                            );
                            
                            if (context.mounted) {
                              if (response['status'] == 'success') {
                                onRefresh();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item deleted")));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus item")));
                              }
                            }
                          } catch (e) {
                            print("Error delete: $e");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFc9302c),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Delete", style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}