import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/workshop_service.dart';
import 'package:mybengkel/screens/main_screen.dart';

class CreateWorkshopScreen extends StatefulWidget {
  const CreateWorkshopScreen({super.key});

  @override
  State<CreateWorkshopScreen> createState() => _CreateWorkshopScreenState();
}

class _CreateWorkshopScreenState extends State<CreateWorkshopScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workshopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _workshopService = WorkshopService();
  bool _isLoading = false;

  @override
  void dispose() {
    _workshopNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _createWorkshop() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await _workshopService.createWorkshop(
        _workshopNameController.text.trim(),
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
      );

      if (success && mounted) {
        // Panggil provider untuk refresh data user
        await Provider.of<AuthProvider>(context, listen: false).refreshUser();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bengkel berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat bengkel. Coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Profil Bengkel'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Lengkapi Profil Bengkel Anda',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Informasi ini akan digunakan untuk mengelola semua data Anda.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _workshopNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Bengkel',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama bengkel tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat Bengkel (Opsional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _createWorkshop,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan dan Lanjutkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
