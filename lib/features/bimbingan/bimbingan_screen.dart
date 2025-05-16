// lib/features/bimbingan/bimbingan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk TextInputFormatter
import 'models/bimbingan_model.dart';
import '../profile/models/user_profile_model.dart';
import 'widgets/bimbingan_list_item.dart';
import 'widgets/reminder_list_item.dart';
import '../../core/services/user_profile_service.dart';
import '../../core/services/bimbingan_service.dart';
import '../../core/services/notification_service.dart';

// Custom formatter untuk input waktu
class _TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.isEmpty) {
      return newValue;
    }
    
    // Remove all colons to work with just numbers
    final digitsOnly = text.replaceAll(':', '');
    
    if (digitsOnly.length > 4) {
      return oldValue;
    }
    
    final buffer = StringBuffer();
    
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2) {
        buffer.write(':');
      }
      buffer.write(digitsOnly[i]);
    }
    
    final formatted = buffer.toString();
    
    // Validate hours and minutes
    if (digitsOnly.length >= 2) {
      final hours = int.tryParse(digitsOnly.substring(0, 2));
      if (hours == null || hours > 23) {
        return oldValue;
      }
    }
    
    if (digitsOnly.length == 4) {
      final minutes = int.tryParse(digitsOnly.substring(2, 4));
      if (minutes == null || minutes > 59) {
        return oldValue;
      }
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class BimbinganScreen extends StatefulWidget {
  final UserProfileModel? userProfile;

  const BimbinganScreen({
    super.key,
    this.userProfile,
  });

  @override
  State<BimbinganScreen> createState() => _BimbinganScreenState();
}

class _BimbinganScreenState extends State<BimbinganScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserProfileModel _userProfile;
  final UserProfileService _profileService = UserProfileService();
  final BimbinganService _bimbinganService = BimbinganService();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize notification service
    _initializeNotifications();
    
    // Get profile from service or widget parameter
    _userProfile = widget.userProfile ?? _profileService.userProfile;
    
    // Reset service when screen is initialized
    _bimbinganService.reset();
    
    // Listen for profile changes
    _profileService.addListener(_onProfileChanged);
    _bimbinganService.addListener(_onBimbinganChanged);
    
    // Load data
    _loadData();
  }
  
  Future<void> _initializeNotifications() async {
    await NotificationService.initialize();
    await NotificationService.checkPermission();
  }
  
  @override
  void dispose() {
    _profileService.removeListener(_onProfileChanged);
    _bimbinganService.removeListener(_onBimbinganChanged);
    _tabController.dispose();
    super.dispose();
  }
  
  void _loadData() async {
    await _bimbinganService.loadBimbingan();
    setState(() {
      _isLoading = false;
    });
  }
  
  void _onBimbinganChanged() {
    if (mounted) {
      setState(() {});
    }
  }
  
  void _onProfileChanged() {
    setState(() {
      _userProfile = _profileService.userProfile;
    });
  }

  @override
Widget build(BuildContext context) {
  if (_isLoading) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bimbingan & Reminder')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Bimbingan & Reminder'),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Jadwal Bimbingan'),
          Tab(text: 'Reminder'),
        ],
      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: [
        // Tab Jadwal Bimbingan
        _buildJadwalTab(),
        
        // Tab Reminder
        _buildReminderTab(),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        if (_userProfile.supervisors.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Anda belum memiliki dosen pembimbing. Silakan tambahkan di halaman profil.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          _showAddBimbinganDialog();
        }
      },
      child: const Icon(Icons.add),
    ),
  );
}
  
Widget _buildJadwalTab() {
  if (_bimbinganService.bimbinganList.isEmpty) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Belum ada jadwal bimbingan',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Tekan tombol + untuk menambahkan jadwal bimbingan',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
  
  return ListView.builder(
    padding: const EdgeInsets.all(16.0),
    itemCount: _bimbinganService.bimbinganList.length,
    itemBuilder: (context, index) {
      return BimbinganListItem(
        key: ValueKey(_bimbinganService.bimbinganList[index].hashCode),
        bimbingan: _bimbinganService.bimbinganList[index],
        index: index,
        onEdit: () {
          _showEditBimbinganDialog(_bimbinganService.bimbinganList[index], index);
        },
        onDelete: () {
          _showDeleteConfirmationDialog(index);
        },
        onToggleReminder: (value) async {
          _bimbinganService.updateReminderStatus(index, value);
          
          final bimbingan = _bimbinganService.bimbinganList[index];
          if (value) {
            await NotificationService.scheduleReminderNotifications(bimbingan);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengingat diaktifkan'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            await NotificationService.cancelReminderNotifications(bimbingan);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengingat dinonaktifkan'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        },
      );
    },
  );
}
  
  Widget _buildReminderTab() {
    final activeReminders = _bimbinganService.bimbinganList
        .where((bimbingan) => bimbingan.reminderActive)
        .toList();
    
    if (activeReminders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada pengingat aktif',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Aktifkan pengingat pada jadwal bimbingan Anda',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: activeReminders.length,
      itemBuilder: (context, index) {
        final reminder = activeReminders[index];
        final originalIndex = _bimbinganService.bimbinganList.indexOf(reminder);
        
        return ReminderListItem(
          key: ValueKey(reminder.hashCode),
          reminder: reminder,
          onReminderToggle: (value) async {
            if (originalIndex != -1) {
              _bimbinganService.updateReminderStatus(originalIndex, value);
              
              if (value) {
                await NotificationService.scheduleReminderNotifications(reminder);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengingat diaktifkan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                await NotificationService.cancelReminderNotifications(reminder);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengingat dinonaktifkan'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            }
          },
        );
      },
    );
  }
  
  void _showAddBimbinganDialog() {
    late String dosenName = _userProfile.supervisors.isNotEmpty ? _userProfile.supervisors[0].name : "";
    late String dosenNIP = _userProfile.supervisors.isNotEmpty ? _userProfile.supervisors[0].nip : "";
    
    DateTime? selectedDate;
    final timeController = TextEditingController();
    final tempat = TextEditingController();
    bool isReminderActive = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Jadwalkan Bimbingan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Dosen Pembimbing',
                    border: OutlineInputBorder(),
                  ),
                  value: 0,
                  items: List.generate(
                    _userProfile.supervisors.length,
                    (index) => DropdownMenuItem<int>(
                      value: index,
                      child: Text(_userProfile.supervisors[index].name),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        dosenName = _userProfile.supervisors[value].name;
                        dosenNIP = _userProfile.supervisors[value].nip;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: selectedDate != null 
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : ''
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Waktu',
                    prefixIcon: Icon(Icons.access_time),
                    hintText: 'Contoh: 10:30',
                    border: OutlineInputBorder(),
                    helperText: 'Format: HH:MM (24 jam)',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                    LengthLimitingTextInputFormatter(5),
                    _TimeTextInputFormatter(),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: tempat,
                  decoration: const InputDecoration(
                    labelText: 'Tempat',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Aktifkan Pengingat'),
                  value: isReminderActive,
                  onChanged: (value) {
                    setDialogState(() {
                      isReminderActive = value;
                    });
                  },
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
              onPressed: () async {
                if (selectedDate != null && timeController.text.isNotEmpty && 
                    tempat.text.isNotEmpty) {
                  
                  final newBimbingan = BimbinganModel(
                    tanggal: selectedDate!,
                    waktu: timeController.text,
                    tempat: tempat.text,
                    dosen: dosenName,
                    nip: dosenNIP,
                    reminderActive: isReminderActive,
                  );
                  
                  _bimbinganService.addBimbingan(newBimbingan);
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Jadwal bimbingan berhasil ditambahkan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  if (isReminderActive) {
                    await NotificationService.scheduleReminderNotifications(newBimbingan);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mohon lengkapi semua data'),
                      backgroundColor: Colors.red,
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
  
  void _showEditBimbinganDialog(BimbinganModel bimbingan, int index) {
    late String dosenName = bimbingan.dosen;
    late String dosenNIP = bimbingan.nip;
    DateTime selectedDate = bimbingan.tanggal;
    final timeController = TextEditingController(text: bimbingan.waktu);
    final tempat = TextEditingController(text: bimbingan.tempat);
    bool isReminderActive = bimbingan.reminderActive;

    int selectedIndex = _userProfile.supervisors.indexWhere(
      (supervisor) => supervisor.nip == dosenNIP
    );
    
    if (selectedIndex == -1 && _userProfile.supervisors.isNotEmpty) {
      selectedIndex = 0;
      dosenName = _userProfile.supervisors[0].name;
      dosenNIP = _userProfile.supervisors[0].nip;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Jadwal Bimbingan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Dosen Pembimbing',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedIndex,
                  items: List.generate(
                    _userProfile.supervisors.length,
                    (index) => DropdownMenuItem<int>(
                      value: index,
                      child: Text(_userProfile.supervisors[index].name),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        dosenName = _userProfile.supervisors[value].name;
                        dosenNIP = _userProfile.supervisors[value].nip;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(
                    text: '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Waktu',
                    prefixIcon: Icon(Icons.access_time),
                    hintText: 'Contoh: 10:30',
                    border: OutlineInputBorder(),
                    helperText: 'Format: HH:MM (24 jam)',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                    LengthLimitingTextInputFormatter(5),
                    _TimeTextInputFormatter(),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: tempat,
                  decoration: const InputDecoration(
                    labelText: 'Tempat',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Aktifkan Pengingat'),
                  value: isReminderActive,
                  onChanged: (value) {
                    setDialogState(() {
                      isReminderActive = value;
                    });
                  },
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
              onPressed: () async {
                if (timeController.text.isNotEmpty && tempat.text.isNotEmpty) {
                  
                  final updatedBimbingan = BimbinganModel(
                    tanggal: selectedDate,
                    waktu: timeController.text,
                    tempat: tempat.text,
                    dosen: dosenName,
                    nip: dosenNIP,
                    reminderActive: isReminderActive,
                  );
                  
                  _bimbinganService.updateBimbingan(index, updatedBimbingan);
                  
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Jadwal bimbingan berhasil diperbarui'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  await NotificationService.cancelReminderNotifications(bimbingan);
                  if (isReminderActive) {
                    await NotificationService.scheduleReminderNotifications(updatedBimbingan);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mohon lengkapi semua data'),
                      backgroundColor: Colors.red,
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
  
  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal Bimbingan'),
        content: const Text('Apakah Anda yakin ingin menghapus jadwal bimbingan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              final bimbingan = _bimbinganService.bimbinganList[index];
              
              _bimbinganService.deleteBimbingan(index);
              
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jadwal bimbingan berhasil dihapus'),
                  backgroundColor: Colors.green,
                ),
              );
              
              await NotificationService.cancelReminderNotifications(bimbingan);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}