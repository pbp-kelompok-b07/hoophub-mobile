import 'dart:convert';
import 'package:hoophub_mobile/catalog/models/product.dart';

List<WishEntry> wishEntryListFromJson(String str) {
  final decoded = json.decode(str);
  if (decoded is List) {
    return List<WishEntry>.from(decoded.map((x) => WishEntry.fromJson(Map<String, dynamic>.from(x))));
  }
  return [WishEntry.fromJson(Map<String, dynamic>.from(decoded))];
}

String wishEntryListToJson(List<WishEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WishEntry {
  final int id;
  final int productId;
  final Product? product;
  final DateTime dateAdded;
  final int userId;

  WishEntry({
    required this.id,
    required this.productId,
    this.product,
    required this.dateAdded,
    required this.userId,
  });

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final cleaned = value.replaceAll('.', '').replaceAll(',', '');
      return int.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  static DateTime _parseDate(dynamic dateRaw) {
    if (dateRaw == null) return DateTime.now();
    try {
      if (dateRaw is int) {
        if (dateRaw.abs() > 1000000000000) return DateTime.fromMillisecondsSinceEpoch(dateRaw);
        return DateTime.fromMillisecondsSinceEpoch(dateRaw * 1000);
      }
      if (dateRaw is String) {
        // Coba parsing standar dulu
        try {
          return DateTime.parse(dateRaw);
        } catch (_) {
           // Ignore
        }
      }
    } catch (_) {}
    return DateTime.now();
  }

  // --- LOGIC FIX URL ---
  static String _fixUrl(String? url) {
    if (url == null || url.isEmpty || url == 'None' || url == 'null') return '';
    if (url.startsWith('http')) return url;
    
    const base = "https://roselia-evanny-hoophub.pbp.cs.ui.ac.id";
    String cleanUrl = url.trim();
    if (!cleanUrl.startsWith('/')) cleanUrl = '/$cleanUrl';
    
    return "$base$cleanUrl";
  }

  factory WishEntry.fromJson(Map<String, dynamic> json) {
    // -------------------------------------------------------------
    // DEBUG: LIHAT APA ISI JSON DARI SERVER
    // -------------------------------------------------------------
    print("--------------------------------------------------");
    print("DEBUG ITEM ID: ${json['id']}");
    print("RAW JSON: $json");
    // -------------------------------------------------------------

    // 1) NESTED PRODUCT
    Product? nestedProduct;
    if (json['product'] != null && json['product'] is Map) {
      var pMap = Map<String, dynamic>.from(json['product']);
      
      // Coba ambil gambar dari berbagai key yang mungkin ada di nested object
      String? rawNestedImg = pMap['image'] ?? pMap['image_url'] ?? pMap['thumbnail'];
      
      // Fix URL
      if (rawNestedImg != null) {
         String fixed = _fixUrl(rawNestedImg);
         pMap['image_url'] = fixed;
         pMap['image'] = fixed; // Cadangan
         print(">> Fixed Nested Image: $fixed"); // Debug print
      }
      
      nestedProduct = Product.fromJson(pMap);
    }

    // 2) PARSE ID
    int pid = 0;
    if (json.containsKey('product_id')) pid = _toInt(json['product_id']);
    else if (nestedProduct != null) pid = nestedProduct.id;
    else if (json['product'] is int) pid = _toInt(json['product']);

    // 3) PARSE FIELDS LAIN
    final dateAdded = _parseDate(json['date_added'] ?? json['dateAdded']);
    final userId = _toInt(json['user_id'] ?? json['userId']);

    // 4) FLATTENED PRODUCT (Biasanya dari show_json)
    if (nestedProduct == null) {
      final Map<String, dynamic> flattened = {};

      if (json.containsKey('product_name')) flattened['name'] = json['product_name'];
      if (json.containsKey('product_brand')) flattened['brand'] = json['product_brand'];
      if (json.containsKey('product_price')) flattened['price'] = json['product_price'];
      flattened['id'] = pid; // Gunakan PID yang sudah diparse
      
      // --- DETEKSI GAMBAR ---
      // Cek semua kemungkinan key yang mungkin dikirim Django
      String? rawImg = json['image_url'] ??
                      json['image'] ??
                      json['product_image'] ??
                      json['product_thumbnail'] ??
                      json['thumbnail'];

      if (rawImg != null) {
        final r = rawImg.toString().trim();
        if (r.isNotEmpty && r.toLowerCase() != 'null' && r.toLowerCase() != 'none') {
          final fixedUrl = _fixUrl(r);
          flattened['image_url'] = fixedUrl;
          flattened['image'] = fixedUrl;
          print(">> Resulting URL: $fixedUrl");
        } else {
          print(">> HASIL: Image dianggap NULL oleh Flutter (string kosong/null)");
        }
      } else {
        print(">> HASIL: Image dianggap NULL oleh Flutter (key tidak ada)");
      }

      // Buat Product Dummy jika ada Nama
      if (flattened.containsKey('name')) {
         if (!flattened.containsKey('description')) flattened['description'] = '';
         if (!flattened.containsKey('category')) flattened['category'] = '';
         if (!flattened.containsKey('stock')) flattened['stock'] = 0;
         
         nestedProduct = Product.fromJson(flattened); 
      }
    }

    return WishEntry(
      id: _toInt(json['id']),
      productId: pid,
      product: nestedProduct,
      dateAdded: dateAdded,
      userId: userId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'date_added': dateAdded.toIso8601String(),
        'user_id': userId,
      };

  Map<String, dynamic> toCreateJson() => {'product_id': productId};
}