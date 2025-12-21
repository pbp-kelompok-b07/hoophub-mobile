import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/report_entry.dart';

class ReportDetailPage extends StatefulWidget {
  final ReportEntry report;
  final bool isAdmin;
  final VoidCallback onRefresh;

  const ReportDetailPage({
    super.key,
    required this.report,
    required this.isAdmin,
    required this.onRefresh,
  });

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}
class _ReportDetailPageState extends State<ReportDetailPage> {
  // Variabel untuk menyimpan status saat ini
  late String _currentStatus;
  
  // Opsi status yang tersedia
  final List<String> _statusOptions = ["Pending", "Resolved", "Rejected"];

  @override
  void initState() {
    super.initState();
    // Inisialisasi status awal dari data report
    _currentStatus = widget.report.status;
    
    // Validasi: Jika status dari DB tidak ada di list opsi, tambahkan sementara
    // agar dropdown tidak error.
    if (!_statusOptions.contains(_currentStatus)) {
      _statusOptions.add(_currentStatus); 
    }
  }

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case "resolved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final request = context.read<CookieRequest>();
    
    // Kirim request ke Django
    // URL sesuaikan: localhost (web) atau 10.0.2.2 (emulator)
    final response = await request.postJson(
      "https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/report/change-status-flutter/${widget.report.id}/",
      jsonEncode({"status": newStatus}),
    );

    if (response['status'] == 'success') {
      setState(() {
        _currentStatus = newStatus; // Update UI Dropdown
        widget.report.status = newStatus; // Update data report lokal
      });
      widget.onRefresh(); // Refresh list di halaman sebelumnya
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status changed to $newStatus")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to change status")),
      );
    }
  }

  // ----------------------------
  // EDIT DIALOG
  // ----------------------------
  void _showEditDialog(BuildContext context) {
    final titleController =
        TextEditingController(text: widget.report.title);
    final descController =
        TextEditingController(text: widget.report.description);

    showDialog(
      context: context,
      builder: (context) {
        final request = context.read<CookieRequest>();

        return AlertDialog(
          title: const Text("Edit Report"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () async {
                final response = await request.post(
                  "https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/report/edit-flutter/${widget.report.id}/",
                  {
                    "title": titleController.text,
                    "description": descController.text,
                  },
                );
                if (response["status"] == "success") {
                  setState(() {
                    widget.report.title = titleController.text;
                    widget.report.description = descController.text;
                    // Opsi: update widget.report.updatedAt jika Django mengirimkan data ini
                  });
                  Navigator.pop(context);
                  widget.onRefresh();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ----------------------------
  // DELETE CONFIRMATION
  // ----------------------------
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final request = context.read<CookieRequest>();

        return AlertDialog(
          title: const Text("Delete Report"),
          content:
              const Text("Are you sure you want to delete this report?"),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
              onPressed: () async {
                final response = await request.post(
                  "https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/report/delete-flutter/${widget.report.id}/",
                  {},
                );

                if (response["status"] == "success") {
                  Navigator.pop(context);
                  widget.onRefresh();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    const Color buttonColor = Color(0xFF00BFA5);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        automaticallyImplyLeading: false,
        leadingWidth: 200,

        leading: Padding(
          padding: const EdgeInsets.only(left: 8, top: 10, bottom: 6),
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),

            icon: Icon(
              Icons.arrow_back,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),

            label: Text(
              'Back to Report List',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 3,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------
            // TITLE
            // ----------------------------
            Text(
              widget.report.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // ------------------------------------------
            // STATUS SECTION (ADMIN DROPDOWN LOGIC)
            // ------------------------------------------
            if (widget.isAdmin) ...[
                // TAMPILAN UNTUK ADMIN: DROPDOWN
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(_currentStatus).withOpacity(0.1),
                    border: Border.all(color: _statusColor(_currentStatus)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      // 1. VALUE LOGIC: Biarkan sesuai aslinya (jangan di-capitalize di sini)
                      // agar cocok dengan data di database/list opsi.
                      value: _currentStatus, 
                      
                      icon: Icon(Icons.arrow_drop_down, color: _statusColor(_currentStatus)),
                      style: TextStyle(
                        color: _statusColor(_currentStatus),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      
                      // 2. ITEMS: Loop opsi status
                      items: _statusOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          
                          // Value Logic: Harus sama persis dengan _currentStatus (huruf kecil/asli)
                          value: value, 
                          
                          // 3. TAMPILAN VISUAL: Di sini baru kita bikin Kapital
                          child: Text(
                            value.capitalize(), // <--- PANGGIL EXTENSION DI SINI
                          ),
                        );
                      }).toList(),
                      
                      onChanged: (String? newValue) {
                        if (newValue != null && newValue != _currentStatus) {
                          _updateStatus(newValue);
                        }
                      },
                    ),
                  ),
                ),
            ] else ...[
                // TAMPILAN UNTUK USER BIASA: READ-ONLY CHIP
                  Chip(
                    label: Text(
                      _currentStatus.capitalize(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _statusColor(_currentStatus),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Ubah angka 20 sesuai keinginan
                      side: BorderSide.none, // (Opsional) Tambahkan ini jika ingin menghilangkan garis pinggir tipis
                    ),
                  ),
            ],

            const SizedBox(height: 16),

            // ----------------------------
            // META INFO
            // ----------------------------
            _infoRow("Report Type", widget.report.reportType),
            _infoRow("Created At", widget.report.createdAt),
            _infoRow("Updated At", widget.report.updatedAt),
            _infoRow("Reporter", widget.report.reporter.username ?? "-"),

            const Divider(height: 32),

            // ----------------------------
            // DESCRIPTION
            // ----------------------------
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.report.description,
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 24),

            // ----------------------------
            // REPORTED USER
            // ----------------------------
            if (widget.report.reportedUser != null) ...[
              const Text(
                "Reported User",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _infoRow(
                "Username",
                widget.report.reportedUser!.username ?? "-",
              ),
              const SizedBox(height: 24),
            ],

            // ----------------------------
            // REPORTED PRODUCT
            // ----------------------------
            if (widget.report.reportedProduct != null) ...[
              const Text(
                "Reported Product",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----------------------------
                  // IMAGE (LEFT)
                  // ----------------------------
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 210, // 👈 ukuran foto
                      height: 270,
                      child: Image.network(
                        "https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/report/proxy-image/?url="
                        "${Uri.encodeComponent(widget.report.reportedProduct!.image)}",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ----------------------------
                  // PRODUCT INFO (RIGHT)
                  // ----------------------------
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.report.reportedProduct!.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Price",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          "Rp ${widget.report.reportedProduct!.price}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],

          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}