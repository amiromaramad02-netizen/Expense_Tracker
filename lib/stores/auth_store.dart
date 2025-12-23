import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStore extends ChangeNotifier {
  static const _kUsersKey = 'users_map_v1'; // stored as 'email:password' lines
  static const _kCurrentKey = 'current_user_email_v1';
  static const _kUserNamePrefix = 'user_name_';
  static const _kSavedPassPrefix = 'saved_pass_';

  String? _currentEmail;
  String? _currentName;
  bool _initialized = false;

  bool get initialized => _initialized;
  String? get currentEmail => _currentEmail;
  String? get currentName => _currentName;
  bool get isAuthenticated => _currentEmail != null;
  bool get hasProfile => isAuthenticated && _currentName != null && _currentName!.isNotEmpty;

  AuthStore() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _currentEmail = prefs.getString(_kCurrentKey);
    if (_currentEmail != null) {
      _currentName = prefs.getString('$_kUserNamePrefix$_currentEmail');
    }
    _initialized = true;
    notifyListeners();
  }

  Future<bool> signUp(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_kUsersKey) ?? [];
    // check if exists
    for (final u in users) {
      final parts = u.split(':');
      if (parts.isNotEmpty && parts[0] == email) return false; // already exists
    }
    users.add('$email:$password');
    await prefs.setStringList(_kUsersKey, users);
    await prefs.setString(_kCurrentKey, email);
    _currentEmail = email;
    // Optionally we might save default remembered state later via UI
    notifyListeners();
    return true;
  }

  /// Save credentials locally for 'remember me' behavior.
  Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_kSavedPassPrefix$email', password);
  }

  Future<void> removeSavedCredentials(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_kSavedPassPrefix$email');
  }

  Future<String?> getSavedPassword(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_kSavedPassPrefix$email');
  }

  Future<bool> hasSavedCredentials(String email) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('$_kSavedPassPrefix$email');
  }

  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_kUsersKey) ?? [];
    for (final u in users) {
      final parts = u.split(':');
      if (parts.length >= 2 && parts[0] == email && parts[1] == password) {
        await prefs.setString(_kCurrentKey, email);
        _currentEmail = email;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCurrentKey);
    _currentEmail = null;
    notifyListeners();
  }

  Future<void> clearAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUsersKey);
    await logout();
  }

  Future<void> saveUserName(String name) async {
    if (!isAuthenticated) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_kUserNamePrefix$_currentEmail', name);
    _currentName = name;
    notifyListeners();
  }

  /// Return list of saved emails (registered users)
  Future<List<String>> getSavedEmails() async {
    final prefs = await SharedPreferences.getInstance();
    final users = prefs.getStringList(_kUsersKey) ?? [];
    return users.map((u) => u.split(':').first).toList();
  }
}

final authStore = AuthStore();
