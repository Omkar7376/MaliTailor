import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_env.dart';
import '../models/tailor_model.dart';

class AuthService {
  static const String _sessionKey = 'is_admin_logged_in';

  final StreamController<TailorModel?> _authStateController =
      StreamController<TailorModel?>.broadcast();

  TailorModel? _currentTailor;
  TailorModel? get currentTailor => _currentTailor;

  Stream<TailorModel?> get authStateChanges => _authStateController.stream;

  TailorModel _buildAdminTailor() {
    return TailorModel(
      uid: AppEnv.defaultTailorId,
      shopName: AppEnv.defaultShopName,
      ownerName: AppEnv.defaultOwnerName,
      email: AppEnv.adminEmail,
      phone: AppEnv.defaultPhone,
      workerShirtWage: AppEnv.defaultShirtWage,
      workerPantWage: AppEnv.defaultPantWage,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<TailorModel?> checkPersistedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_sessionKey) ?? false;
      if (isLoggedIn) {
        _currentTailor = _buildAdminTailor();
        _authStateController.add(_currentTailor);
        return _currentTailor;
      }
    } catch (_) {}
    return null;
  }

  Future<TailorModel?> signIn(String username, String password) async {
    final u = username.trim();
    final p = password.trim();

    final expectedUser = AppEnv.adminUsername;
    final expectedEmail = AppEnv.adminEmail;
    final expectedPass = AppEnv.adminPassword;

    // Check credentials against environment configuration
    if ((u == expectedUser || u == expectedEmail) && p == expectedPass) {
      _currentTailor = _buildAdminTailor();

      // Persist session locally until logout or storage/history cleared
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_sessionKey, true);
      } catch (_) {
        // Fallback gracefully if hot-reload hasn't bound the web plugin yet
      }

      _authStateController.add(_currentTailor);
      return _currentTailor;
    } else {
      throw Exception('Invalid username or password. Please try again.');
    }
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (_) {}
    _currentTailor = null;
    _authStateController.add(null);
  }
}
