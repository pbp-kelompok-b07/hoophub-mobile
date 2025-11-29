import 'package:flutter/material.dart';
import 'package:hoophub_mobile/review/screens/review_entry_list.dart';
import 'package:http/http.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:hoophub_mobile/widgets/searchbar.dart';
import 'package:hoophub_mobile/widgets/navbar.dart';
import 'package:hoophub_mobile/constants.dart';
import 'package:hoophub_mobile/screens/login.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>{
  int _selectedIndex = 0;
  int _lastNavIndex = 0; // terakhir dipilih di BottomNavigationBar (0..navBarItemCount-1)

  late final List<Widget> _pages;
  static const int navBarItemCount = 4; // jumlah item di BottomNavigationBar

  static const List<Map<String, dynamic>> _profileMenuItems = [
    {'title': 'My Wishlist', 'icon': Icons.favorite_border, 'route': 'wishlist', 'index': 2}, // Navigasi ke tab Wishlist
    {'title': 'My Cart', 'icon': Icons.shopping_cart_outlined, 'route': 'cart', 'index': 3}, // Navigasi ke tab Shop/Cart
    {'title': 'My Invoice', 'icon': Icons.receipt_long, 'route': 'invoice', 'index': 4}, // Halaman terpisah (index -1)
    {'title': 'My Review', 'icon': Icons.rate_review_outlined, 'route': 'review', 'index': 5}, // Halaman terpisah (index -1)
    {'title': 'My Report', 'icon': Icons.error_outline, 'route': 'report', 'index': 6},
    {'title': 'Log Out', 'icon': Icons.logout_outlined, 'route': 'logout', 'index': -1}, // Logout action
  ];

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar halaman. Halaman MenuPage sekarang adalah Index 0.
    _pages = [
      _DashboardContent(
        handleLogout: _handleLogout,
        goToWishlistTab: _goToWishlistTab, // [TAMBAHAN]: Meneruskan fungsi navigasi
      ),  // Index 0: Konten Dashboard/Menu
      const Center(child: Text("Shop Page", style: TextStyle(fontSize: 30))),
      const Center(child: Text("Wishlist Page", style: TextStyle(fontSize: 30))),
      const Center(child: Text("Cart Page", style: TextStyle(fontSize: 30))),
      const Center(child: Text("Invoice Page", style: TextStyle(fontSize: 30))),
      const ReviewEntryListPage(),
      const Center(child: Text("Report Page", style: TextStyle(fontSize: 30))),
    ];
  }

  Future<void> _handleLogout(BuildContext context) async {
    final request = context.read<CookieRequest>();

    await request.logout(
      'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/authentication/logout-flutter/',
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have logged out!')),
    );

    // Kembali ke halaman login, reset stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<Map<String, dynamic>?> _showAnimatedProfileMenu() {
    return showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ..._profileMenuItems.map((item) {
                    return ListTile(
                      leading: Icon(item['icon'], color: Theme.of(context).colorScheme.primary),
                      title: Text(item['title']),
                      onTap: () {
                        Navigator.pop(context, item); // return item
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }

  void _onRegularItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Jika index adalah salah satu item di navbar, simpan sebagai lastNavIndex
      if (index < navBarItemCount && index >= 0) {
        _lastNavIndex = index;
      }
    });
  }

  void _goToWishlistTab() {
    _onRegularItemTapped(2); // Pindah ke indeks Wishlist
  }

void _showProfileMenu() async {
    // 1. Dapatkan RenderBox dari Scaffold untuk menghitung posisi global
    final RenderBox? navBarRenderBox = context.findRenderObject() as RenderBox?;
    if (navBarRenderBox == null) {
      _onRegularItemTapped(0);
      return;
    }
    
    // Tampilkan menu
    final selectedItem = await _showAnimatedProfileMenu();

    // Handler setelah item dipilih atau pop-up ditutup
    if (selectedItem != null) {
      _handleMenuSelection(selectedItem, context);
    } else {
      // Jika pop-up ditutup tanpa memilih (tapped outside), 
      _onRegularItemTapped(0); 
    }
  }

  // Handler menu item yang dipilih dari Pop-up
  void _handleMenuSelection(Map<String, dynamic> item, BuildContext context) {
    final String route = item['route'];
    final int? index = item['index'] as int?;

    if (route == 'logout') {
      _handleLogout(context);
    } else if (index != null && index >= 0) {
      // Izinkan _selectedIndex bernilai >= navBarItemCount.
      // Jangan ubah BottomNavigationBar.currentIndex langsung jika
      // index berada di luar jangkauan navbar — kita simpan highlight
      // terakhir di _lastNavIndex dan cukup ubah state.
      if (index < _pages.length) {
        setState(() {
          _selectedIndex = index;
          if (index < navBarItemCount) _lastNavIndex = index;
        });
      } else {
        // Jika index di luar jangkauan _pages, fallback ke Home
        _onRegularItemTapped(0);
      }
    } else {
      // Item kustom (Invoice, Review)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigasi ke halaman ${item['title']} belum diimplementasikan.')),
      );
      // Pindahkan ke tab Profile setelah aksi
      _onRegularItemTapped(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
      body: _pages[_selectedIndex], // Tampilkan halaman sesuai index
      
      // ====================== BOTTOM NAVIGATION BAR ======================
      bottomNavigationBar: CustomBottomNavBar(
        // Pastikan nilai yang dikirim ke BottomNavigationBar valid (0..navBarItemCount-1)
        selectedIndex: (_selectedIndex >= 0 && _selectedIndex < navBarItemCount) ? _selectedIndex : _lastNavIndex,
        onRegularItemTapped: _onRegularItemTapped,
        onProfileTapped: _showProfileMenu,
      ),
    );
  }
}
class _DashboardContent extends StatelessWidget {
  final Future<void> Function(BuildContext) handleLogout;
  final VoidCallback goToWishlistTab;

  const _DashboardContent({
    required this.handleLogout,
    required this.goToWishlistTab, // [TAMBAHAN]: Wajib diisi
  });

  static const List<Map<String, dynamic>> menuItems = [
    {'title': 'Catalog', 'description': 'Lihat daftar produk basket.', 'icon': Icons.list_alt},
    {'title': 'Cart', 'description': 'Kelola keranjang belanja kamu.', 'icon': Icons.shopping_cart_outlined},
    {'title': 'Wishlist', 'description': 'Simpan produk favoritmu.', 'icon': Icons.favorite_border},
    {'title': 'Invoice', 'description': 'Lihat riwayat pembayaran.', 'icon': Icons.receipt_long},
    {'title': 'Report', 'description': 'Laporkan masalah pesanan.', 'icon': Icons.error_outline},
    {'title': 'Review', 'description': 'Beri ulasan produk.', 'icon': Icons.rate_review_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    final username = context.watch<CookieRequest>().jsonData['username'];
    final double topPadding = MediaQuery.of(context).padding.top;
    final Color headerColor = Theme.of(context).colorScheme.primary; 

    return CustomScrollView(
        slivers: [
          // ================= 1. HEADER (Selamat Datang) =================
          SliverToBoxAdapter(
            child: Container(
              color: headerColor,
              padding: EdgeInsets.only(top: topPadding + 10),
              child:Padding(
                padding: const EdgeInsets.only(top: 30, left: 25, right: 20, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username != null 
                          ? 'Hi, $username'  
                          : 'hoophub', 
                      style: const TextStyle(
                        fontSize: 32, 
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================= 2. STICKY SEARCH BAR =================
          StickySearchBar(
            onWishlistTap: goToWishlistTab,
          ),

        // =================== 3. HERO SECTION  =====================
          SliverToBoxAdapter( 
            child: Column(
              children: [
                Stack( // Stack sekarang aman karena berada di dalam SliverToBoxAdapter
                  alignment: Alignment.centerLeft,
                  children: [
                    Image.asset(
                      "images/main-page.jpg",
                      width: double.infinity,
                      height: 350,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                const SizedBox(height: 40), // SizedBox juga harus di dalam SliverToBoxAdapter
              ],
            ),
          ),

          // ================= 4. KONTEN GRID (Menu Cards) =================
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid( // <--- GANTI GRIDVIEW DENGAN SLIVERGRID
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 4 / 3,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final item = menuItems[index];
                  return _MenuCard(
                    title: item['title'],
                    description: item['description'],
                  );
                },
                childCount: menuItems.length,
              ),
            ),
          ),
          
          // Tambahkan padding di bagian bawah agar tidak tertutup nav bar jika ada
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
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
