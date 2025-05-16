// lib/features/profile/models/user_profile_model.dart
class UserProfileModel {
  final String name;
  final String nim;
  final String email;
  final String jurusan;
  final String fakultas;
  final String? phoneNumber;
  final String? photoUrl;
  final List<Supervisor> supervisors;

  UserProfileModel({
    required this.name,
    required this.nim,
    required this.email,
    required this.jurusan,
    required this.fakultas,
    this.phoneNumber,
    this.photoUrl,
    required this.supervisors,
  });

  // Add fromJson and toJson methods
 // Update factory fromJson di user_profile_model.dart
factory UserProfileModel.fromJson(Map<String, dynamic> json) {
  return UserProfileModel(
    name: json['name'] ?? '',
    nim: json['nim'] ?? '',
    email: json['email'] ?? '',
    jurusan: json['jurusan'] ?? '', // Tidak ada default, biarkan kosong
    fakultas: json['fakultas'] ?? '', // Tidak ada default, biarkan kosong
    phoneNumber: json['phoneNumber'],
    photoUrl: json['photoUrl'],
    supervisors: (json['supervisors'] as List? ?? [])
        .map((s) => Supervisor.fromJson(s))
        .toList(),
  );
}

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nim': nim,
      'email': email,
      'jurusan': jurusan,
      'fakultas': fakultas,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'supervisors': supervisors.map((s) => s.toJson()).toList(),
    };
  }
}

class Supervisor {
  final String name;
  final String nip;
  final String phoneNumber;

  Supervisor({
    required this.name,
    required this.nip,
    required this.phoneNumber,
  });

  factory Supervisor.fromJson(Map<String, dynamic> json) {
    return Supervisor(
      name: json['name'] ?? '',
      nip: json['nip'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nip': nip,
      'phoneNumber': phoneNumber,
    };
  }
}