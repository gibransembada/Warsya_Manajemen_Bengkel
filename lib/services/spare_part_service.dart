import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/spare_part_model.dart';
import 'package:flutter/foundation.dart';

class SparePartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all spare parts for a workshop
  Stream<List<SparePartModel>> getSpareParts(String workshopId) {
    return _firestore
        .collection('spare_parts')
        .where('workshopId', isEqualTo: workshopId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SparePartModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get spare part by ID
  Future<SparePartModel?> getSparePartById(String sparePartId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('spare_parts').doc(sparePartId).get();

      if (doc.exists) {
        return SparePartModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting spare part: $e');
      return null;
    }
  }

  // Add new spare part
  Future<bool> addSparePart(SparePartModel sparePart) async {
    try {
      await _firestore.collection('spare_parts').add(sparePart.toMap());
      return true;
    } catch (e) {
      debugPrint('Error adding spare part: $e');
      return false;
    }
  }

  // Update spare part
  Future<bool> updateSparePart(SparePartModel sparePart) async {
    try {
      await _firestore
          .collection('spare_parts')
          .doc(sparePart.id)
          .update(sparePart.toMap());
      return true;
    } catch (e) {
      debugPrint('Error updating spare part: $e');
      return false;
    }
  }

  // Delete spare part
  Future<bool> deleteSparePart(String sparePartId) async {
    try {
      await _firestore.collection('spare_parts').doc(sparePartId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting spare part: $e');
      return false;
    }
  }

  // Update stock
  Future<bool> updateStock(String sparePartId, int newStock) async {
    try {
      await _firestore.collection('spare_parts').doc(sparePartId).update({
        'stock': newStock,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating stock: $e');
      return false;
    }
  }

  // Search spare parts
  Stream<List<SparePartModel>> searchSpareParts(
      String workshopId, String query) {
    return _firestore
        .collection('spare_parts')
        .where('workshopId', isEqualTo: workshopId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SparePartModel.fromMap(doc.data(), doc.id))
          .where((sparePart) =>
              sparePart.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Get spare parts with low stock
  Stream<List<SparePartModel>> getLowStockSpareParts(
      String workshopId, int threshold) {
    return _firestore
        .collection('spare_parts')
        .where('workshopId', isEqualTo: workshopId)
        .where('stock', isLessThanOrEqualTo: threshold)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SparePartModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get spare part count
  Future<int> getSparePartCount(String workshopId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('spare_parts')
          .where('workshopId', isEqualTo: workshopId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting spare part count: $e');
      return 0;
    }
  }

  // Get total inventory value
  Future<double> getTotalInventoryValue(String workshopId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('spare_parts')
          .where('workshopId', isEqualTo: workshopId)
          .get();

      double totalValue = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final buyPrice = (data['buyPrice'] ?? 0).toDouble();
        final stock = data['stock'] ?? 0;
        totalValue += buyPrice * stock;
      }
      return totalValue;
    } catch (e) {
      debugPrint('Error getting total inventory value: $e');
      return 0;
    }
  }
}
