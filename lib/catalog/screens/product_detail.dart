import 'package:flutter/material.dart';
import 'package:hoophub_mobile/catalog/models/product.dart';
import 'package:hoophub_mobile/review/screens/review_create_page.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;
    final bool inStock = p.stock > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                label: Text(
                  'Back to Catalog',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _ProductImageCard(imageUrl: p.imageUrl),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 3,
                          child: _ProductInfoSection(
                            product: p,
                            inStock: inStock,
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProductImageCard(imageUrl: p.imageUrl),
                      const SizedBox(height: 16),
                      _ProductInfoSection(
                        product: p,
                        inStock: inStock,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Something wrong with this product?',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report sent.'),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.report_gmailerrorred_outlined,
                    size: 18,
                    color: Colors.orange,
                  ),
                  label: const Text(
                    'Report',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImageCard extends StatelessWidget {
  final String imageUrl;

  const _ProductImageCard({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.image)),
                )
              : const Center(child: Icon(Icons.image)),
        ),
      ),
    );
  }
}

class _ProductInfoSection extends StatelessWidget {
  final Product product;
  final bool inStock;

  const _ProductInfoSection({
    required this.product,
    required this.inStock,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${p.brand} • ${p.category}',
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Rp ${p.price}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFFFFA000),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: inStock ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                inStock ? 'Available' : 'Out of stock',
                style: TextStyle(
                  fontSize: 12,
                  color: inStock ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Release date: -',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Go to review page.'),
                  ),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // 'builder' yang akan membuat instance halaman tujuan
                    builder: (context) => ReviewCreatePage(productId: p.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA000),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Review'),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to wishlist.'),
                  ),
                );
              },
              icon: Icon(
                Icons.favorite_border,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                'Add to wishlist',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          p.description.isNotEmpty
              ? p.description
              : 'No description available.',
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 24),
        const Text(
          'Reviews',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'No reviews yet.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }
}
