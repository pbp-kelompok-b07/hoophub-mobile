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
import 'package:hoophub_mobile/catalog/models/product.dart';
import 'package:hoophub_mobile/catalog/screens/product_detail.dart';

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
      const Center(child: Text("Invoice Page", style: TextStyle(fontSize: 30))),
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
            
            // --- PERBAIKAN DI SINI ---
            if (index >= 3) {
              // Jika index 3 (Cart) ke atas, anggap itu bagian dari menu Profile (index 3 di Navbar)
              _lastNavIndex = 3; 
            } else {
              // Jika Home (0), Catalog (1), atau Wishlist (2), ikuti index aslinya
              _lastNavIndex = index;
            }
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
      
      // BODY: ini yang akan berganti-ganti. 
      // Saat _selectedIndex = 0, dia nampilin _DashboardContent (Gambar + Cards)
      body: _pages[_selectedIndex], 

      // NAVBAR: ini akan selalu muncul di bawah
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

    Future<List<Product>> fetchAllProducts() async {
      final request = context.read<CookieRequest>();

      final response = await request.get(
        'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/catalog/json/',
      );

      final List<Product> products = [];
      for (final item in response) {
        products.add(Product.fromJson(item as Map<String, dynamic>));
      }
      return products;
    }

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
                      fontSize: 26,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 17),
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
                // Ubah alignment jika perlu (misal: bottomLeft, center)
                alignment: Alignment.centerLeft, 
                children: [
                  // 1. Gambar Latar Belakang (Paling Bawah)
                  Image.asset(
                    "images/main-page.jpg",
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,
                  ),

                  // 2. (Opsional) Lapisan Gelap agar teks lebih terbaca
                  Container(
                    height: 350,
                    width: double.infinity,
                    color: Colors.black.withOpacity(0.1), // Gelapkan gambar 30%
                  ),

                  // 3. Teks Menumpuk di Atas Gambar
                  const Padding(
                    padding: EdgeInsets.all(24.0), // Jarak dari pinggir gambar
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "WELCOME TO\nHOOPHUB",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white, // Gunakan warna putih agar kontras
                            height: 1.2,
                            shadows: [ // Tambahkan bayangan agar lebih jelas
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 4.0,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Up to 50% Off on selected items.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        FutureBuilder(
          future: fetchAllProducts(), // Fungsi fetch semua produk
          builder: (context, AsyncSnapshot<List<Product>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
            }
            
            final allData = snapshot.data ?? [];

            List<Product> filterAndLimit(List<Product> list, String category) {
              return list.where((p) => 
                p.category.toLowerCase().contains(category.toLowerCase()) && 
                p.imageUrl.isNotEmpty && 
                p.imageUrl != "null" // Tambahan jika Django mengirim string "null"
              ).take(7).toList();
            }

            // LOGIKA FILTERING SEDERHANA
            final basketball = filterAndLimit(allData, 'basketball');
            final shoes = filterAndLimit(allData, 'shoes');
            final tops = filterAndLimit(allData, 'tops');
            final legwear = filterAndLimit(allData, 'legwear');

            return SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 10),
                // SEKSI BASKETBALL
                ProductSection(title: "BASKETBALLS", products: basketball),
                const SizedBox(height: 50),
                
                // SEKSI SEPATU
                ProductSection(title: "SHOES", products: shoes),
                const SizedBox(height: 50),

                // SEKSI BAJU / JERSEY
                ProductSection(title: "TOPS", products: tops),
                const SizedBox(height: 50),

                // SEKSI CELANA / LEGWEAR
                ProductSection(title: "LEGWEAR", products: legwear),
                const SizedBox(height: 30),
              ]),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class ProductSection extends StatefulWidget {
  final String title;
  final List<Product> products;

  const ProductSection({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  State<ProductSection> createState() => _ProductSectionState();
}

class _ProductSectionState extends State<ProductSection> {
  late PageController _pageController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Tentukan start index
    int startPage = widget.products.length > 1 ? 1 : 0;
    
    _pageController = PageController(
      initialPage: startPage, 
      viewportFraction: 0.4, 
    );

    _currentPage = startPage.toDouble(); 

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? startPage.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            widget.title.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,),
          ),
        ),
        SizedBox(
          height: 320, 
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.products.length,
            padEnds: true, 
            physics: const BouncingScrollPhysics(), 
            itemBuilder: (context, index) {
              double relativePosition = index - _currentPage;
              double distanceFromCenter = relativePosition.abs();
              double scale = (1 - (distanceFromCenter * 0.25)).clamp(0.8, 1.0);
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: 1.0,
                  child: _ProductCard(
                    product: widget.products[index], 
                    imageUrl: widget.products[index].imageUrl,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


class _ProductCard extends StatelessWidget {
  final Product product;
  final String imageUrl;

  const _ProductCard({
    required this.product,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Kita bungkus dengan Center/Align agar saat di-scale down,
    // dia tetap berada di tengah vertikal.
    return Align(
      alignment: Alignment.center,
      child: Container(
        // Hapus margin horizontal di sini, biarkan PageView yang mengaturnya via gap
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: InkWell(
          onTap: () {
             // Navigasi ke detail
             Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Penting: agar column tidak stretch
            children: [
              Container(
                height: 200, 
                width: double.infinity, // Lebar mengikuti parent (PageView item)
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover, // Gambar akan dicrop rapi mengisi kotak 180px
                          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        )
                      : const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
              // -------------------------------

              const SizedBox(height: 20),
              // Nama Produk
              Text(
                product.name.trim().replaceAll(RegExp(r'\s+'), ' '),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Harga
              Text(
                "Rp ${product.price}",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w100,
                  fontSize: 12
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}