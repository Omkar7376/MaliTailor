import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/models/order_model.dart';
import '../data/models/customer_model.dart';
import '../data/services/firestore_service.dart';
import 'auth_controller.dart';

class OrderController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<OrderModel> allOrders = <OrderModel>[].obs;
  final RxList<OrderModel> filteredOrders = <OrderModel>[].obs;
  
  // Status filter: All, Pending, In Progress, Ready, Delivered
  final RxString selectedStatusFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;

  // --- Reactive Form State for "New Order" ---
  final Rx<CustomerModel?> selectedCustomerForOrder = Rx<CustomerModel?>(null);
  final RxString customerName = ''.obs;
  final RxString customerMobile = ''.obs;
  final RxString bookNo = ''.obs;
  final RxString orderType = 'Both'.obs;

  // Standard piece rates
  static const double defaultShirtRate = 350.0;
  static const double defaultPantRate = 400.0;
  double get workerShirtWageRate => _authController.workerShirtWage.value;
  double get workerPantWageRate => _authController.workerPantWage.value;

  final RxInt shirtQty = 1.obs;
  final RxDouble shirtRate = defaultShirtRate.obs;
  final RxInt pantQty = 1.obs;
  final RxDouble pantRate = defaultPantRate.obs;
  final RxDouble discount = 0.0.obs;
  final RxDouble advanceAmount = 0.0.obs;
  final Rx<DateTime> deliveryDate = (DateTime.now().add(const Duration(days: 7))).obs;
  final RxBool isUrgent = false.obs;
  final RxString orderNote = ''.obs;
  // Separate Shirt & Pant Worker Assignments
  final RxString shirtWorkerId = ''.obs;
  final RxString shirtWorkerName = ''.obs;
  late final RxDouble shirtWorkerWage = workerShirtWageRate.obs;

  final RxString pantWorkerId = ''.obs;
  final RxString pantWorkerName = ''.obs;
  late final RxDouble pantWorkerWage = workerPantWageRate.obs;

  // Legacy fallback if single worker is assigned
  final RxString assignedWorkerId = ''.obs;
  final RxString assignedWorkerName = ''.obs;

  final RxBool isLoading = false.obs;
  StreamSubscription? _ordersSub;

  // Reactive computed properties
  double get shirtTotal => shirtQty.value * shirtRate.value;
  double get pantTotal => pantQty.value * pantRate.value;
  double get totalAmount => shirtTotal + pantTotal;
  double get workerWage => shirtWorkerWage.value + pantWorkerWage.value;
  double get adminProfit => totalAmount - workerWage - discount.value;

  double get finalPayable {
    final net = totalAmount - discount.value - advanceAmount.value;
    return net < 0 ? 0 : net;
  }

  // Update auto-calculated worker wage when garment quantities change
  void autoUpdateWorkerWage() {
    shirtWorkerWage.value = shirtQty.value * workerShirtWageRate;
    pantWorkerWage.value = pantQty.value * workerPantWageRate;
  }

  bool get isUrgentDelivery {
    if (isUrgent.value) return true;
    final diff = deliveryDate.value.difference(DateTime.now()).inDays;
    return diff <= 2;
  }

  @override
  void onInit() {
    super.onInit();
    _subscribeOrders();
    // Reactively refresh real-time order stream if auth state changes
    ever(_authController.currentTailor, (_) => _subscribeOrders());
  }

  @override
  void onClose() {
    _ordersSub?.cancel();
    super.onClose();
  }

  String _subscribedTailorId = '';

  void _subscribeOrders() {
    final tailorId = _authController.tailorId;
    if (tailorId.isEmpty || (_subscribedTailorId == tailorId && _ordersSub != null)) return;
    _subscribedTailorId = tailorId;
    _ordersSub?.cancel();
    _ordersSub = _firestoreService.getOrders(tailorId).listen(
      (orders) {
        allOrders.assignAll(orders);
        applyFilter();
      },
      onError: (err) {
        debugPrint('Realtime orders stream error: $err');
      },
    );
  }

  Future<void> refreshOrders() async {
    final tailorId = _authController.tailorId;
    if (tailorId.isNotEmpty) {
      _ordersSub?.cancel();
      _ordersSub = _firestoreService.getOrders(tailorId).listen(
        (orders) {
          allOrders.assignAll(orders);
          applyFilter();
        },
      );
    }
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    applyFilter();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  void applyFilter() {
    List<OrderModel> list = allOrders;

    if (selectedStatusFilter.value != 'All') {
      list = list.where((o) => o.status.toLowerCase() == selectedStatusFilter.value.toLowerCase()).toList();
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.toLowerCase().trim();
      list = list.where((o) {
        return o.orderId.toLowerCase().contains(q) ||
            o.customerName.toLowerCase().contains(q) ||
            o.customerMobile.toLowerCase().contains(q) ||
            o.bookNo.toLowerCase().contains(q);
      }).toList();
    }

    filteredOrders.assignAll(list);
  }

  void selectCustomer(CustomerModel customer) {
    selectedCustomerForOrder.value = customer;
    customerName.value = customer.name;
    customerMobile.value = customer.mobile;
    bookNo.value = customer.bookNo;
  }

  void resetNewOrderForm() {
    selectedCustomerForOrder.value = null;
    customerName.value = '';
    customerMobile.value = '';
    bookNo.value = '';
    orderType.value = 'Both';
    shirtQty.value = 1;
    shirtRate.value = defaultShirtRate;
    pantQty.value = 1;
    pantRate.value = defaultPantRate;
    discount.value = 0.0;
    advanceAmount.value = 0.0;
    deliveryDate.value = DateTime.now().add(const Duration(days: 7));
    isUrgent.value = false;
    orderNote.value = '';
    assignedWorkerId.value = '';
    assignedWorkerName.value = '';
    shirtWorkerId.value = '';
    shirtWorkerName.value = '';
    shirtWorkerWage.value = workerShirtWageRate;
    pantWorkerId.value = '';
    pantWorkerName.value = '';
    pantWorkerWage.value = workerPantWageRate;
  }

  Future<bool> createOrder() async {
    if (customerName.value.trim().isEmpty || customerMobile.value.trim().isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please select or enter customer name and mobile number.',
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isLoading.value = true;
      final nextOrderNumber = 1000 + allOrders.length + 1;
      final orderId = 'ORD-$nextOrderNumber';

      // Combined or primary assigned worker name for high level cards
      final combinedWorkerName = (shirtWorkerName.value.isNotEmpty && pantWorkerName.value.isNotEmpty)
          ? '${shirtWorkerName.value} (Shirt) & ${pantWorkerName.value} (Pant)'
          : (shirtWorkerName.value.isNotEmpty ? shirtWorkerName.value : pantWorkerName.value);

      final newOrder = OrderModel(
        orderId: orderId,
        customerId: selectedCustomerForOrder.value?.id ?? 'cust_${DateTime.now().millisecondsSinceEpoch}',
        customerName: customerName.value.trim(),
        customerMobile: customerMobile.value.trim(),
        bookNo: bookNo.value.trim(),
        orderDate: DateTime.now(),
        deliveryDate: deliveryDate.value,
        orderType: orderType.value,
        shirtQty: shirtQty.value,
        shirtRate: shirtRate.value,
        shirtTotal: shirtTotal,
        pantQty: pantQty.value,
        pantRate: pantRate.value,
        pantTotal: pantTotal,
        totalAmount: totalAmount,
        discount: discount.value,
        advanceAmount: advanceAmount.value,
        finalPayable: finalPayable,
        status: 'Pending',
        note: orderNote.value.trim(),
        assignedWorkerId: shirtWorkerId.value.isNotEmpty ? shirtWorkerId.value : pantWorkerId.value,
        assignedWorkerName: combinedWorkerName.isNotEmpty ? combinedWorkerName : null,
        workerWage: workerWage,
        shirtWorkerId: shirtWorkerId.value.isNotEmpty ? shirtWorkerId.value : null,
        shirtWorkerName: shirtWorkerName.value.isNotEmpty ? shirtWorkerName.value : null,
        shirtWorkerWage: shirtWorkerWage.value,
        pantWorkerId: pantWorkerId.value.isNotEmpty ? pantWorkerId.value : null,
        pantWorkerName: pantWorkerName.value.isNotEmpty ? pantWorkerName.value : null,
        pantWorkerWage: pantWorkerWage.value,
        isUrgent: isUrgent.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final tailorId = _authController.tailorId;
      await _firestoreService.addOrder(tailorId, newOrder);

      // Immediately insert into allOrders so UI updates without waiting for network stream
      if (!allOrders.any((o) => o.orderId == orderId)) {
        allOrders.insert(0, newOrder);
        applyFilter();
      }

      Get.snackbar(
        'Order Recorded',
        'Order #$orderId for ${newOrder.customerName} saved successfully!',
        backgroundColor: const Color(0xFF16A34A).withAlpha(220),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
      );

      resetNewOrderForm();
      return true;
    } catch (e, stack) {
      debugPrint('Error creating order: $e\n$stack');
      Get.snackbar(
        'Error',
        'Failed to create order: $e',
        backgroundColor: Colors.redAccent.withAlpha(220),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    try {
      final tailorId = _authController.tailorId;
      await _firestoreService.updateOrderStatus(tailorId, orderId, newStatus);
      Get.snackbar(
        'Status Updated',
        'Order $orderId status changed to $newStatus',
        backgroundColor: const Color(0xFF0D9488).withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e');
    }
  }

  Future<bool> updateOrder(OrderModel updated) async {
    try {
      isLoading.value = true;
      final tailorId = _authController.tailorId;
      await _firestoreService.updateOrder(tailorId, updated);
      final idx = allOrders.indexWhere((o) => o.orderId == updated.orderId);
      if (idx != -1) {
        allOrders[idx] = updated;
        applyFilter();
      }
      Get.snackbar(
        'Updated',
        'Order #${updated.orderId} updated successfully',
        backgroundColor: const Color(0xFF16A34A).withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    try {
      isLoading.value = true;
      final tailorId = _authController.tailorId;
      await _firestoreService.deleteOrder(tailorId, orderId);
      allOrders.removeWhere((o) => o.orderId == orderId);
      applyFilter();
      Get.snackbar(
        'Order Deleted',
        'Order #$orderId has been deleted',
        backgroundColor: Colors.redAccent.withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete order: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendWhatsAppNotification(OrderModel order) async {
    final cleanPhone = order.customerMobile.replaceAll(RegExp(r'[^0-9]'), '');
    final shopName = _authController.currentTailor.value?.shopName ?? 'StitchUp Tailor Studio';
    
    final message = '''
✂️ *${shopName.toUpperCase()}* - Order Update

Hello *${order.customerName}*,
Your tailoring order details:
📋 *Order ID:* ${order.orderId}
📖 *Ledger Book #:* ${order.bookNo}
📅 *Delivery Date:* ${order.deliveryDate.day}/${order.deliveryDate.month}/${order.deliveryDate.year}
⚡ *Current Status:* *${order.status.toUpperCase()}*

💰 *Total Bill:* ₹${order.totalAmount.toStringAsFixed(0)}
💳 *Advance Paid:* ₹${order.advanceAmount.toStringAsFixed(0)}
💵 *Balance Due:* ₹${order.finalPayable.toStringAsFixed(0)}

Thank you for choosing *$shopName*!
''';

    final uri = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'WhatsApp Notification',
        'Could not open WhatsApp for phone: $cleanPhone',
        backgroundColor: Colors.amber.shade900,
        colorText: Colors.white,
      );
    }
  }
}