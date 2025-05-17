// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/user_profile_model.dart';
import 'widgets/profile_details_card.dart';
import '../../../core/services/user_profile_service.dart';
import '../../../core/services/logbook_service.dart';
import '../../../core/services/milestone_service.dart';
import '../../../core/services/bimbingan_service.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _profileService.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    _profileService.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _loadProfile() async {
    await _profileService.loadProfile();
    setState(() {
      _isLoading = false;
    });
  }

  void _onProfileChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Profil'),
          automaticallyImplyLeading: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileDetailsCard(
              profile: _profileService.userProfile,
              onEdit: _showEditProfileDialog,
            ),
            const SizedBox(height: 8),
            _buildSupervisorsCard(),
            const SizedBox(height: 8),
            _buildAdditionalOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSupervisorsCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dosen Pembimbing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: _showEditSupervisorsDialog,
                  tooltip: 'Edit Dosen Pembimbing',
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            if (_profileService.userProfile.supervisors.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Belum ada dosen pembimbing',
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ..._profileService.userProfile.supervisors.map((supervisor) => _buildSupervisorItem(supervisor)),
          ],
        ),
      ),
    );
  }

  Widget _buildSupervisorItem(Supervisor supervisor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            supervisor.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'NIP: ${supervisor.nip}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                supervisor.phoneNumber,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Pengaturan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Bantuan'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Bantuan Aplikasi'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Home Screen', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Menampilkan ringkasan aktivitas, progress tesis, dan pengumuman penting. Anda dapat melihat jadwal bimbingan mendatang dan milestone terdekat.'),
                            SizedBox(height: 12),
                            
                            Text('Profile Screen', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Untuk mengatur informasi profil Anda, termasuk data diri, kontak, dan informasi akademik.'),
                            SizedBox(height: 12),
                            
                            Text('Logbook', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Untuk mencatat dan mengubah aktivitas terkait pengerjaan tugas akhir. Anda dapat menambahkan entri baru dan mengedit entri yang sudah ada.'),
                            SizedBox(height: 12),
                            
                            Text('Milestone', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Menampilkan progress pengerjaan tugas akhir Anda. Anda dapat melihat tahapan yang sudah diselesaikan dan yang masih harus dikerjakan.'),
                            SizedBox(height: 12),
                            
                            Text('Jadwalkan Bimbingan', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Untuk membuat jadwal bimbingan dengan dosen pembimbing. Anda dapat memilih tanggal, waktu, dan topik bimbingan.'),
                            SizedBox(height: 12),
                            
                            Text('Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Fitur untuk mengingatkan Anda tentang jadwal bimbingan yang telah direncanakan. Notifikasi akan muncul sebelum jadwal bimbingan.'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Tutup'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
                leading: const Icon(Icons.attribution),
                title: const Text('Credits'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: const Color.fromARGB(255, 232, 232, 236), // warna item soft
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Pengembangan Aplikasi Mobile!',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Mulfi Hazwi Artaf [122140186]',
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Muhammad Faza  [122140199]',
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Naufal Saqib Athaya [122140072]',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar', style: TextStyle(color: Colors.red)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Konfirmasi Logout'),
                      content: const Text('Apakah Anda yakin ingin keluar?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            
                            try {
                              // Clear all services data
                              _profileService.clearProfile();
                              LogbookService().clearEntries();
                              MilestoneService().clearChapters();
                              BimbinganService().clearBimbingan();
                              BimbinganService().reset();
                              
                              // Logout dari Firebase
                              await FirebaseAuth.instance.signOut();
                              
                              if (context.mounted) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/login', 
                                  (Route<dynamic> route) => false,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal logout: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Keluar'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final profile = _profileService.userProfile;
    final nameController = TextEditingController(text: profile.name);
    final nimController = TextEditingController(text: profile.nim);
    final emailController = TextEditingController(text: profile.email);
    final phoneController = TextEditingController(text: profile.phoneNumber ?? '');
    final jurusanController = TextEditingController(text: profile.jurusan);
    final fakultasController = TextEditingController(text: profile.fakultas);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Nama field
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap',
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              
              // NIM field
              TextFormField(
                controller: nimController,
                decoration: InputDecoration(
                  labelText: 'NIM',
                  hintText: 'Masukkan NIM',
                  prefixIcon: const Icon(Icons.badge, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              
              // Email field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Masukkan email',
                  prefixIcon: const Icon(Icons.email, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              
              // Phone field
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'No. Telepon',
                  hintText: 'Masukkan nomor telepon',
                  prefixIcon: const Icon(Icons.phone, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              // Jurusan field
              TextFormField(
                controller: jurusanController,
                decoration: InputDecoration(
                  labelText: 'Program Studi',
                  hintText: 'Masukkan program studi',
                  prefixIcon: const Icon(Icons.school, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  helperText: 'Contoh: Teknik Informatika, Sistem Informasi, dll',
                  helperStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              
              // Fakultas field
              TextFormField(
                controller: fakultasController,
                decoration: InputDecoration(
                  labelText: 'Fakultas',
                  hintText: 'Masukkan fakultas',
                  prefixIcon: const Icon(Icons.business, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  helperText: 'Contoh: Fakultas Teknologi Industri, FMIPA, dll',
                  helperStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedProfile = UserProfileModel(
                name: nameController.text,
                nim: nimController.text,
                email: emailController.text,
                jurusan: jurusanController.text,
                fakultas: fakultasController.text,
                phoneNumber: phoneController.text.isEmpty ? null : phoneController.text,
                supervisors: profile.supervisors,
              );
              
              _profileService.updateProfile(updatedProfile);
              
              // Update Firebase Auth display name
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null && currentUser.displayName != nameController.text) {
                try {
                  await currentUser.updateDisplayName(nameController.text);
                } catch (e) {
                  debugPrint('Failed to update display name: $e');
                }
              }
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profil berhasil diperbarui'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditSupervisorsDialog() {
    final profile = _profileService.userProfile;
    
    final name1Controller = TextEditingController(
        text: profile.supervisors.isNotEmpty ? profile.supervisors[0].name : '');
    final nip1Controller = TextEditingController(
        text: profile.supervisors.isNotEmpty ? profile.supervisors[0].nip : '');
    final phone1Controller = TextEditingController(
        text: profile.supervisors.isNotEmpty ? profile.supervisors[0].phoneNumber : '');

    final name2Controller = TextEditingController(
        text: profile.supervisors.length > 1 ? profile.supervisors[1].name : '');
    final nip2Controller = TextEditingController(
        text: profile.supervisors.length > 1 ? profile.supervisors[1].nip : '');
    final phone2Controller = TextEditingController(
        text: profile.supervisors.length > 1 ? profile.supervisors[1].phoneNumber : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Edit Dosen Pembimbing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dosen Pembimbing 1',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: name1Controller,
                decoration: InputDecoration(
                  labelText: 'Nama Dosen',
                  hintText: 'Masukkan nama dosen',
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nip1Controller,
                decoration: InputDecoration(
                  labelText: 'NIP',
                  hintText: 'Masukkan NIP dosen',
                  prefixIcon: const Icon(Icons.badge, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phone1Controller,
                decoration: InputDecoration(
                  labelText: 'No. Telepon',
                  hintText: 'Masukkan nomor telepon',
                  prefixIcon: const Icon(Icons.phone, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              const Text(
                'Dosen Pembimbing 2',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: name2Controller,
                decoration: InputDecoration(
                  labelText: 'Nama Dosen',
                  hintText: 'Masukkan nama dosen',
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nip2Controller,
                decoration: InputDecoration(
                  labelText: 'NIP',
                  hintText: 'Masukkan NIP dosen',
                  prefixIcon: const Icon(Icons.badge, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phone2Controller,
                decoration: InputDecoration(
                  labelText: 'No. Telepon',
                  hintText: 'Masukkan nomor telepon',
                  prefixIcon: const Icon(Icons.phone, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final supervisors = <Supervisor>[];
              
              if (name1Controller.text.isNotEmpty) {
                supervisors.add(Supervisor(
                  name: name1Controller.text,
                  nip: nip1Controller.text,
                  phoneNumber: phone1Controller.text,
                ));
              }
              
              if (name2Controller.text.isNotEmpty) {
                supervisors.add(Supervisor(
                  name: name2Controller.text,
                  nip: nip2Controller.text,
                  phoneNumber: phone2Controller.text,
                ));
              }

              final updatedProfile = UserProfileModel(
                name: profile.name,
                nim: profile.nim,
                email: profile.email,
                jurusan: profile.jurusan,
                fakultas: profile.fakultas,
                phoneNumber: profile.phoneNumber,
                supervisors: supervisors,
              );
              
              _profileService.updateProfile(updatedProfile);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dosen pembimbing berhasil diperbarui'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}