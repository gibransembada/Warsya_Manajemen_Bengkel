import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/spare_part_service.dart';
import '../models/spare_part_model.dart';

class AddEditSparePartScreen extends StatefulWidget {
  final SparePartModel? sparePart;

  const AddEditSparePartScreen({super.key, this.sparePart});

  @override
  State<AddEditSparePartScreen> createState() => _AddEditSparePartScreenState();
}

class _AddEditSparePartScreenState extends State<AddEditSparePartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _stockController = TextEditingController();

  final SparePartService _sparePartService = SparePartService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.sparePart != null) {
      _nameController.text = widget.sparePart!.name;
      _codeController.text = widget.sparePart!.code;
      _descriptionController.text = widget.sparePart!.description ?? '';
      _buyPriceController.text = widget.sparePart!.buyPrice.toString();
      _sellPriceController.text = widget.sparePart!.sellPrice.toString();
      _stockController.text = widget.sparePart!.stock.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _saveSparePart() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = context.read<AuthProvider>().user;
      final workshopId = user?.workshopId;

      if (workshopId != null) {
        final buyPrice = double.tryParse(_buyPriceController.text) ?? 0.0;
        final sellPrice = double.tryParse(_sellPriceController.text) ?? 0.0;
        final stock = int.tryParse(_stockController.text) ?? 0;

        final sparePartData = SparePartModel(
          id: widget.sparePart?.id ?? '',
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          description: _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          buyPrice: buyPrice,
          sellPrice: sellPrice,
          stock: stock,
          workshopId: workshopId,
          createdAt: widget.sparePart?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (widget.sparePart != null) {
          await _sparePartService.updateSparePart(sparePartData);
        } else {
          await _sparePartService.addSparePart(sparePartData);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.sparePart != null
                    ? 'Spare part berhasil diperbarui'
                    : 'Spare part berhasil ditambahkan',
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
    final isEditing = widget.sparePart != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Spare Part' : 'Tambah Spare Part'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
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
                        isEditing ? Icons.edit : Icons.inventory,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isEditing
                            ? 'Edit Data Spare Part'
                            : 'Tambah Spare Part Baru',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lengkapi informasi spare part di bawah ini',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Nama Spare Part
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Spare Part *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                  hintText: 'Contoh: Kampas Rem Depan',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama spare part wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kode Spare Part
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Spare Part *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                  hintText: 'Contoh: KR001, OLI002',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode spare part wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deskripsi
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                  hintText: 'Deskripsi detail spare part (opsional)',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Harga Beli
              TextFormField(
                controller: _buyPriceController,
                decoration: const InputDecoration(
                  labelText: 'Harga Beli *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_cart),
                  prefixText: 'Rp ',
                  hintText: 'Contoh: 50000',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga beli wajib diisi';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Harga Jual
              TextFormField(
                controller: _sellPriceController,
                decoration: const InputDecoration(
                  labelText: 'Harga Jual *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: 'Rp ',
                  hintText: 'Contoh: 75000',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga jual wajib diisi';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Stok
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stok *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory_2),
                  hintText: 'Contoh: 10',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Stok wajib diisi';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Stok harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveSparePart,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Icon(isEditing ? Icons.save : Icons.add),
                label: Text(_isLoading
                    ? 'Menyimpan...'
                    : (isEditing ? 'Simpan Perubahan' : 'Tambah Spare Part')),
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
