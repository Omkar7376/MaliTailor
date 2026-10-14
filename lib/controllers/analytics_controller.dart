import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/order_model.dart';
import '../data/models/worker_model.dart';
import '../data/models/worker_transaction_model.dart';
import '../data/services/firestore_service.dart';
import 'auth_controller.dart';

enum TimeFilter {
  weekly,
  monthly,
  yearly,
  allTime,
}

enum AnalysisViewMode {
  admin,
  worker,
}

class WorkerSalarySummary {
  final WorkerModel worker;
  final int totalOrdersAssigned;
  final double totalWagesEarned;
  final double totalAdvanceTaken;
  final double totalPayoutGiven;
  final double netPendingSalary; // totalWagesEarned - totalAdvanceTaken - totalPayoutGiven

  WorkerSalarySummary({
    required this.worker,
    required this.totalOrdersAssigned,
    required this.totalWagesEarned,
    required this.totalAdvanceTaken,
    required this.totalPayoutGiven,
    required this.netPendingSalary,
  });
}

class AnalyticsController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthController _authController = Get.find<AuthController>();

  final Rx<AnalysisViewMode> viewMode = AnalysisViewMode.admin.obs;
  final Rx<TimeFilter> selectedFilter = TimeFilter.monthly.obs;

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxList<WorkerModel> workers = <WorkerModel>[].obs;
  final RxList<WorkerTransactionModel> transactions = <WorkerTransactionModel>[].obs;

  StreamSubscription? _ordersSub;
  StreamSubscription? _workersSub;
  StreamSubscription? _txSub;

  @override
  void onInit() {
    super.onInit();
    _subscribeData();
  }

  @override
  void onClose() {
    _ordersSub?.cancel();
    _workersSub?.cancel();
    _txSub?.cancel();
    super.onClose();
  }

  void _subscribeData() {
    final tailorId = _authController.tailorId;
    _ordersSub?.cancel();
    _ordersSub = _firestoreService.getOrders(tailorId).listen((list) {
      orders.assignAll(list);
    });

    _workersSub?.cancel();
    _workersSub = _firestoreService.getWorkers(tailorId).listen((list) {
      workers.assignAll(list);
    });

    _txSub?.cancel();
    _txSub = _firestoreService.getWorkerTransactions(tailorId).listen((list) {
      transactions.assignAll(list);
    });
  }

  final Rx<DateTime> selectedMonthDate = DateTime.now().obs;
  final Rx<DateTimeRange?> customDateRange = Rx<DateTimeRange?>(null);

  void setViewMode(AnalysisViewMode mode) {
    viewMode.value = mode;
  }

  void setFilter(TimeFilter filter) {
    selectedFilter.value = filter;
    if (filter != TimeFilter.monthly) {
      customDateRange.value = null;
    }
  }

  void setCustomDateRange(DateTimeRange range) {
    customDateRange.value = range;
    selectedFilter.value = TimeFilter.allTime; // Uses custom date range
  }

  void previousMonth() {
    final current = selectedMonthDate.value;
    selectedMonthDate.value = DateTime(current.year, current.month - 1, 1);
    selectedFilter.value = TimeFilter.monthly;
    customDateRange.value = null;
  }

  void nextMonth() {
    final current = selectedMonthDate.value;
    selectedMonthDate.value = DateTime(current.year, current.month + 1, 1);
    selectedFilter.value = TimeFilter.monthly;
    customDateRange.value = null;
  }

  // Filter orders by selected timeframe or month/custom range
  List<OrderModel> get filteredOrders {
    final now = DateTime.now();
    final customRange = customDateRange.value;
    if (customRange != null) {
      final start = DateTime(customRange.start.year, customRange.start.month, customRange.start.day);
      final end = DateTime(customRange.end.year, customRange.end.month, customRange.end.day, 23, 59, 59);
      return orders.where((o) => o.orderDate.isAfter(start.subtract(const Duration(seconds: 1))) && o.orderDate.isBefore(end.add(const Duration(seconds: 1)))).toList();
    }

    return orders.where((o) {
      final orderDate = o.orderDate;
      switch (selectedFilter.value) {
        case TimeFilter.weekly:
          return orderDate.isAfter(now.subtract(const Duration(days: 7)));
        case TimeFilter.monthly:
          final sel = selectedMonthDate.value;
          return orderDate.year == sel.year && orderDate.month == sel.month;
        case TimeFilter.yearly:
          return orderDate.year == selectedMonthDate.value.year;
        case TimeFilter.allTime:
          return true;
      }
    }).toList();
  }

  // Filter transactions by selected timeframe or month/custom range
  List<WorkerTransactionModel> get filteredTransactions {
    final now = DateTime.now();
    final customRange = customDateRange.value;
    if (customRange != null) {
      final start = DateTime(customRange.start.year, customRange.start.month, customRange.start.day);
      final end = DateTime(customRange.end.year, customRange.end.month, customRange.end.day, 23, 59, 59);
      return transactions.where((t) => t.date.isAfter(start.subtract(const Duration(seconds: 1))) && t.date.isBefore(end.add(const Duration(seconds: 1)))).toList();
    }

    return transactions.where((t) {
      final txDate = t.date;
      switch (selectedFilter.value) {
        case TimeFilter.weekly:
          return txDate.isAfter(now.subtract(const Duration(days: 7)));
        case TimeFilter.monthly:
          final sel = selectedMonthDate.value;
          return txDate.year == sel.year && txDate.month == sel.month;
        case TimeFilter.yearly:
          return txDate.year == selectedMonthDate.value.year;
        case TimeFilter.allTime:
          return true;
      }
    }).toList();
  }

  // =========================================================================
  // ADMIN INCOME & PROFIT METRICS
  // =========================================================================
  // 1. Total Income / Billing from orders
  double get adminTotalIncome =>
      filteredOrders.fold(0.0, (sum, o) => sum + o.totalAmount);

  // 2. Advance Collected from customers
  double get adminAdvanceCollected =>
      filteredOrders.fold(0.0, (sum, o) => sum + o.advanceAmount);

  // 3. Pending Payment Due from customers
  double get adminPendingPaymentDue =>
      filteredOrders.fold(0.0, (sum, o) => sum + o.finalPayable);

  // 4. Total Worker Wages Payable for these orders
  double get totalWorkerWagesForOrders =>
      filteredOrders.fold(0.0, (sum, o) => sum + o.workerWage);

  // 5. Admin Net Profit = Total Billing - Worker Wages - Discounts
  double get adminNetProfit {
    final total = adminTotalIncome;
    final wages = totalWorkerWagesForOrders;
    final discount = filteredOrders.fold(0.0, (sum, o) => sum + o.discount);
    final net = total - wages - discount;
    return net < 0 ? 0.0 : net;
  }

  // Orders count
  int get totalOrderCount => filteredOrders.length;
  int get deliveredOrderCount =>
      filteredOrders.where((o) => o.status.toLowerCase() == 'delivered').length;
  int get inProgressOrderCount =>
      filteredOrders.where((o) => o.status.toLowerCase() == 'in progress').length;
  int get pendingOrderCount =>
      filteredOrders.where((o) => o.status.toLowerCase() == 'pending').length;

  // =========================================================================
  // WORKER SALARY & ADVANCE METRICS (Dynamic by selected month/period)
  // =========================================================================
  // 1. Total Paid Salary to workers for this period (payout transactions)
  double get workerTotalPaidSalary =>
      filteredTransactions
          .where((t) => t.type == WorkerTransactionType.payout)
          .fold(0.0, (sum, t) => sum + t.amount);

  // 2. Advance Paid / Extra cash given to workers in this period
  double get workerTotalAdvancePaidSalary =>
      filteredTransactions
          .where((t) => t.type == WorkerTransactionType.advance)
          .fold(0.0, (sum, t) => sum + t.amount);

  // 3. Total Wages Earned across assigned orders in this period
  double get workerTotalEarnedWages {
    double total = 0.0;
    for (final o in filteredOrders) {
      if (o.shirtWorkerId != null && o.shirtWorkerWage > 0) {
        total += o.shirtWorkerWage;
      }
      if (o.pantWorkerId != null && o.pantWorkerWage > 0) {
        total += o.pantWorkerWage;
      }
      // Fallback for legacy single assignment
      if (o.shirtWorkerId == null && o.pantWorkerId == null && o.assignedWorkerId != null) {
        total += o.workerWage;
      }
    }
    return total;
  }

  // 4. Pending Due Salary across all workers in this period
  // = Earned Wages in period - Advances in period - Payouts in period
  double get workerTotalPendingDueSalary {
    final pending = workerTotalEarnedWages - workerTotalAdvancePaidSalary - workerTotalPaidSalary;
    return pending < 0 ? 0.0 : pending;
  }

  // Per-worker detailed summaries (Calculated dynamically for selected month/timeframe)
  List<WorkerSalarySummary> get workerSalarySummaries {
    return workers.map((worker) {
      int assignedCount = 0;
      double earnedWages = 0.0;

      for (final o in filteredOrders) {
        bool isAssigned = false;
        if (o.shirtWorkerId == worker.workerId && o.shirtWorkerWage > 0) {
          earnedWages += o.shirtWorkerWage;
          isAssigned = true;
        }
        if (o.pantWorkerId == worker.workerId && o.pantWorkerWage > 0) {
          earnedWages += o.pantWorkerWage;
          isAssigned = true;
        }
        // Fallback for legacy single assignment
        if (o.shirtWorkerId == null && o.pantWorkerId == null && o.assignedWorkerId == worker.workerId) {
          earnedWages += o.workerWage;
          isAssigned = true;
        }
        if (isAssigned) assignedCount++;
      }

      // Sum of advances taken by this worker in this period
      final workerAdvances = filteredTransactions
          .where((t) => t.workerId == worker.workerId && t.type == WorkerTransactionType.advance)
          .fold(0.0, (sum, t) => sum + t.amount);

      // Sum of payouts given to this worker in this period
      final workerPayouts = filteredTransactions
          .where((t) => t.workerId == worker.workerId && t.type == WorkerTransactionType.payout)
          .fold(0.0, (sum, t) => sum + t.amount);

      // Net salary balance for this period
      final netPending = earnedWages - workerAdvances - workerPayouts;

      return WorkerSalarySummary(
        worker: worker,
        totalOrdersAssigned: assignedCount,
        totalWagesEarned: earnedWages,
        totalAdvanceTaken: workerAdvances,
        totalPayoutGiven: workerPayouts,
        netPendingSalary: netPending,
      );
    }).toList();
  }
}
