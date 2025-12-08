// To parse this JSON data, do
//
//     final reportEntry = reportEntryFromJson(jsonString);

import 'dart:convert';

List<ReportEntry> reportEntryFromJson(String str) => List<ReportEntry>.from(json.decode(str).map((x) => ReportEntry.fromJson(x)));

String reportEntryToJson(List<ReportEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ReportEntry {
    String id;
    String reportType;
    String status;
    String title;
    String description;
    String createdAt;
    String updatedAt;
    Reporte reporter;
    Reporte reportedUser;
    ReportedProduct reportedProduct;

    ReportEntry({
        required this.id,
        required this.reportType,
        required this.status,
        required this.title,
        required this.description,
        required this.createdAt,
        required this.updatedAt,
        required this.reporter,
        required this.reportedUser,
        required this.reportedProduct,
    });

    factory ReportEntry.fromJson(Map<String, dynamic> json) => ReportEntry(
        id: json["id"],
        reportType: json["report_type"],
        status: json["status"],
        title: json["title"],
        description: json["description"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        reporter: Reporte.fromJson(json["reporter"]),
        reportedUser: Reporte.fromJson(json["reported_user"]),
        reportedProduct: ReportedProduct.fromJson(json["reported_product"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "report_type": reportType,
        "status": status,
        "title": title,
        "description": description,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "reporter": reporter.toJson(),
        "reported_user": reportedUser.toJson(),
        "reported_product": reportedProduct.toJson(),
    };
}

class ReportedProduct {
    int id;
    String name;
    String price;
    String image;

    ReportedProduct({
        required this.id,
        required this.name,
        required this.price,
        required this.image,
    });

    factory ReportedProduct.fromJson(Map<String, dynamic> json) => ReportedProduct(
        id: json["id"],
        name: json["name"],
        price: json["price"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "image": image,
    };
}

class Reporte {
    int? id;
    String? username;

    Reporte({
        required this.id,
        required this.username,
    });

    factory Reporte.fromJson(Map<String, dynamic> json) => Reporte(
        id: json["id"],
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
    };
}
