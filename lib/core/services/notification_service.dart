// lib/core/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/bimbingan/models/bimbingan_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _notifications.initialize(initSettings);
    
    const androidChannel = AndroidNotificationChannel(
      'bimbingan_channel',
      'Bimbingan Notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(androidChannel);
    }
  }
  
  static Future<void> scheduleReminderNotifications(BimbinganModel reminder) async {
    if (!reminder.reminderActive) return;
    
    // Parse waktu dari string "HH:MM"
    final timeParts = reminder.waktu.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    // Buat DateTime dari tanggal dan waktu yang diinput user
    final scheduledDateTime = DateTime(
      reminder.tanggal.year,
      reminder.tanggal.month,
      reminder.tanggal.day,
      hour,
      minute,
    );
    
    // Skip jika waktu sudah lewat
    if (scheduledDateTime.isBefore(DateTime.now())) {
      return;
    }
    
    const androidDetails = AndroidNotificationDetails(
      'bimbingan_channel',
      'Bimbingan Notifications',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );
    
    const notificationDetails = NotificationDetails(android: androidDetails);
    
    // ID unik berdasarkan waktu bimbingan
    final uniqueId = '${reminder.tanggal.day}${reminder.tanggal.month}$hour$minute'.hashCode;
    
    // Schedule notifikasi tepat waktu
    final tzScheduled = tz.TZDateTime.from(scheduledDateTime, tz.local);
    await _notifications.zonedSchedule(
      uniqueId,
      '⏰ Bimbingan Dimulai!',
      'Bimbingan dengan ${reminder.dosen} di ${reminder.tempat}',
      tzScheduled,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    
    // Schedule notifikasi 30 menit sebelum
    final thirtyMinBefore = scheduledDateTime.subtract(const Duration(minutes: 30));
    if (thirtyMinBefore.isAfter(DateTime.now())) {
      final tz30 = tz.TZDateTime.from(thirtyMinBefore, tz.local);
      await _notifications.zonedSchedule(
        uniqueId + 1,
        '🔔 Pengingat Bimbingan',
        'Bimbingan dengan ${reminder.dosen} akan dimulai dalam 30 menit di ${reminder.tempat}',
        tz30,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
  
  static Future<void> cancelReminderNotifications(BimbinganModel reminder) async {
    final timeParts = reminder.waktu.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    final uniqueId = '${reminder.tanggal.day}${reminder.tanggal.month}$hour$minute'.hashCode;
    
    await _notifications.cancel(uniqueId);
    await _notifications.cancel(uniqueId + 1);
  }
  
  static Future<bool> checkPermission() async {
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.areNotificationsEnabled();
      
      if (granted != true) {
        return await androidImplementation.requestNotificationsPermission() ?? false;
      }
      
      return granted ?? false;
    }
    
    return true;
  }
}