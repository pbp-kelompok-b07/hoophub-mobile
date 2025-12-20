import 'package:flutter/material.dart';
import 'package:hoophub_mobile/review/models/review_entry.dart';
import 'package:hoophub_mobile/review/widgets/review_entry_card.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class ReviewEntryListPage extends StatefulWidget {
  const ReviewEntryListPage({super.key});

  @override
  State<ReviewEntryListPage> createState() => _ReviewEntryListPageState();
}

class _ReviewEntryListPageState extends State<ReviewEntryListPage> {
  int? _selectedRatingFilter;
  final List<int?> _ratings = [null, 5, 4, 3, 2, 1];

  Future<List<ReviewEntry>> fetchReviews(CookieRequest request) async {
    try {
      final response = await request.get(
        'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/review/json-flutter/',
      );

      var data = response;

      List<ReviewEntry> listReviews = [];
      for (var d in data) {
        if (d != null) {
          listReviews.add(ReviewEntry.fromJson(d));
        }
      }
      return listReviews;
    } catch (e) {
      print("fetch error: $e");
      return [];
    }
  }

  void refreshPage() {
    setState(() {});
  }

  List<ReviewEntry> _applyFilter(List<ReviewEntry> reviews) {
    if (_selectedRatingFilter == null) {
      // default = null (all)
      return reviews;
    } else {
      return reviews
          .where((review) => review.rating == _selectedRatingFilter)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: fetchReviews(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No reviews yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            } else {
              List<ReviewEntry> reviews = snapshot.data as List<ReviewEntry>;
              List<ReviewEntry> filtered = _applyFilter(reviews);

              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final rating = _ratings[index];
                        final isSelected = rating == _selectedRatingFilter;

                        String label = rating == null ? "All" : "$rating ★";

                        return FilterChip(
                          label: Text(label),
                          selected: isSelected,
                          side: BorderSide.none,
                          selectedColor: Color(0xFFEE9B00),
                          backgroundColor: Colors.grey[200],
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedRatingFilter = selected ? rating : null;
                            });
                          },
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemCount: _ratings.length,
                    ),
                  ),

                  const Divider(height: 1, thickness: 1),

                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text('No reviews yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ) 
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, index) => ReviewEntryCard(
                              review: filtered[index],
                              onRefresh: refreshPage,
                            ),
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
