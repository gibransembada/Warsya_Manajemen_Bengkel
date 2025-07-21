import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/auth_provider.dart';
import '../services/spare_part_service.dart';
import '../services/work_order_service.dart';
import '../services/spare_part_purchase_service.dart';
import '../models/spare_part_model.dart';
import 'package:intl/intl.dart';

class SparePartDashboardScreen extends StatefulWidget {
  const SparePartDashboardScreen({super.key});

  @override
  State<SparePartDashboardScreen> createState() =>
      _SparePartDashboardScreenState();
}

class _SparePartDashboardScreenState extends State<SparePartDashboardScreen> {
  final SparePartService _sparePartService = SparePartService();
  final WorkOrderService _workOrderService = WorkOrderService();
  final SparePartPurchaseService _purchaseService = SparePartPurchaseService();
  List<SparePartModel> _spareParts = [];
  List<Map<String, dynamic>> _salesHistory = [];
  bool _isLoading = true;
  String _selectedPeriod = 'today'; // today, week, month

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final workshopId = authProvider.currentUser?.workshopId ?? '';

      if (workshopId.isNotEmpty) {
        // Load spare parts
        final sparePartsStream = _sparePartService.getSpareParts(workshopId);
        final spareParts = await sparePartsStream.first;

        // Load sales history dari work orders dan spare part purchases
        final salesHistory = await _getSalesHistory(workshopId);

        setState(() {
          _spareParts = spareParts;
          _salesHistory = salesHistory;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getSalesHistory(String workshopId) async {
    List<Map<String, dynamic>> salesHistory = [];

    try {
      // 1. Ambil data dari work orders yang sudah dibayar
      final workOrdersSnapshot =
          await _workOrderService.getWorkOrdersStream(workshopId).first;
      final paidWorkOrders =
          workOrdersSnapshot.where((wo) => wo.status == 'dibayar').toList();

      for (final workOrder in paidWorkOrders) {
        for (final sparePart in workOrder.spareParts) {
          salesHistory.add({
            'date': workOrder.createdAt,
            'sparePartId': sparePart.sparePartId,
            'sparePartName': sparePart.name,
            'quantity': sparePart.quantity,
            'revenue': sparePart.total,
            'source': 'work_order',
            'workOrderId': workOrder.id,
            'customerName': workOrder.customerName,
          });
        }
      }

      // 2. Ambil data dari spare part purchases (penjualan langsung)
      final purchasesSnapshot =
          await _purchaseService.getPurchaseHistoryStream(workshopId).first;

      for (final purchase in purchasesSnapshot) {
        for (final item in purchase.items) {
          salesHistory.add({
            'date': purchase.createdAt,
            'sparePartId': item.sparePartId,
            'sparePartName': item.name,
            'quantity': item.quantity,
            'revenue': item.total,
            'source': 'direct_sale',
            'purchaseId': purchase.id,
            'customerName': purchase.customerName,
          });
        }
      }

      // Filter berdasarkan periode yang dipilih
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      switch (_selectedPeriod) {
        case 'today':
          salesHistory = salesHistory.where((sale) {
            final saleDate = DateTime(
                sale['date'].year, sale['date'].month, sale['date'].day);
            return saleDate.isAtSameMomentAs(today);
          }).toList();
          break;
        case 'week':
          final weekAgo = today.subtract(const Duration(days: 7));
          salesHistory = salesHistory.where((sale) {
            return sale['date'].isAfter(weekAgo);
          }).toList();
          break;
        case 'month':
          final monthAgo = DateTime(now.year, now.month - 1, now.day);
          salesHistory = salesHistory.where((sale) {
            return sale['date'].isAfter(monthAgo);
          }).toList();
          break;
      }

      // Urutkan berdasarkan tanggal terbaru
      salesHistory.sort((a, b) => b['date'].compareTo(a['date']));
    } catch (e) {
      debugPrint('Error getting sales history: $e');
    }

    return salesHistory;
  }

  List<Map<String, dynamic>> _getTopSellingSpareParts() {
    final Map<String, Map<String, dynamic>> aggregated = {};

    for (final sale in _salesHistory) {
      final sparePartId = sale['sparePartId'] as String;
      final sparePartName = sale['sparePartName'] as String;
      final quantity = sale['quantity'] as int;
      final revenue = (sale['revenue'] as num).toDouble();

      if (aggregated.containsKey(sparePartId)) {
        aggregated[sparePartId]!['quantity'] =
            (aggregated[sparePartId]!['quantity'] as int) + quantity;
        aggregated[sparePartId]!['revenue'] =
            (aggregated[sparePartId]!['revenue'] as double) + revenue;
      } else {
        aggregated[sparePartId] = {
          'name': sparePartName,
          'quantity': quantity,
          'revenue': revenue,
        };
      }
    }

    final sorted = aggregated.values.toList()
      ..sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));

    return sorted.take(5).toList();
  }

  List<SparePartModel> _getLowStockSpareParts() {
    return _spareParts
        .where((sp) => sp.stock <= 10) // Stok <= 10 dianggap low stock
        .toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spare Part'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 20),
                    _buildSummaryCards(),
                    const SizedBox(height: 20),
                    _buildTopSellingSection(),
                    const SizedBox(height: 20),
                    _buildLowStockSection(),
                    const SizedBox(height: 20),
                    _buildSalesChart(),
                    const SizedBox(height: 20),
                    _buildSalesHistorySection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Periode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildPeriodChip('today', 'Hari Ini')),
                const SizedBox(width: 8),
                Expanded(child: _buildPeriodChip('week', 'Minggu Ini')),
                const SizedBox(width: 8),
                Expanded(child: _buildPeriodChip('month', 'Bulan Ini')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPeriod = period;
        });
        _loadData(); // Reload data ketika periode berubah
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[600],
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildSummaryCards() {
    final totalSpareParts = _spareParts.length;
    final lowStockCount = _getLowStockSpareParts().length;
    final totalRevenue = _salesHistory.fold<double>(
        0, (sum, sale) => sum + (sale['revenue'] as num).toDouble());
    final totalQuantity = _salesHistory.fold<int>(
        0, (sum, sale) => sum + (sale['quantity'] as int));

    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildSummaryCard(
              'Total Spare Part',
              totalSpareParts.toString(),
              Icons.inventory_2,
              Colors.blue,
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _buildSummaryCard(
              'Stok Menipis',
              lowStockCount.toString(),
              Icons.warning,
              Colors.orange,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _buildSummaryCard(
              'Total Penjualan',
              '$totalQuantity unit',
              Icons.shopping_cart,
              Colors.green,
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _buildSummaryCard(
              'Total Revenue',
              'Rp ${NumberFormat('#,###').format(totalRevenue)}',
              Icons.attach_money,
              Colors.purple,
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellingSection() {
    final topSelling = _getTopSellingSpareParts();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  'Spare Part Paling Laku',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (topSelling.isEmpty)
              const Center(
                child: Text('Belum ada data penjualan'),
              )
            else
              ...topSelling.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(item['name']),
                  subtitle: Text('${item['quantity']} unit terjual'),
                  trailing: Text(
                    'Rp ${NumberFormat('#,###').format(item['revenue'])}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockSection() {
    final lowStockItems = _getLowStockSpareParts();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[600]),
                const SizedBox(width: 8),
                const Text(
                  'Stok Menipis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (lowStockItems.isEmpty)
              const Center(
                child: Text('Semua stok aman'),
              )
            else
              ...lowStockItems.take(5).map((sparePart) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: sparePart.stock <= 0
                          ? Colors.red[100]
                          : Colors.orange[100],
                      child: Icon(
                        Icons.inventory_2,
                        color: sparePart.stock <= 0
                            ? Colors.red[600]
                            : Colors.orange[600],
                      ),
                    ),
                    title: Text(sparePart.name),
                    subtitle: Text('Kode: ${sparePart.code}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            sparePart.stock <= 0 ? Colors.red : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${sparePart.stock} unit',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    final topSelling = _getTopSellingSpareParts();

    if (topSelling.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grafik Penjualan Spare Part',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: topSelling.isNotEmpty
                      ? topSelling.first['quantity'].toDouble() * 1.2
                      : 10,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < topSelling.length) {
                            final name =
                                topSelling[value.toInt()]['name'] as String;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                name.length > 8
                                    ? '${name.substring(0, 8)}...'
                                    : name,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: topSelling.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: item['quantity'].toDouble(),
                          color: Colors.blue[600],
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesHistorySection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Riwayat Penjualan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_salesHistory.isEmpty)
              const Center(
                child: Text('Belum ada riwayat penjualan'),
              )
            else
              ..._salesHistory.take(10).map((sale) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: sale['source'] == 'work_order'
                          ? Colors.green[100]
                          : Colors.blue[100],
                      child: Icon(
                        sale['source'] == 'work_order'
                            ? Icons.build
                            : Icons.shopping_cart,
                        color: sale['source'] == 'work_order'
                            ? Colors.green[600]
                            : Colors.blue[600],
                      ),
                    ),
                    title: Text(sale['sparePartName']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${sale['quantity']} unit - ${DateFormat('dd/MM/yyyy').format(sale['date'])}',
                        ),
                        Text(
                          '${sale['customerName']} (${sale['source'] == 'work_order' ? 'Work Order' : 'Penjualan Langsung'})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      'Rp ${NumberFormat('#,###').format(sale['revenue'])}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
