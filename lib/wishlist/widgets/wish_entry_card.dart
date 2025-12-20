import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hoophub_mobile/wishlist/models/wish_entry.dart';

class WishEntryCard extends StatelessWidget {
  final WishEntry entry;
  final DateFormat dateFmt;
  final bool isAuthenticated;
  final int? processingAddProductId;
  final int? processingRemoveId;
  final Future<void> Function(WishEntry entry)? onAddToCart;
  final Future<void> Function(WishEntry entry)? onRemoveFromWishlist;

  const WishEntryCard({
    super.key,
    required this.entry,
    required this.dateFmt,
    required this.isAuthenticated,
    this.processingAddProductId,
    this.processingRemoveId,
    this.onAddToCart,
    this.onRemoveFromWishlist,
  });
  
  String _productName(WishEntry e) {
    final prod = e.product as dynamic;
    return prod?.name ?? prod?.title ?? prod?.product_name ?? 'Unknown';
  }

  String _productBrand(WishEntry e) {
    final prod = e.product as dynamic;
    return prod?.brand ?? prod?.brandName ?? prod?.manufacturer ?? '';
  }
  
  double _priceOf(WishEntry e) {
    try {
      final prod = e.product as dynamic;
      final p = prod?.price ?? prod?.priceValue ?? prod?.price_int ?? 0;
      if (p == null) return 0;
      if (p is num) return p.toDouble();
      final s = p.toString().replaceAll(RegExp(r"[^0-9\-.,]"), '');
      return double.tryParse(s.replaceAll(',', '')) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  String? _productImageUrl(WishEntry e) {
    final prod = e.product as dynamic;
    return prod?.imageUrl ?? prod?.image_url ?? prod?.image ?? prod?.thumbnail;
  }

  // --- WIDGET BUILDER ---
  @override
  Widget build(BuildContext context) {
    final productName = _productName(entry);
    final productBrand = _productBrand(entry);
    final price = _priceOf(entry);
    final imageUrl = _productImageUrl(entry);
    
    final productId = (entry.product as dynamic)?.id ?? -1;
    final isAdding = processingAddProductId == productId;
    final isRemoving = processingRemoveId == entry.id;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF005F73),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
            child: imageUrl == null ? const Center(child: Text('No Image')) : null,
          ),

          const SizedBox(width: 16),

          // Title + meta + buttons
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Text(
                  productName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // meta
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (productBrand.isNotEmpty) Text(productBrand, style: const TextStyle(color: Colors.white)),
                      if (productBrand.isNotEmpty && price > 0) const SizedBox(width: 8),
                      if (price > 0) Text('Rp ${price.toInt()}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Text(dateFmt.format(entry.dateAdded), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),

                // buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEE9B00),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      // Memanggil callback dari parameter
                      onPressed: isAdding || onAddToCart == null ? null : () => onAddToCart!(entry),
                      child: isAdding
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Add to cart'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBB3E03),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      // Memanggil callback dari parameter
                      onPressed: isRemoving || onRemoveFromWishlist == null ? null : () => onRemoveFromWishlist!(entry),
                      child: isRemoving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}