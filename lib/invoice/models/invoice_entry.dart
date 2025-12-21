import 'dart:convert';

// Update: Menggunakan operator ?. agar tidak error jika string kosong
List<InvoiceEntry> invoiceEntryFromJson(String str) => 
    List<InvoiceEntry>.from(json.decode(str).map((x) => InvoiceEntry.fromJson(x)));

class InvoiceEntry {
  String status;
  bool isAdmin;
  List<Invoice> invoices;

  InvoiceEntry({
    required this.status,
    required this.isAdmin,
    required this.invoices,
  });

  factory InvoiceEntry.fromJson(Map<String, dynamic> json) => InvoiceEntry(
        status: json["status"] ?? "", 
        isAdmin: json["isAdmin"] ?? false, 
        invoices: json["invoices"] == null 
            ? [] 
            : List<Invoice>.from(json["invoices"].map((x) => Invoice.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "isAdmin": isAdmin,
        "invoices": List<dynamic>.from(invoices.map((x) => x.toJson())),
      };
}

class Invoice {
  String id;
  String invoiceNo;
  String date;
  String fullName;
  String address;
  String city;
  int totalPrice;
  String status;
  List<Item> items;

  Invoice({
    required this.id,
    required this.invoiceNo,
    required this.date,
    required this.fullName,
    required this.address,
    required this.city,
    required this.totalPrice,
    required this.status,
    required this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json["id"]?.toString() ?? "",
        invoiceNo: json["invoice_no"] ?? "No Invoice",
        date: json["date"] ?? "",
        fullName: json["fullName"] ?? "Guest",
        address: json["address"] ?? "",
        city: json["city"] ?? "",
        totalPrice: json["total_price"] ?? 0,
        status: json["status"] ?? "Pending",
        items: json["items"] == null 
            ? [] 
            : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "invoiceNo": invoiceNo,
        "date": date,
        "fullName": fullName,
        "address": address,
        "city": city,
        "totalPrice": totalPrice,
        "status": status,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class Item {
  int productId;
  String name;
  String brand;
  int price;
  int quantity;
  int subtotal;
  String image;

  Item({
    required this.productId,
    required this.name,
    required this.brand,
    required this.price,
    required this.quantity,
    required this.subtotal,
    required this.image,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        productId: json["productId"] ?? json["product_id"] ?? 0,
        name: json["name"] ?? "Unknown Product",
        brand: json["brand"] ?? "",
        price: json["price"] ?? 0,
        quantity: json["quantity"] ?? 0,
        subtotal: json["subtotal"] ?? 0,
        image: json["image"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "name": name,
        "brand": brand,
        "price": price,
        "quantity": quantity,
        "subtotal": subtotal,
        "image": image,
      };
}