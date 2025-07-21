import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/spare_part_service.dart';
import '../models/spare_part_model.dart';
import 'add_edit_spare_part_screen.dart';

class SparePartsScreen extends StatefulWidget {
  const SparePartsScreen({super.key});

  @override
  State<SparePartsScreen> createState() => _SparePartsScreenState();
}

class _SparePartsScreenState extends State<SparePartsScreen> {
  final SparePartService _sparePartService = SparePartService();
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Oli',
    'Filter',
    'Ban',
    'Rem',
    'Aki',
    'Lampu',
    'Kabel',
    'Bearing',
    'Gasket',
    'Lainnya',
  ];

  // Fungsi untuk mendeteksi kategori berdasarkan nama spare part
  String _getCategoryFromName(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('oli') || lowerName.contains('oil')) {
      return 'Oli';
    } else if (lowerName.contains('filter') || lowerName.contains('saringan')) {
      return 'Filter';
    } else if (lowerName.contains('ban') ||
        lowerName.contains('tire') ||
        lowerName.contains('roda')) {
      return 'Ban';
    } else if (lowerName.contains('rem') ||
        lowerName.contains('brake') ||
        lowerName.contains('kampas')) {
      return 'Rem';
    } else if (lowerName.contains('aki') ||
        lowerName.contains('battery') ||
        lowerName.contains('accu')) {
      return 'Aki';
    } else if (lowerName.contains('lampu') ||
        lowerName.contains('lamp') ||
        lowerName.contains('led')) {
      return 'Lampu';
    } else if (lowerName.contains('kabel') ||
        lowerName.contains('cable') ||
        lowerName.contains('wire')) {
      return 'Kabel';
    } else if (lowerName.contains('bearing') || lowerName.contains('laher')) {
      return 'Bearing';
    } else if (lowerName.contains('gasket') || lowerName.contains('seal')) {
      return 'Gasket';
    } else {
      return 'Lainnya';
    }
  }

  // Fungsi untuk mendapatkan warna kategori
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Oli':
        return Colors.orange;
      case 'Filter':
        return Colors.blue;
      case 'Ban':
        return Colors.black;
      case 'Rem':
        return Colors.red;
      case 'Aki':
        return Colors.green;
      case 'Lampu':
        return Colors.yellow.shade700;
      case 'Kabel':
        return Colors.purple;
      case 'Bearing':
        return Colors.teal;
      case 'Gasket':
        return Colors.indigo;
      case 'Lainnya':
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final workshopId = user?.workshopId;

    if (workshopId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Spare Part'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: const Center(child: Text('Bengkel belum dikonfigurasi')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spare Part'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari spare part...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue[600],
                        backgroundColor: Colors.grey[100],
                        labelStyle: TextStyle(
                          color:
                              isSelected ? Colors.blue[600] : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pushNamed(context, '/spare-part-purchase-history');
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              FocusScope.of(context).unfocus();
              _showAddSparePartScreen();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<SparePartModel>>(
        stream: _sparePartService.getSpareParts(workshopId),
        builder: (context, snapshot) {
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

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final spareParts = snapshot.data ?? [];
          final filteredSpareParts = spareParts.where((sparePart) {
            // Filter berdasarkan pencarian
            final matchesSearch = _searchQuery.isEmpty ||
                sparePart.name.toLowerCase().contains(_searchQuery) ||
                sparePart.code.toLowerCase().contains(_searchQuery);

            // Filter berdasarkan kategori
            final matchesCategory = _selectedCategory == 'Semua' ||
                _getCategoryFromName(sparePart.name) == _selectedCategory;

            return matchesSearch && matchesCategory;
          }).toList();

          if (filteredSpareParts.isEmpty) {
            if (_searchQuery.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada hasil pencarian',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Coba kata kunci lain',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Belum ada spare part',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Tambahkan spare part pertama Anda',
                      style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddSparePartScreen(),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Spare Part'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredSpareParts.length,
            itemBuilder: (context, index) {
              final sparePart = filteredSpareParts[index];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: sparePart.stock <= 0
                                  ? Colors.red[50]
                                  : Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: sparePart.stock <= 0
                                    ? Colors.red[200]!
                                    : Colors.green[200]!,
                              ),
                            ),
                            child: Icon(
                              Icons.inventory_2,
                              color: sparePart.stock <= 0
                                  ? Colors.red[600]
                                  : Colors.green[600],
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sparePart.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Kode: ${sparePart.code}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Badge kategori
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(
                                        _getCategoryFromName(sparePart.name)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getCategoryFromName(sparePart.name),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditSparePartScreen(sparePart);
                              } else if (value == 'delete') {
                                _showDeleteDialog(context, sparePart);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit')
                                  ])),
                              const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Hapus',
                                        style: TextStyle(color: Colors.red))
                                  ])),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Harga Jual',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${sparePart.sellPrice.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: sparePart.stock <= 0
                                    ? Colors.red[50]
                                    : Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: sparePart.stock <= 0
                                      ? Colors.red[200]!
                                      : Colors.green[200]!,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stok',
                                    style: TextStyle(
                                      color: sparePart.stock <= 0
                                          ? Colors.red[700]
                                          : Colors.green[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${sparePart.stock} unit',
                                    style: TextStyle(
                                      color: sparePart.stock <= 0
                                          ? Colors.red[700]
                                          : Colors.green[700],
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
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddSparePartScreen() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const AddEditSparePartScreen(),
      ),
    )
        .then((result) {
      if (result == true) {
        // Refresh data jika berhasil
        setState(() {});
      }
    });
  }

  void _showEditSparePartScreen(SparePartModel sparePart) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => AddEditSparePartScreen(sparePart: sparePart),
      ),
    )
        .then((result) {
      if (result == true) {
        // Refresh data jika berhasil
        setState(() {});
      }
    });
  }

  void _showDeleteDialog(BuildContext context, SparePartModel sparePart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus spare part "${sparePart.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              setState(() => _isLoading = true);

              try {
                await _sparePartService.deleteSparePart(sparePart.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Berhasil dihapus'),
                      backgroundColor: Colors.green));
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error: $e'), backgroundColor: Colors.red));
                }
              } finally {
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
