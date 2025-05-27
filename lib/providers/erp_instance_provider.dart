import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class ErpInstanceProvider with ChangeNotifier {
  String? _erpInstanceUrl;
  final StorageService _storageService = StorageService();

  ErpInstanceProvider(this._erpInstanceUrl); // Initial URL from main.dart

  String? get erpInstanceUrl => _erpInstanceUrl;
  bool get isInstanceConfigured => _erpInstanceUrl != null && _erpInstanceUrl!.isNotEmpty;

  Future<void> setErpInstanceUrl(String url) async {
    _erpInstanceUrl = url;
    await _storageService.saveErpInstanceUrl(url);
    notifyListeners();
  }

  Future<void> clearErpInstanceUrl() async {
    _erpInstanceUrl = null;
    await _storageService.clearErpInstanceUrl();
    notifyListeners();
  }

  // Optionally, load from storage if not provided initially (already done in main.dart)
  // Future<void> loadInstanceUrl() async {
  //   _erpInstanceUrl = await _storageService.getErpInstanceUrl();
  //   notifyListeners();
  // }
}
