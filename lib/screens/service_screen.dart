import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/customer_model.dart';
import '../models/spare_part_model.dart';
import '../models/work_order_model.dart';
import '../services/customer_service.dart';
import '../services/spare_part_service.dart';
import '../services/work_order_service.dart';
import '../providers/auth_provider.dart';
import 'package:uuid/uuid.dart';
import 'add_edit_customer_screen.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({Key? key}) : super(key: key);

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  final _serviceNameController = TextEditingController();
  final _serviceDescController = TextEditingController();
  final _servicePriceController = TextEditingController();

  CustomerModel? _selectedCustomer;
  List<SparePartModel> _selectedSpareParts = [];
  Map<String, int> _sparePartQty = {};

  final _sparePartService = SparePartService();
  final _workOrderService = WorkOrderService();

  bool _isLoading = false;
  Key _customerKey = UniqueKey();
  Key _sparePartKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final String workshopId =
        Provider.of<AuthProvider>(context, listen: false).user?.workshopId ??
            '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Kendaraan'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[50]!, Colors.blue[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.build_circle, size: 40, color: Colors.blue[600]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Service Kendaraan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Input data service dan spare part yang diganti',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Customer Selection Section
            _buildSectionHeader('Pilih Customer', Icons.person),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _CustomerAutocomplete(
                  key: _customerKey,
                  workshopId: workshopId,
                  selectedCustomer: _selectedCustomer,
                  onChanged: (customer) {
                    setState(() {
                      _selectedCustomer = customer;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Service Details Section
            _buildSectionHeader('Detail Jasa Service', Icons.build),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _serviceNameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Jasa Service',
                        hintText: 'Contoh: Ganti Oli, Service Mesin',
                        prefixIcon: const Icon(Icons.build),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _serviceDescController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Service',
                        hintText: 'Jelaskan detail pekerjaan yang dilakukan...',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _servicePriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga Jasa',
                        hintText: 'Rp 0',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Spare Parts Section
            _buildSectionHeader('Spare Part yang Diganti', Icons.inventory),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _SparePartAutocomplete(
                  key: _sparePartKey,
                  sparePartsStream: _sparePartService.getSpareParts(workshopId),
                  selectedSpareParts: _selectedSpareParts,
                  sparePartQty: _sparePartQty,
                  onChanged: (selected, qtyMap) {
                    setState(() {
                      _selectedSpareParts = selected;
                      _sparePartQty = qtyMap;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Menyimpan...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text(
                            'Simpan Service',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[600], size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Future<void> _saveService() async {
    final String workshopId =
        Provider.of<AuthProvider>(context, listen: false).user?.workshopId ??
            '';
    if (_selectedCustomer == null ||
        _serviceNameController.text.isEmpty ||
        _servicePriceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lengkapi data!')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final serviceItem = ServiceItem(
        id: const Uuid().v4(),
        name: _serviceNameController.text,
        price: double.tryParse(_servicePriceController.text) ?? 0,
        description: _serviceDescController.text,
      );
      final sparePartItems = _selectedSpareParts.map((sp) {
        final qty = _sparePartQty[sp.id] ?? 1;
        return SparePartItem(
          id: const Uuid().v4(),
          name: sp.name,
          sparePartId: sp.id,
          price: sp.sellPrice,
          quantity: qty,
          total: sp.sellPrice * qty,
        );
      }).toList();
      final serviceTotal = serviceItem.price;
      final sparePartTotal = sparePartItems.fold(
        0.0,
        (sum, item) => sum + item.total,
      );
      final totalAmount = serviceTotal + sparePartTotal;
      final workOrder = WorkOrder(
        id: '',
        workshopId: workshopId,
        customerId: _selectedCustomer!.id,
        customerName: _selectedCustomer!.name,
        customerPhone: _selectedCustomer!.phoneNumber,
        vehicleNumber: _selectedCustomer!.vehicleNumber ?? '',
        vehicleType: _selectedCustomer!.vehicleBrand ?? '',
        description: _serviceDescController.text,
        services: [serviceItem],
        spareParts: sparePartItems,
        serviceTotal: serviceTotal,
        sparePartTotal: sparePartTotal,
        totalAmount: totalAmount,
        status: 'dikerjakan',
        createdAt: DateTime.now(),
        updatedAt: null,
      );
      await _workOrderService.createWorkOrder(workOrder);
      // Update stok spare part
      for (final item in sparePartItems) {
        final sp = _selectedSpareParts.firstWhere(
          (s) => s.id == item.sparePartId,
        );
        final newStock = sp.stock - item.quantity;
        await _sparePartService.updateStock(sp.id, newStock);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi service berhasil disimpan!')),
      );
      setState(() {
        _selectedCustomer = null;
        _selectedSpareParts = [];
        _sparePartQty = {};
        _serviceNameController.clear();
        _serviceDescController.clear();
        _servicePriceController.clear();
        _customerKey = UniqueKey();
        _sparePartKey = UniqueKey();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal simpan: $e')));
    }
    setState(() => _isLoading = false);
  }
}

class _CustomerAutocomplete extends StatefulWidget {
  final String workshopId;
  final CustomerModel? selectedCustomer;
  final void Function(CustomerModel?) onChanged;

  const _CustomerAutocomplete({
    super.key,
    required this.workshopId,
    required this.selectedCustomer,
    required this.onChanged,
  });

  @override
  State<_CustomerAutocomplete> createState() => _CustomerAutocompleteState();
}

class _CustomerAutocompleteState extends State<_CustomerAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  final CustomerService _customerService = CustomerService();

  @override
  void initState() {
    super.initState();
    if (widget.selectedCustomer != null) {
      _controller.text = widget.selectedCustomer!.name;
    }
  }

  @override
  void didUpdateWidget(_CustomerAutocomplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCustomer != oldWidget.selectedCustomer) {
      if (widget.selectedCustomer == null) {
        _controller.clear();
      } else {
        _controller.text = widget.selectedCustomer!.name;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<CustomerModel>(
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<CustomerModel>.empty();
            }
            final customers =
                await _customerService.getCustomers(widget.workshopId).first;
            return customers.where(
              (customer) => customer.name.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
            );
          },
          displayStringForOption: (customer) => customer.name,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            _controller.text = controller.text;
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Cari customer berdasarkan nama...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addNewCustomer(),
                  tooltip: 'Tambah Customer Baru',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            );
          },
          onSelected: (CustomerModel customer) {
            setState(() {
              widget.onChanged(customer);
              _controller.text = customer.name;
            });
            // Sembunyikan keyboard setelah memilih customer
            FocusScope.of(context).unfocus();
          },
        ),
        if (widget.selectedCustomer != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedCustomer!.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.selectedCustomer!.address ??
                            'Alamat tidak tersedia',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        widget.selectedCustomer!.phoneNumber,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      widget.onChanged(null);
                      _controller.clear();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _addNewCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddEditCustomerScreen()),
    ).then((_) {
      // Refresh customer list if needed
      if (mounted) {
        setState(() {});
      }
    });
  }
}

class _SparePartAutocomplete extends StatefulWidget {
  final Stream<List<SparePartModel>> sparePartsStream;
  final List<SparePartModel> selectedSpareParts;
  final Map<String, int> sparePartQty;
  final void Function(List<SparePartModel>, Map<String, int>) onChanged;

  const _SparePartAutocomplete({
    super.key,
    required this.sparePartsStream,
    required this.selectedSpareParts,
    required this.sparePartQty,
    required this.onChanged,
  });

  @override
  State<_SparePartAutocomplete> createState() => _SparePartAutocompleteState();
}

class _SparePartAutocompleteState extends State<_SparePartAutocomplete> {
  final TextEditingController _controller = TextEditingController();
  List<SparePartModel> _allSpareParts = [];
  List<SparePartModel> _selected = [];
  Map<String, int> _qty = {};

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedSpareParts);
    _qty = Map.from(widget.sparePartQty);
  }

  @override
  void didUpdateWidget(_SparePartAutocomplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSpareParts != oldWidget.selectedSpareParts) {
      _selected = List.from(widget.selectedSpareParts);
      _qty = Map.from(widget.sparePartQty);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SparePartModel>>(
      stream: widget.sparePartsStream,
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

        _allSpareParts = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Autocomplete<SparePartModel>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable<SparePartModel>.empty();
                }
                return _allSpareParts.where(
                  (SparePartModel sp) =>
                      sp.name.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          ) &&
                      !_selected.any((s) => s.id == sp.id),
                );
              },
              displayStringForOption: (sp) => sp.name,
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                _controller.text = controller.text;
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
                  _selected.add(sp);
                  _qty[sp.id] = 1;
                  widget.onChanged(_selected, _qty);
                });
                _controller.clear();
                // Sembunyikan keyboard setelah memilih spare part
                FocusScope.of(context).unfocus();
              },
            ),
            const SizedBox(height: 16),
            if (_selected.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory, color: Colors.blue[600], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Spare Part Terpilih:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._selected.map(
                    (sp) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2,
                                    color: Colors.blue[600],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sp.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green[50],
                                              borderRadius:
                                                  BorderRadius.circular(
                                                4,
                                              ),
                                              border: Border.all(
                                                color: Colors.green[200]!,
                                              ),
                                            ),
                                            child: Text(
                                              'Stok: ${sp.stock}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.green[700],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Rp ${sp.sellPrice.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.orange[700],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selected
                                          .removeWhere((s) => s.id == sp.id);
                                      _qty.remove(sp.id);
                                      widget.onChanged(_selected, _qty);
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if ((_qty[sp.id] ?? 1) > 1) {
                                            _qty[sp.id] =
                                                (_qty[sp.id] ?? 1) - 1;
                                            widget.onChanged(_selected, _qty);
                                          }
                                        });
                                      },
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.blue[200]!,
                                        ),
                                      ),
                                      child: Text(
                                        '${_qty[sp.id] ?? 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.green,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          final currentQty = _qty[sp.id] ?? 1;
                                          if (currentQty < sp.stock) {
                                            _qty[sp.id] = currentQty + 1;
                                            widget.onChanged(_selected, _qty);
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Stok ${sp.name} hanya ${sp.stock} unit!',
                                                ),
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                Flexible(
                                  child: Text(
                                    'Total: Rp ${((_qty[sp.id] ?? 1) * sp.sellPrice).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.green,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}
