import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'username';
  static const String _keyApprovedDocuments = 'approved_documents';
  static const String _keyLastLoginUsername = 'last_login_username';

  // Check apakah username adalah admin (contains "admin")
  bool isAdminUser(String? username) {
    if (username == null || username.isEmpty) return false;
    return username.toLowerCase().contains('admin');
  }

  // Check apakah username adalah member (contains "member")
  bool isMemberUser(String? username) {
    if (username == null || username.isEmpty) return false;
    return username.toLowerCase().contains('member');
  }

  // Check apakah user sudah login
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get username yang tersimpan
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  // Login user
  Future<bool> login(String username, String password) async {
    // Simulasi validasi - dalam real app, ini akan hit API
    if (username.isNotEmpty && password.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUsername, username);
      // Save last login username (persist even after logout)
      await prefs.setString(_keyLastLoginUsername, username);
      return true;
    }
    return false;
  }

  // Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyApprovedDocuments); // Clear approval status
    // Note: _keyLastLoginUsername NOT removed - persist for next login
  }

  // Get last login username (tetap ada setelah logout)
  Future<String?> getLastLoginUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastLoginUsername);
  }

  /// Get list dokumen yang sudah di-approve oleh user
  Future<List<String>> getApprovedDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyApprovedDocuments);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Save dokumen yang sudah di-approve (menambahkan ke list existing)
  Future<void> saveApprovedDocument(String documentId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentApprovals = await getApprovedDocuments();

    // Cek apakah sudah ada, jika belum tambahkan
    if (!currentApprovals.contains(documentId)) {
      currentApprovals.add(documentId);
      final jsonString = jsonEncode(currentApprovals);
      await prefs.setString(_keyApprovedDocuments, jsonString);
    }
  }

  /// Clear semua approved documents (dipanggil saat logout)
  Future<void> clearApprovedDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyApprovedDocuments);
  }
}
