import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hoophub_mobile/wishlist/models/wish_entry.dart';
import 'package:hoophub_mobile/wishlist/widgets/wish_entry_card.dart';

class WishEntryListPage extends StatefulWidget {
  final List<WishEntry> initialEntries;
  final List<String> brands;
  final bool isAuthenticated;

  final Future<void> Function(WishEntry entry)? onAddToCart;
  final Future<bool> Function(WishEntry entry)? onRemoveFromWishlist;

  const WishEntryListPage({
    super.key,
    this.initialEntries = const [],
    this.brands = const [],
    this.isAuthenticated = true,
    this.onAddToCart,
    this.onRemoveFromWishlist,
  });

  @override
  State<WishEntryListPage> createState() => _WishEntryListPageState();
}

class _WishEntryListPageState extends State<WishEntryListPage> {
  late List<WishEntry> _allEntries;
  late List<WishEntry> _visibleEntries;
  String _selectedBrand = '';
  String _selectedSort = 'date_desc';
  final List<_FlashMessage> _messages = [];
  final DateFormat _dateFmt = DateFormat('MMM d, yyyy HH:mm');
  int? _processingAddProductId;
  int? _processingRemoveId;

  @override
  void initState() {
    super.initState();
    _allEntries = List.from(widget.initialEntries);
    _visibleEntries = List.from(_allEntries);
    // default selections
    _selectedBrand = '';
    _selectedSort = 'date_desc';
    _applyFiltersAndSort();
  }

  /// Safe flash message helper.
  /// It avoids using BuildContext when the widget is unmounted.
  void _flash(String text, {String type = 'info'}) {
    // update local message list only if still mounted
    if (mounted) {
      setState(() {
        _messages.add(_FlashMessage(text: text, type: type));
      });

      // automatically remove after 3.5s
      Future.delayed(const Duration(milliseconds: 3500), () {
        if (mounted) {
          setState(() {
            if (_messages.isNotEmpty) _messages.removeAt(0);
          });
        }
      });

      // show a SnackBar for quick feedback; only use BuildContext when mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
      );
    } else {
      // If not mounted, we simply skip showing UI feedback.
      // This avoids using BuildContext across async gaps.
    }
  }

  double _priceOf(WishEntry e) {
    try {
      final prod = e.product as dynamic;
      final p = prod?.price ?? prod?.priceValue ?? prod?.price_int ?? 0;
      if (p == null) return 0;
      if (p is num) return p.toDouble();
      // Menghilangkan semua yang bukan angka/koma/titik/minus
      final s = p.toString().replaceAll(RegExp(r"[^0-9\-.,]"), '');
      // Mengganti koma dengan titik dan mencoba parse
      return double.tryParse(s.replaceAll(',', '')) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  void _applyFiltersAndSort() {
    final brand = _selectedBrand;
    List<WishEntry> list = List.from(_allEntries);

    if (brand.isNotEmpty) {
      list = list.where((e) {
        final prod = e.product as dynamic;
        final pBrand = (prod?.brand ?? prod?.brandName ?? '')?.toString() ?? '';
        return pBrand.toLowerCase() == brand.toLowerCase();
      }).toList();
    }

    switch (_selectedSort) {
      case 'date_asc':
        list.sort((a, b) => a.dateAdded.compareTo(b.dateAdded));
        break;
      case 'date_desc':
        list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case 'price_asc':
        list.sort((a, b) => _priceOf(a).compareTo(_priceOf(b)));
        break;
      case 'price_desc':
        list.sort((a, b) => _priceOf(b).compareTo(_priceOf(a)));
        break;
    }

    if (mounted) {
      setState(() {
        _visibleEntries = list;
      });
    } else {
      _visibleEntries = list;
    }
  }

  Future<void> _handleAddToCart(WishEntry entry) async {
      if (!widget.isAuthenticated) {
        _flash('Please sign in to add to cart', type: 'error');
        return;
      }
      
      // Asumsi: kita menggunakan ID Produk untuk Add to Cart
      // Karena model WishEntry tidak diperlihatkan, kita asumsikan ID Produk adalah entry.product.id
      final productId = (entry.product as dynamic)?.id ?? -1;
      if (productId <= 0) {
        if (mounted) _flash('Product ID not found.', type: 'error');
        return;
      }
      
      if (mounted) setState(() => _processingAddProductId = productId);
      
      try {
        if (widget.onAddToCart != null) {
          await widget.onAddToCart!(entry);
          if (!mounted) return;
          _flash('Added to cart', type: 'success');
        } else {
          if (!mounted) return;
          _flash('Added to cart (local)', type: 'success');
        }
      } catch (err) {
        if (mounted) _flash('Failed to add to cart', type: 'error');
      } finally {
        // Selesai memproses
        if (mounted) setState(() => _processingAddProductId = null);
      }
    }

  Future<void> _handleRemove(WishEntry entry) async {
    if (!widget.isAuthenticated) {
      _flash('Please sign in to manage your wishlist', type: 'error');
      return;
    }

    if (mounted) setState(() => _processingRemoveId = entry.id);
    try {
      bool ok = true;
      if (widget.onRemoveFromWishlist != null) {
        ok = await widget.onRemoveFromWishlist!(entry);
      }
      // guard after awaiting
      if (!mounted) return;

      if (ok) {
        if (mounted) {
          setState(() {
            _allEntries.removeWhere((e) => e.id == entry.id);
            _applyFiltersAndSort();
          });
        } else {
          _allEntries.removeWhere((e) => e.id == entry.id);
          _applyFiltersAndSort();
        }
        _flash('Item removed from wishlist', type: 'success');
      } else {
        _flash('Failed to remove item', type: 'error');
      }
    } catch (err) {
      if (mounted) _flash('Network error', type: 'error');
    } finally {
      if (mounted) setState(() => _processingRemoveId = null);
    }
  }

  void _resetFilters() {
    if (mounted) {
      setState(() {
        _selectedBrand = '';
        _selectedSort = 'date_desc';
        _applyFiltersAndSort();
      });
    } else {
      _selectedBrand = '';
      _selectedSort = 'date_desc';
      _applyFiltersAndSort();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('hoophub - Wishlist'),
        backgroundColor: const Color(0xFF005F73),
      ),
      body: widget.isAuthenticated ? _buildContent(context) : _buildNotAuth(context),
    );
  }

  Widget _buildNotAuth(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You must be logged in.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('To see your wishlist or add a new one, please log in to your account.', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEE9B00)),
              onPressed: () {
                // navigate to login - user should wire this
                _flash('Please implement navigation to login', type: 'info');
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
          child: Row(
            children: const [
              Expanded(
                child: Text('Your wishlist is here!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),

        // Filter bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Brand', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedBrand.isEmpty ? null : _selectedBrand,
                    hint: const Text('All'),
                    items: [const DropdownMenuItem(value: '', child: Text('All'))]
                        .followedBy(widget.brands.map((b) => DropdownMenuItem(value: b, child: Text(b))))
                        .toList(),
                    onChanged: (v) {
                      if (mounted) {
                        setState(() {
                          _selectedBrand = v ?? '';
                          _applyFiltersAndSort();
                        });
                      } else {
                        _selectedBrand = v ?? '';
                        _applyFiltersAndSort();
                      }
                    },
                  ),
                ],
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sort', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: _selectedSort,
                    items: const [
                      DropdownMenuItem(value: 'date_desc', child: Text('Date (Newest)')),
                      DropdownMenuItem(value: 'date_asc', child: Text('Date (Oldest)')),
                      DropdownMenuItem(value: 'price_desc', child: Text('Price (Highest)')),
                      DropdownMenuItem(value: 'price_asc', child: Text('Price (Lowest)')),
                    ],
                    onChanged: (v) {
                      if (mounted) {
                        setState(() {
                          _selectedSort = v ?? 'date_desc';
                          _applyFiltersAndSort();
                        });
                      } else {
                        _selectedSort = v ?? 'date_desc';
                        _applyFiltersAndSort();
                      }
                    },
                  ),
                ],
              ),

              TextButton(
                onPressed: _resetFilters,
                child: const Text('Reset', style: TextStyle(decoration: TextDecoration.underline, color: Color(0xFF005F73))),
              ),
            ],
          ),
        ),

        // messages box
        if (_messages.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: _messages.map((m) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: m.type == 'success' ? Colors.green[50] : m.type == 'error' ? Colors.red[50] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(m.text),
                  )).toList(),
            ),
          ),
        ],

        // Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6),
            child: _visibleEntries.isEmpty
              ? const Center(child: Text('Your wishlist is empty.'))
              : LayoutBuilder(builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 12,
                        childAspectRatio: crossAxisCount == 1 ? 4.2 : 3.2,
                    ),
                    itemCount: _visibleEntries.length,
                    itemBuilder: (context, idx) {
                      final entry = _visibleEntries[idx];
                      return WishEntryCard(
                        entry: entry,
                        dateFmt: _dateFmt,
                        isAuthenticated: widget.isAuthenticated,
                        // Mengirimkan state loading dari parent widget
                        processingAddProductId: _processingAddProductId, 
                        processingRemoveId: _processingRemoveId,
                        onAddToCart: _handleAddToCart, 
                        onRemoveFromWishlist: _handleRemove,
                      );
                    },
                  );
                }),
          ),
        ),
      ],
    );
  }
}

class _FlashMessage {
  final String text;
  final String type; // 'info' | 'success' | 'error'
  _FlashMessage({required this.text, this.type = 'info'});
}