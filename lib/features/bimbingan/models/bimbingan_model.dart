// lib/features/bimbingan/models/bimbingan_model.dart
class BimbinganModel {
  final DateTime tanggal;
  final String waktu;
  final String tempat;
  final String dosen;
  final String nip;
  bool reminderActive;

  BimbinganModel({
    required this.tanggal,
    required this.waktu,
    required this.tempat,
    required this.dosen,
    required this.nip,
    this.reminderActive = true,
  });

  int get daysRemaining => tanggal.difference(DateTime.now()).inDays;

  BimbinganModel copyWith({
    DateTime? tanggal,
    String? waktu,
    String? tempat,
    String? dosen,
    String? nip,
    String? status,
    bool? reminderActive,
  }) {
    return BimbinganModel(
      tanggal: tanggal ?? this.tanggal,
      waktu: waktu ?? this.waktu,
      tempat: tempat ?? this.tempat,
      dosen: dosen ?? this.dosen,
      nip: nip ?? this.nip,
      reminderActive: reminderActive ?? this.reminderActive,
    );
  }

  // Convert to JSON untuk save ke storage
  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal.toIso8601String(),
      'waktu': waktu,
      'tempat': tempat,
      'dosen': dosen,
      'nip': nip,
      'reminderActive': reminderActive,
    };
  }

  // Create from JSON
  factory BimbinganModel.fromJson(Map<String, dynamic> json) {
    return BimbinganModel(
      tanggal: DateTime.parse(json['tanggal']),
      waktu: json['waktu'],
      tempat: json['tempat'],
      dosen: json['dosen'],
      nip: json['nip'],
      reminderActive: json['reminderActive'] ?? true,
    );
  }
}