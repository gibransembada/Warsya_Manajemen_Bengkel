import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_service.dart';
import 'spare_part_service.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CustomerService _customerService = CustomerService();
  final SparePartService _sparePartService = SparePartService();

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats(String workshopId) async {
    try {
      final customerCount = await _customerService.getCustomerCount(workshopId);
      final sparePartCount =
          await _sparePartService.getSparePartCount(workshopId);
      final totalInventoryValue =
          await _sparePartService.getTotalInventoryValue(workshopId);

      // Ambil jumlah work order dari Firestore
      final workOrderSnapshot = await _firestore
          .collection('work_orders')
          .where('workshopId', isEqualTo: workshopId)
          .get();
      final workOrderCount = workOrderSnapshot.docs.length;

      // Hitung total spare part yang sudah dibeli (dari koleksi spare_part_purchases)
      final purchasesSnapshot = await _firestore
          .collection('spare_part_purchases')
          .where('workshopId', isEqualTo: workshopId)
          .get();
      int sparePartPurchased = 0;
      for (var doc in purchasesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['items'] != null) {
          for (var item in List.from(data['items'])) {
            sparePartPurchased += (item['quantity'] ?? 1) as int;
          }
        }
      }

      // Get monthly revenue data for chart
      final monthlyRevenue = await _getMonthlyRevenue(workshopId);

      // Get today's revenue
      final todayRevenue = await _getTodayRevenue(workshopId);

      // Get customer growth data
      final customerGrowth = await _getCustomerGrowth(workshopId);

      // Get top spare parts
      final topSpareParts = await _getTopSpareParts(workshopId);

      return {
        'customerCount': customerCount,
        'sparePartCount': sparePartCount,
        'workOrderCount': workOrderCount,
        'totalInventoryValue': totalInventoryValue,
        'monthlyRevenue': monthlyRevenue,
        'todayRevenue': todayRevenue,
        'customerGrowth': customerGrowth,
        'topSpareParts': topSpareParts,
        'sparePartPurchased': sparePartPurchased,
      };
    } catch (e) {
      debugPrint('Error getting dashboard stats: $e');
      return {
        'customerCount': 0,
        'sparePartCount': 0,
        'workOrderCount': 0,
        'totalInventoryValue': 0.0,
        'monthlyRevenue': [],
        'todayRevenue': 0.0,
        'customerGrowth': [],
        'topSpareParts': [],
        'sparePartPurchased': 0,
      };
    }
  }

  // Get monthly revenue data for chart
  Future<List<Map<String, dynamic>>> _getMonthlyRevenue(
      String workshopId) async {
    try {
      final now = DateTime.now();
      final firstMonth = DateTime(now.year, now.month - 5, 1);
      final lastMonth = DateTime(now.year, now.month + 1, 1);

      debugPrint('Dashboard: Querying work orders for workshop: $workshopId');
      debugPrint(
          'Dashboard: Date range: ${firstMonth.toIso8601String()} to ${lastMonth.toIso8601String()}');

      // Query work_orders untuk 6 bulan terakhir, ambil semua dan filter di aplikasi
      final snapshot = await _firestore
          .collection('work_orders')
          .where('workshopId', isEqualTo: workshopId)
          .get();

      debugPrint('Dashboard: Found ${snapshot.docs.length} work orders total');

      // Map bulan ke total pendapatan
      Map<String, double> revenuePerMonth = {};
      for (int i = 5; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        revenuePerMonth[key] = 0.0;
      }

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'pending';

        debugPrint('Dashboard: Work order ${doc.id} status: $status');

        // Hanya hitung jika status dibayar
        if (status != 'dibayar') {
          debugPrint(
              'Dashboard: Skipping work order ${doc.id} - status is not dibayar');
          continue;
        }

        debugPrint(
            'Dashboard: Processing work order ${doc.id} with status: $status');

        // Handle createdAt field yang bisa berupa string atau Timestamp
        DateTime createdAt;
        final createdAtRaw = data['createdAt'];
        if (createdAtRaw is Timestamp) {
          createdAt = createdAtRaw.toDate();
        } else if (createdAtRaw is String) {
          createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
        } else {
          createdAt = DateTime.now();
        }

        debugPrint(
            'Dashboard: Work order ${doc.id} createdAt: ${createdAt.toIso8601String()}');

        // Hanya hitung jika dalam range 6 bulan terakhir
        if (createdAt.isBefore(firstMonth) || createdAt.isAfter(lastMonth)) {
          debugPrint(
              'Dashboard: Work order ${doc.id} outside date range, skipping');
          continue;
        }

        final key =
            '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
        double total = 0.0;

        // Hitung total jasa
        if (data['services'] != null) {
          for (var service in List.from(data['services'])) {
            final servicePrice = (service['price'] ?? 0).toDouble();
            total += servicePrice;
            debugPrint(
                'Dashboard: Service ${service['name']}: Rp $servicePrice');
          }
        }

        // Hitung total spare part
        if (data['spareParts'] != null) {
          for (var part in List.from(data['spareParts'])) {
            final price = (part['price'] ?? 0).toDouble();
            final qty = (part['quantity'] ?? 1).toDouble();
            final partTotal = price * qty;
            total += partTotal;
            debugPrint(
                'Dashboard: Spare part ${part['name']}: ${qty.toInt()} x Rp $price = Rp $partTotal');
          }
        }

        debugPrint(
            'Dashboard: Work order ${doc.id} total: Rp $total for month $key');
        if (revenuePerMonth.containsKey(key)) {
          revenuePerMonth[key] = revenuePerMonth[key]! + total;
        }
      }

      // Tambahkan pendapatan dari pembelian spare part (jika ada koleksi pembelian)
      final purchaseSnapshot = await _firestore
          .collection('spare_part_purchases')
          .where('workshopId', isEqualTo: workshopId)
          .get();

      debugPrint(
          'Dashboard: Found ${purchaseSnapshot.docs.length} spare part purchases');

      for (var doc in purchaseSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAtRaw = data['createdAt'];
        DateTime createdAt;
        if (createdAtRaw is Timestamp) {
          createdAt = createdAtRaw.toDate();
        } else if (createdAtRaw is String) {
          createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
        } else {
          createdAt = DateTime.now();
        }

        // Hanya hitung jika dalam range 6 bulan terakhir
        if (createdAt.isBefore(firstMonth) || createdAt.isAfter(lastMonth)) {
          continue;
        }

        final key =
            '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}';
        final total = (data['total'] ?? 0).toDouble();
        debugPrint('Dashboard: Purchase ${doc.id}: Rp $total for month $key');
        if (revenuePerMonth.containsKey(key)) {
          revenuePerMonth[key] = revenuePerMonth[key]! + total;
        }
      }

      // Format hasil untuk chart
      final months = <Map<String, dynamic>>[];
      for (int i = 5; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        final revenue = revenuePerMonth[key] ?? 0.0;
        months.add({
          'month': date,
          'revenue': revenue,
        });
        debugPrint('Dashboard: Month $key revenue: Rp $revenue');
      }

      debugPrint('Dashboard: Final monthly revenue data: $months');
      return months;
    } catch (e) {
      debugPrint('Error getting monthly revenue: $e');
      return [];
    }
  }

  // Get today's revenue
  Future<double> _getTodayRevenue(String workshopId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      debugPrint('Dashboard: Querying work orders for today');

      // Query work_orders untuk workshop ini, ambil semua dan filter di aplikasi
      final snapshot = await _firestore
          .collection('work_orders')
          .where('workshopId', isEqualTo: workshopId)
          .get();

      debugPrint('Dashboard: Found ${snapshot.docs.length} work orders total');

      double totalRevenue = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'pending';

        debugPrint('Dashboard: Work order ${doc.id} status: $status');

        // Hanya hitung jika status dibayar
        if (status != 'dibayar') {
          debugPrint(
              'Dashboard: Skipping work order ${doc.id} - status is not dibayar');
          continue;
        }

        debugPrint(
            'Dashboard: Processing work order ${doc.id} with status: $status');

        // Handle createdAt field yang bisa berupa string atau Timestamp
        DateTime createdAt;
        final createdAtRaw = data['createdAt'];
        if (createdAtRaw is Timestamp) {
          createdAt = createdAtRaw.toDate();
        } else if (createdAtRaw is String) {
          createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
        } else {
          createdAt = DateTime.now();
        }

        debugPrint(
            'Dashboard: Work order ${doc.id} createdAt: ${createdAt.toIso8601String()}');

        // Hanya hitung jika dalam range hari ini
        final createdAtDate =
            DateTime(createdAt.year, createdAt.month, createdAt.day);
        if (createdAtDate != today) {
          debugPrint(
              'Dashboard: Work order ${doc.id} not created today, skipping');
          continue;
        }

        // Hitung total jasa
        if (data['services'] != null) {
          for (var service in List.from(data['services'])) {
            final servicePrice = (service['price'] ?? 0).toDouble();
            totalRevenue += servicePrice;
            debugPrint(
                'Dashboard: Service ${service['name']}: Rp $servicePrice');
          }
        }

        // Hitung total spare part
        if (data['spareParts'] != null) {
          for (var part in List.from(data['spareParts'])) {
            final price = (part['price'] ?? 0).toDouble();
            final qty = (part['quantity'] ?? 1).toDouble();
            final partTotal = price * qty;
            totalRevenue += partTotal;
            debugPrint(
                'Dashboard: Spare part ${part['name']}: ${qty.toInt()} x Rp $price = Rp $partTotal');
          }
        }

        debugPrint('Dashboard: Work order ${doc.id} total: Rp $totalRevenue');
      }

      debugPrint('Dashboard: Total today revenue: Rp $totalRevenue');
      return totalRevenue;
    } catch (e) {
      debugPrint('Error getting today\'s revenue: $e');
      return 0.0;
    }
  }

  // Get total customers per month (per bulan, bukan kumulatif)
  Future<List<Map<String, dynamic>>> _getCustomerGrowth(
      String workshopId) async {
    try {
      final snapshot = await _firestore
          .collection('customers')
          .where('workshopId', isEqualTo: workshopId)
          .get();

      final customers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        return createdAt;
      }).toList();

      // Cari bulan terbaru dari data pelanggan, fallback ke DateTime.now()
      DateTime latest = customers.isNotEmpty
          ? customers.reduce((a, b) => a.isAfter(b) ? a : b)
          : DateTime.now();

      // Buat 6 bulan terakhir sampai bulan terbaru
      List<Map<String, dynamic>> growth = [];
      for (int i = 5; i >= 0; i--) {
        final date = DateTime(latest.year, latest.month - i, 1);
        final nextMonth = DateTime(date.year, date.month + 1, 1);
        // Hanya hitung pelanggan yang dibuat di bulan ini saja
        final total = customers.where((dt) =>
          dt.isAfter(date.subtract(const Duration(seconds: 1))) && dt.isBefore(nextMonth)
        ).length;
        growth.add({
          'month': date,
          'customers': total,
        });
      }
      return growth;
    } catch (e) {
      debugPrint('Error getting customer growth: $e');
      return [];
    }
  }

  // Get top spare parts by stock value
  Future<List<Map<String, dynamic>>> _getTopSpareParts(
      String workshopId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('spare_parts')
          .where('workshopId', isEqualTo: workshopId)
          .orderBy('stock', descending: true)
          .limit(5)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? '',
          'stock': data['stock'] ?? 0,
          'value': (data['buyPrice'] ?? 0) * (data['stock'] ?? 0),
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting top spare parts: $e');
      return [];
    }
  }

  // Get recent activities
  Future<List<Map<String, dynamic>>> getRecentActivities(
      String workshopId) async {
    try {
      // This would combine recent customers, spare parts, and work orders
      final activities = <Map<String, dynamic>>[];

      // Get recent customers
      final recentCustomers = await _firestore
          .collection('customers')
          .where('workshopId', isEqualTo: workshopId)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      for (var doc in recentCustomers.docs) {
        final data = doc.data();
        activities.add({
          'type': 'customer',
          'title': 'Pelanggan baru: ${data['name']}',
          'timestamp': (data['createdAt'] as Timestamp).toDate(),
          'icon': 'person_add',
        });
      }

      // Get recent spare parts
      final recentSpareParts = await _firestore
          .collection('spare_parts')
          .where('workshopId', isEqualTo: workshopId)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      for (var doc in recentSpareParts.docs) {
        final data = doc.data();
        activities.add({
          'type': 'spare_part',
          'title': 'Spare part baru: ${data['name']}',
          'timestamp': (data['createdAt'] as Timestamp).toDate(),
          'icon': 'inventory',
        });
      }

      // Sort by timestamp
      activities.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      return activities.take(5).toList();
    } catch (e) {
      debugPrint('Error getting recent activities: $e');
      return [];
    }
  }

  // Get revenue history by period (daily, weekly, monthly, yearly)
  Future<List<Map<String, dynamic>>> getRevenueHistory(
      String workshopId, String period) async {
    try {
      final now = DateTime.now();
      List<Map<String, dynamic>> revenueData = [];

      switch (period) {
        case 'daily':
          // Data 30 hari terakhir
          for (int i = 29; i >= 0; i--) {
            final date = DateTime(now.year, now.month, now.day - i);
            final revenue = await _getRevenueForDate(workshopId, date);
            revenueData.add({
              'date': date,
              'revenue': revenue,
              'label': DateFormat('dd/MM').format(date),
            });
          }
          break;

        case 'weekly':
          // Data 12 minggu terakhir
          for (int i = 11; i >= 0; i--) {
            final weekStart = now.subtract(Duration(days: i * 7));
            final weekEnd = weekStart.add(const Duration(days: 6));
            final revenue =
                await _getRevenueForDateRange(workshopId, weekStart, weekEnd);
            revenueData.add({
              'date': weekStart,
              'revenue': revenue,
              'label': 'Minggu ${DateFormat('dd/MM').format(weekStart)}',
            });
          }
          break;

        case 'monthly':
          // Data 12 bulan terakhir
          for (int i = 11; i >= 0; i--) {
            final date = DateTime(now.year, now.month - i, 1);
            final revenue = await _getRevenueForMonth(workshopId, date);
            revenueData.add({
              'date': date,
              'revenue': revenue,
              'label': DateFormat('MMM yyyy').format(date),
            });
          }
          break;

        case 'yearly':
          // Data 5 tahun terakhir
          for (int i = 4; i >= 0; i--) {
            final year = now.year - i;
            final revenue = await _getRevenueForYear(workshopId, year);
            revenueData.add({
              'date': DateTime(year, 1, 1),
              'revenue': revenue,
              'label': year.toString(),
            });
          }
          break;
      }

      return revenueData;
    } catch (e) {
      debugPrint('Error getting revenue history: $e');
      return [];
    }
  }

  // Get revenue for specific date
  Future<double> _getRevenueForDate(String workshopId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Query work orders
      final snapshot = await _firestore
          .collection('work_orders')
          .where('workshopId', isEqualTo: workshopId)
          .get();

      double totalRevenue = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] ?? 'pending';

        if (status != 'dibayar') continue;

        DateTime createdAt;
        final createdAtRaw = data['createdAt'];
        if (createdAtRaw is Timestamp) {
          createdAt = createdAtRaw.toDate();
        } else if (createdAtRaw is String) {
          createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
        } else {
          createdAt = DateTime.now();
        }

        final createdAtDate =
            DateTime(createdAt.year, createdAt.month, createdAt.day);
        if (createdAtDate != startOfDay) continue;

        // Hitung total jasa
        if (data['services'] != null) {
          for (var service in List.from(data['services'])) {
            final servicePrice = (service['price'] ?? 0).toDouble();
            totalRevenue += servicePrice;
          }
        }

        // Hitung total spare part
        if (data['spareParts'] != null) {
          for (var part in List.from(data['spareParts'])) {
            final price = (part['price'] ?? 0).toDouble();
            final qty = (part['quantity'] ?? 1).toDouble();
            totalRevenue += price * qty;
          }
        }
      }

      // Query spare part purchases
      final purchaseSnapshot = await _firestore
          .collection('spare_part_purchases')
          .where('workshopId', isEqualTo: workshopId)
          .get();

      for (var doc in purchaseSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        DateTime createdAt;
        final createdAtRaw = data['createdAt'];
        if (createdAtRaw is Timestamp) {
          createdAt = createdAtRaw.toDate();
        } else if (createdAtRaw is String) {
          createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
        } else {
          createdAt = DateTime.now();
        }

        final createdAtDate =
            DateTime(createdAt.year, createdAt.month, createdAt.day);
        if (createdAtDate != startOfDay) continue;

        final total = (data['total'] ?? 0).toDouble();
        totalRevenue += total;
      }

      return totalRevenue;
    } catch (e) {
      debugPrint('Error getting revenue for date: $e');
      return 0.0;
    }
  }

  // Get revenue for date range
  Future<double> _getRevenueForDateRange(
      String workshopId, DateTime startDate, DateTime endDate) async {
    try {
      double totalRevenue = 0.0;
      DateTime currentDate = startDate;

      while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
        totalRevenue += await _getRevenueForDate(workshopId, currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }

      return totalRevenue;
    } catch (e) {
      debugPrint('Error getting revenue for date range: $e');
      return 0.0;
    }
  }

  // Get revenue for specific month
  Future<double> _getRevenueForMonth(String workshopId, DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 1);

      return await _getRevenueForDateRange(
          workshopId, startOfMonth, endOfMonth);
    } catch (e) {
      debugPrint('Error getting revenue for month: $e');
      return 0.0;
    }
  }

  // Get revenue for specific year
  Future<double> _getRevenueForYear(String workshopId, int year) async {
    try {
      final startOfYear = DateTime(year, 1, 1);
      final endOfYear = DateTime(year + 1, 1, 1);

      return await _getRevenueForDateRange(workshopId, startOfYear, endOfYear);
    } catch (e) {
      debugPrint('Error getting revenue for year: $e');
      return 0.0;
    }
  }
}
