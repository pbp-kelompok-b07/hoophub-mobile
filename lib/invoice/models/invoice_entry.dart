import 'dart:convert';

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
        isAdmin: json["is_admin"] ?? json["isAdmin"] ?? false, 
        invoices: json["invoices"] == null 
            ? [] 
            : List<Invoice>.from(json["invoices"].map((x) => Invoice.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "is_admin": isAdmin,
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
  String postalCode;
  double totalPrice;
  String status;
  List<Item> items;

  Invoice({
    required this.id,
    required this.invoiceNo,
    required this.date,
    required this.fullName,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.totalPrice,
    required this.status,
    required this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json["id"]?.toString() ?? "",
        invoiceNo: json["invoice_no"] ?? "No Invoice",
        date: json["date"] ?? "",
        fullName: json["full_name"] ?? json["fullName"] ?? "",
        address: json["address"] ?? "",
        city: json["city"] ?? "",
        postalCode: json["postal_code"]?.toString() ?? "",
        totalPrice: (json["total_price"] ?? 0).toDouble(),
        status: json["status"] ?? "Pending",
        items: json["items"] == null 
            ? [] 
            : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "invoice_no": invoiceNo,
        "date": date,
        "full_name": fullName,
        "address": address,
        "city": city,
        "postal_code": postalCode,
        "total_price": totalPrice,
        "status": status,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class Item {
  int productId;
  String name;
  String brand;
  double price;
  int quantity;
  double subtotal;
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
        productId: (json["product_id"] ?? json["productId"] ?? 0).toInt(),
        name: json["name"]?.toString() ?? "Unknown Product",
        brand: json["brand"]?.toString() ?? "",
        price: (json["price"] ?? 0).toDouble(),
        quantity: (json["quantity"] ?? 0).toInt(),
        subtotal: (json["subtotal"] ?? 0).toDouble(),
        image: json["image"]?.toString() ?? "",
      );

  Map<String, dynamic> toJson() => {
        "product_id": productId,
        "name": name,
        "brand": brand,
        "price": price,
        "quantity": quantity,
        "subtotal": subtotal,
        "image": image,
      };
}