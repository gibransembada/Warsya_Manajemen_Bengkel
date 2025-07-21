import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/work_order_model.dart';
import '../services/work_order_service.dart';
import '../providers/auth_provider.dart';
import 'work_order_detail_screen.dart';

class WorkOrdersScreen extends StatefulWidget {
  const WorkOrdersScreen({Key? key}) : super(key: key);

  @override
  State<WorkOrdersScreen> createState() => _WorkOrdersScreenState();
}

class _WorkOrdersScreenState extends State<WorkOrdersScreen> {
  final WorkOrderService _workOrderService = WorkOrderService();
  String _selectedStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final workshopId = authProvider.currentUser?.workshopId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Orders'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final workshopId = authProvider.currentUser?.workshopId ?? '';
              if (workshopId.isNotEmpty) {
                final success =
                    await _workOrderService.fixWorkOrderStatuses(workshopId);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Status work order berhasil diperbaiki')),
                  );
                }
              }
            },
            tooltip: 'Perbaiki Status',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Status
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filter: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', 'Semua'),
                        const SizedBox(width: 8),
                        _buildFilterChip('pending', 'Pending'),
                        const SizedBox(width: 8),
                        _buildFilterChip('dikerjakan', 'Dikerjakan'),
                        const SizedBox(width: 8),
                        _buildFilterChip('selesai', 'Selesai'),
                        const SizedBox(width: 8),
                        _buildFilterChip('dibayar', 'Dibayar'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daftar Work Order
          Expanded(
            child: StreamBuilder<List<WorkOrder>>(
              stream: _selectedStatus == 'all'
                  ? _workOrderService.getWorkOrdersStream(workshopId)
                  : _workOrderService.getWorkOrdersByStatus(
                      workshopId, _selectedStatus),
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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${snapshot.error}',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
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

                final workOrders = snapshot.data ?? [];

                if (workOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assignment,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _selectedStatus == 'all'
                              ? 'Belum ada work order'
                              : 'Tidak ada work order dengan status $_selectedStatus',
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: workOrders.length,
                  itemBuilder: (context, index) {
                    final workOrder = workOrders[index];
                    return _buildWorkOrderCard(workOrder);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status, String label) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = status;
        });
      },
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildWorkOrderCard(WorkOrder workOrder) {
    Color statusColor;
    String statusText;

    switch (workOrder.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pending';
        break;
      case 'dikerjakan':
        statusColor = Colors.blue;
        statusText = 'Dikerjakan';
        break;
      case 'selesai':
        statusColor = Colors.green;
        statusText = 'Selesai';
        break;
      case 'dibayar':
        statusColor = Colors.purple;
        statusText = 'Dibayar';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(
              child: Text(
                workOrder.customerName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
                'Kendaraan: ${workOrder.vehicleType} - ${workOrder.vehicleNumber}'),
            Text('Total: Rp ${workOrder.totalAmount.toStringAsFixed(0)}'),
            Text(
              'Tanggal: ${_formatDate(workOrder.createdAt)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkOrderDetailScreen(workOrder: workOrder),
            ),
          );
        },
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    super.dispose();
  }
}
