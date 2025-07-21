import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/customer_service.dart';
import '../models/customer_model.dart';

class AddEditCustomerScreen extends StatefulWidget {
  final CustomerModel? customer;

  const AddEditCustomerScreen({super.key, this.customer});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _vehicleBrandController = TextEditingController();

  final CustomerService _customerService = CustomerService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phoneNumber;
      _addressController.text = widget.customer!.address ?? '';
      _vehicleNumberController.text = widget.customer!.vehicleNumber ?? '';
      _vehicleBrandController.text = widget.customer!.vehicleBrand ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _vehicleNumberController.dispose();
    _vehicleBrandController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthProvider>().user;
      final workshopId = user?.workshopId;

      if (workshopId != null) {
        final customerData = CustomerModel(
          id: widget.customer?.id ?? '',
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
          vehicleNumber: _vehicleNumberController.text.trim().isNotEmpty
              ? _vehicleNumberController.text.trim()
              : null,
          vehicleBrand: _vehicleBrandController.text.trim().isNotEmpty
              ? _vehicleBrandController.text.trim()
              : null,
          workshopId: workshopId,
          createdAt: widget.customer?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.customer != null) {
          await _customerService.updateCustomer(customerData);
        } else {
          await _customerService.addCustomer(customerData);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.customer != null
                    ? 'Pelanggan berhasil diperbarui'
                    : 'Pelanggan berhasil ditambahkan',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.customer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Pelanggan' : 'Tambah Pelanggan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        isEditing ? Icons.edit : Icons.person_add,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isEditing
                            ? 'Edit Data Pelanggan'
                            : 'Tambah Pelanggan Baru',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lengkapi informasi pelanggan di bawah ini',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Nama Lengkap
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Masukkan nama lengkap pelanggan',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama pelanggan wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nomor Telepon
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: 'Contoh: 081234567890',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Alamat
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Masukkan alamat lengkap',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Nomor Kendaraan
              TextFormField(
                controller: _vehicleNumberController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Kendaraan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.directions_car),
                  hintText: 'Contoh: B 1234 ABC',
                ),
              ),
              const SizedBox(height: 16),

              // Jenis Kendaraan
              TextFormField(
                controller: _vehicleBrandController,
                decoration: const InputDecoration(
                  labelText: 'Jenis Kendaraan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                  hintText: 'Contoh: Honda Vario, Yamaha NMAX',
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveCustomer,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(isEditing ? Icons.save : Icons.add),
                label: Text(_isLoading
                    ? 'Menyimpan...'
                    : (isEditing ? 'Simpan Perubahan' : 'Tambah Pelanggan')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Batal
              OutlinedButton(
                onPressed:
                    _isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Batal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
