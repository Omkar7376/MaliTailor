import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../data/models/worker_model.dart';
import '../data/models/worker_transaction_model.dart';
import '../data/services/firestore_service.dart';
import 'auth_controller.dart';

class WorkerController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<WorkerModel> workers = <WorkerModel>[].obs;
  final RxList<WorkerTransactionModel> transactions = <WorkerTransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  StreamSubscription? _workersSub;
  StreamSubscription? _txSub;

  @override
  void onInit() {
    super.onInit();
    _subscribeWorkers();
    _subscribeTransactions();
  }

  @override
  void onClose() {
    _workersSub?.cancel();
    _txSub?.cancel();
    super.onClose();
  }

  void _subscribeWorkers() {
    final tailorId = _authController.tailorId;
    _workersSub?.cancel();
    _workersSub = _firestoreService.getWorkers(tailorId).listen((list) {
      workers.assignAll(list);
    });
  }

  void _subscribeTransactions() {
    final tailorId = _authController.tailorId;
    _txSub?.cancel();
    _txSub = _firestoreService.getWorkerTransactions(tailorId).listen((list) {
      transactions.assignAll(list);
    });
  }

  Future<void> refreshWorkers() async {
    _subscribeWorkers();
    _subscribeTransactions();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Get total advances taken by a specific worker
  double getWorkerAdvance(String workerId) {
    return transactions
        .where((t) => t.workerId == workerId && t.type == WorkerTransactionType.advance)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Record Advance / Extra Cash given to worker
  Future<void> recordAdvance({
    required String workerId,
    required String workerName,
    required double amount,
    required String note,
    String? orderId,
  }) async {
    try {
      isLoading.value = true;
      final tx = WorkerTransactionModel(
        transactionId: 'tx_${const Uuid().v4().substring(0, 8)}',
        workerId: workerId,
        workerName: workerName,
        type: WorkerTransactionType.advance,
        amount: amount,
        orderId: orderId,
        note: note.trim().isEmpty ? 'Advance Cash Taken' : note.trim(),
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final tailorId = _authController.tailorId;
      await _firestoreService.addWorkerTransaction(tailorId, tx);

      Get.snackbar(
        'Advance Recorded',
        '₹${amount.toStringAsFixed(0)} advance recorded for $workerName (will be deducted from salary)',
        backgroundColor: const Color(0xFFD97706).withAlpha(220),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to record advance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Record Salary Payout / Settlement
  Future<void> recordPayout({
    required String workerId,
    required String workerName,
    required double amount,
    required String note,
  }) async {
    try {
      isLoading.value = true;
      final tx = WorkerTransactionModel(
        transactionId: 'tx_${const Uuid().v4().substring(0, 8)}',
        workerId: workerId,
        workerName: workerName,
        type: WorkerTransactionType.payout,
        amount: amount,
        note: note.trim().isEmpty ? 'Salary Settlement Payout' : note.trim(),
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final tailorId = _authController.tailorId;
      await _firestoreService.addWorkerTransaction(tailorId, tx);

      Get.snackbar(
        'Salary Paid',
        '₹${amount.toStringAsFixed(0)} salary payout recorded for $workerName',
        backgroundColor: const Color(0xFF16A34A).withAlpha(220),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to record payout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update payment transaction (e.g., change amount, note, date)
  Future<void> updateTransaction(WorkerTransactionModel tx) async {
    try {
      isLoading.value = true;
      final tailorId = _authController.tailorId;
      await _firestoreService.updateWorkerTransaction(tailorId, tx);

      Get.snackbar(
        'Payment Updated',
        'Payment of ₹${tx.amount.toStringAsFixed(0)} for ${tx.workerName} updated',
        backgroundColor: const Color(0xFF16A34A).withAlpha(220),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update transaction: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete payment transaction
  Future<void> deleteTransaction(String transactionId, String workerName, double amount) async {
    try {
      isLoading.value = true;
      final tailorId = _authController.tailorId;
      await _firestoreService.deleteWorkerTransaction(tailorId, transactionId);

      Get.snackbar(
        'Payment Removed',
        'Payment record of ₹${amount.toStringAsFixed(0)} for $workerName was deleted',
        backgroundColor: const Color(0xFFDC2626).withAlpha(220),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete transaction: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addWorker({
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      isLoading.value = true;
      final newWorker = WorkerModel(
        workerId: 'wrk_${const Uuid().v4().substring(0, 8)}',
        name: name.trim(),
        phone: phone.trim(),
        role: role,
        assignedOrderIds: [],
      );

      final tailorId = _authController.tailorId;
      await _firestoreService.addWorker(tailorId, newWorker);

      Get.snackbar(
        'Staff Added',
        '$name ($role) added successfully',
        backgroundColor: const Color(0xFF16A34A).withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to add staff: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateWorker(WorkerModel worker) async {
    try {
      isLoading.value = true;
      final tailorId = _authController.tailorId;
      await _firestoreService.updateWorker(tailorId, worker);

      Get.snackbar(
        'Staff Updated',
        '${worker.name} details updated',
        backgroundColor: const Color(0xFF16A34A).withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update staff: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteWorker(String workerId, String workerName) async {
    try {
      isLoading.value = true;
      final tailorId = _authController.tailorId;
      await _firestoreService.deleteWorker(tailorId, workerId);

      Get.snackbar(
        'Staff Removed',
        '$workerName was removed',
        backgroundColor: const Color(0xFFDC2626).withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete staff: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> assignOrder(String orderId, WorkerModel worker, {double? workerWage}) async {
    try {
      final tailorId = _authController.tailorId;
      await _firestoreService.assignWorkerToOrder(
        tailorId,
        orderId,
        worker.workerId,
        worker.name,
        workerWage: workerWage,
      );
      Get.snackbar(
        'Assigned',
        'Order $orderId assigned to ${worker.name}${workerWage != null ? ' (Wage: ₹${workerWage.toStringAsFixed(0)})' : ''}',
        backgroundColor: const Color(0xFF0D9488).withAlpha(200),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Assignment failed: $e');
    }
  }
}
