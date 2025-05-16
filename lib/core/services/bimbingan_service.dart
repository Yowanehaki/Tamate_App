// lib/core/services/bimbingan_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../../features/bimbingan/models/bimbingan_model.dart';

class BimbinganService extends ChangeNotifier {
  static final BimbinganService _instance = BimbinganService._internal();
  factory BimbinganService() => _instance;
  BimbinganService._internal();

  List<BimbinganModel> _bimbinganList = [];
  List<BimbinganModel> get bimbinganList => _bimbinganList;

  // Load entries from SharedPreferences
  Future<void> loadBimbingan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _bimbinganList = [];
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String key = 'bimbingan_${user.uid}';
    final String? bimbinganJson = prefs.getString(key);
    
    if (bimbinganJson != null) {
      final List<dynamic> decoded = json.decode(bimbinganJson);
      _bimbinganList = decoded.map((item) => BimbinganModel.fromJson(item)).toList();
    } else {
      _bimbinganList = []; // Clear list if no data found
    }
    notifyListeners();
  }

  // Save entries to SharedPreferences
  Future<void> _saveBimbingan() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String key = 'bimbingan_${user.uid}';
    final String bimbinganJson = json.encode(_bimbinganList.map((b) => b.toJson()).toList());
    await prefs.setString(key, bimbinganJson);
  }

  // Add bimbingan
  void addBimbingan(BimbinganModel bimbingan) {
    _bimbinganList.add(bimbingan);
    _saveBimbingan();
    notifyListeners();
  }

  // Update bimbingan
  void updateBimbingan(int index, BimbinganModel bimbingan) {
    if (index >= 0 && index < _bimbinganList.length) {
      _bimbinganList[index] = bimbingan;
      _saveBimbingan();
      notifyListeners();
    }
  }

  // Delete bimbingan
  void deleteBimbingan(int index) {
    if (index >= 0 && index < _bimbinganList.length) {
      _bimbinganList.removeAt(index);
      _saveBimbingan();
      notifyListeners();
    }
  }

  // Update reminder status
  void updateReminderStatus(int index, bool status) {
    if (index >= 0 && index < _bimbinganList.length) {
      _bimbinganList[index].reminderActive = status;
      _saveBimbingan();
      notifyListeners();
    }
  }

  // Clear entries (untuk UI saja, data tetap di storage)
  void clearBimbingan() {
    _bimbinganList.clear();
    notifyListeners();
  }
  
  // Reset service state (untuk saat user ganti)
  void reset() {
    _bimbinganList = [];
    notifyListeners();
  }
}