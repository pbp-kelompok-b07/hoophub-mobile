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

  factory Product.fromJson(Map<String, dynamic> json) {
    // Asumsi format JSON dari Django pakai serializers:
    // {
    //   "pk": 1,
    //   "fields": {
    //     "name": "...",
    //     "description": "...",
    //     "price": 100000,
    //     "image_url": "https://...",
    //     "brand": "...",
    //     "category": "...",
    //     "stock": 10
    //   }
    // }
    final fields = json['fields'] as Map<String, dynamic>;

    return Product(
      id: json['pk'] as int,
      name: fields['name'] as String? ?? '',
      description: fields['description'] as String? ?? '',
      price: fields['price'] as int? ?? 0,
      imageUrl: fields['image_url'] as String? ?? '',
      brand: fields['brand'] as String? ?? '',
      category: fields['category'] as String? ?? '',
      stock: fields['stock'] as int? ?? 0,
    );
  }
}
