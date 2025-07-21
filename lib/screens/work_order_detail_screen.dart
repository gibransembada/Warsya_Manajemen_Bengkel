import 'package:flutter/material.dart';
import '../models/work_order_model.dart';
import '../services/work_order_service.dart';
import 'edit_work_order_screen.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class WorkOrderDetailScreen extends StatefulWidget {
  final WorkOrder workOrder;

  const WorkOrderDetailScreen({Key? key, required this.workOrder})
      : super(key: key);

  @override
  State<WorkOrderDetailScreen> createState() => _WorkOrderDetailScreenState();
}

class _WorkOrderDetailScreenState extends State<WorkOrderDetailScreen> {
  final WorkOrderService _workOrderService = WorkOrderService();
  bool _isUpdatingStatus = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Work Order'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              await _shareWorkOrder();
            },
            tooltip: 'Bagikan Nota',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              await _printWorkOrder(context);
            },
            tooltip: 'Cetak Nota',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Hapus', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
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
                          'Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildStatusChip(widget.workOrder.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (widget.workOrder.status != 'dibayar')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isUpdatingStatus
                              ? null
                              : _showStatusUpdateDialog,
                          child: _isUpdatingStatus
                              ? const CircularProgressIndicator()
                              : const Text('Update Status'),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informasi Pelanggan
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
                    _buildInfoRow('Nama', widget.workOrder.customerName),
                    _buildInfoRow('Telepon', widget.workOrder.customerPhone),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informasi Kendaraan
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
                    _buildInfoRow('Jenis', widget.workOrder.vehicleType),
                    _buildInfoRow('Nomor', widget.workOrder.vehicleNumber),
                    _buildInfoRow('Deskripsi', widget.workOrder.description),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Daftar Item
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daftar Item',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.workOrder.services.length +
                          widget.workOrder.spareParts.length,
                      itemBuilder: (context, index) {
                        if (index < widget.workOrder.services.length) {
                          final service = widget.workOrder.services[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                service.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: service.description != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        service.description!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    )
                                  : null,
                              trailing: Text(
                                'Rp ${service.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          );
                        } else {
                          final sparePartIndex =
                              index - widget.workOrder.services.length;
                          final sparePart =
                              widget.workOrder.spareParts[sparePartIndex];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                sparePart.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Qty: ${sparePart.quantity} x Rp ${sparePart.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              trailing: Text(
                                'Rp ${sparePart.total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Jasa:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${widget.workOrder.serviceTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Spare Part:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${widget.workOrder.sparePartTotal.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Keseluruhan:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp ${widget.workOrder.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informasi Tambahan
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Tambahan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Tanggal Dibuat',
                      _formatDate(widget.workOrder.createdAt),
                    ),
                    if (widget.workOrder.updatedAt != null)
                      _buildInfoRow(
                        'Terakhir Diupdate',
                        _formatDate(widget.workOrder.updatedAt!),
                      ),
                    _buildInfoRow('ID Work Order', widget.workOrder.id),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      case 'dikerjakan':
        color = Colors.blue;
        text = 'Dikerjakan';
        break;
      case 'selesai':
        color = Colors.green;
        text = 'Selesai';
        break;
      case 'dibayar':
        color = Colors.purple;
        text = 'Dibayar';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
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
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showStatusUpdateDialog() {
    final currentStatus = widget.workOrder.status;
    String? selectedStatus;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih status baru:'),
              const SizedBox(height: 16),
              ...['pending', 'dikerjakan', 'selesai', 'dibayar'].map((status) {
                return RadioListTile<String>(
                  title: Text(_getStatusText(status)),
                  value: status,
                  groupValue: selectedStatus ?? currentStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedStatus != null && selectedStatus != currentStatus) {
                Navigator.pop(context);
                _updateStatus(selectedStatus!);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'dikerjakan':
        return 'Dikerjakan';
      case 'selesai':
        return 'Selesai';
      case 'dibayar':
        return 'Dibayar';
      default:
        return 'Unknown';
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      final success = await _workOrderService.updateWorkOrderStatus(
        widget.workOrder.id,
        newStatus,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Status berhasil diupdate ke ' + _getStatusText(newStatus),
              ),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengupdate status')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EditWorkOrderScreen(workOrder: widget.workOrder),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation();
        break;
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Work Order'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus work order ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteWorkOrder();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWorkOrder() async {
    try {
      final success = await _workOrderService.deleteWorkOrder(
        widget.workOrder.id,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Work Order berhasil dihapus')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus Work Order')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error deleting work order: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _printWorkOrder(BuildContext context) async {
    // Ambil workshopId dari work order
    final workshopId = widget.workOrder.workshopId;
    String workshopName = 'BENGKEL';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('workshops')
          .doc(workshopId)
          .get();
      if (doc.exists && doc.data() != null) {
        workshopName = doc['workshopName'] ?? 'BENGKEL';
      }
    } catch (e) {
      // fallback ke default
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  workshopName,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'NOTA WORK ORDER',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Divider(),
              pw.Text(
                'No. WO: ${widget.workOrder.id}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Tanggal: ${_formatDate(widget.workOrder.createdAt)}'),
              pw.Text('Status: ${_getStatusText(widget.workOrder.status)}'),
              pw.SizedBox(height: 8),
              pw.Text(
                'Pelanggan: ${widget.workOrder.customerName}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text('Telepon: ${widget.workOrder.customerPhone}'),
              pw.Text('Kendaraan: ${widget.workOrder.vehicleType}'),
              pw.Text('Nomor: ${widget.workOrder.vehicleNumber}'),
              pw.Text('Deskripsi: ${widget.workOrder.description}'),
              pw.SizedBox(height: 12),
              pw.Text(
                'Item Jasa:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 4),
              ...widget.workOrder.services.map(
                (service) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text(service.name)),
                    pw.Text('Rp${service.price.toStringAsFixed(0)}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
              if (widget.workOrder.spareParts.isNotEmpty) ...[
                pw.Text(
                  'Item Spare Part:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                ...widget.workOrder.spareParts.map(
                  (part) => pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text(part.name)),
                      pw.Text(
                        '${part.quantity} x Rp${part.price.toStringAsFixed(0)}',
                      ),
                      pw.Text('Rp${part.total.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
              ],
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Jasa:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Rp${widget.workOrder.serviceTotal.toStringAsFixed(0)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Spare Part:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Rp${widget.workOrder.sparePartTotal.toStringAsFixed(0)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL KESELURUHAN:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    'Rp${widget.workOrder.totalAmount.toStringAsFixed(0)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  'Terima kasih telah mempercayakan kendaraan Anda kepada kami',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Simpan nota ini sebagai bukti transaksi',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _shareWorkOrder() async {
    try {
      // Ambil nama bengkel dari Firestore
      String workshopName = 'BENGKEL';
      try {
        final doc = await FirebaseFirestore.instance
            .collection('workshops')
            .doc(widget.workOrder.workshopId)
            .get();
        if (doc.exists && doc.data() != null) {
          workshopName = doc['workshopName'] ?? 'BENGKEL';
        }
      } catch (e) {
        // fallback ke default
      }

      // Buat PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    workshopName,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    'NOTA WORK ORDER',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  'No. WO: ${widget.workOrder.id}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Tanggal: ${_formatDate(widget.workOrder.createdAt)}'),
                pw.Text('Status: ${_getStatusText(widget.workOrder.status)}'),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Pelanggan: ${widget.workOrder.customerName}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Telepon: ${widget.workOrder.customerPhone}'),
                pw.Text('Kendaraan: ${widget.workOrder.vehicleType}'),
                pw.Text('Nomor: ${widget.workOrder.vehicleNumber}'),
                pw.Text('Deskripsi: ${widget.workOrder.description}'),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Item Jasa:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                ...widget.workOrder.services.map(
                  (service) => pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text(service.name)),
                      pw.Text('Rp${service.price.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 8),
                if (widget.workOrder.spareParts.isNotEmpty) ...[
                  pw.Text(
                    'Item Spare Part:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  ...widget.workOrder.spareParts.map(
                    (part) => pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(child: pw.Text(part.name)),
                        pw.Text(
                          '${part.quantity} x Rp${part.price.toStringAsFixed(0)}',
                        ),
                        pw.Text('Rp${part.total.toStringAsFixed(0)}'),
                      ],
                    ),
                  ),
                ],
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Jasa:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Rp${widget.workOrder.serviceTotal.toStringAsFixed(0)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Spare Part:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Rp${widget.workOrder.sparePartTotal.toStringAsFixed(0)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL KESELURUHAN:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Rp${widget.workOrder.totalAmount.toStringAsFixed(0)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Text(
                    'Terima kasih telah mempercayakan kendaraan Anda kepada kami',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Simpan nota ini sebagai bukti transaksi',
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Simpan PDF ke temporary directory
      final tempDir = await getTemporaryDirectory();
      final file =
          File('${tempDir.path}/nota_work_order_${widget.workOrder.id}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Share PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Nota Work Order - ${widget.workOrder.id}',
        subject: 'Nota Work Order',
      );
    } catch (e) {
      debugPrint('Error sharing work order: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membagikan nota: $e')),
        );
      }
    }
  }
}
