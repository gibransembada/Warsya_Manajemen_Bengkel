import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? address;
  final String? vehicleNumber;
  final String? vehicleBrand;
  final String? vehicleModel;
  final String workshopId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.address,
    this.vehicleNumber,
    this.vehicleBrand,
    this.vehicleModel,
    required this.workshopId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map, String id) {
    return CustomerModel(
      id: id,
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'],
      vehicleNumber: map['vehicleNumber'],
      vehicleBrand: map['vehicleBrand'],
      vehicleModel: map['vehicleModel'],
      workshopId: map['workshopId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'vehicleNumber': vehicleNumber,
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
      'workshopId': workshopId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? address,
    String? vehicleNumber,
    String? vehicleBrand,
    String? vehicleModel,
    String? workshopId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleBrand: vehicleBrand ?? this.vehicleBrand,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      workshopId: workshopId ?? this.workshopId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
