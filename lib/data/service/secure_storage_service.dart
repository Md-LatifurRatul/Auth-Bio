import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _biometricUsersKey = 'biometric_users';
  static const _userRolesKey = 'user_roles';

  /// Add or update a user for biometric login
  Future<void> addBiometricUser(String uid, String role) async {
    final map = await getBiometricUsers();
    map[uid] = role;
    await _storage.write(key: _biometricUsersKey, value: jsonEncode(map));
  }

  /// Remove a user from biometric list
  Future<void> removeBiometricUser(String uid) async {
    final map = await getBiometricUsers();
    map.remove(uid);
    await _storage.write(key: _biometricUsersKey, value: jsonEncode(map));
  }

  /// Get all saved biometric users (uid -> role)
  Future<Map<String, String>> getBiometricUsers() async {
    final raw = await _storage.read(key: _biometricUsersKey);
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw));
  }

  /// Set user role for a UID (used for normal login)
  Future<void> setUserRoleForUid(String uid, String role) async {
    final raw = await _storage.read(key: _userRolesKey);
    final map = raw == null ? <String, String>{} : Map<String, String>.from(jsonDecode(raw));
    map[uid] = role;
    await _storage.write(key: _userRolesKey, value: jsonEncode(map));
  }

  /// Get user role by UID
  Future<String?> getUserRole(String uid) async {
    final raw = await _storage.read(key: _userRolesKey);
    if (raw == null) return null;
    final map = Map<String, String>.from(jsonDecode(raw));
    return map[uid];
  }

  /// Clear all storage (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
