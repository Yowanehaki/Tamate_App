// lib/features/milestone/models/section_model.dart
class SectionModel {
  final String title;
  bool completed;

  SectionModel({
    required this.title,
    this.completed = false,
  });

  SectionModel copyWith({
    String? title,
    bool? completed,
  }) {
    return SectionModel(
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  // Convert to JSON untuk save ke storage
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'completed': completed,
    };
  }

  // Create from JSON
  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      title: json['title'],
      completed: json['completed'] ?? false,
    );
  }
}