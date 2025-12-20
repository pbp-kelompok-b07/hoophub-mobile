// To parse this JSON data, do
//
//     final invoiceEntry = invoiceEntryFromJson(jsonString);

import 'dart:convert';

List<InvoiceEntry> invoiceEntryFromJson(String str) => List<InvoiceEntry>.from(json.decode(str).map((x) => InvoiceEntry.fromJson(x)));

String invoiceEntryToJson(List<InvoiceEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class InvoiceEntry {
    String id;
    String name;
    String description;
    String category;
    int stock;
    String price;
    String color;
    String size;
    String thumbnail;
    bool isFeatured;
    int userId;

    InvoiceEntry({
        required this.id,
        required this.name,
        required this.description,
        required this.category,
        required this.stock,
        required this.price,
        required this.color,
        required this.size,
        required this.thumbnail,
        required this.isFeatured,
        required this.userId,
    });

    factory InvoiceEntry.fromJson(Map<String, dynamic> json) => InvoiceEntry(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        category: json["category"],
        stock: json["stock"],
        price: json["price"],
        color: json["color"],
        size: json["size"],
        thumbnail: json["thumbnail"],
        isFeatured: json["is_featured"],
        userId: json["user_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "category": category,
        "stock": stock,
        "price": price,
        "color": color,
        "size": size,
        "thumbnail": thumbnail,
        "is_featured": isFeatured,
        "user_id": userId,
    };
}
