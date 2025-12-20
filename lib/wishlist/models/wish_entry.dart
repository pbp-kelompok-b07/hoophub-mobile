import 'dart:convert';
import 'package:hoophub_mobile/catalog/models/product.dart';

List<WishEntry> wishEntryListFromJson(String str) {
  final decoded = json.decode(str);
  if (decoded is List) {
    return List<WishEntry>.from(decoded.map((x) => WishEntry.fromJson(Map<String, dynamic>.from(x))));
  }
  // jika kadang endpoint mengembalikan single object
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

  // ---------- helpers ----------
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
    if (dateRaw is int) {
      final val = dateRaw;
      // deteksi seconds (10 digit) atau milliseconds (13+ digit)
      if (val.abs() > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(val);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(val * 1000);
      }
    }
    if (dateRaw is String) {
      final numeric = int.tryParse(dateRaw);
      if (numeric != null) return _parseDate(numeric);
      try {
        return DateTime.parse(dateRaw);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  // ---------- factory ----------
  factory WishEntry.fromJson(Map<String, dynamic> json) {
    // 1) nested product?
    Product? nestedProduct;
    if (json['product'] != null && json['product'] is Map) {
      nestedProduct = Product.fromJson(Map<String, dynamic>.from(json['product']));
    }

    // 2) detect product id
    int pid = 0;
    if (json.containsKey('product_id')) {
      pid = _toInt(json['product_id']);
    } else if (json.containsKey('productId')) {
      pid = _toInt(json['productId']);
    } else if (nestedProduct != null) {
      pid = nestedProduct.id;
    } else if (json['product'] is int) {
      pid = _toInt(json['product']);
    }

    // 3) parse date_added (several possible keys)
    final dateRaw = json['date_added'] ?? json['dateAdded'] ?? json['created_at'];
    final dateAdded = _parseDate(dateRaw);

    // 4) parse user id
    final userId = _toInt(json['user_id'] ?? json['userId'] ?? json['user']);

    // 5) jika flattened fields ada, buat nestedProduct agar front-end dapat memakai Product
    if (nestedProduct == null) {
      final Map<String, dynamic> flattened = {};

      if (json.containsKey('product_name')) flattened['name'] = json['product_name'];
      if (json.containsKey('product_brand')) flattened['brand'] = json['product_brand'];
      if (json.containsKey('product_price')) flattened['price'] = json['product_price'];
      if (json.containsKey('product_id')) flattened['id'] = json['product_id'];

      // banyak kemungkinan nama untuk image -> map ke key yang Product.fromJson mengharapkan (image_url)
      if (json.containsKey('product_thumbnail')) flattened['image_url'] = json['product_thumbnail'];
      if (json.containsKey('product_image')) flattened['image_url'] = flattened['image_url'] ?? json['product_image'];
      if (json.containsKey('image')) flattened['image_url'] = flattened['image_url'] ?? json['image'];
      if (json.containsKey('image_url')) flattened['image_url'] = flattened['image_url'] ?? json['image_url'];

      if (flattened.isNotEmpty) {
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

  // ---------- serialisasi ----------
  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'date_added': dateAdded.toIso8601String(),
        'user_id': userId,
      };

  /// payload minimal untuk membuat wishlist di server
  Map<String, dynamic> toCreateJson() => {
        'product_id': productId,
      };
}