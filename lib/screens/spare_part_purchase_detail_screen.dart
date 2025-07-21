import 'package:flutter/material.dart';
import '../models/spare_part_purchase_model.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class SparePartPurchaseDetailScreen extends StatelessWidget {
  final SparePartPurchase purchase;

  const SparePartPurchaseDetailScreen({
    Key? key,
    required this.purchase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pembelian'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              await _printReceipt(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              await _shareReceipt(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Struk
            _buildReceiptHeader(),
            const SizedBox(height: 20),

            // Informasi Transaksi
            _buildTransactionInfo(),
            const SizedBox(height: 20),

            // Daftar Item
            _buildItemsList(),
            const SizedBox(height: 20),

            // Total
            _buildTotalSection(),
            const SizedBox(height: 20),

            // Footer
            _buildReceiptFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 48,
              color: Colors.blue[600],
            ),
            const SizedBox(height: 12),
            const Text(
              'STRUK PEMBELIAN SPARE PART',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              purchase.transactionNumber,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Transaksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Tanggal', _formatDate(purchase.createdAt)),
            _buildInfoRow('Waktu', _formatTime(purchase.createdAt)),
            if (purchase.customerName != null)
              _buildInfoRow('Pelanggan', purchase.customerName!),
            if (purchase.customerPhone != null)
              _buildInfoRow('Telepon', purchase.customerPhone!),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Item yang Dibeli',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...purchase.items.map((item) => _buildItemRow(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(PurchaseItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp ${item.price.toStringAsFixed(0)} x ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Rp ${item.total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Card(
      elevation: 2,
      color: Colors.green[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TOTAL PEMBAYARAN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              'Rp ${purchase.total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptFooter() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Terima kasih telah berbelanja',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Simpan struk ini sebagai bukti pembelian',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Dicetak pada: ${_formatDateTime(DateTime.now())}',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;

    final monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];

    return '$day ${monthNames[dateTime.month - 1]} $year';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    return '$day ${monthNames[dateTime.month - 1]} $year, $hour:$minute';
  }

  Future<void> _printReceipt(BuildContext context) async {
    // Ambil workshopId dari purchase
    final workshopId = purchase.workshopId;
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
                child: pw.Text(workshopName,
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text('STRUK PEMBELIAN SPARE PART',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Divider(),
              pw.Text('No. Transaksi: ${purchase.transactionNumber}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Tanggal: ${_formatDate(purchase.createdAt)}'),
              pw.Text('Waktu: ${_formatTime(purchase.createdAt)}'),
              if (purchase.customerName != null)
                pw.Text('Pelanggan: ${purchase.customerName}'),
              if (purchase.customerPhone != null)
                pw.Text('Telepon: ${purchase.customerPhone}'),
              pw.SizedBox(height: 12),
              pw.Text('Item yang Dibeli:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              ...purchase.items.map((item) => pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(child: pw.Text(item.name)),
                      pw.Text(
                          '${item.quantity} x Rp${item.price.toStringAsFixed(0)}'),
                      pw.Text('Rp${item.total.toStringAsFixed(0)}'),
                    ],
                  )),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('Rp${purchase.total.toStringAsFixed(0)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Center(
                  child: pw.Text(
                      'Terima kasih telah berbelanja di Bengkel Maju Jaya',
                      style: pw.TextStyle(fontSize: 12))),
              pw.Center(
                  child: pw.Text('Simpan struk ini sebagai bukti pembelian',
                      style:
                          pw.TextStyle(fontSize: 10, color: PdfColors.grey))),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  Future<void> _shareReceipt(BuildContext context) async {
    try {
      // Ambil nama bengkel dari Firestore
      String workshopName = 'BENGKEL';
      try {
        final doc = await FirebaseFirestore.instance
            .collection('workshops')
            .doc(purchase.workshopId)
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
                    'STRUK PEMBELIAN SPARE PART',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Divider(),
                pw.Text(
                  'No. Transaksi: ${purchase.transactionNumber}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text('Tanggal: ${_formatDateForPdf(purchase.createdAt)}'),
                pw.Text('Waktu: ${_formatTimeForPdf(purchase.createdAt)}'),
                if (purchase.customerName != null)
                  pw.Text('Pelanggan: ${purchase.customerName}'),
                if (purchase.customerPhone != null)
                  pw.Text('Telepon: ${purchase.customerPhone}'),
                pw.SizedBox(height: 12),
                pw.Text(
                  'Item yang Dibeli:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 4),
                ...purchase.items.map(
                  (item) => pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(item.name),
                            pw.Text(
                              '${item.quantity} x Rp${item.price.toStringAsFixed(0)}',
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      pw.Text('Rp${item.total.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Rp${purchase.total.toStringAsFixed(0)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Text(
                    'Terima kasih telah berbelanja di bengkel kami',
                    style: pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Simpan struk ini sebagai bukti pembelian',
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
      final file = File(
          '${tempDir.path}/struk_pembelian_${purchase.transactionNumber}.pdf');
      await file.writeAsBytes(await pdf.save());

      // Share PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Struk Pembelian Spare Part - ${purchase.transactionNumber}',
        subject: 'Struk Pembelian Spare Part',
      );
    } catch (e) {
      debugPrint('Error sharing receipt: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membagikan struk: $e')),
        );
      }
    }
  }

  String _formatDateForPdf(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTimeForPdf(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
