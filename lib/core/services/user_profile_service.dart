// lib/core/services/user_profile_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../../features/profile/models/user_profile_model.dart';

class UserProfileService extends ChangeNotifier {
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  UserProfileModel _userProfile = UserProfileModel(
    name: '',
    nim: '',
    email: '',
    jurusan: '',
    fakultas: '',
    phoneNumber: null,
    supervisors: [],
  );

  UserProfileModel get userProfile => _userProfile;

  // Load profile from SharedPreferences
  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String key = 'profile_${user.uid}';
    final String? profileJson = prefs.getString(key);
    
    // Cek apakah ini first time login untuk user ini
    final String firstLoginKey = 'first_login_${user.uid}';
    final bool isFirstLogin = prefs.getBool(firstLoginKey) ?? true;
    
    if (profileJson != null) {
      final decodedProfile = json.decode(profileJson);
      
      // Jika first login, reset jurusan dan fakultas
      if (isFirstLogin) {
        decodedProfile['jurusan'] = '';
        decodedProfile['fakultas'] = '';
        // Tandai sudah login
        await prefs.setBool(firstLoginKey, false);
      }
      
      _userProfile = UserProfileModel.fromJson(decodedProfile);
      
      // Jika first login, simpan perubahan
      if (isFirstLogin) {
        await _saveProfile();
      }
    } else {
      // User baru
      _userProfile = UserProfileModel(
        name: user.displayName ?? '',
        nim: '',
        email: user.email ?? '',
        jurusan: '', // KOSONG
        fakultas: '', // KOSONG
        phoneNumber: null,
        supervisors: [],
      );
      // Tandai sudah login
      await prefs.setBool(firstLoginKey, false);
      await _saveProfile();
    }
    notifyListeners();
  }

  // Save profile to SharedPreferences
  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String key = 'profile_${user.uid}';
    await prefs.setString(key, json.encode(_userProfile.toJson()));
  }

  void updateProfile(UserProfileModel profile) {
    _userProfile = profile;
    _saveProfile();
    notifyListeners();
  }

  // Clear profile (for logout)
  void clearProfile() {
    _userProfile = UserProfileModel(
      name: '',
      nim: '',
      email: '',
      jurusan: '',
      fakultas: '',
      phoneNumber: null,
      supervisors: [],
    );
    notifyListeners();
  }
}