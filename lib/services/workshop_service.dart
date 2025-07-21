import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class WorkshopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Membuat profil bengkel baru dan menautkannya ke pengguna saat ini.
  ///
  /// [workshopName] adalah nama dari bengkel.
  /// [address] adalah alamat bengkel (opsional).
  ///
  /// Mengembalikan `true` jika berhasil, `false` jika gagal.
  Future<bool> createWorkshop(String workshopName, {String? address}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Seharusnya tidak pernah terjadi jika pengguna sudah login
      return false;
    }

    try {
      // 1. Buat dokumen baru di koleksi 'workshops'
      DocumentReference workshopDoc =
          await _firestore.collection('workshops').add({
        'workshopName': workshopName,
        'address': address ?? '', // Simpan string kosong jika null
        'ownerUid': currentUser.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Dapatkan ID bengkel yang baru dibuat
      String workshopId = workshopDoc.id;

      // 3. Update dokumen pengguna di koleksi 'users'
      await _firestore.collection('users').doc(currentUser.uid).update({
        'workshopId': workshopId,
        'role': 'owner', // Pastikan rolenya adalah owner
      });

      return true;
    } catch (e) {
      debugPrint('Error creating workshop: $e');
      return false;
    }
  }

  /// Mengambil data bengkel berdasarkan workshopId.
  ///
  /// [workshopId] adalah ID dari bengkel yang ingin diambil datanya.
  ///
  /// Mengembalikan Map<String, dynamic> jika berhasil, null jika gagal.
  Future<Map<String, dynamic>?> getWorkshopData(String workshopId) async {
    try {
      DocumentSnapshot workshopDoc =
          await _firestore.collection('workshops').doc(workshopId).get();

      if (workshopDoc.exists) {
        return workshopDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting workshop data: $e');
      return null;
    }
  }

  /// Memperbarui data bengkel.
  ///
  /// [workshopId] adalah ID dari bengkel yang ingin diperbarui.
  /// [workshopName] adalah nama baru dari bengkel.
  /// [address] adalah alamat baru bengkel (opsional).
  ///
  /// Mengembalikan `true` jika berhasil, `false` jika gagal.
  Future<bool> updateWorkshop(String workshopId, String workshopName,
      {String? address}) async {
    try {
      await _firestore.collection('workshops').doc(workshopId).update({
        'workshopName': workshopName,
        'address': address ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating workshop: $e');
      return false;
    }
  }
}
