// lib/core/services/milestone_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../../features/milestone/models/chapter_model.dart';
import '../../features/milestone/models/section_model.dart';

class MilestoneService extends ChangeNotifier {
  static final MilestoneService _instance = MilestoneService._internal();
  factory MilestoneService() => _instance;
  MilestoneService._internal();

  List<ChapterModel> _chapters = [];
  List<ChapterModel> get chapters => _chapters;

  // Default chapters template
  List<ChapterModel> _getDefaultChapters() {
    return [
      ChapterModel(
        title: 'BAB I - PENDAHULUAN',
        sections: [
          SectionModel(title: 'Latar Belakang'),
          SectionModel(title: 'Rumusan Masalah'),
          SectionModel(title: 'Tujuan Penelitian'),
          SectionModel(title: 'Batasan Masalah'),
          SectionModel(title: 'Manfaat Penelitian'),
          SectionModel(title: 'Sistematika Penulisan'),
        ],
        expanded: true,
      ),
      ChapterModel(
        title: 'BAB II - TINJAUAN PUSTAKA',
        sections: [
          SectionModel(title: 'Landasan Teori'),
          SectionModel(title: 'Penelitian Terdahulu'),
          SectionModel(title: 'Kerangka Pemikiran'),
        ],
        expanded: false,
      ),
      ChapterModel(
        title: 'BAB III - METODOLOGI PENELITIAN',
        sections: [
          SectionModel(title: 'Jenis Penelitian'),
          SectionModel(title: 'Teknik Pengumpulan Data'),
          SectionModel(title: 'Alat dan Bahan'),
          SectionModel(title: 'Metode Pengembangan Sistem'),
        ],
        expanded: false,
      ),
      ChapterModel(
        title: 'BAB IV - HASIL DAN PEMBAHASAN',
        sections: [
          SectionModel(title: 'Hasil Penelitian'),
          SectionModel(title: 'Analisis Data'),
          SectionModel(title: 'Interpretasi Hasil'),
          SectionModel(title: 'Implementasi Sistem'),
          SectionModel(title: 'Pengujian Sistem'),
        ],
        expanded: false,
      ),
      ChapterModel(
        title: 'BAB V - PENUTUP',
        sections: [
          SectionModel(title: 'Kesimpulan'),
          SectionModel(title: 'Saran'),
        ],
        expanded: false,
      ),
    ];
  }

  // Load chapters from SharedPreferences
  Future<void> loadChapters() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String key = 'milestone_${user.uid}';
    final String? chaptersJson = prefs.getString(key);
    
    if (chaptersJson != null) {
      final List<dynamic> decoded = json.decode(chaptersJson);
      _chapters = decoded.map((item) => ChapterModel.fromJson(item)).toList();
    } else {
      // If no saved data, use default chapters
      _chapters = _getDefaultChapters();
      _saveChapters(); // Save default chapters
    }
    notifyListeners();
  }

  // Save chapters to SharedPreferences
  Future<void> _saveChapters() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String key = 'milestone_${user.uid}';
    final String chaptersJson = json.encode(_chapters.map((c) => c.toJson()).toList());
    await prefs.setString(key, chaptersJson);
  }

  // Update section completion status
  void updateSectionCompletion(int chapterIndex, int sectionIndex, bool completed) {
    if (chapterIndex < _chapters.length && 
        sectionIndex < _chapters[chapterIndex].sections.length) {
      _chapters[chapterIndex].sections[sectionIndex].completed = completed;
      _chapters[chapterIndex].updateProgress();
      _saveChapters();
      notifyListeners();
    }
  }

  // Update chapter expanded status
  void updateChapterExpanded(int chapterIndex, bool expanded) {
    if (chapterIndex < _chapters.length) {
      _chapters[chapterIndex].expanded = expanded;
      _saveChapters();
      notifyListeners();
    }
  }

  // Add section to chapter
  void addSection(int chapterIndex, String title) {
    if (chapterIndex < _chapters.length) {
      _chapters[chapterIndex].sections.add(
        SectionModel(title: title, completed: false),
      );
      _chapters[chapterIndex].updateProgress();
      _saveChapters();
      notifyListeners();
    }
  }

  // Update section title
  void updateSectionTitle(int chapterIndex, int sectionIndex, String newTitle) {
    if (chapterIndex < _chapters.length && 
        sectionIndex < _chapters[chapterIndex].sections.length) {
      _chapters[chapterIndex].sections[sectionIndex] = 
          _chapters[chapterIndex].sections[sectionIndex].copyWith(title: newTitle);
      _saveChapters();
      notifyListeners();
    }
  }

  // Delete section
  void deleteSection(int chapterIndex, int sectionIndex) {
    if (chapterIndex < _chapters.length && 
        sectionIndex < _chapters[chapterIndex].sections.length) {
      _chapters[chapterIndex].sections.removeAt(sectionIndex);
      _chapters[chapterIndex].updateProgress();
      _saveChapters();
      notifyListeners();
    }
  }

  // Get overall progress
  double getOverallProgress() {
    int totalSections = 0;
    int completedSections = 0;

    for (var chapter in _chapters) {
      totalSections += chapter.sections.length;
      completedSections += chapter.sections.where((section) => section.completed).length;
    }

    return totalSections > 0 ? completedSections / totalSections : 0.0;
  }

  // Clear chapters (untuk UI saja, data tetap di storage)
  void clearChapters() {
    _chapters.clear();
    notifyListeners();
  }
}