import 'package:flutter/material.dart';

class CustomSearchPage extends StatefulWidget {
  const CustomSearchPage({super.key});

  @override
  State<CustomSearchPage> createState() => _CustomSearchPageState();
}

class _CustomSearchPageState extends State<CustomSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _searchResults = []; // Contoh data hasil pencarian

  // Daftar saran pencarian yang dimuat saat halaman dibuka
  final List<String> _recentSearches = [
    'Nike Air Jordan 1 Low',
    'Adidas Harden Vol. 7',
    'Puma Clyde All-Pro',
    'Basket Ball Molten B7G4500',
    'Socks Nike Elite Mid',
  ];

  @override
  void initState() {
    super.initState();
    // Fokus otomatis pada TextField setelah halaman dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      // Tampilkan saran pencarian awal
      setState(() {
        _searchResults = _recentSearches;
      });
    });
    // Tambahkan listener untuk memproses pencarian secara real-time
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  // Fungsi dummy untuk melakukan pencarian
  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    
    if (query.isEmpty) {
      // Jika input kosong, tampilkan saran terakhir
      setState(() {
        _searchResults = _recentSearches;
      });
      return;
    }

    // Filter daftar saran atau hasil (dalam kasus nyata, ini akan memanggil API)
    setState(() {
      _searchResults = _recentSearches
          .where((item) => item.toLowerCase().contains(query))
          .toList();
    });
  }

  // Widget kustom untuk meniru search bar di header
  Widget _buildCustomSearchBar(BuildContext context) {
    return Container(
      height: 50.0,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        autocorrect: false,
        decoration: InputDecoration(
          hintText: "Search items...",
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 24),
          border: InputBorder.none, // Hapus border bawaan TextField
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0),
        ),
        style: const TextStyle(color: Colors.black, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // Warna app bar sesuai dengan warna header/background di halaman utama
        backgroundColor: Colors.white, 
        elevation: 0,
        automaticallyImplyLeading: false, // Hapus tombol back bawaan
        
        title: Row(
          children: [
            // Tambahkan tombol kembali (panah kiri)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            
            const SizedBox(width: 8),

            // Masukkan Search Bar kustom di sini
            Expanded(
              child: _buildCustomSearchBar(context),
            ),
            
            const SizedBox(width: 16),

          ],
        ),
        toolbarHeight: 70, // Tinggi toolbar yang disesuaikan
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final item = _searchResults[index];
          return ListTile(
            leading: Icon(Icons.history, color: Colors.grey[400]),
            title: Text(item, style: const TextStyle(fontSize: 16)),
            onTap: () {
              // Ketika hasil diklik, pindahkan query ke search bar
              _searchController.text = item;
              _searchController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _searchController.text.length));
              _focusNode.unfocus(); // Opsional: tutup keyboard
              // Di sini Anda bisa memicu pencarian akhir
            },
          );
        },
      ),
    );
  }
}