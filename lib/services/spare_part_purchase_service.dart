import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/spare_part_purchase_model.dart';

class SparePartPurchaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate transaction number
  String _generateTransactionNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    return 'SP$year$month$day$hour$minute$second';
  }

  // Stream untuk mendapatkan semua transaksi pembelian berdasarkan workshopId
  Stream<List<SparePartPurchase>> getPurchaseHistoryStream(String workshopId) {
    return _firestore
        .collection('spare_part_purchases')
        .where('workshopId', isEqualTo: workshopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return SparePartPurchase.fromMap(data);
      }).toList();
    });
  }

  // Mendapatkan transaksi berdasarkan ID
  Future<SparePartPurchase?> getPurchaseById(String purchaseId) async {
    try {
      final doc = await _firestore
          .collection('spare_part_purchases')
          .doc(purchaseId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return SparePartPurchase.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting purchase: $e');
      return null;
    }
  }

  // Membuat transaksi pembelian baru
  Future<String?> createPurchase(SparePartPurchase purchase) async {
    try {
      // Generate transaction number jika belum ada
      final purchaseData = purchase.toMap();
      if (purchase.transactionNumber.isEmpty) {
        purchaseData['transactionNumber'] = _generateTransactionNumber();
      }

      final docRef =
          await _firestore.collection('spare_part_purchases').add(purchaseData);

      debugPrint('Purchase created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating purchase: $e');
      return null;
    }
  }

  // Menghapus transaksi pembelian
  Future<bool> deletePurchase(String purchaseId) async {
    try {
      await _firestore
          .collection('spare_part_purchases')
          .doc(purchaseId)
          .delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting purchase: $e');
      return false;
    }
  }

  // Mendapatkan statistik pembelian
  Future<Map<String, dynamic>> getPurchaseStats(String workshopId) async {
    try {
      final snapshot = await _firestore
          .collection('spare_part_purchases')
          .where('workshopId', isEqualTo: workshopId)
          .get();

      double totalRevenue = 0.0;
      int totalTransactions = snapshot.docs.length;
      int totalItems = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalRevenue += (data['total'] ?? 0).toDouble();

        if (data['items'] != null) {
          for (var item in List.from(data['items'])) {
            totalItems += (item['quantity'] ?? 1) as int;
          }
        }
      }

      return {
        'totalRevenue': totalRevenue,
        'totalTransactions': totalTransactions,
        'totalItems': totalItems,
      };
    } catch (e) {
      debugPrint('Error getting purchase stats: $e');
      return {
        'totalRevenue': 0.0,
        'totalTransactions': 0,
        'totalItems': 0,
      };
    }
  }
}
