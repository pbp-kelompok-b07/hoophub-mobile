import 'package:flutter/material.dart';
import '../models/report_entry.dart';
import '../screens/report_detail_page.dart';

class ReportEntryCard extends StatelessWidget {
  final ReportEntry report;
  final VoidCallback onRefresh;
  final bool isAdmin;

  const ReportEntryCard({
    super.key,
    required this.report,
    required this.onRefresh,
    required this.isAdmin,
  });

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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDetailPage(
              report: report,
              isAdmin: isAdmin,
              onRefresh: onRefresh,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Sedikit dirapikan marginnya
        elevation: 2, // Tambahkan sedikit bayangan agar terlihat timbul
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------------------------------
              // HEADER: JUDUL (KIRI) & STATUS (KANAN)
              // ------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. JUDUL
                  Expanded(
                    child: Text(
                      report.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // 2. STATUS CHIP
                    Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(report.status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          report.status,
                          style: TextStyle(
                            color: _statusColor(report.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                ],
              ),

              const SizedBox(height: 8),

              // ------------------------------------------
              // DESCRIPTION
              // ------------------------------------------
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700], // Warna abu-abu agar kontras dengan judul
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}