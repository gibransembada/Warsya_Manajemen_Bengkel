import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  UserModel? get currentUser => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.signInWithEmailAndPassword(email, password);
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password,
    String name,
    String phoneNumber,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.registerWithEmailAndPassword(
        email,
        password,
        name,
        phoneNumber,
      );
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
    } catch (e) {
      debugPrint('Error in signOut: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Mengambil ulang data pengguna dari Firestore dan memperbarui state.
  Future<void> refreshUser() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
        if (userDoc.exists) {
          _user =
              UserModel.fromMap({...userDoc.data()!, 'uid': firebaseUser.uid});
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Error refreshing user: $e');
      }
    }
  }
}
