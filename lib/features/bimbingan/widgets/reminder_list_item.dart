// lib/features/bimbingan/widgets/reminder_list_item.dart
import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../models/bimbingan_model.dart';

class ReminderListItem extends StatelessWidget {
  final BimbinganModel reminder;
  final ValueChanged<bool>? onReminderToggle;

  const ReminderListItem({
    super.key,
    required this.reminder,
    this.onReminderToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Get combined datetime from reminder
    final now = DateTime.now();
    final reminderDateTime = DateTime(
      reminder.tanggal.year,
      reminder.tanggal.month,
      reminder.tanggal.day,
      int.parse(reminder.waktu.split(':')[0]),
      int.parse(reminder.waktu.split(':')[1]),
    );
    
    // Calculate time difference
    final difference = reminderDateTime.difference(now);
    final isPast = difference.isNegative;
    final daysRemaining = difference.inDays;
    final hoursRemaining = difference.inHours;
    final minutesRemaining = difference.inMinutes % 60;
    
    // Determine status and color
    String timeStatus;
    Color urgencyColor;
    
    if (isPast) {
      // Already passed
      urgencyColor = Colors.grey;
      final absDifference = now.difference(reminderDateTime);
      if (absDifference.inMinutes < 60) {
        timeStatus = 'Lewat ${absDifference.inMinutes} menit';
      } else if (absDifference.inHours < 24) {
        timeStatus = 'Lewat ${absDifference.inHours} jam';
      } else {
        timeStatus = 'Lewat ${absDifference.inDays} hari';
      }
    } else {
      // Future appointment
      if (hoursRemaining == 0 && minutesRemaining < 30) {
        urgencyColor = Colors.red;
        timeStatus = 'Dalam $minutesRemaining menit!';
      } else if (hoursRemaining < 24) {
        urgencyColor = Colors.orange;
        if (hoursRemaining == 0) {
          timeStatus = 'Dalam $minutesRemaining menit';
        } else {
          timeStatus = 'Dalam $hoursRemaining jam $minutesRemaining menit';
        }
      } else if (daysRemaining == 0) {
        urgencyColor = Colors.orange;
        timeStatus = 'Hari ini ${reminder.waktu}';
      } else if (daysRemaining == 1) {
        urgencyColor = Colors.blue;
        timeStatus = 'Besok ${reminder.waktu}';
      } else if (daysRemaining < 7) {
        urgencyColor = Colors.green;
        timeStatus = 'Dalam $daysRemaining hari';
      } else {
        urgencyColor = Colors.green;
        timeStatus = 'Dalam $daysRemaining hari';
      }
    }
    
    // Icon based on status
    IconData statusIcon;
    if (isPast) {
      statusIcon = Icons.history;
    } else if (hoursRemaining == 0 && minutesRemaining < 30) {
      statusIcon = Icons.warning;
    } else {
      statusIcon = Icons.notifications_active;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: urgencyColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading avatar
            CircleAvatar(
              backgroundColor: urgencyColor.withOpacity(0.2),
              radius: 20,
              child: Icon(statusIcon, color: urgencyColor, size: 24),
            ),
            const SizedBox(width: 12),
            
            // Content - Use Expanded to prevent overflow
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Bimbingan dengan ${reminder.dosen}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isPast ? Colors.grey[600] : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Date and Time in Column for better layout
                  Row(
                    children: [
                      Icon(
                        Icons.event, 
                        size: 16, 
                        color: isPast ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatDate(reminder.tanggal),
                        style: TextStyle(
                          fontSize: 14,
                          color: isPast ? Colors.grey[500] : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time, 
                        size: 16, 
                        color: isPast ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reminder.waktu,
                        style: TextStyle(
                          fontSize: 14,
                          color: isPast ? Colors.grey[500] : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on, 
                        size: 16, 
                        color: isPast ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          reminder.tempat,
                          style: TextStyle(
                            fontSize: 14,
                            color: isPast ? Colors.grey[500] : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Time status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: urgencyColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer, size: 16, color: urgencyColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            timeStatus,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: urgencyColor,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Notification status (if reminder is active and not past)
                  if (reminder.reminderActive && !isPast) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.alarm_on,
                          size: 14,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Notifikasi aktif',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[600],
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Trailing switch - removed extra width
            Switch(
              value: reminder.reminderActive,
              activeColor: isPast ? Colors.grey : Colors.blue,
              onChanged: isPast ? null : onReminderToggle,
            ),
          ],
        ),
      ),
    );
  }
}