import 'package:flutter/material.dart';
import 'package:hoophub_mobile/catalog/models/product.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:hoophub_mobile/catalog/screens/product_detail.dart';

class CustomSearchPage extends StatefulWidget {
  const CustomSearchPage({super.key});

  @override
  State<CustomSearchPage> createState() => _CustomSearchPageState();
}

class _CustomSearchPageState extends State<CustomSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = true;

  // Daftar saran pencarian yang dimuat saat halaman dibuka
  List<Product> _allProducts = []; // Semua produk dari Django
  List<Product> _searchResults = []; // Produk yang sudah difilter

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk ambil data dari Django saat halaman dibuka
    _fetchProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _searchController.addListener(_performSearch);
  }

  Future<void> _fetchProducts() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'https://roselia-evanny-hoophub.pbp.cs.ui.ac.id/catalog/json/',
      );
      
      List<Product> listProduct = [];
      for (var d in response) {
        if (d != null) {
          listProduct.add(Product.fromJson(d as Map<String, dynamic>));
        }
      }

      setState(() {
        _allProducts = listProduct;
        _searchResults = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error fetching products: $e");
    }
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allProducts.where((product) {
          final name = product.name.toLowerCase();
          final brand = product.brand.toLowerCase();
          return name.contains(query) || brand.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_performSearch);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  onChanged: (value) {
                    _performSearch();
                  },
                  decoration: InputDecoration(
                    hintText: "Search shoes, jerseys...",
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _searchController.text.isEmpty // Kondisi jika user belum mengetik
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: Colors.grey),
                  Text("Type something to find products", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : _searchResults.isEmpty 
            ? const Center(child: Text("Product not found."))
            : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
              return ListTile(
                leading: const Icon(Icons.search, color: Colors.grey),
                title: Text(product.name),
                subtitle: Text(product.brand),
                trailing: Text("Rp${product.price}"),
                onTap: () {
                  // PINDAH KE DETAIL PAGE
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}