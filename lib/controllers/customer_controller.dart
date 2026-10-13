import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../data/models/customer_model.dart';
import '../data/models/shirt_measurement_model.dart';
import '../data/models/pant_measurement_model.dart';
import '../data/models/order_model.dart';
import '../data/services/firestore_service.dart';
import 'auth_controller.dart';

class CustomerController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<CustomerModel> allCustomers = <CustomerModel>[].obs;
  final RxList<CustomerModel> filteredCustomers = <CustomerModel>[].obs;
  final RxString searchQuery = ''.obs;

  // Selected customer for profile view
  final Rx<CustomerModel?> selectedCustomer = Rx<CustomerModel?>(null);
  final Rx<ShirtMeasurementModel> shirtMeasurement = ShirtMeasurementModel.empty().obs;
  final Rx<PantMeasurementModel> pantMeasurement = PantMeasurementModel.empty().obs;
  final RxList<OrderModel> customerOrders = <OrderModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSavingMeasurement = false.obs;

  StreamSubscription? _customersSub;
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    _subscribeCustomers();
  }

  @override
  void onClose() {
    _customersSub?.cancel();
    _debounceTimer?.cancel();
    super.onClose();
  }

  void _subscribeCustomers() {
    final tailorId = _authController.tailorId;
    _customersSub?.cancel();
    _customersSub = _firestoreService.getCustomers(tailorId).listen((customers) {
      allCustomers.assignAll(customers);
      applySearch(searchQuery.value);
    });
  }

  Future<void> refreshCustomers() async {
    _subscribeCustomers();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      applySearch(query);
    });
  }

  void applySearch(String query) {
    if (query.trim().isEmpty) {
      filteredCustomers.assignAll(allCustomers);
    } else {
      final q = query.toLowerCase().trim();
      filteredCustomers.assignAll(allCustomers.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.mobile.toLowerCase().contains(q) ||
            c.bookNo.toLowerCase().contains(q);
      }).toList());
    }
  }

  Future<void> selectCustomer(String customerId) async {
    isLoading.value = true;
    try {
      final tailorId = _authController.tailorId;
      final cust = await _firestoreService.getCustomerById(tailorId, customerId);
      selectedCustomer.value = cust;

      if (cust != null) {
        // Load measurements
        final shirt = await _firestoreService.getShirtMeasurement(tailorId, customerId);
        shirtMeasurement.value = shirt;

        final pant = await _firestoreService.getPantMeasurement(tailorId, customerId);
        pantMeasurement.value = pant;

        // Load customer orders
        _firestoreService.getOrders(tailorId).listen((orders) {
          customerOrders.assignAll(
            orders.where((o) => o.customerId == customerId).toList(),
          );
        });
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<CustomerModel?> addCustomer({
    required String name,
    required String mobile,
    required String bookNo,
    String gender = 'Male',
    String address = '',
  }) async {
    try {
      isLoading.value = true;
      final newCustomer = CustomerModel(
        id: const Uuid().v4(),
        bookNo: bookNo.trim(),
        name: name.trim(),
        mobile: mobile.trim(),
        gender: gender,
        address: address.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final tailorId = _authController.tailorId;
      await _firestoreService.addCustomer(tailorId, newCustomer);

      Get.snackbar(
        'Success',
        'Customer ${newCustomer.name} added (Book #$bookNo)',
        backgroundColor: const Color(0xFF16A34A).withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return newCustomer;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add customer: $e',
        backgroundColor: Colors.redAccent.withAlpha(200),
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateCustomer(CustomerModel updated) async {
    try {
      isLoading.value = true;
      final tailorId = _authController.tailorId;
      await _firestoreService.updateCustomer(tailorId, updated);
      if (selectedCustomer.value?.id == updated.id) {
        selectedCustomer.value = updated;
      }
      Get.snackbar(
        'Success',
        'Customer updated successfully',
        backgroundColor: const Color(0xFF16A34A).withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update customer: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteCustomer(String customerId) async {
    try {
      isLoading.value = true;
      final tailorId = _authController.tailorId;
      await _firestoreService.deleteCustomer(tailorId, customerId);
      if (selectedCustomer.value?.id == customerId) {
        selectedCustomer.value = null;
      }
      Get.snackbar(
        'Deleted',
        'Customer has been removed',
        backgroundColor: Colors.redAccent.withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete customer: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveShirt(ShirtMeasurementModel model) async {
    final cust = selectedCustomer.value;
    if (cust == null) return;
    try {
      isSavingMeasurement.value = true;
      final tailorId = _authController.tailorId;
      await _firestoreService.saveShirtMeasurement(tailorId, cust.id, model);
      shirtMeasurement.value = model;
      Get.snackbar(
        'Saved',
        'Shirt measurements recorded',
        backgroundColor: const Color(0xFF16A34A).withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not save measurements: $e');
    } finally {
      isSavingMeasurement.value = false;
    }
  }

  Future<void> savePant(PantMeasurementModel model) async {
    final cust = selectedCustomer.value;
    if (cust == null) return;
    try {
      isSavingMeasurement.value = true;
      final tailorId = _authController.tailorId;
      await _firestoreService.savePantMeasurement(tailorId, cust.id, model);
      pantMeasurement.value = model;
      Get.snackbar(
        'Saved',
        'Pant measurements recorded',
        backgroundColor: const Color(0xFF16A34A).withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not save measurements: $e');
    } finally {
      isSavingMeasurement.value = false;
    }
  }

  // Quick helper to increment measurement strings by 0.25 or 0.5
  static String adjustValue(String current, double delta) {
    double val = double.tryParse(current) ?? 0.0;
    val += delta;
    if (val < 0) val = 0;
    return val.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
  }
}
