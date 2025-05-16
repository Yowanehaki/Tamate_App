// lib/features/milestone/models/chapter_model.dart
import 'section_model.dart';

class ChapterModel {
  final String title;
  final List<SectionModel> sections;
  bool expanded;
  double progress;

  ChapterModel({
    required this.title,
    required this.sections,
    this.expanded = false,
    this.progress = 0.0,
  });

  void updateProgress() {
    if (sections.isEmpty) {
      progress = 0.0;
      return;
    }

    int completedCount = sections.where((section) => section.completed).length;
    progress = completedCount / sections.length;
  }

  ChapterModel copyWith({
    String? title,
    List<SectionModel>? sections,
    bool? expanded,
    double? progress,
  }) {
    return ChapterModel(
      title: title ?? this.title,
      sections: sections ?? this.sections,
      expanded: expanded ?? this.expanded,
      progress: progress ?? this.progress,
    );
  }

  // Convert to JSON untuk save ke storage
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'sections': sections.map((s) => s.toJson()).toList(),
      'expanded': expanded,
      'progress': progress,
    };
  }

  // Create from JSON
  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      title: json['title'],
      sections: (json['sections'] as List)
          .map((s) => SectionModel.fromJson(s))
          .toList(),
      expanded: json['expanded'] ?? false,
      progress: json['progress']?.toDouble() ?? 0.0,
    );
  }
}