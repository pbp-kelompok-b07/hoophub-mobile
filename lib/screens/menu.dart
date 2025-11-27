import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:hoophub_mobile/screens/login.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final request = context.read<CookieRequest>();

    await request.logout(
      'http://localhost:8000/authentication/logout-flutter/',
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Berhasil logout')),
    );

    // Kembali ke halaman login, reset stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cookie = context.watch<CookieRequest>();
    final username = cookie.jsonData['username'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('HoopHub Menu'),
        actions: [
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (username != null)
              Text(
                'Hi, $username 👋',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Explore our features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 4 / 3,
                children: const [
                  _MenuCard(
                    title: 'Catalog',
                    description: 'Lihat daftar produk basket.',
                  ),
                  _MenuCard(
                    title: 'Cart',
                    description: 'Kelola keranjang belanja kamu.',
                  ),
                  _MenuCard(
                    title: 'Wishlist',
                    description: 'Simpan produk favoritmu.',
                  ),
                  _MenuCard(
                    title: 'Invoice',
                    description: 'Lihat riwayat pembayaran.',
                  ),
                  _MenuCard(
                    title: 'Report',
                    description: 'Laporkan masalah pesanan.',
                  ),
                  _MenuCard(
                    title: 'Review',
                    description: 'Beri ulasan produk.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String description;

  const _MenuCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigasi ke modul $title belum diatur.')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FilledButton.tonal(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Fitur $title di app masih placeholder (modul temanmu).',
                        ),
                      ),
                    );
                  },
                  child: const Text('Explore'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
