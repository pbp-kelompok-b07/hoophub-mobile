import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:hoophub_mobile/wishlist/models/wish_entry.dart';
import 'package:hoophub_mobile/wishlist/widgets/wish_entry_card.dart';

class WishEntryListPage extends StatefulWidget {
  final List<WishEntry>? initialEntries;

  const WishEntryListPage({
    super.key,
    this.initialEntries,
  });

  @override
  State<WishEntryListPage> createState() => _WishEntryListPageState();
}

class _WishEntryListPageState extends State<WishEntryListPage> {
  // Data
  List<WishEntry> _allEntries = [];
  List<WishEntry> _visibleEntries = [];
  List<String> _brands = [];

  // State UI
  bool _isLoading = true;
  String _selectedBrand = '';
  String _selectedSort = 'date_desc';
  
  final DateFormat _dateFmt = DateFormat('MMM d, yyyy HH:mm');
  int? _processingAddProductId;
  int? _processingRemoveId;

  // URL SERVER (PBP Live)
  final String baseUrl = "https://roselia-evanny-hoophub.pbp.cs.ui.ac.id"; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWishlist();
    });
  }

  Widget _boxedDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    double minWidth = 140,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      constraints: BoxConstraints(minWidth: minWidth),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          DropdownButton<T>(
            value: value,
            underline: const SizedBox(), // hilangkan garis bawah default
            icon: const Icon(Icons.keyboard_arrow_down),
            items: items,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // 1. FETCH DATA DARI SERVER
  Future<void> _fetchWishlist() async {
    final request = context.read<CookieRequest>();
    
    if (!request.loggedIn) {
      setState(() {
        _isLoading = false;
        _allEntries = [];
        _visibleEntries = [];
      });
      return;
    }

    try {
      final response = await request.get('$baseUrl/wishlist/api/json/');
      
      List<WishEntry> fetchedEntries = [];
      Set<String> uniqueBrands = {};

      for (var d in response) {
        if (d != null) {
          WishEntry entry = WishEntry.fromJson(d);

          // Hanya masukkan jika produk berhasil di-parse (tidak null)
          if (entry.product != null) {
            fetchedEntries.add(entry);
            
            if (entry.product!.brand.isNotEmpty) {
              uniqueBrands.add(entry.product!.brand);
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _allEntries = fetchedEntries;
          _brands = uniqueBrands.toList()..sort();
          _isLoading = false;
          _applyFiltersAndSort(); 
        });
      }
    } catch (e) {
      print("Error fetching wishlist: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load wishlist.')),
        );
      }
    }
  }

  // 2. LOGIKA FILTER & SORT
  void _applyFiltersAndSort() {
    final brand = _selectedBrand;
    List<WishEntry> list = List.from(_allEntries);

    // Filter Brand
    if (brand.isNotEmpty) {
      list = list.where((e) {
        return e.product?.brand.toLowerCase() == brand.toLowerCase();
      }).toList();
    }

    // Sort
    switch (_selectedSort) {
      case 'date_asc':
        list.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
        break;
      case 'date_desc':
        list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case 'price_asc':
        list.sort((a, b) => (a.product?.price ?? 0).compareTo(b.product?.price ?? 0));
        break;
      case 'price_desc':
        list.sort((a, b) => (b.product?.price ?? 0).compareTo(a.product?.price ?? 0));
        break;
    }

    setState(() {
      _visibleEntries = list;
    });
  }

  // 3. LOGIKA REMOVE
  Future<void> _handleRemove(WishEntry entry) async {
    final request = context.read<CookieRequest>();
    setState(() => _processingRemoveId = entry.id);

    try {
      final response = await request.postJson(
        '$baseUrl/wishlist/flutter/remove/',
        jsonEncode({'wishlist_id': entry.id}),
      );

      if (response['deleted'] == true) {
        setState(() {
          _allEntries.removeWhere((e) => e.id == entry.id);
          _applyFiltersAndSort();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from wishlist')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Failed to remove')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error')),
      );
    } finally {
      if (mounted) setState(() => _processingRemoveId = null);
    }
  }

  // 4. LOGIKA ADD TO CART (Disamakan dengan Catalog Page)
  Future<void> _handleAddToCart(WishEntry entry) async {
    if (entry.product == null) return;
    
    final request = context.read<CookieRequest>();
    // Set loading indicator khusus untuk item ini
    setState(() => _processingAddProductId = entry.product!.id);

    try {
      // Menggunakan pola URL yang sama dengan Catalog Page
      // Endpoint: /cart/add-flutter/<product_id>/
      final response = await request.post(
        '$baseUrl/cart/add-flutter/${entry.product!.id}/', 
        {}, // Body kosong karena ID ada di URL
      );

      if (mounted) {
        if (response['status'] == 'success') {
          // SUKSES: Tampilkan SnackBar Hijau & Tetap di halaman
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Berhasil ditambahkan ke keranjang"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // GAGAL (Logic dari server): Tampilkan SnackBar Merah
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Gagal menambahkan"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // ERROR JARINGAN / LAINNYA
      print("Error add to cart: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e")),
        );
      }
    } finally {
      // Matikan loading indicator
      if (mounted) setState(() => _processingAddProductId = null);
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedBrand = '';
      _selectedSort = 'date_desc';
      _applyFiltersAndSort();
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('hoophub - Wishlist', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF005F73),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildContent(context, request),
    );
  }

  Widget _buildContent(BuildContext context, CookieRequest request) {
    // 1. Cek Login
    if (!request.loggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('You must be logged in.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('To see your wishlist, please log in.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    // 2. Cek Loading
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Header Text
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
          child: const Row(
            children: [
              Expanded(
                child: Text('Your wishlist is here!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),

        // Filter & Sort Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. FILTER BRAND
                _boxedDropdown<String>(
                  label: 'Brand',
                  value: _selectedBrand.isEmpty ? null : _selectedBrand,
                  items: [const DropdownMenuItem(value: '', child: Text('All'))]
                      .followedBy(_brands.map((b) => DropdownMenuItem(value: b, child: Text(b))))
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedBrand = v ?? '';
                      _applyFiltersAndSort();
                    });
                  },
                  // Atur lebar minimal agar tidak terlalu lebar
                  minWidth: 120, 
                ),

                const SizedBox(width: 12),

                // 2. SORT
                _boxedDropdown<String>(
                  label: 'Sort',
                  value: _selectedSort,
                  items: const [
                    DropdownMenuItem(value: 'date_desc', child: Text('Newest')),
                    DropdownMenuItem(value: 'date_asc', child: Text('Oldest')),
                    DropdownMenuItem(value: 'price_desc', child: Text('Price High')),
                    DropdownMenuItem(value: 'price_asc', child: Text('Price Low')),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _selectedSort = v ?? 'date_desc';
                      _applyFiltersAndSort();
                    });
                  },
                  minWidth: 130,
                ),

                const SizedBox(width: 12),

                // 3. RESET BUTTON (ICON ONLY - LEBIH HEMAT TEMPAT)
                InkWell(
                  onTap: _resetFilters,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      shape: BoxShape.circle, // Bentuk bulat
                    ),
                    child: const Icon(
                      Icons.refresh, // Ikon Reset/Refresh
                      color: Color(0xFF005F73),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Grid/List Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6),
            child: _visibleEntries.isEmpty
              ? const Center(child: Text('Your wishlist is empty.'))
              : LayoutBuilder(builder: (context, constraints) {
                  // Cek lebar layar. Jika > 800 (Desktop/Tablet), pakai Grid 2 kolom.
                  // Jika Mobile, pakai List 1 kolom (agar tinggi kartu fit konten).
                  bool isMobile = constraints.maxWidth <= 800;

                  if (isMobile) {
                    // TAMPILAN MOBILE: Pakai ListView agar tidak ada gap
                    return ListView.builder(
                      itemCount: _visibleEntries.length,
                      itemBuilder: (context, idx) {
                        final entry = _visibleEntries[idx];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0), // Jarak antar kartu
                          child: WishEntryCard(
                            entry: entry,
                            dateFmt: _dateFmt,
                            isAuthenticated: true,
                            processingAddProductId: _processingAddProductId, 
                            processingRemoveId: _processingRemoveId,
                            onAddToCart: _handleAddToCart, 
                            onRemoveFromWishlist: _handleRemove,
                          ),
                        );
                      },
                    );
                  } else {
                    // TAMPILAN DESKTOP: Tetap pakai GridView agar rapih 2 kolom
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.2, // Rasio untuk desktop bisa diatur
                      ),
                      itemCount: _visibleEntries.length,
                      itemBuilder: (context, idx) {
                        final entry = _visibleEntries[idx];
                        return WishEntryCard(
                          entry: entry,
                          dateFmt: _dateFmt,
                          isAuthenticated: true,
                          processingAddProductId: _processingAddProductId, 
                          processingRemoveId: _processingRemoveId,
                          onAddToCart: _handleAddToCart, 
                          onRemoveFromWishlist: _handleRemove,
                        );
                      },
                    );
                  }
                }),
          ),
        ),
      ],
    );
  }
}