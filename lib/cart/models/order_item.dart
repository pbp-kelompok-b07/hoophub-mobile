import 'dart:convert';

List<OrderItemEntry> orderItemEntryFromJson(String str) => List<OrderItemEntry>.from(json.decode(str).map((x) => OrderItemEntry.fromJson(x)));

String orderItemEntryToJson(List<OrderItemEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderItemEntry {
    String model;
    int pk;
    OrderItemFields fields;

    OrderItemEntry({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory OrderItemEntry.fromJson(Map<String, dynamic> json) => OrderItemEntry(
        model: json["model"],
        pk: json["pk"],
        fields: OrderItemFields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": model,
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class OrderItemFields {
    String order;
    String product;
    int quantity;
    int priceAtCheckout;
    
    String? productName; 

    OrderItemFields({
        required this.order,
        required this.product,
        required this.quantity,
        required this.priceAtCheckout,
        this.productName,
    });

    factory OrderItemFields.fromJson(Map<String, dynamic> json) => OrderItemFields(
        order: json["order"],
        product: json["product"],
        quantity: json["quantity"],
        priceAtCheckout: json["price_at_checkout"],
        
        productName: json["product_name"] ?? "Product ID: ${json["product"]}",
    );

    Map<String, dynamic> toJson() => {
        "order": order,
        "product": product,
        "quantity": quantity,
        "price_at_checkout": priceAtCheckout,
        "product_name": productName,
    };
    
    int get lineTotal => priceAtCheckout * quantity;
}