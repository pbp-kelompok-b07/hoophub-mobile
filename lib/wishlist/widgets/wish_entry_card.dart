import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hoophub_mobile/wishlist/models/wish_entry.dart';
import 'package:hoophub_mobile/catalog/screens/product_detail.dart';

class WishEntryCard extends StatelessWidget {
  final WishEntry entry;
  final DateFormat dateFmt;
  final bool isAuthenticated;
  final int? processingAddProductId;
  final int? processingRemoveId;
  final Function(WishEntry) onAddToCart;
  final Function(WishEntry) onRemoveFromWishlist;

  const WishEntryCard({
    super.key,
    required this.entry,
    required this.dateFmt,
    required this.isAuthenticated,
    this.processingAddProductId,
    this.processingRemoveId,
    required this.onAddToCart,
    required this.onRemoveFromWishlist,
  });

  // Helper URL Gambar
  String _fixImageUrl(String? url) {
    if (url == null) return '';
    url = url.trim();
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    const base = "https://roselia-evanny-hoophub.pbp.cs.ui.ac.id";
    if (url.startsWith('/')) return base + url;
    return '$base/$url'; // tambahkan slash jika belum ada
  }

  @override
  Widget build(BuildContext context) {
    final product = entry.product;
    if (product == null) return const SizedBox.shrink();

    final isRemoving = processingRemoveId == entry.id;
    final isAddingCart = processingAddProductId == product.id;
    final imageUrl = _fixImageUrl(product.imageUrl);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF265C68),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GAMBAR (KIRI)
            Container(
              width: 100,
              height: 100, // Ukuran kotak gambar
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                image: imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imageUrl.isEmpty
                  ? const Center(child: Icon(Icons.image, color: Colors.grey))
                  : null,
            ),

            const SizedBox(width: 14),

            // 2. KONTEN (KANAN)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk (Max 2 baris agar informatif tapi rapi)
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Harga
                  Text(
                    'Rp ${product.price}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Tanggal
                  Text(
                    dateFmt.format(entry.dateAdded),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3. TOMBOL AKSI (BARIS BAWAH)
                  Row(
                    children: [
                      // Tombol Add to Cart (Kuning)
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 32, // Tinggi tombol compact
                          child: ElevatedButton(
                            onPressed: isAddingCart ? null : () => onAddToCart(entry),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEAA221), // Warna Oranye/Kuning
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: isAddingCart
                                ? const SizedBox(
                                    width: 14, height: 14, 
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  )
                                : const Text('Add to cart', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),

                      // Tombol Delete (Merah Bata)
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: isRemoving ? null : () => onRemoveFromWishlist(entry),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC44D26), // Warna Merah Bata
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 0,
                            ),
                            child: isRemoving
                                ? const SizedBox(
                                    width: 14, height: 14, 
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  )
                                : const Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}