import 'dart:convert';

List<CartEntry> cartEntryFromJson(String str) => List<CartEntry>.from(json.decode(str).map((x) => CartEntry.fromJson(x)));

String cartEntryToJson(List<CartEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CartEntry {
    String model;
    String pk;
    CartEntryFields fields;

    CartEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory CartEntry.fromJson(Map<String, dynamic> json) => CartEntry(
        model: json["model"],
        pk: json["pk"].toString(),
        fields: CartEntryFields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class CartEntryFields {
    int user;
    int product;
    String productName;
    int price;          
    int quantity;       
    String? thumbnailUrl;
    int subtotal;      
    CartEntryFields({
        required this.user,
        required this.product,
        required this.productName,
        required this.price,
        required this.quantity,
        this.thumbnailUrl,
        required this.subtotal,
    });

    factory CartEntryFields.fromJson(Map<String, dynamic> json) => CartEntryFields(
        user: json["user"],
        product: json["product"],
        productName: json["product_name"] ?? "Unknown Product",
        price: json["price"],
        quantity: json["quantity"],
        thumbnailUrl: json["thumbnail_url"],
        subtotal: json["subtotal"] ?? (json["price"] * json["quantity"]),
    );

    Map<String, dynamic> toJson() => {
        "user": user,
        "product": product,
        "product_name": productName,
        "price": price,
        "quantity": quantity,
        "thumbnail_url": thumbnailUrl,
        "subtotal": subtotal,
    };
}