import 'package:flutter/material.dart';
import '../models/work_order_model.dart';
import '../models/spare_part_model.dart';
import '../services/work_order_service.dart';
import '../services/spare_part_service.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class EditWorkOrderScreen extends StatefulWidget {
  final WorkOrder workOrder;

  const EditWorkOrderScreen({
    Key? key,
    required this.workOrder,
  }) : super(key: key);

  @override
  State<EditWorkOrderScreen> createState() => _EditWorkOrderScreenState();
}

class _EditWorkOrderScreenState extends State<EditWorkOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final WorkOrderService _workOrderService = WorkOrderService();
  final SparePartService _sparePartService = SparePartService();

  late TextEditingController _descriptionController;
  late List<ServiceItem> _services;
  late List<SparePartItem> _spareParts;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.workOrder.description);
    _services = List.from(widget.workOrder.services);
    _spareParts = List.from(widget.workOrder.spareParts);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Work Order'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveChanges,
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informasi Pelanggan (Read-only)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Pelanggan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                                'Nama', widget.workOrder.customerName),
                            _buildInfoRow(
                                'Telepon', widget.workOrder.customerPhone),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Informasi Kendaraan (Read-only)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Kendaraan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                                'Jenis', widget.workOrder.vehicleType),
                            _buildInfoRow(
                                'Nomor', widget.workOrder.vehicleNumber),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi (Editable)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Deskripsi Pekerjaan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Masukkan deskripsi pekerjaan...',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Daftar Jasa (Editable)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Daftar Jasa',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _addService,
                                  icon: const Icon(Icons.add),
                                  tooltip: 'Tambah Jasa',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _services.length,
                              itemBuilder: (context, index) {
                                return _buildServiceItem(index);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Daftar Spare Part (Editable)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Daftar Spare Part',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _addSparePart,
                                  icon: const Icon(Icons.add),
                                  tooltip: 'Tambah Spare Part',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildSparePartAutocomplete(),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _spareParts.length,
                              itemBuilder: (context, index) {
                                return _buildSparePartItem(index);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSparePartAutocomplete() {
    final String workshopId =
        Provider.of<AuthProvider>(context, listen: false).user?.workshopId ??
            '';

    return StreamBuilder<List<SparePartModel>>(
      stream: _sparePartService.getSpareParts(workshopId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Terjadi kesalahan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Trigger rebuild
                    });
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        final allSpareParts = snapshot.data ?? [];
        final availableSpareParts = allSpareParts
            .where((sp) =>
                !_spareParts.any((selected) => selected.sparePartId == sp.id))
            .toList();

        return Autocomplete<SparePartModel>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<SparePartModel>.empty();
            }
            return availableSpareParts.where(
              (sp) => sp.name.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
            );
          },
          displayStringForOption: (sp) => sp.name,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Cari & pilih spare part...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            );
          },
          onSelected: (SparePartModel sp) {
            setState(() {
              _spareParts.add(SparePartItem(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: sp.name,
                sparePartId: sp.id,
                price: sp.sellPrice,
                quantity: 1,
                total: sp.sellPrice,
              ));
            });
          },
        );
      },
    );
  }

  Widget _buildServiceItem(int index) {
    final service = _services[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: service.name,
                    decoration: const InputDecoration(
                      labelText: 'Nama Jasa',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _services[index] = ServiceItem(
                        id: service.id,
                        name: value,
                        price: service.price,
                        description: service.description,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextFormField(
                    initialValue: service.price.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final price = double.tryParse(value) ?? 0;
                      _services[index] = ServiceItem(
                        id: service.id,
                        name: service.name,
                        price: price,
                        description: service.description,
                      );
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => _removeService(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Hapus Jasa',
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: service.description ?? '',
              decoration: const InputDecoration(
                labelText: 'Deskripsi (Opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                _services[index] = ServiceItem(
                  id: service.id,
                  name: service.name,
                  price: service.price,
                  description: value.isEmpty ? null : value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSparePartItem(int index) {
    final sparePart = _spareParts[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: sparePart.name,
                    decoration: const InputDecoration(
                      labelText: 'Nama Spare Part',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      final total = (sparePart.price * sparePart.quantity);
                      _spareParts[index] = SparePartItem(
                        id: sparePart.id,
                        name: value,
                        sparePartId: sparePart.sparePartId,
                        price: sparePart.price,
                        quantity: sparePart.quantity,
                        total: total,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    initialValue: sparePart.price.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      border: OutlineInputBorder(),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final price = double.tryParse(value) ?? 0;
                      final total = (price * sparePart.quantity);
                      _spareParts[index] = SparePartItem(
                        id: sparePart.id,
                        name: sparePart.name,
                        sparePartId: sparePart.sparePartId,
                        price: price,
                        quantity: sparePart.quantity,
                        total: total,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: sparePart.quantity.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final quantity = int.tryParse(value) ?? 1;
                      final total = (sparePart.price * quantity);
                      _spareParts[index] = SparePartItem(
                        id: sparePart.id,
                        name: sparePart.name,
                        sparePartId: sparePart.sparePartId,
                        price: sparePart.price,
                        quantity: quantity,
                        total: total,
                      );
                    },
                  ),
                ),
                IconButton(
                  onPressed: () => _removeSparePart(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Hapus Spare Part',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Total: Rp ${sparePart.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addService() {
    setState(() {
      _services.add(ServiceItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
        price: 0,
        description: '',
      ));
    });
  }

  void _addSparePart() {
    setState(() {
      _spareParts.add(SparePartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '',
        sparePartId: '',
        price: 0,
        quantity: 1,
        total: 0,
      ));
    });
  }

  void _removeService(int index) {
    setState(() {
      _services.removeAt(index);
    });
  }

  void _removeSparePart(int index) {
    setState(() {
      _spareParts.removeAt(index);
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Hitung total baru
      final serviceTotal =
          _services.fold<double>(0, (sum, service) => sum + service.price);
      final sparePartTotal = _spareParts.fold<double>(
          0, (sum, sparePart) => sum + sparePart.total);
      final totalAmount = serviceTotal + sparePartTotal;

      // Buat work order yang diupdate
      final updatedWorkOrder = WorkOrder(
        id: widget.workOrder.id,
        workshopId: widget.workOrder.workshopId,
        customerId: widget.workOrder.customerId,
        customerName: widget.workOrder.customerName,
        customerPhone: widget.workOrder.customerPhone,
        vehicleNumber: widget.workOrder.vehicleNumber,
        vehicleType: widget.workOrder.vehicleType,
        description: _descriptionController.text,
        services: _services,
        spareParts: _spareParts,
        serviceTotal: serviceTotal,
        sparePartTotal: sparePartTotal,
        totalAmount: totalAmount,
        status: widget.workOrder.status,
        createdAt: widget.workOrder.createdAt,
        updatedAt: DateTime.now(),
      );

      final success = await _workOrderService.updateWorkOrder(updatedWorkOrder);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Work Order berhasil diupdate')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengupdate Work Order')),
        );
      }
    } catch (e) {
      debugPrint('Error updating work order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
