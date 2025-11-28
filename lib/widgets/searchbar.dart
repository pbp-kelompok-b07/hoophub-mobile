import 'package:flutter/material.dart';
import 'package:hoophub_mobile/widgets/search_page.dart';

class StickySearchBar extends StatefulWidget {
  final VoidCallback? onWishlistTap;

  const StickySearchBar({
    super.key,
    this.onWishlistTap
    });
  

  
  @override
  State<StickySearchBar> createState() => _StickySearchBarState();
}

class _StickySearchBarState extends State<StickySearchBar> {
  bool _isHovering = false; // State untuk melacak status hover

  // Warna dasar abu-abu muda
  static const Color _defaultColor = Color(0xFFF5F5F5);
  // Warna saat hover, sedikit lebih gelap
  static const Color _hoverColor = Color(0xFFE0E0E0); 

  @override
  Widget build(BuildContext context) {
    // Menghitung tinggi Status Bar secara dinamis (untuk perangkat mobile)
    final double topPadding = MediaQuery.of(context).padding.top;
    
    // Tinggi total toolbar: Tinggi Status Bar (dynamic) + Margin di bawahnya (10) + Tinggi Search Bar (50) + Margin atas (10)
    // Kita akan menggunakan tinggi yang cukup besar agar search bar tidak menempel ke tepi atas
    const double searchBarHeight = 50.0;
    const double verticalMargin = 20.0;
    final double requiredToolbarHeight = topPadding + searchBarHeight + (verticalMargin * 2);

    return SliverAppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      pinned: true, // Membuat Search Bar menempel
      floating: false,
      automaticallyImplyLeading: false, 
      toolbarHeight: requiredToolbarHeight, 
      scrolledUnderElevation: 0.0,
      shadowColor: Colors.transparent,

      // Isi Search Bar
      flexibleSpace: Padding(
        padding: EdgeInsets.only(
          top: topPadding + verticalMargin, // Padding atas (Status Bar + margin)
          bottom: verticalMargin, // Padding bawah
          right: 20,
          left: 20
        ), // Padding di bagian kanan (untuk ikon love)
        child: Row(
          children: [
            // 1. Kotak Input Search (Clickable)
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.text,
                onEnter: (event) {
                  setState(() {
                    _isHovering = true; // Set true saat mouse masuk
                  });
                },
                onExit: (event) {
                  setState(() {
                    _isHovering = false; // Set false saat mouse keluar
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => 
                            const CustomSearchPage(),
                        // Animasi Transisi (Fade/Pudar)
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                                opacity: animation, // Menggunakan animasi untuk opacity
                                child: child,
                            );
                        },
                        transitionDuration: const Duration(milliseconds: 150), 
                        reverseTransitionDuration: const Duration(milliseconds: 150),
                      ),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _isHovering ? _hoverColor : _defaultColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[600], size: 24),
                        SizedBox(width: 12),
                        Text(
                          "Search ",
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              ),
            ),
            
            SizedBox(width: 16),
            
            // 2. Ikon Love (Clickable)
            IconButton(
                // Ukuran ikon IconButton harus diset lebih kecil karena IconButton memiliki padding default
                iconSize: 30, 
                padding: EdgeInsets.zero, // Hapus padding default IconButton
                // Warna splash effect
                splashColor: Colors.white30.withValues(), 
                // Warna highlight saat diklik
                highlightColor: Colors.white30.withValues(),
                onPressed: () {
                    // [LOGIKA CALLBACK/NAVIGASI]
                    if (widget.onWishlistTap != null) {
                        widget.onWishlistTap!();
                    } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => const Center(child: Text("Wishlist Page", style: TextStyle(fontSize: 30))),
                          ),
                      );
                    }
                },
              icon: const Icon(
                Icons.favorite_border, 
                color: Colors.white, 
                size: 30, // Terapkan ukuran pada Icon itu sendiri juga
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const List<String> productList = [
  'Nike Air Jordan 1 Low',
  'Adidas Harden Vol. 7',
  'Puma Clyde All-Pro',
  'Basket Ball Molten B7G4500',
  'Socks Nike Elite Mid',
  'Jersey Kobe Bryant 8',
  'Jersey Michael Jordan 23',
  'Headband Nike Dri-Fit',
];

class ProductSearchDelegate extends SearchDelegate<String> {
  // 1. Teks Bantuan
  @override
  String get searchFieldLabel => 'Search Product';

  // 2. Aksi di sisi kanan App Bar (Icon Hapus)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          // Menghapus teks pencarian saat ikon Clear diklik
          query = ''; 
          showSuggestions(context);
        },
      ),
    ];
  }

  // 3. Aksi di sisi kiri App Bar (Icon Back)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        // Menutup halaman pencarian saat ikon Back diklik
        close(context, '');
      },
    );
  }

  // 4. Menampilkan Hasil Pencarian
  @override
  Widget buildResults(BuildContext context) {
    // Fungsi ini dipanggil saat user menekan Enter/Search
    final results = productList
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return const Center(child: Text("Produk tidak ditemukan."));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.shopping_bag_outlined),
          title: Text(results[index], style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('Lihat detail produk ini.'),
          onTap: () {
            // Logika navigasi ke detail produk
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigasi ke Detail Produk: ${results[index]}')),
            );
            // close(context, results[index]); // Bisa juga menutup halaman search
          },
        );
      },
    );
  }

  // 5. Menampilkan Saran Pencarian
  @override
  Widget buildSuggestions(BuildContext context) {
    // Fungsi ini dipanggil secara real-time saat user mengetik
    final suggestionList = query.isEmpty
        ? productList.take(5).toList() // 5 Saran populer jika belum mengetik
        : productList
            .where((item) => item.toLowerCase().startsWith(query.toLowerCase())) // Saran berdasarkan input
            .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final suggestion = suggestionList[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(suggestion),
          onTap: () {
            // Mengganti teks pencarian dengan saran yang diklik dan menampilkan hasilnya
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }
}