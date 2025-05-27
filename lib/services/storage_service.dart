import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _erpInstanceUrlKey = 'erp_instance_url';
  static const _authTokenKey = 'auth_token_sid'; // For session ID (sid)
  static const _userIdKey = 'user_id_email';
  static const _employeeNameKey = 'employee_name_id';
  static const _fullNameKey = 'full_name';


  final _secureStorage = const FlutterSecureStorage();

  // --- ERP Instance URL (using SharedPreferences as it's not super sensitive) ---
  Future<void> saveErpInstanceUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_erpInstanceUrlKey, url);
  }

  Future<String?> getErpInstanceUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_erpInstanceUrlKey);
  }

  Future<void> clearErpInstanceUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_erpInstanceUrlKey);
  }

  // --- Session Data (using FlutterSecureStorage for sensitive data) ---
  Future<void> saveSessionData({
    required String sid,
    required String userId,
    required String employeeName,
    required String fullName,
  }) async {
    await _secureStorage.write(key: _authTokenKey, value: sid);
    await _secureStorage.write(key: _userIdKey, value: userId);
    await _secureStorage.write(key: _employeeNameKey, value: employeeName);
    await _secureStorage.write(key: _fullNameKey, value: fullName);
  }

  Future<Map<String, String?>> getSessionData() async {
    final sid = await _secureStorage.read(key: _authTokenKey);
    final userId = await _secureStorage.read(key: _userIdKey);
    final employeeName = await _secureStorage.read(key: _employeeNameKey);
    final fullName = await _secureStorage.read(key: _fullNameKey);
    return {
      'sid': sid,
      'userId': userId,
      'employeeName': employeeName,
      'fullName': fullName,
    };
  }

  Future<void> clearSessionData() async {
    await _secureStorage.delete(key: _authTokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _employeeNameKey);
    await _secureStorage.delete(key: _fullNameKey);
  }
}
