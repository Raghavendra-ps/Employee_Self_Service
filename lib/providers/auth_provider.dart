import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../services/erpnext_api_service.dart'; // We'll create this
import 'erp_instance_provider.dart';


class AuthProvider with ChangeNotifier {
  final ErpInstanceProvider _erpInstanceProvider;
  final StorageService _storageService;
  late ErpNextApiService _apiService; // Will be initialized

  String? _sid; // Session ID from ERPNext
  String? _userId; // email/username
  String? _employeeName; // e.g. EMP/0001
  String? _fullName;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  AuthProvider(
    this._erpInstanceProvider,
    this._storageService, {
    String? initialAuthToken,
    String? initialUserId,
    String? initialEmployeeName,
    String? initialFullName,
  }) {
    _sid = initialAuthToken;
    _userId = initialUserId;
    _employeeName = initialEmployeeName;
    _fullName = initialFullName;
    _isLoggedIn = _sid != null && _sid!.isNotEmpty;
    // Initialize ApiService here, it needs the ErpInstanceProvider
    _apiService = ErpNextApiService(_erpInstanceProvider);
  }


  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get currentUserId => _userId;
  String? get currentEmployeeName => _employeeName;
  String? get currentFullName => _fullName;
  String? get currentSessionId => _sid;


  Future<void> login(String username, String password) async {
    if (_erpInstanceProvider.erpInstanceUrl == null) {
      throw Exception("ERPNext instance URL is not configured.");
    }
    _isLoading = true;
    notifyListeners();

    try {
      final loginData = await _apiService.login(username, password);

      _sid = loginData['sid'];
      _userId = loginData['user_id'];
      _fullName = loginData['full_name'];

      // Crucial: Fetch employee details
      final employeeDetails = await _apiService.fetchEmployeeForUser(_userId!, _sid!);
      if (employeeDetails != null && employeeDetails['employee_name'] != null) {
         _employeeName = employeeDetails['employee_name'];
         // You might also get company, department etc. here if needed.
      } else {
        throw Exception("Logged in, but could not fetch employee details.");
      }


      if (_sid != null && _userId != null && _employeeName != null && _fullName != null) {
        await _storageService.saveSessionData(
          sid: _sid!,
          userId: _userId!,
          employeeName: _employeeName!,
          fullName: _fullName!,
        );
        _isLoggedIn = true;
      } else {
        throw Exception("Login failed to retrieve all required session data.");
      }

    } catch (e) {
      _isLoggedIn = false;
      await _storageService.clearSessionData(); // Clear any partial data
      rethrow; // Let the UI handle the error display
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    // Optionally: Call ERPNext's logout endpoint if it exists and is needed
    // await _apiService.logout(_sid);
    _sid = null;
    _userId = null;
    _employeeName = null;
    _fullName = null;
    _isLoggedIn = false;
    await _storageService.clearSessionData();
    await _storageService.clearErpInstanceUrl(); // Or decide if this should be cleared on logout
    notifyListeners();
  }

  // Call this on app start to check if session is still valid with ERPNext
  // This is more advanced and can be added later.
  // For now, we trust the stored token until an API call fails with 401/403.
  Future<void> validateCurrentSession() async {
    if (!_isLoggedIn || _sid == null) return;
    // Try a lightweight API call to see if session is valid
    // try {
    //   await _apiService.getCurrentLoggedInUser(_sid!); // Example API call
    // } catch (e) {
    //   // If it fails, session is likely invalid
    //   await logout();
    // }
  }
}
