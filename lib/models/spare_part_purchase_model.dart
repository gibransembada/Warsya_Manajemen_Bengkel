import 'package:cloud_firestore/cloud_firestore.dart';

class SparePartPurchase {
  final String id;
  final String workshopId;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final List<PurchaseItem> items;
  final double total;
  final DateTime createdAt;
  final String transactionNumber;

  SparePartPurchase({
    required this.id,
    required this.workshopId,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.total,
    required this.createdAt,
    required this.transactionNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'workshopId': workshopId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'createdAt': Timestamp.fromDate(createdAt),
      'transactionNumber': transactionNumber,
    };
  }

  factory SparePartPurchase.fromMap(Map<String, dynamic> map) {
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

    return SparePartPurchase(
      id: map['id'] ?? '',
      workshopId: map['workshopId'] ?? '',
      customerId: map['customerId'],
      customerName: map['customerName'],
      customerPhone: map['customerPhone'],
      items: List<PurchaseItem>.from(
        map['items']?.map((x) => PurchaseItem.fromMap(x)) ?? [],
      ),
      total: (map['total'] ?? 0.0).toDouble(),
      createdAt: createdAt,
      transactionNumber: map['transactionNumber'] ?? '',
    );
  }
}

class PurchaseItem {
  final String id;
  final String sparePartId;
  final String name;
  final double price;
  final int quantity;
  final double total;

  PurchaseItem({
    required this.id,
    required this.sparePartId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sparePartId': sparePartId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  factory PurchaseItem.fromMap(Map<String, dynamic> map) {
    return PurchaseItem(
      id: map['id'] ?? '',
      sparePartId: map['sparePartId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      total: (map['total'] ?? 0.0).toDouble(),
    );
  }
}
