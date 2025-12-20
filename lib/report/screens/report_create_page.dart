  import 'package:flutter/material.dart';
  import 'package:pbp_django_auth/pbp_django_auth.dart';
  import 'package:provider/provider.dart';

  class ReportCreatePage extends StatefulWidget {
    final int productId;

    const ReportCreatePage({super.key, required this.productId});

    @override
    State<ReportCreatePage> createState() => _ReportCreatePageState();
  }

  class _ReportCreatePageState extends State<ReportCreatePage> {
    final _formKey = GlobalKey<FormState>();
    String _title = "";
    String _description = "";
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();


    @override
    Widget build(BuildContext context) {
      final request = context.watch<CookieRequest>();

      return Scaffold(
        appBar: AppBar(
          title: const Text("Create Report"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                  ),
                  onChanged: (value) {
                    setState(() {
                      _title = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a title";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Description",
                  ),
                  controller: _descriptionController, 
                  onChanged: (value) {
                    setState(() {
                      _description = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a description";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final response = await request.post(
                        'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/report/create-flutter/',
                        {
                          'object_id': widget.productId.toString(),  // Ubah key jadi 'object_id'
                          'report_type': 'product',                  // Tambahkan ini! (karena logic kamu ngecek string 'product')
                          'title': _title,
                          'description': _description,
                        },
                      );

                      if (!context.mounted) return;

                      if (response['success']) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Report created successfully')),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to create report: ${response['message']}')),
                        );
                      }
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }