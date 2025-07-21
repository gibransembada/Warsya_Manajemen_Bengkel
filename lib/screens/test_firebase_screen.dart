import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirebaseScreen extends StatefulWidget {
  const TestFirebaseScreen({super.key});

  @override
  State<TestFirebaseScreen> createState() => _TestFirebaseScreenState();
}

class _TestFirebaseScreenState extends State<TestFirebaseScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _status = 'Checking connection...';

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      // Test Firestore
      await _firestore.collection('test').doc('test').set({
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Test Auth
      await _auth.signInAnonymously();

      setState(() {
        _status = '✅ Firebase terhubung dengan sukses!\n\n' 'Firestore: OK\n' +
            'Authentication: OK';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Firebase Connection'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Status Koneksi Firebase',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _status,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkConnection,
                child: const Text('Test Ulang Koneksi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
