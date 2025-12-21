import 'package:flutter/material.dart';
import 'package:hoophub_mobile/report/screens/report_create_page.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:hoophub_mobile/report/models/report_entry.dart';
import 'package:hoophub_mobile/report/widgets/report_entry_card.dart';

class ReportEntryListPage extends StatefulWidget {
  const ReportEntryListPage({super.key});

  @override
  State<ReportEntryListPage> createState() => _ReportEntryListPageState();
}

class _ReportEntryListPageState extends State<ReportEntryListPage> {
  String? _selectedStatusFilter;

  final List<String?> _statusOptions = [
    null,        // All
    "pending",
    "resolved",
    "rejected",
  ];

  // ----------------------------
  // FETCH REPORTS (UPDATED)
  // ----------------------------
  Future<Map<String, dynamic>> fetchReports(CookieRequest request) async {
    try {
      // Ganti URL sesuai environment (localhost untuk Web, 10.0.2.2 untuk Android Emulator)
      final response = await request.get(
        'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/report/my-json-flutter/',
      );

      // 1. Ambil status admin dari JSON (default false jika null)
      bool isAdmin = response['is_admin'] ?? false;

      // 2. Ambil list reports dari key 'reports'
      List<ReportEntry> listReports = [];
      var reportsJson = response['reports'];

      // 3. Loop data reports
      if (reportsJson != null) {
        for (var item in reportsJson) {
          if (item != null) {
            listReports.add(ReportEntry.fromJson(item));
          }
        }
      }

      // 4. Return Paket Lengkap (Admin Status + List Data)
      return {
        "status": true,
        "isAdmin": isAdmin,
        "reports": listReports,
      };

    } catch (e) {
      print("fetch report error: $e");
      // Return data kosong jika error agar aplikasi tidak crash
      return {
        "status": false,
        "isAdmin": false,
        "reports": <ReportEntry>[],
      };
    }
  }
  void refreshPage() {
    setState(() {});
  }

  // ----------------------------
  // FILTER BASED ON STATUS
  // ----------------------------
  List<ReportEntry> _applyStatusFilter(List<ReportEntry> reports) {
    if (_selectedStatusFilter == null) {
      return reports; // show all
    }

    return reports
        .where((report) =>
            report.status.toLowerCase() ==
            _selectedStatusFilter!.toLowerCase())
        .toList();
  }

  // ----------------------------
  // BUILD PAGE
  // ----------------------------
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: fetchReports(request),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          
          if (!snapshot.hasData || snapshot.data!['reports'].isEmpty) {
            return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No report yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 16),
                  ],
                ),
              );
          } 

          final bool isAdmin = snapshot.data!['isAdmin'];
          final List<ReportEntry> reports = snapshot.data!['reports'];
          final List<ReportEntry> filtered = _applyStatusFilter(reports);

          return Column(
            children: [
              // ----------------------------
              // FILTER ROW (status)
              // ----------------------------
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _statusOptions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final status = _statusOptions[index];
                    final bool isSelected = status == _selectedStatusFilter;

                    final displayName = status == null
                        ? "All"
                        : status[0].toUpperCase() + status.substring(1);

                    // Fungsi utilitas untuk menentukan warna berdasarkan status (Hanya dipakai saat isSelected = false)
                    Color getStatusColor(String? status) {
                      switch (status) {
                        case "resolved":
                          return Colors.green;
                        case "rejected":
                          return Colors.red;
                        case "pending":
                        case null: // Termasuk "All"
                        default:
                          return Colors.orange;
                      }
                    }

                    // Warna dasar untuk border/teks saat TIDAK dipilih
                    final Color baseColor = getStatusColor(status);
                    
                    // Warna Kuning/Orange Solid untuk filter yang SEDANG DIPILIH
                    const Color selectedOrange = Colors.orange;

                    return FilterChip(
                      label: Text(displayName),
                      selected: isSelected,
                      
                      // 1. SELECTED COLOR: Selalu ORANGE jika dipilih
                      selectedColor: selectedOrange,
                      
                      // 2. BACKGROUND COLOR: Abu-abu jika tidak dipilih
                      backgroundColor: isSelected ? selectedOrange.withOpacity(0.1) : Colors.grey[200],
                      
                      showCheckmark: false,
                      elevation: 0,
                      
                      // 3. SHAPE: Bentuk pil/bulet
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: Colors.transparent,
                          width: 0,
                        )
                      ),
                      
                      // 4. LABEL STYLE
                      labelStyle: TextStyle(
                        // Warna label: Putih jika dipilih, Abu-abu gelap jika tidak
                        color: isSelected ? Colors.white : Colors.grey[700], 
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedStatusFilter = selected ? status : null; 
                        });
                      },
                    );
                  },
                ),
              ),

              const Divider(height: 1, thickness: 1),

              // ----------------------------
              // LIST OF REPORT CARDS
              // ----------------------------
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text("No reports found."))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, index) => ReportEntryCard(
                          report: filtered[index],
                          onRefresh: refreshPage,
                          isAdmin: isAdmin,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
