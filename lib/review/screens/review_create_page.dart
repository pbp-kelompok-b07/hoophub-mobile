import 'package:flutter/material.dart';
import 'package:hoophub_mobile/review/screens/review_entry_list.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ReviewCreatePage extends StatefulWidget {
  final int productId;

  const ReviewCreatePage({super.key, required this.productId});

  @override
  State<ReviewCreatePage> createState() => _ReviewCreatePageState();
}

class _ReviewCreatePageState extends State<ReviewCreatePage> {
  final _formKey = GlobalKey<FormState>();
  int _rating = 0;
  String _review = "";
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Write your review!'),
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _reviewController,
                  decoration: InputDecoration(
                    labelText: "Write your review.",
                    hintText: "Write your review about this product!",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  maxLines: 3,
                  onChanged: (String? value) {
                    setState(() {
                      _review = value!;
                    });
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text(
                      "Rating",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 5; i++)
                          IconButton(
                            icon: Icon(
                              Icons.star,
                              color: i < _rating
                                  ? const Color(0xFFEE9B00)
                                  : Colors.grey[300],
                              size: 30,
                            ),
                            onPressed: () {
                              setState(() {
                                _rating = i + 1;
                              });
                            },
                          ),
                      ],
                    ),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEE9B00),
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate() && _rating > 0) {
                          final response = await request.postJson(
                            "https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/review/create-flutter/${widget.productId}/",
                            jsonEncode(<String, String>{
                              'review': _review,
                              'rating': _rating.toString(),
                            }),
                          );

                          if (context.mounted) {
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Review created successfully!"),
                                ),
                              );
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => ReviewEntryListPage()),
                              // );
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response['message'] ??
                                        "Failed to create new review.",
                                  ),
                                ),
                              );
                            }
                          }
                        } else if (_rating == 0) {
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please provide a rating!"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Submit",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
