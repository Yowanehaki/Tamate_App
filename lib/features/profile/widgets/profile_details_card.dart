import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';

class ProfileDetailsCard extends StatelessWidget {
  final UserProfileModel profile;
  final VoidCallback? onEdit;

  const ProfileDetailsCard({
    super.key,
    required this.profile,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Avatar tanpa tombol kamera
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile.name.isEmpty ? 'Nama Belum Diisi' : profile.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              profile.nim.isEmpty ? 'NIM Belum Diisi' : profile.nim,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoRow(
              Icons.school, 
              profile.jurusan.isEmpty ? 'Program Studi Belum Diisi' : profile.jurusan
            ),
            _buildInfoRow(
              Icons.business, 
              profile.fakultas.isEmpty ? 'Fakultas Belum Diisi' : profile.fakultas
            ),
            _buildInfoRow(
              Icons.email, 
              profile.email.isEmpty ? 'Email Belum Diisi' : profile.email
            ),
            if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty)
              _buildInfoRow(Icons.phone, profile.phoneNumber!),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
                label: const Text('Edit Profil'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: text.contains('Belum Diisi') ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}