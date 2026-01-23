import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'username';
  static const String _keyHasApproved = 'has_approved';
  static const String _keyLastLoginUsername = 'last_login_username';

  // Check apakah username adalah admin (contains "admin")
  bool isAdminUser(String? username) {
    if (username == null || username.isEmpty) return false;
    return username.toLowerCase().contains('admin');
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
    await prefs.remove(_keyHasApproved); // Clear approval status
    // Note: _keyLastLoginUsername NOT removed - persist for next login
  }

  // Get last login username (tetap ada setelah logout)
  Future<String?> getLastLoginUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastLoginUsername);
  }

  // Check apakah admin sudah approve
  Future<bool> hasApproved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasApproved) ?? false;
  }

  // Save approval status
  Future<void> saveApproval() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasApproved, true);
  }
}
