import 'package:flutter/material.dart';
import 'package:hoophub_mobile/cart/models/cart_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === GAMBAR PRODUK (Kiri) ===
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.network(
            cartItem.fields.thumbnailUrl ?? "",
            fit: BoxFit.cover,
            errorBuilder: (ctx, error, stackTrace) => Container(
              color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey)
            ),
          ),
        ),
        
        const SizedBox(width: 20),

        // === DETAIL PRODUK (Kanan) ===
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Produk
              Text(
                cartItem.fields.productName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              
              // Harga
              Text("Price: Rp${cartItem.fields.price}", style: const TextStyle(fontSize: 16)),
              
              // Quantity
              Text("Quantity: ${cartItem.fields.quantity}", style: const TextStyle(fontSize: 16)),
              
              const SizedBox(height: 5),
              // Subtotal
              Text(
                "Subtotal: Rp${cartItem.fields.subtotal}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              
              const SizedBox(height: 10),
              

              const SizedBox(height: 10),

              // Tombol Delete
              ElevatedButton(
                onPressed: () async {
                   final response = await request.postJson(
                    'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/cart/delete-flutter/', 
                    {'id': cartItem.pk},
                  );
                  if (response['status'] == 'success') {
                    onRefresh();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Item deleted")));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFc9302c),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        )
      ],
    );
  }
}