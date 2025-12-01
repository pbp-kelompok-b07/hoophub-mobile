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
      final cleaned = value.replaceAll('.', '').replaceAll(',', '');
      return int.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  static String _clean(String? value) {
    if (value == null) return '';
    var s = value.trim();
    if (s.length >= 2 && s.startsWith('"') && s.endsWith('"')) {
      s = s.substring(1, s.length - 1);
    }
    return s;
  }

  factory Product.fromJson(Map<String, dynamic> json) {

    final Map<String, dynamic> fields;
    if (json['fields'] != null && json['fields'] is Map<String, dynamic>) {
      fields = json['fields'] as Map<String, dynamic>;
    } else {
      fields = json;
    }

    final dynamic idValue = json['pk'] ?? json['id'] ?? fields['id'];

    return Product(
      id: _toInt(idValue),
      name: _clean(fields['name'] as String?),
      description: _clean(fields['description'] as String?),
      price: _toInt(fields['price']),
      imageUrl: _clean(
        (fields['image_url'] ?? fields['image']) as String?,
      ),
      brand: _clean(fields['brand'] as String?),
      category: _clean(fields['category'] as String?),
      stock: _toInt(fields['stock']),
    );
  }
}
