// logbook_entry_model.dart
class LogbookEntryModel {
  final DateTime tanggal;
  final String kategori;
  final String deskripsi;

  LogbookEntryModel({
    required this.tanggal,
    required this.kategori,
    required this.deskripsi,
  });

  // Convert to JSON untuk save ke storage
  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal.toIso8601String(),
      'kategori': kategori,
      'deskripsi': deskripsi,
    };
  }

  // Create from JSON
  factory LogbookEntryModel.fromJson(Map<String, dynamic> json) {
    return LogbookEntryModel(
      tanggal: DateTime.parse(json['tanggal']),
      kategori: json['kategori'],
      deskripsi: json['deskripsi'],
    );
  }
}