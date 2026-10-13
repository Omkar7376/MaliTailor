import 'dart:async';
import '../../core/config/app_env.dart';
import '../models/tailor_model.dart';

class AuthService {
  final StreamController<TailorModel?> _authStateController =
      StreamController<TailorModel?>.broadcast();

  TailorModel? _currentTailor;
  TailorModel? get currentTailor => _currentTailor;

  Stream<TailorModel?> get authStateChanges => _authStateController.stream;

  Future<TailorModel?> signIn(String username, String password) async {
    final u = username.trim();
    final p = password.trim();

    final expectedUser = AppEnv.adminUsername;
    final expectedEmail = AppEnv.adminEmail;
    final expectedPass = AppEnv.adminPassword;

    // Check credentials against environment configuration
    if ((u == expectedUser || u == expectedEmail) && p == expectedPass) {
      _currentTailor = TailorModel(
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
      _authStateController.add(_currentTailor);
      return _currentTailor;
    } else {
      throw Exception('Invalid username or password. Please try again.');
    }
  }

  Future<void> signOut() async {
    _currentTailor = null;
    _authStateController.add(null);
  }
}
