import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/config/app_env.dart';
import '../data/models/tailor_model.dart';
import '../data/services/auth_service.dart';
import '../data/services/firestore_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  static final TailorModel defaultTailor = TailorModel(
    uid: AppEnv.defaultTailorId,
    shopName: AppEnv.defaultShopName,
    ownerName: AppEnv.defaultOwnerName,
    email: AppEnv.adminEmail,
    phone: AppEnv.defaultPhone,
    workerShirtWage: AppEnv.defaultShirtWage,
    workerPantWage: AppEnv.defaultPantWage,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final Rx<TailorModel?> currentTailor = Rx<TailorModel?>(defaultTailor);
  final RxDouble workerShirtWage = AppEnv.defaultShirtWage.obs;
  final RxDouble workerPantWage = AppEnv.defaultPantWage.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get isAuthenticated => currentTailor.value != null;
  String get tailorId => currentTailor.value?.uid ?? 'admin_studio_01';

  StreamSubscription? _tailorSub;

  @override
  void onInit() {
    super.onInit();
    currentTailor.bindStream(_authService.authStateChanges);
    _subscribeTailorProfile();
    ever(currentTailor, (_) => _subscribeTailorProfile());
  }

  @override
  void onClose() {
    _tailorSub?.cancel();
    super.onClose();
  }

  void _subscribeTailorProfile() {
    final tid = tailorId;
    if (tid.isEmpty) return;
    _tailorSub?.cancel();
    _tailorSub = _firestoreService.getTailorProfile(tid).listen((profile) {
      workerShirtWage.value = profile.workerShirtWage;
      workerPantWage.value = profile.workerPantWage;
    });
  }

  Future<void> updateWageRates(double shirtRate, double pantRate) async {
    try {
      isLoading.value = true;
      await _firestoreService.updateTailorWageRates(tailorId, shirtRate, pantRate);
      workerShirtWage.value = shirtRate;
      workerPantWage.value = pantRate;
      Get.snackbar(
        'Pricing Rates Updated',
        'Next orders will calculate Shirt wage at ₹${shirtRate.toStringAsFixed(0)} & Pant wage at ₹${pantRate.toStringAsFixed(0)}',
        backgroundColor: const Color(0xFF16A34A).withAlpha(220),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update wage rates: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Resets all data collections in Firestore & in memory, preserving only admin details.
  Future<void> resetAllDataExceptAdmin() async {
    try {
      isLoading.value = true;
      await _firestoreService.clearAllRecordsExceptAdmin(tailorId);
      Get.snackbar(
        'Database Cleared',
        'All orders, customers, and staff records removed. Ready for new entries.',
        backgroundColor: const Color(0xFF16A34A).withAlpha(220),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to clear records: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final tailor = await _authService.signIn(username, password);
      if (tailor != null) {
        currentTailor.value = tailor;
        Get.offAllNamed(AppRoutes.dashboard);
        return true;
      }
      return false;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Access Denied',
        errorMessage.value,
        backgroundColor: Colors.redAccent.withAlpha(220),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String shopName,
    required String ownerName,
    required String email,
    required String password,
    required String phone,
  }) async {
    // For admin setup, automatically log in as admin using configured credentials
    return login(AppEnv.adminUsername, AppEnv.adminPassword);
  }

  Future<void> logout() async {
    await _authService.signOut();
    currentTailor.value = null;
    Get.offAllNamed(AppRoutes.login);
  }
}
