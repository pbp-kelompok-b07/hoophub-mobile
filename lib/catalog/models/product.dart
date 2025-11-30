class Product {
  final int id;
  final String name;
  final String description;
  final int price;
  final String imageUrl;
  final String brand;
  final String category;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.brand,
    required this.category,
    required this.stock,
  });

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      // kalau pakai titik/koma pemisah, bisa dibersihin dulu
      final cleaned = value.replaceAll('.', '').replaceAll(',', '');
      return int.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    // Bisa dua bentuk:
    // 1) { "pk": 1, "fields": { ... } }
    // 2) { "id": 1, "name": "...", ... }

    final Map<String, dynamic> fields;
    if (json['fields'] != null && json['fields'] is Map<String, dynamic>) {
      fields = json['fields'] as Map<String, dynamic>;
    } else {
      fields = json;
    }

    final dynamic idValue = json['pk'] ?? json['id'] ?? fields['id'];

    return Product(
      id: _toInt(idValue),
      name: fields['name'] as String? ?? '',
      description: fields['description'] as String? ?? '',
      price: _toInt(fields['price']),
      imageUrl: fields['image_url'] as String? ?? '',
      brand: fields['brand'] as String? ?? '',
      category: fields['category'] as String? ?? '',
      stock: _toInt(fields['stock']),
    );
  }
}
