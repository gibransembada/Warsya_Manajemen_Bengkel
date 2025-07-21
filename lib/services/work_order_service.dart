import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/work_order_model.dart';

class WorkOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream untuk mendapatkan semua work order berdasarkan workshopId
  Stream<List<WorkOrder>> getWorkOrdersStream(String workshopId) {
    return _firestore
        .collection('work_orders')
        .where('workshopId', isEqualTo: workshopId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return WorkOrder.fromMap(data);
      }).toList();
    });
  }

  // Mendapatkan work order berdasarkan ID
  Future<WorkOrder?> getWorkOrderById(String workOrderId) async {
    try {
      final doc =
          await _firestore.collection('work_orders').doc(workOrderId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return WorkOrder.fromMap(data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting work order: $e');
      return null;
    }
  }

  // Membuat work order baru
  Future<String?> createWorkOrder(WorkOrder workOrder) async {
    try {
      // Konversi data untuk Firestore
      final workOrderData = workOrder.toMap();
      // Simpan createdAt sebagai Timestamp Firestore
      workOrderData['createdAt'] = Timestamp.fromDate(workOrder.createdAt);
      if (workOrder.updatedAt != null) {
        workOrderData['updatedAt'] = Timestamp.fromDate(workOrder.updatedAt!);
      }

      final docRef =
          await _firestore.collection('work_orders').add(workOrderData);
      debugPrint('Work order created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating work order: $e');
      return null;
    }
  }

  // Update work order
  Future<bool> updateWorkOrder(WorkOrder workOrder) async {
    try {
      final updateData = workOrder.toMap();
      updateData['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _firestore
          .collection('work_orders')
          .doc(workOrder.id)
          .update(updateData);
      return true;
    } catch (e) {
      debugPrint('Error updating work order: $e');
      return false;
    }
  }

  // Update status work order
  Future<bool> updateWorkOrderStatus(String workOrderId, String status) async {
    try {
      await _firestore.collection('work_orders').doc(workOrderId).update({
        'status': status,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating work order status: $e');
      return false;
    }
  }

  // Menghapus work order
  Future<bool> deleteWorkOrder(String workOrderId) async {
    try {
      await _firestore.collection('work_orders').doc(workOrderId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting work order: $e');
      return false;
    }
  }

  // Filter work order berdasarkan status
  Stream<List<WorkOrder>> getWorkOrdersByStatus(
      String workshopId, String status) {
    try {
      return _firestore
          .collection('work_orders')
          .where('workshopId', isEqualTo: workshopId)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return WorkOrder.fromMap(data);
        }).toList();
      }).handleError((error) {
        debugPrint('Error in getWorkOrdersByStatus: $error');
        return <WorkOrder>[];
      });
    } catch (e) {
      debugPrint('Error setting up getWorkOrdersByStatus stream: $e');
      return Stream.value(<WorkOrder>[]);
    }
  }

  // Mendapatkan statistik work order
  Future<Map<String, int>> getWorkOrderStats(String workshopId) async {
    try {
      final snapshot = await _firestore
          .collection('work_orders')
          .where('workshopId', isEqualTo: workshopId)
          .get();

      int pending = 0;
      int dikerjakan = 0;
      int selesai = 0;
      int dibayar = 0;

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] ?? 'pending';
        switch (status) {
          case 'pending':
            pending++;
            break;
          case 'dikerjakan':
            dikerjakan++;
            break;
          case 'selesai':
            selesai++;
            break;
          case 'dibayar':
            dibayar++;
            break;
        }
      }

      return {
        'pending': pending,
        'dikerjakan': dikerjakan,
        'selesai': selesai,
        'dibayar': dibayar,
        'total': snapshot.docs.length,
      };
    } catch (e) {
      debugPrint('Error getting work order stats: $e');
      return {
        'pending': 0,
        'dikerjakan': 0,
        'selesai': 0,
        'dibayar': 0,
        'total': 0,
      };
    }
  }

  // Fungsi untuk memperbaiki status work order yang menggunakan status lama
  Future<bool> fixWorkOrderStatuses(String workshopId) async {
    try {
      final snapshot = await _firestore
          .collection('work_orders')
          .where('workshopId', isEqualTo: workshopId)
          .get();

      int fixedCount = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final currentStatus = data['status'] ?? 'pending';

        // Mapping status lama ke status baru
        String newStatus = currentStatus;
        switch (currentStatus) {
          case 'paid':
            newStatus = 'dibayar';
            break;
          case 'completed':
            newStatus = 'selesai';
            break;
          case 'in_progress':
            newStatus = 'dikerjakan';
            break;
          case 'pending':
            newStatus = 'pending';
            break;
        }

        // Update jika status berubah
        if (newStatus != currentStatus) {
          await _firestore.collection('work_orders').doc(doc.id).update({
            'status': newStatus,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          });
          fixedCount++;
          debugPrint(
              'Fixed work order ${doc.id}: $currentStatus -> $newStatus');
        }
      }

      debugPrint('Fixed $fixedCount work order statuses');
      return true;
    } catch (e) {
      debugPrint('Error fixing work order statuses: $e');
      return false;
    }
  }
}
