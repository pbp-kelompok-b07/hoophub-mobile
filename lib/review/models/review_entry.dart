// To parse this JSON data, do
//
//     final reviewEntry = reviewEntryFromJson(jsonString);

import 'dart:convert';

List<ReviewEntry> reviewEntryFromJson(String str) => List<ReviewEntry>.from(
  json.decode(str).map((x) => ReviewEntry.fromJson(x)),
);

String reviewEntryToJson(List<ReviewEntry> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReviewEntry {
  String id;
  String date;
  String review;
  int rating;
  Product product;
  String user;

  ReviewEntry({
    required this.id,
    required this.date,
    required this.review,
    required this.rating,
    required this.product,
    required this.user,
  });

  factory ReviewEntry.fromJson(Map<String, dynamic> json) => ReviewEntry(
    id: json["id"],
    date: json["date"],
    review: json["review"] ?? "",
    rating: json["rating"],
    product: Product.fromJson(json["product"]),
    user: json["user"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "date": date,
    "review": review,
    "rating": rating,
    "product": product.toJson(),
    "user": user,
  };
}

class Product {
  String name;
  String price;
  String image;
  int id;

  Product({
    required this.name,
    required this.price,
    required this.image,
    required this.id,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    name: json["name"],
    price: json["price"],
    image: json["image"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "price": price,
    "image": image,
    "id": id,
  };
}
