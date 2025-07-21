import 'package:flutter/material.dart';

class CreateWorkOrderScreen extends StatelessWidget {
  const CreateWorkOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Work Order'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_add, size: 80, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Buat Work Order',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Fitur akan segera hadir!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              '• Pilih customer\n• Input jasa service\n• Pilih spare part\n• Hitung total biaya',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
