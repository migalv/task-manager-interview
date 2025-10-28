import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../interfaces/user_operations.dart';

// UserManager handles user-related operations
class UserManager extends ChangeNotifier implements UserOperations {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDarkMode = false;
  String _selectedLanguage = 'en';
  Map<String, dynamic> _userPreferences = {};
  final bool _isOnline = true;

  // Getters for UI state
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;
  bool get isLoggedIn => _currentUser != null;
  bool get isOnline => _isOnline;

  // Authentication responsibility
  @override
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      // Validate login credentials
      if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
        _setError('Invalid email format');
        return false;
      }
      if (password.isEmpty || password.length < 8) {
        _setError('Password must be at least 8 characters');
        return false;
      }

      // Make API call to authenticate
      final response = await http.post(
        Uri.parse('https://api.example.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        _currentUser = _createUserFromJson(userData);

        // Save user data locally
        await _saveUserToPreferences(userData);
        await _loadUserPreferences();

        _setError(null);
        return true;
      } else {
        _setError('Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> logout() async {
    _setLoading(true);
    try {
      // API call to logout
      await http.post(Uri.parse('https://api.example.com/auth/logout'));

      // Clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      await prefs.remove('user_preferences');

      _currentUser = null;
      _userPreferences.clear();
      _setError(null);
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile information
  @override
  Future<void> updateProfile(String name, String email) async {
    if (_currentUser == null) {
      _setError('No user logged in');
      return;
    }

    _setLoading(true);
    try {
      // Validate profile data
      if (name.isEmpty || name.length < 2) {
        _setError('Name must be at least 2 characters');
        return;
      }
      if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
        _setError('Invalid email format');
        return;
      }

      // API call
      final response = await http.put(
        Uri.parse('https://api.example.com/users/${_currentUser!.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email}),
      );

      if (response.statusCode == 200) {
        // Update current user with new data
        final userData = jsonDecode(response.body);
        _currentUser = _createUserFromJson(userData);
        await _saveUserToPreferences(userData);
        _setError(null);
      } else {
        _setError('Update failed: ${response.body}');
      }
    } catch (e) {
      _setError('Update error: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  Future<void> changePassword(String newPassword) async {
    if (_currentUser == null) {
      _setError('No user logged in');
      return;
    }

    _setLoading(true);
    try {
      // Validate new password
      if (newPassword.isEmpty || newPassword.length < 8) {
        _setError('Password must be at least 8 characters');
        return;
      }
      if (!newPassword.contains(RegExp(r'[A-Z]'))) {
        _setError('Password must contain uppercase letter');
        return;
      }
      if (!newPassword.contains(RegExp(r'[0-9]'))) {
        _setError('Password must contain number');
        return;
      }

      final response = await http.put(
        Uri.parse('https://api.example.com/users/${_currentUser!.id}/password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': newPassword}),
      );

      if (response.statusCode == 200) {
        _setError(null);
      } else {
        _setError('Password change failed: ${response.body}');
      }
    } catch (e) {
      _setError('Password change error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // UI preferences management
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _savePreference('dark_mode', _isDarkMode);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _selectedLanguage = languageCode;
    await _savePreference('language', languageCode);
    notifyListeners();
  }

  // Session management
  Future<void> extendSession() async {
    try {
      await http.post(Uri.parse('https://api.example.com/auth/extend'));
    } catch (e) {
      _setError('Session extension failed: $e');
    }
  }

  // Helper methods that handle multiple responsibilities
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> _saveUserToPreferences(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getString('user_preferences');
    if (prefsJson != null) {
      _userPreferences = jsonDecode(prefsJson);
      _isDarkMode = _userPreferences['dark_mode'] ?? false;
      _selectedLanguage = _userPreferences['language'] ?? 'en';
    }
  }

  Future<void> _savePreference(String key, dynamic value) async {
    _userPreferences[key] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_preferences', jsonEncode(_userPreferences));
  }

  User _createUserFromJson(Map<String, dynamic> json) {
    final userType = json['type'] ?? 'regular';
    switch (userType) {
      case 'admin':
        return AdminUser(
          id: json['id'],
          name: json['name'],
          email: json['email'],
          managedDepartments: List<String>.from(
            json['managed_departments'] ?? [],
          ),
        );
      case 'guest':
        return GuestUser(
          id: json['id'],
          name: json['name'],
          email: json['email'],
        );
      default:
        return RegularUser(
          id: json['id'],
          name: json['name'],
          email: json['email'],
          department: json['department'] ?? 'General',
        );
    }
  }

  // Additional operations
  @override
  Future<List<String>> getAllUsers() async {
    // Get all users in the system
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> deleteUser(String userId) async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> promoteUserToAdmin(String userId) async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> demoteUserFromAdmin(String userId) async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> resetUserPassword(String userId, String newPassword) async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> backupDatabase() async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> restoreDatabase(String backupPath) async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> updateSystemSettings(Map<String, dynamic> settings) async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<List<String>> getSystemLogs() async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> requestAccount() async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> extendGuestSession() async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> sendEmailNotification(String userId, String message) async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> sendPushNotification(String userId, String message) async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> sendSMSNotification(String userId, String message) async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<Map<String, dynamic>> generateUserReport(String userId) async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<Map<String, dynamic>> generateSystemReport() async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> exportUserData(String userId, String format) async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> logUserAction(String userId, String action) async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<List<String>> getUserAuditLog(String userId) async {
    throw UnimplementedError('Not implemented in UserManager');
  }

  @override
  Future<void> clearAuditLogs() async {
    throw UnimplementedError('Not implemented in UserManager');
  }
}
