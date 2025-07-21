import 'package:cloud_firestore/cloud_firestore.dart';

class SparePartModel {
  final String id;
  final String name;
  final String code;
  final double buyPrice;
  final double sellPrice;
  final int stock;
  final String? description;
  final String? brand;
  final String workshopId;
  final DateTime createdAt;
  final DateTime updatedAt;

  SparePartModel({
    required this.id,
    required this.name,
    required this.code,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    this.description,
    this.brand,
    required this.workshopId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SparePartModel.fromMap(Map<String, dynamic> map, String id) {
    return SparePartModel(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      buyPrice: (map['buyPrice'] ?? 0).toDouble(),
      sellPrice: (map['sellPrice'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      description: map['description'],
      brand: map['brand'],
      workshopId: map['workshopId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'buyPrice': buyPrice,
      'sellPrice': sellPrice,
      'stock': stock,
      'description': description,
      'brand': brand,
      'workshopId': workshopId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  SparePartModel copyWith({
    String? id,
    String? name,
    String? code,
    double? buyPrice,
    double? sellPrice,
    int? stock,
    String? description,
    String? brand,
    String? workshopId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SparePartModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      workshopId: workshopId ?? this.workshopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
