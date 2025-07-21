import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import 'package:flutter/foundation.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all customers for a workshop
  Stream<List<CustomerModel>> getCustomers(String workshopId) {
    return _firestore
        .collection('customers')
        .where('workshopId', isEqualTo: workshopId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get customer by ID
  Future<CustomerModel?> getCustomerById(String customerId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('customers').doc(customerId).get();

      if (doc.exists) {
        return CustomerModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting customer: $e');
      return null;
    }
  }

  // Add new customer
  Future<bool> addCustomer(CustomerModel customer) async {
    try {
      await _firestore.collection('customers').add(customer.toMap());
      return true;
    } catch (e) {
      debugPrint('Error adding customer: $e');
      return false;
    }
  }

  // Update customer
  Future<bool> updateCustomer(CustomerModel customer) async {
    try {
      await _firestore
          .collection('customers')
          .doc(customer.id)
          .update(customer.toMap());
      return true;
    } catch (e) {
      debugPrint('Error updating customer: $e');
      return false;
    }
  }

  // Delete customer
  Future<bool> deleteCustomer(String customerId) async {
    try {
      await _firestore.collection('customers').doc(customerId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting customer: $e');
      return false;
    }
  }

  // Search customers
  Stream<List<CustomerModel>> searchCustomers(String workshopId, String query) {
    // Sementara gunakan client-side filtering untuk menghindari index
    return _firestore
        .collection('customers')
        .where('workshopId', isEqualTo: workshopId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CustomerModel.fromMap(doc.data(), doc.id))
          .where((customer) =>
              customer.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Get customer count
  Future<int> getCustomerCount(String workshopId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('customers')
          .where('workshopId', isEqualTo: workshopId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint('Error getting customer count: $e');
      return 0;
    }
  }
}
