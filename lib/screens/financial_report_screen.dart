import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/dashboard_service.dart';
import 'package:intl/intl.dart';

class FinancialReportScreen extends StatefulWidget {
  const FinancialReportScreen({super.key});

  @override
  State<FinancialReportScreen> createState() => _FinancialReportScreenState();
}

class _FinancialReportScreenState extends State<FinancialReportScreen> {
  final DashboardService _dashboardService = DashboardService();
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _revenueHistory = [];
  bool _isLoading = true;
  bool _isLoadingHistory = false;
  String _selectedPeriod = 'today'; // today, week, month, year
  String _selectedHistoryPeriod = 'daily'; // daily, weekly, monthly, yearly

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadRevenueHistory();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final workshopId = authProvider.currentUser?.workshopId ?? '';
      if (workshopId.isNotEmpty) {
        final stats = await _dashboardService.getDashboardStats(workshopId);
        setState(() {
          _stats = stats;
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

  Future<void> _loadRevenueHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final workshopId = authProvider.currentUser?.workshopId ?? '';
      if (workshopId.isNotEmpty) {
        final history = await _dashboardService.getRevenueHistory(
            workshopId, _selectedHistoryPeriod);
        setState(() {
          _revenueHistory = history;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      setState(() => _isLoadingHistory = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
      }
    }
  }

  double _getRevenueForPeriod() {
    if (_stats == null) return 0.0;

    final monthlyRevenue =
        _stats?['monthlyRevenue'] as List<Map<String, dynamic>>? ?? [];
    final todayRevenue = _stats?['todayRevenue'] as double? ?? 0.0;
    final now = DateTime.now();

    switch (_selectedPeriod) {
      case 'today':
        return todayRevenue;
      case 'week':
        // Hitung pendapatan minggu ini dari data riwayat harian
        if (_revenueHistory.isNotEmpty && _selectedHistoryPeriod == 'daily') {
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6));

          double weekRevenue = 0.0;
          for (var data in _revenueHistory) {
            final date = data['date'] as DateTime? ?? DateTime.now();
            if (date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
                date.isBefore(weekEnd.add(const Duration(days: 1)))) {
              weekRevenue += (data['revenue'] as double?) ?? 0.0;
            }
          }
          return weekRevenue;
        } else {
          // Fallback ke perhitungan dari monthly revenue
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          double weekRevenue = 0.0;

          for (var data in monthlyRevenue) {
            final month = data['month'] as DateTime;
            if (month.year == now.year && month.month == now.month) {
              // Jika bulan ini, hitung per hari
              final monthStart = DateTime(now.year, now.month, 1);
              final monthEnd = DateTime(now.year, now.month + 1, 1);
              final daysInMonth = monthEnd.difference(monthStart).inDays;
              final dailyRevenue =
                  ((data['revenue'] as double?) ?? 0.0) / daysInMonth;

              // Hitung hari yang masuk dalam minggu ini
              for (int i = 0; i < 7; i++) {
                final day = weekStart.add(Duration(days: i));
                if (day.month == now.month) {
                  weekRevenue += dailyRevenue;
                }
              }
            }
          }
          return weekRevenue;
        }
      case 'month':
        final currentMonth = DateTime(now.year, now.month, 1);
        for (var data in monthlyRevenue) {
          final month = data['month'] as DateTime;
          if (month.year == currentMonth.year &&
              month.month == currentMonth.month) {
            return (data['revenue'] as double?) ?? 0.0;
          }
        }
        return 0.0;
      case 'year':
        double total = 0.0;
        for (var data in monthlyRevenue) {
          final month = data['month'] as DateTime;
          if (month.year == now.year) {
            total += (data['revenue'] as double?) ?? 0.0;
          }
        }
        return total;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadData();
              _loadRevenueHistory();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadData();
                await _loadRevenueHistory();
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 20),
                    _buildRevenueSummary(),
                    const SizedBox(height: 20),
                    _buildRevenueHistorySection(),
                    const SizedBox(height: 20),
                    _buildDetailedBreakdown(),
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
                const SizedBox(width: 8),
                Expanded(child: _buildPeriodChip('year', 'Tahun Ini')),
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
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[600],
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildRevenueSummary() {
    final revenue = _getRevenueForPeriod();
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Card(
      elevation: 3,
      color: Colors.green[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.trending_up, size: 48, color: Colors.green[600]),
            const SizedBox(height: 12),
            Text(
              'Total Pendapatan',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              formatter.format(revenue),
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700]),
            ),
            const SizedBox(height: 8),
            Text(_getPeriodText(),
                style: TextStyle(fontSize: 14, color: Colors.green[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueHistorySection() {
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
                const Text('Riwayat Pendapatan',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildHistoryPeriodSelector(),
            const SizedBox(height: 16),
            _buildRevenueHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryPeriodSelector() {
    return Row(
      children: [
        Expanded(child: _buildHistoryPeriodChip('daily', 'Harian')),
        const SizedBox(width: 8),
        Expanded(child: _buildHistoryPeriodChip('weekly', 'Mingguan')),
        const SizedBox(width: 8),
        Expanded(child: _buildHistoryPeriodChip('monthly', 'Bulanan')),
        const SizedBox(width: 8),
        Expanded(child: _buildHistoryPeriodChip('yearly', 'Tahunan')),
      ],
    );
  }

  Widget _buildHistoryPeriodChip(String period, String label) {
    final isSelected = _selectedHistoryPeriod == period;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedHistoryPeriod = period;
        });
        _loadRevenueHistory();
      },
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[600],
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildRevenueHistoryList() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_revenueHistory.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.history, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text('Belum ada data riwayat pendapatan',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }

    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final today = DateTime.now();

    // Urutkan data dari yang terbaru ke yang lama
    final sortedHistory = List<Map<String, dynamic>>.from(_revenueHistory);
    sortedHistory.sort((a, b) {
      final dateA = a['date'] as DateTime? ?? DateTime.now();
      final dateB = b['date'] as DateTime? ?? DateTime.now();
      return dateB.compareTo(dateA); // Terbaru di atas
    });

    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: sortedHistory.length,
        itemBuilder: (context, index) {
          final data = sortedHistory[index];
          final revenue = (data['revenue'] as double?) ?? 0.0;
          final label = data['label'] as String? ?? '';
          final date = data['date'] as DateTime? ?? DateTime.now();

          // Cek apakah ini hari ini
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isToday ? Colors.blue[50] : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: isToday
                  ? BorderSide(color: Colors.blue[300]!, width: 2)
                  : BorderSide.none,
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isToday ? Colors.blue[200] : Colors.blue[100],
                child: Icon(isToday ? Icons.today : Icons.attach_money,
                    color: isToday ? Colors.blue[700] : Colors.blue[600]),
              ),
              title: Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isToday ? Colors.blue[700] : null,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[600],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'HARI INI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                DateFormat('dd MMM yyyy').format(date),
                style: TextStyle(
                    color: isToday ? Colors.blue[600] : Colors.grey[600]),
              ),
              trailing: Text(
                formatter.format(revenue),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: revenue > 0
                      ? (isToday ? Colors.blue[700] : Colors.green[600])
                      : Colors.grey[600],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getPeriodText() {
    switch (_selectedPeriod) {
      case 'today':
        return 'Hari Ini';
      case 'week':
        return 'Minggu Ini';
      case 'month':
        return 'Bulan Ini';
      case 'year':
        return 'Tahun Ini';
      default:
        return '';
    }
  }

  Widget _buildDetailedBreakdown() {
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
                Icon(Icons.analytics, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text('Rincian Pendapatan',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildBreakdownItem(
                'Work Orders',
                _stats?['workOrderCount']?.toString() ?? '0',
                'transaksi',
                Icons.assignment,
                Colors.blue),
            const SizedBox(height: 8),
            _buildBreakdownItem(
                'Spare Part Sales',
                _stats?['sparePartPurchased']?.toString() ?? '0',
                'item terjual',
                Icons.shopping_cart,
                Colors.green),
            const SizedBox(height: 8),
            _buildBreakdownItem(
                'Total Customers',
                _stats?['customerCount']?.toString() ?? '0',
                'pelanggan',
                Icons.people,
                Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(
      String title, String value, String unit, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('$value $unit',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
