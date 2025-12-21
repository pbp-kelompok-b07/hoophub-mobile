import 'dart:convert';

List<CartEntry> cartEntryFromJson(String str) => List<CartEntry>.from(json.decode(str).map((x) => CartEntry.fromJson(x)));

String cartEntryToJson(List<CartEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CartEntry {
    int pk;
    CartEntryFields fields;

    CartEntry({
        required this.pk,
        required this.fields,
    });

    factory CartEntry.fromJson(Map<String, dynamic> json) => CartEntry(
        pk: json["pk"], 
        fields: CartEntryFields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class CartEntryFields {
    String productName;
    String brand;
    int price;
    int quantity;
    int subtotal;
    String thumbnailUrl;

    CartEntryFields({
        required this.productName,
        required this.brand,
        required this.price,
        required this.quantity,
        required this.subtotal,
        required this.thumbnailUrl,
    });

    factory CartEntryFields.fromJson(Map<String, dynamic> json) => CartEntryFields(
        productName: json["product_name"],

        brand: json["brand"],
        
        price: json["price"] is int ? json["price"] : int.parse(json["price"].toString()), 
        
        quantity: json["quantity"],
        
        subtotal: json["subtotal"] is int ? json["subtotal"] : int.parse(json["subtotal"].toString()), 
        
        thumbnailUrl: json["thumbnail_url"] ?? "", 
    );

    Map<String, dynamic> toJson() => {
        "product_name": productName,
        "brand": brand,
        "price": price,
        "quantity": quantity,
        "subtotal": subtotal,
        "thumbnail_url": thumbnailUrl,
    };
}