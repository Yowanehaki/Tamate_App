// lib/features/logbook/logbook_screen.dart
import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/services/logbook_service.dart'; // Import service
import 'models/logbook_entry_model.dart';
import 'widgets/logbook_entry_card.dart';

class LogbookScreen extends StatefulWidget {
  const LogbookScreen({super.key});

  @override
  State<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends State<LogbookScreen> {
  final LogbookService _logbookService = LogbookService();
  List<LogbookEntryModel> _filteredEntries = [];
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _logbookService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _logbookService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _loadData() async {
    await _logbookService.loadEntries();
    setState(() {
      _isLoading = false;
      _filterEntries();
    });
  }

  void _onDataChanged() {
    _filterEntries();
  }

  void _filterEntries() {
    setState(() {
      _filteredEntries = _logbookService.entries.where((entry) {
        bool matchesSearch = entry.deskripsi.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            entry.kategori.toLowerCase().contains(_searchQuery.toLowerCase());
        bool matchesCategory = _selectedCategory == null || entry.kategori == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Logbook')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logbook'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Urutkan',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _filteredEntries.isEmpty 
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredEntries.length,
                    itemBuilder: (context, index) {
                      return LogbookEntryCard(
                        entry: _filteredEntries[index],
                        index: index,
                        onEdit: () => _showEditLogbookDialog(_filteredEntries[index]),
                        onDelete: () => _deleteEntry(_filteredEntries[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddLogbookDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari aktivitas...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filterEntries();
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada aktivitas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan aktivitas baru dengan tombol + di bawah',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLogbookDialog() {
    final kategoriController = TextEditingController();
    final deskripsiController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? selectedCategory;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Aktivitas'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date picker field
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormatter.formatDate(selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Category field
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category),
                  ),
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'Bimbingan', child: Text('Bimbingan')),
                    DropdownMenuItem(value: 'Penelitian', child: Text('Penelitian')),
                    DropdownMenuItem(value: 'Konsultasi', child: Text('Konsultasi')),
                    DropdownMenuItem(value: 'Penulisan', child: Text('Penulisan')),
                    DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                      if (value != null) {
                        kategoriController.text = value;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Description field
                TextFormField(
                  controller: deskripsiController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
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
                if (kategoriController.text.isNotEmpty && 
                    deskripsiController.text.isNotEmpty) {
                  final newEntry = LogbookEntryModel(
                    tanggal: selectedDate,
                    kategori: kategoriController.text,
                    deskripsi: deskripsiController.text,
                  );
                  _logbookService.addEntry(newEntry);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Aktivitas berhasil ditambahkan'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Silakan isi semua kolom'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLogbookDialog(LogbookEntryModel entry) {
    final kategoriController = TextEditingController(text: entry.kategori);
    final deskripsiController = TextEditingController(text: entry.deskripsi);
    DateTime selectedDate = entry.tanggal;
    String? selectedCategory = entry.kategori;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Aktivitas'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date picker field
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      DateFormatter.formatDate(selectedDate),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Category field
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category),
                  ),
                  value: selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'Bimbingan', child: Text('Bimbingan')),
                    DropdownMenuItem(value: 'Penelitian', child: Text('Penelitian')),
                    DropdownMenuItem(value: 'Konsultasi', child: Text('Konsultasi')),
                    DropdownMenuItem(value: 'Penulisan', child: Text('Penulisan')),
                    DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                      if (value != null) {
                        kategoriController.text = value;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Description field
                TextFormField(
                  controller: deskripsiController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
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
                if (kategoriController.text.isNotEmpty && 
                    deskripsiController.text.isNotEmpty) {
                  int index = _logbookService.entries.indexOf(entry);
                  if (index != -1) {
                    final updatedEntry = LogbookEntryModel(
                      tanggal: selectedDate,
                      kategori: kategoriController.text,
                      deskripsi: deskripsiController.text,
                    );
                    _logbookService.updateEntry(index, updatedEntry);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Aktivitas berhasil diperbarui'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Silakan isi semua kolom'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteEntry(LogbookEntryModel entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin menghapus entri ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _logbookService.deleteEntry(entry);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Entri dihapus'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter berdasarkan:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Kategori'),
              onTap: () {
                Navigator.pop(context);
                _showCategoryFilter();
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Hapus Filter'),
              onTap: () {
                setState(() {
                  _selectedCategory = null;
                  _filterEntries();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String?>(
              title: const Text('Semua'),
              value: null,
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _filterEntries();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Bimbingan'),
              value: 'Bimbingan',
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _filterEntries();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Penelitian'),
              value: 'Penelitian',
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _filterEntries();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Konsultasi'),
              value: 'Konsultasi',
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _filterEntries();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Penulisan'),
              value: 'Penulisan',
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _filterEntries();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Lainnya'),
              value: 'Lainnya',
              groupValue: _selectedCategory,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _filterEntries();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Urutkan berdasarkan:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Terbaru'),
              onTap: () {
                _logbookService.sortEntries((a, b) => b.tanggal.compareTo(a.tanggal));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Terlama'),
              onTap: () {
                _logbookService.sortEntries((a, b) => a.tanggal.compareTo(b.tanggal));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Kategori (A-Z)'),
              onTap: () {
                _logbookService.sortEntries((a, b) => a.kategori.compareTo(b.kategori));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}