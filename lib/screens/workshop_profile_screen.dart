import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/workshop_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkshopProfileScreen extends StatefulWidget {
  const WorkshopProfileScreen({super.key});

  @override
  State<WorkshopProfileScreen> createState() => _WorkshopProfileScreenState();
}

class _WorkshopProfileScreenState extends State<WorkshopProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _workshopNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _workshopService = WorkshopService();
  bool _isLoading = false;
  bool _isEditing = false;
  Map<String, dynamic>? _workshopData;
  int _customerCount = 0;
  int _workOrderCount = 0;
  int _sparePartCount = 0;

  @override
  void initState() {
    super.initState();
    _loadWorkshopData();
    _loadWorkshopStats();
  }

  @override
  void dispose() {
    _workshopNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkshopData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      if (user?.workshopId != null) {
        final workshopDoc =
            await _workshopService.getWorkshopData(user!.workshopId!);
        if (workshopDoc != null && mounted) {
          setState(() {
            _workshopData = workshopDoc;
            _workshopNameController.text = workshopDoc['workshopName'] ?? '';
            _addressController.text = workshopDoc['address'] ?? '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadWorkshopStats() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user?.workshopId != null) {
      // Ambil jumlah pelanggan
      final customerSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('workshopId', isEqualTo: user!.workshopId)
          .get();
      // Ambil jumlah work order
      final workOrderSnapshot = await FirebaseFirestore.instance
          .collection('work_orders')
          .where('workshopId', isEqualTo: user.workshopId)
          .get();
      // Ambil jumlah spare part
      final sparePartSnapshot = await FirebaseFirestore.instance
          .collection('spare_parts')
          .where('workshopId', isEqualTo: user.workshopId)
          .get();
      if (mounted) {
        setState(() {
          _customerCount = customerSnapshot.docs.length;
          _workOrderCount = workOrderSnapshot.docs.length;
          _sparePartCount = sparePartSnapshot.docs.length;
        });
      }
    }
  }

  Future<void> _updateWorkshop() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;

        if (user?.workshopId != null) {
          final success = await _workshopService.updateWorkshop(
            user!.workshopId!,
            _workshopNameController.text.trim(),
            address: _addressController.text.trim().isNotEmpty
                ? _addressController.text.trim()
                : null,
          );

          if (success && mounted) {
            await _loadWorkshopData();
            setState(() => _isEditing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil bengkel berhasil diperbarui!'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gagal memperbarui profil bengkel.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Bengkel'),
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
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading
                ? null
                : () async {
                    await _loadWorkshopData();
                    await _loadWorkshopStats();
                  },
            tooltip: 'Refresh Profil & Statistik',
          ),
          if (!_isEditing && _workshopData != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed:
                  _isLoading ? null : () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _workshopData == null
              ? _buildNoWorkshopView()
              : _buildWorkshopProfileView(),
    );
  }

  Widget _buildNoWorkshopView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada profil bengkel',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan buat profil bengkel terlebih dahulu',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/create-workshop');
            },
            child: const Text('Buat Profil Bengkel'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan icon bengkel
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.store,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profil Bengkel',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _workshopData?['workshopName'] ?? 'Nama Bengkel',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Form atau tampilan data
          if (_isEditing) _buildEditForm() else _buildDisplayView(),

          // Tambahkan tombol logout di bawah jika tidak sedang edit
          if (!_isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(160, 44),
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Apakah Anda yakin ingin logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text('Ya, Logout'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await Provider.of<AuthProvider>(context, listen: false)
                          .signOut();
                      if (mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login', (route) => false);
                      }
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDisplayView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          'Informasi Bengkel',
          [
            _buildInfoRow(
                'Nama Bengkel', _workshopData?['workshopName'] ?? '-'),
            _buildInfoRow('Alamat', _workshopData?['address'] ?? 'Belum diisi'),
            _buildInfoRow('Pemilik',
                Provider.of<AuthProvider>(context).user?.name ?? '-'),
            _buildInfoRow(
                'Email', Provider.of<AuthProvider>(context).user?.email ?? '-'),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Statistik Bengkel',
          [
            _buildInfoRow('Total Pelanggan', _customerCount.toString()),
            _buildInfoRow('Total Work Order', _workOrderCount.toString()),
            _buildInfoRow('Spare Part Tersedia', _sparePartCount.toString()),
          ],
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Informasi Bengkel',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _workshopNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Bengkel',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.store),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama bengkel tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Alamat Bengkel',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _workshopNameController.text =
                          _workshopData?['workshopName'] ?? '';
                      _addressController.text = _workshopData?['address'] ?? '';
                    });
                  },
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateWorkshop,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
