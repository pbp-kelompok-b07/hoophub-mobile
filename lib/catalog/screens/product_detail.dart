import 'package:flutter/material.dart';
import 'package:hoophub_mobile/catalog/models/product.dart';
import 'package:hoophub_mobile/review/models/review_entry.dart' as review_data;
import 'package:hoophub_mobile/review/screens/review_create_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:hoophub_mobile/report/screens/report_create_page.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  void _refreshReviews() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
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
                            refreshTrigger: _refreshReviews,
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
                        refreshTrigger: _refreshReviews,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportCreatePage(productId: p.id),
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

  const _ProductImageCard({required this.imageUrl});
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
  final VoidCallback refreshTrigger;

  const _ProductInfoSection({
    required this.product,
    required this.inStock,
    required this.refreshTrigger,
  });

  Future<List<review_data.ReviewEntry>> fetchReviews(
    CookieRequest request,
  ) async {
    try {
      final response = await request.get(
        'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/review/json-all-flutter/',
      );

      var data = response;

      List<review_data.ReviewEntry> listReviews = [];
      for (var d in data) {
        if (d != null) {
          var entry = review_data.ReviewEntry.fromJson(d);
          if (entry.product.id == product.id) {
            listReviews.add(entry);
          }
        }
      }
      return listReviews;
    } catch (e) {
      print("fetch error: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = product;
    final request = context.watch<CookieRequest>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p.name,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '${p.brand} • ${p.category}',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
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
                color: inStock
                    ? const Color(0xFFE8F5E9)
                    : const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                inStock ? 'Available' : 'Out of stock',
                style: TextStyle(
                  fontSize: 12,
                  color: inStock
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
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
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewCreatePage(productId: p.id),
                  ),
                );
                refreshTrigger();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFA000),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
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
                  const SnackBar(content: Text('Added to wishlist.')),
                );
              },
              icon: Icon(
                Icons.favorite_border,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                'Add to wishlist',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        FutureBuilder(
          future: fetchReviews(request),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text(
                  'No reviews yet.',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                );
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final review = snapshot.data![index];
                    return Card(
                      color: Colors.white,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.user,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),

                            Text(
                              review.date,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),

                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    for (int i = 0; i < 5; i++)
                                      Icon(
                                        Icons.star,
                                        color: i < review.rating
                                            ? const Color(0xFFEE9B00)
                                            : Colors.grey[300],
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),
                            Text(
                              review.review,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }
          },
        ),
      ],
    );
  }
}
