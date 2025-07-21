import 'package:cloud_firestore/cloud_firestore.dart';

class WorkOrder {
  final String id;
  final String workshopId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String vehicleNumber;
  final String vehicleType;
  final String description;
  final List<ServiceItem> services; // Jasa/service
  final List<SparePartItem> spareParts; // Spare part
  final double serviceTotal; // Total jasa
  final double sparePartTotal; // Total spare part
  final double totalAmount; // Total keseluruhan
  final String status; // 'pending', 'dikerjakan', 'selesai', 'dibayar'
  final DateTime createdAt;
  final DateTime? updatedAt;

  WorkOrder({
    required this.id,
    required this.workshopId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.description,
    required this.services,
    required this.spareParts,
    required this.serviceTotal,
    required this.sparePartTotal,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workshopId': workshopId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'vehicleNumber': vehicleNumber,
      'vehicleType': vehicleType,
      'description': description,
      'services': services.map((item) => item.toMap()).toList(),
      'spareParts': spareParts.map((item) => item.toMap()).toList(),
      'serviceTotal': serviceTotal,
      'sparePartTotal': sparePartTotal,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory WorkOrder.fromMap(Map<String, dynamic> map) {
    // Handle createdAt field yang bisa berupa string, Timestamp, atau null
    DateTime createdAt;
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    // Handle updatedAt field yang bisa berupa string, Timestamp, atau null
    DateTime? updatedAt;
    final updatedAtRaw = map['updatedAt'];
    if (updatedAtRaw is Timestamp) {
      updatedAt = updatedAtRaw.toDate();
    } else if (updatedAtRaw is String) {
      updatedAt = DateTime.tryParse(updatedAtRaw);
    }

    return WorkOrder(
      id: map['id'] ?? '',
      workshopId: map['workshopId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      vehicleNumber: map['vehicleNumber'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      description: map['description'] ?? '',
      services: List<ServiceItem>.from(
        map['services']?.map((x) => ServiceItem.fromMap(x)) ?? [],
      ),
      spareParts: List<SparePartItem>.from(
        map['spareParts']?.map((x) => SparePartItem.fromMap(x)) ?? [],
      ),
      serviceTotal: (map['serviceTotal'] ?? 0.0).toDouble(),
      sparePartTotal: (map['sparePartTotal'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

// Model untuk item jasa/service
class ServiceItem {
  final String id;
  final String name;
  final double price;
  final String? description;

  ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
    };
  }

  factory ServiceItem.fromMap(Map<String, dynamic> map) {
    return ServiceItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'],
    );
  }
}

// Model untuk item spare part
class SparePartItem {
  final String id;
  final String name;
  final String sparePartId; // ID dari spare part di collection spare_parts
  final double price;
  final int quantity;
  final double total;

  SparePartItem({
    required this.id,
    required this.name,
    required this.sparePartId,
    required this.price,
    required this.quantity,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sparePartId': sparePartId,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  factory SparePartItem.fromMap(Map<String, dynamic> map) {
    return SparePartItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      sparePartId: map['sparePartId'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      total: (map['total'] ?? 0.0).toDouble(),
    );
  }
}
