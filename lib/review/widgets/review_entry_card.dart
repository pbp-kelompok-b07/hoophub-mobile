import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hoophub_mobile/review/models/review_entry.dart';
import 'package:hoophub_mobile/review/screens/review_edit_page.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ReviewEntryCard extends StatelessWidget {
  final ReviewEntry review;
  final VoidCallback onRefresh;

  const ReviewEntryCard({
    super.key,
    required this.review,
    required this.onRefresh,
  });

  String priceFormatter(String priceStr) {
    int price = int.tryParse(priceStr) ?? 0;
    double value = price.toDouble();

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return currencyFormatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/review/proxy-image/?url=${Uri.encodeComponent(review.product.image)}',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // name
                Text(
                  review.product.name,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // const SizedBox(height: 3),

                // price
                Text(
                  priceFormatter(review.product.price),
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 3),

                // date
                Text(
                  review.date,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 6),

                // rating
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < 5; i++)
                      Icon(
                        Icons.star,
                        color: i < review.rating ? const Color(0xFFEE9B00) : Colors.grey[300],
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 6),

                // review
                Text(
                  review.review,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEE9B00),
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ReviewEditPage(review: review),
                          ),
                        );

                        if (result == true) {
                          onRefresh();
                        }
                      }, 
                      child: Text(
                        "Edit", 
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.normal, 
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6,),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFBB3E03),
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete review?', style: TextStyle(fontWeight: FontWeight.bold)),
                            content: const Text(
                              'This action cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          final response = await request.postJson(
                            "https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/review/delete-flutter/${review.id}/",
                            jsonEncode({}),
                          );

                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Review successfully deleted!"),
                                ),
                              );
                              onRefresh();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response['message'] ??
                                        'Failed to delete the review.',
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: Text(
                        "Delete", 
                        style: TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.normal, 
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
