import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/spare_part_model.dart';
import '../models/spare_part_purchase_model.dart';
import '../services/spare_part_service.dart';
import '../services/spare_part_purchase_service.dart';
import '../providers/auth_provider.dart';

class SparePartPurchaseScreen extends StatefulWidget {
  const SparePartPurchaseScreen({Key? key}) : super(key: key);

  @override
  State<SparePartPurchaseScreen> createState() =>
      _SparePartPurchaseScreenState();
}

class _SparePartPurchaseScreenState extends State<SparePartPurchaseScreen> {
  final SparePartService _sparePartService = SparePartService();
  final SparePartPurchaseService _purchaseService = SparePartPurchaseService();
  final TextEditingController _searchController = TextEditingController();
  final List<SparePartModel> _cart = [];
  final Map<String, int> _cartQty = {};
  bool _isLoading = false;
  String _workshopId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _workshopId = authProvider.currentUser?.workshopId ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beli Spare Part'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pushNamed(context, '/spare-part-purchase-history');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Autocomplete<SparePartModel>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty) return [];
                    final all = await _sparePartService
                        .getSpareParts(_workshopId)
                        .first;
                    return all
                        .where((sp) =>
                            sp.name.toLowerCase().contains(
                                textEditingValue.text.toLowerCase()) &&
                            sp.stock > 0)
                        .toList();
                  },
                  displayStringForOption: (sp) => sp.name,
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'Cari spare part... (min. 1 karakter)',
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                      ),
                      style: const TextStyle(fontSize: 16),
                    );
                  },
                  onSelected: (SparePartModel sp) {
                    setState(() {
                      if (!_cart.any((item) => item.id == sp.id)) {
                        _cart.add(sp);
                        _cartQty[sp.id] = 1;
                      }
                      _searchController.clear();
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('Keranjang kosong',
                            style: TextStyle(fontSize: 18, color: Colors.grey)),
                        const SizedBox(height: 8),
                        const Text('Cari dan tambahkan spare part ke keranjang',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _cart.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final sp = _cart[i];
                      final qty = _cartQty[sp.id] ?? 1;
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: sp.stock > 0
                                      ? Colors.green[50]
                                      : Colors.red[50],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.inventory_2,
                                    color: sp.stock > 0
                                        ? Colors.green
                                        : Colors.red,
                                    size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(sp.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text(
                                        'Harga: Rp ${sp.sellPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 13)),
                                    Text('Stok: ${sp.stock}',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: sp.stock > 0
                                                ? Colors.green
                                                : Colors.red)),
                                    const SizedBox(height: 2),
                                    Text(
                                        'Subtotal: Rp ${(sp.sellPrice * qty).toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        size: 28),
                                    onPressed: qty > 1
                                        ? () {
                                            setState(() {
                                              _cartQty[sp.id] = qty - 1;
                                            });
                                          }
                                        : null,
                                  ),
                                  Container(
                                    width: 36,
                                    alignment: Alignment.center,
                                    child: Text('$qty',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  IconButton(
                                    icon:
                                        const Icon(Icons.add_circle, size: 28),
                                    onPressed: qty < sp.stock
                                        ? () {
                                            setState(() {
                                              _cartQty[sp.id] = qty + 1;
                                            });
                                          }
                                        : null,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _cart.removeAt(i);
                                        _cartQty.remove(sp.id);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_cart.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        'Rp ${_cart.fold<double>(0, (sum, sp) => sum + (sp.sellPrice * (_cartQty[sp.id] ?? 1))).toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blue),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _checkout,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check),
                    label:
                        const Text('Checkout', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _checkout() async {
    setState(() => _isLoading = true);
    try {
      // Unfocus untuk menghilangkan keyboard
      FocusScope.of(context).unfocus();

      final total = _cart.fold<double>(
          0, (sum, sp) => sum + (sp.sellPrice * (_cartQty[sp.id] ?? 1)));

      final items = _cart
          .map((sp) => PurchaseItem(
                id: const Uuid().v4(),
                sparePartId: sp.id,
                name: sp.name,
                price: sp.sellPrice,
                quantity: _cartQty[sp.id] ?? 1,
                total: sp.sellPrice * (_cartQty[sp.id] ?? 1),
              ))
          .toList();

      final purchase = SparePartPurchase(
        id: '',
        workshopId: _workshopId,
        customerId: null,
        customerName: null,
        customerPhone: null,
        items: items,
        total: total,
        createdAt: DateTime.now(),
        transactionNumber: '', // Akan di-generate otomatis oleh service
      );

      await _purchaseService.createPurchase(purchase);

      // Update stok
      for (final sp in _cart) {
        final newStock = sp.stock - (_cartQty[sp.id] ?? 1);
        await _sparePartService.updateStock(sp.id, newStock);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pembelian berhasil!')),
      );

      setState(() {
        _cart.clear();
        _cartQty.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal checkout: $e')),
      );
    }
    setState(() => _isLoading = false);
  }
}
