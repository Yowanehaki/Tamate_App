// lib/core/services/logbook_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../../features/logbook/models/logbook_entry_model.dart';

class LogbookService extends ChangeNotifier {
  static final LogbookService _instance = LogbookService._internal();
  factory LogbookService() => _instance;
  LogbookService._internal();

  List<LogbookEntryModel> _entries = [];
  List<LogbookEntryModel> get entries => _entries;

  // Load entries from SharedPreferences
  Future<void> loadEntries() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String key = 'logbook_${user.uid}';
    final String? entriesJson = prefs.getString(key);
    
    if (entriesJson != null) {
      final List<dynamic> decoded = json.decode(entriesJson);
      _entries = decoded.map((item) => LogbookEntryModel.fromJson(item)).toList();
      notifyListeners();
    }
  }

  // Save entries to SharedPreferences
  Future<void> _saveEntries() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String key = 'logbook_${user.uid}';
    final String entriesJson = json.encode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(key, entriesJson);
  }

  // Add entry
  void addEntry(LogbookEntryModel entry) {
    _entries.insert(0, entry);
    _saveEntries();
    notifyListeners();
  }

  // Update entry  
  void updateEntry(int index, LogbookEntryModel entry) {
    if (index >= 0 && index < _entries.length) {
      _entries[index] = entry;
      _saveEntries();
      notifyListeners();
    }
  }

  // Delete entry
  void deleteEntry(LogbookEntryModel entry) {
    _entries.remove(entry);
    _saveEntries();
    notifyListeners();
  }

  // Sort entries
  void sortEntries(int Function(LogbookEntryModel, LogbookEntryModel) compare) {
    _entries.sort(compare);
    _saveEntries();
    notifyListeners();
  }

  // Clear entries (untuk UI saja, data tetap di storage)
  void clearEntries() {
    _entries.clear();
    notifyListeners();
  }
}