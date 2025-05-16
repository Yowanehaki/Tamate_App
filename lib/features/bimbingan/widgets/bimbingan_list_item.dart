// lib/features/bimbingan/widgets/bimbingan_list_item.dart
import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/bimbingan_model.dart';

class BimbinganListItem extends StatelessWidget {
  final BimbinganModel bimbingan;
  final int index;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<bool>? onToggleReminder;

  const BimbinganListItem({
    super.key,
    required this.bimbingan,
    required this.index,
    this.onEdit,
    this.onDelete,
    this.onToggleReminder,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final bimbinganDateTime = DateTime(
      bimbingan.tanggal.year,
      bimbingan.tanggal.month,
      bimbingan.tanggal.day,
      int.parse(bimbingan.waktu.split(':')[0]),
      int.parse(bimbingan.waktu.split(':')[1]),
    );
    
    final difference = bimbinganDateTime.difference(now);
    final isPast = difference.isNegative;
    Color primaryColor = isPast ? Colors.grey : Colors.blue;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month, 
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Jadwal #${index + 1}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isPast ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (isPast)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person, 'Dosen', bimbingan.dosen, isPast: isPast),
            _buildInfoRow(Icons.numbers, 'NIP', bimbingan.nip, isPast: isPast),
            _buildInfoRow(Icons.event, 'Tanggal', DateFormatter.formatDate(bimbingan.tanggal), isPast: isPast),
            _buildInfoRow(Icons.access_time, 'Waktu', bimbingan.waktu, isPast: isPast),
            _buildInfoRow(Icons.location_on, 'Tempat', bimbingan.tempat, isPast: isPast),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      bimbingan.reminderActive ? Icons.notifications_active : Icons.notifications_off,
                      color: bimbingan.reminderActive ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pengingat',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPast ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: bimbingan.reminderActive,
                  activeColor: Colors.green,
                  onChanged: isPast ? null : onToggleReminder,
                ),
              ],
            ),
            if (bimbingan.reminderActive && !isPast) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.alarm_on, size: 14, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Notifikasi: 30 menit sebelum & tepat waktu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(Icons.edit, color: primaryColor),
                  label: Text('Edit', style: TextStyle(color: primaryColor)),
                  onPressed: onEdit,
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Hapus', style: TextStyle(color: Colors.red)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color, bool isPast = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon, 
            size: 18, 
            color: isPast 
                ? (color?.withOpacity(0.6) ?? Colors.grey) 
                : (color ?? Colors.blue),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPast ? Colors.grey[600] : Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isPast 
                    ? (color?.withOpacity(0.6) ?? Colors.grey[600]) 
                    : (color ?? Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}