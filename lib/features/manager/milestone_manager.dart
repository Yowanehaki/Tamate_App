// lib/core/manager/milestone_manager.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MilestoneManager extends ChangeNotifier {
  // Singleton instance
  static final MilestoneManager _instance = MilestoneManager._internal();
  
  factory MilestoneManager() {
    return _instance;
  }
  
  MilestoneManager._internal() {
    // Initialize listener untuk auth changes
    _initAuthListener();
  }
  
  // Progress per bab (0-4 untuk BAB I-V)
  final Map<int, double> _chapterProgress = {0: 0.0, 1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0};
  
  // Progress keseluruhan
  double _overallProgress = 0.0;
  
  // Current user ID
  String? _currentUserId;
  
  // Initialize auth listener
  void _initAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && user.uid != _currentUserId) {
        _currentUserId = user.uid;
        _loadProgress();
      } else if (user == null) {
        _clearLocalData();
      }
    });
  }
  
  // Getter
  double getChapterProgress(int index) => _chapterProgress[index] ?? 0.0;
  
  double get overallProgress => _overallProgress;
  
  // Update progress per chapter
  void updateChapterProgress(int index, double progress) {
    _chapterProgress[index] = progress;
    _saveProgress();
    notifyListeners();
  }
  
  // Update progress keseluruhan
  void updateOverallProgress(double progress) {
    _overallProgress = progress;
    _saveProgress();
    notifyListeners();
  }
  
  // Load progress dari SharedPreferences berdasarkan user ID
  Future<void> _loadProgress() async {
    if (_currentUserId == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Load progress per chapter dengan user ID
    for (int i = 0; i < 5; i++) {
      _chapterProgress[i] = prefs.getDouble('${_currentUserId}_chapter_progress_$i') ?? 0.0;
    }
    
    // Load overall progress
    _overallProgress = prefs.getDouble('${_currentUserId}_overall_progress') ?? 0.0;
    
    notifyListeners();
  }
  
  // Save progress ke SharedPreferences dengan user ID
  Future<void> _saveProgress() async {
    if (_currentUserId == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Save progress per chapter
    for (int i = 0; i < 5; i++) {
      await prefs.setDouble('${_currentUserId}_chapter_progress_$i', _chapterProgress[i] ?? 0.0);
    }
    
    // Save overall progress
    await prefs.setDouble('${_currentUserId}_overall_progress', _overallProgress);
  }
  
  // Clear local data only (tidak hapus dari SharedPreferences)
  void _clearLocalData() {
    for (int i = 0; i < 5; i++) {
      _chapterProgress[i] = 0.0;
    }
    _overallProgress = 0.0;
    _currentUserId = null;
    notifyListeners();
  }
  
  // Method untuk clear progress dari SharedPreferences (dipanggil saat logout)
  Future<void> clearProgress() async {
    if (_currentUserId == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Clear all progress data untuk user saat ini
    for (int i = 0; i < 5; i++) {
      await prefs.remove('${_currentUserId}_chapter_progress_$i');
    }
    await prefs.remove('${_currentUserId}_overall_progress');
    
    _clearLocalData();
  }
  
  // Reset dan reload progress (dipanggil saat login/register)
  Future<void> resetAndReload() async {
    await _loadProgress();
  }
}