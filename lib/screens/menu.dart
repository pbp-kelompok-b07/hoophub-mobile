import 'package:flutter/material.dart';
import 'package:hoophub_mobile/cart/screens/cart_page.dart';
import 'package:hoophub_mobile/review/screens/review_entry_list.dart';
import 'package:hoophub_mobile/report/screens/report_entry_list.dart';
import 'package:http/http.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:hoophub_mobile/widgets/searchbar.dart';
import 'package:hoophub_mobile/widgets/navbar.dart';
import 'package:hoophub_mobile/screens/login.dart';
import 'package:hoophub_mobile/catalog/screens/catalog_page.dart';
import 'package:hoophub_mobile/invoice/screens/invoice_list_page.dart'; // Sesuaikan path foldermu

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;
  int _lastNavIndex = 0;

  late final List<Widget> _pages;
  static const int navBarItemCount = 4;

  static const List<Map<String, dynamic>> _profileMenuItems = [
    {'title': 'My Wishlist', 'icon': Icons.favorite_border, 'route': 'wishlist', 'index': 2},
    {'title': 'My Cart', 'icon': Icons.shopping_cart_outlined, 'route': 'cart', 'index': 3},
    {'title': 'My Invoice', 'icon': Icons.receipt_long, 'route': 'invoice', 'index': 4},
    {'title': 'My Review', 'icon': Icons.rate_review_outlined, 'route': 'review', 'index': 5},
    {'title': 'My Report', 'icon': Icons.error_outline, 'route': 'report', 'index': 6},
    {'title': 'Log Out', 'icon': Icons.logout_outlined, 'route': 'logout', 'index': -1},
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      _DashboardContent(
        handleLogout: _handleLogout,
        goToWishlistTab: _goToWishlistTab,
      ),
      const CatalogPage(),
      const Center(child: Text("Wishlist Page", style: TextStyle(fontSize: 30))),
      const CartPage(),
      const InvoiceListPage(),
      const ReviewEntryListPage(),
      const ReportEntryListPage(),
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
                      leading: Icon(
                        item['icon'],
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(item['title']),
                      onTap: () {
                        Navigator.pop(context, item);
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
          ).animate(
            CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        );
      },
    );
  }

  void _onRegularItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index < navBarItemCount && index >= 0) {
        _lastNavIndex = index;
      }
    });
  }

  void _goToWishlistTab() {
    _onRegularItemTapped(2);
  }

  void _showProfileMenu() async {
    final RenderBox? navBarRenderBox =
        context.findRenderObject() as RenderBox?;
    if (navBarRenderBox == null) {
      _onRegularItemTapped(0);
      return;
    }

    final selectedItem = await _showAnimatedProfileMenu();

    if (selectedItem != null) {
      _handleMenuSelection(selectedItem, context);
    } else {
      _onRegularItemTapped(0);
    }
  }

  void _handleMenuSelection(Map<String, dynamic> item, BuildContext context) {
    final String route = item['route'];
    final int? index = item['index'] as int?;

    if (route == 'logout') {
      _handleLogout(context);
    } else if (index != null && index >= 0) {
      if (index < _pages.length) {
        setState(() {
          _selectedIndex = index;
          if (index < navBarItemCount) _lastNavIndex = index;
        });
      } else {
        _onRegularItemTapped(0);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Navigasi ke halaman ${item['title']} belum diimplementasikan.'),
        ),
      );
      _onRegularItemTapped(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _pages[_selectedIndex],
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: (_selectedIndex >= 0 && _selectedIndex < navBarItemCount)
            ? _selectedIndex
            : _lastNavIndex,
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
    required this.goToWishlistTab,
  });

  static const List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Catalog',
      'description': 'Lihat daftar produk basket.',
      'icon': Icons.list_alt,
      'adminOnly': false,
    },
    {
      'title': 'Cart',
      'description': 'Kelola keranjang belanja kamu.',
      'icon': Icons.shopping_cart_outlined,
      'adminOnly': false,
    },
    {
      'title': 'Wishlist',
      'description': 'Simpan produk favoritmu.',
      'icon': Icons.favorite_border,
      'adminOnly': false,
    },
    {
      'title': 'Invoice',
      'description': 'Lihat riwayat pembayaran.',
      'icon': Icons.receipt_long,
      'adminOnly': false,
    },
    {
      'title': 'Report',
      'description': 'Laporkan masalah pesanan.',
      'icon': Icons.error_outline,
      'adminOnly': false,
    },
    {
      'title': 'Review',
      'description': 'Beri ulasan produk.',
      'icon': Icons.rate_review_outlined,
      'adminOnly': false,
    },
    {
      'title': 'Manage Products',
      'description': 'Kelola produk hoophub (Admin).',
      'icon': Icons.settings,
      'adminOnly': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cookieRequest = context.watch<CookieRequest>();
    final bool isLoggedIn = cookieRequest.loggedIn;
    final String? username = cookieRequest.jsonData['username'];
    final bool isAdmin = cookieRequest.jsonData['is_admin'] ?? false;

    final visibleMenu = menuItems.where((item) {
      final bool adminOnly = item['adminOnly'] == true;
      if (adminOnly && !isAdmin) {
        return false;
      }
      return true;
    }).toList();

    final double topPadding = MediaQuery.of(context).padding.top;
    final Color headerColor = Theme.of(context).colorScheme.primary;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: headerColor,
            padding: EdgeInsets.only(top: topPadding + 10),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 30, left: 25, right: 20, bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLoggedIn && username != null
                        ? (isAdmin ? 'Hi Admin, $username' : 'Hi, $username')
                        : 'Welcome, Guest',
                    style: const TextStyle(
                      fontSize: 32,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  isAdmin
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Admin Mode',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
        StickySearchBar(
          onWishlistTap: goToWishlistTab,
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              Stack(
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
              const SizedBox(height: 40),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 4 / 3,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final item = visibleMenu[index];
                return _MenuCard(
                  title: item['title'],
                  description: item['description'],
                );
              },
              childCount: visibleMenu.length,
            ),
          ),
        ),
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

  void _handleTap(BuildContext context) {
    if (title == 'Catalog') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CatalogPage()),
      );
    } else if (title == 'Manage Products') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin feature: Manage Products are not implement yet.'),
        ),
      );
    } else if (title == 'Cart') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigasi to modul $title not getting arranged.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleTap(context),
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
                  onPressed: () => _handleTap(context),
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
