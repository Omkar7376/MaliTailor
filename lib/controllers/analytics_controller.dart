import 'dart:async';
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

  void setViewMode(AnalysisViewMode mode) {
    viewMode.value = mode;
  }

  void setFilter(TimeFilter filter) {
    selectedFilter.value = filter;
  }

  // Filter orders by selected timeframe
  List<OrderModel> get filteredOrders {
    final now = DateTime.now();
    return orders.where((o) {
      final orderDate = o.orderDate;
      switch (selectedFilter.value) {
        case TimeFilter.weekly:
          return orderDate.isAfter(now.subtract(const Duration(days: 7)));
        case TimeFilter.monthly:
          return orderDate.year == now.year && orderDate.month == now.month;
        case TimeFilter.yearly:
          return orderDate.year == now.year;
        case TimeFilter.allTime:
          return true;
      }
    }).toList();
  }

  // Filter transactions by selected timeframe
  List<WorkerTransactionModel> get filteredTransactions {
    final now = DateTime.now();
    return transactions.where((t) {
      final txDate = t.date;
      switch (selectedFilter.value) {
        case TimeFilter.weekly:
          return txDate.isAfter(now.subtract(const Duration(days: 7)));
        case TimeFilter.monthly:
          return txDate.year == now.year && txDate.month == now.month;
        case TimeFilter.yearly:
          return txDate.year == now.year;
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
  // WORKER SALARY & ADVANCE METRICS
  // =========================================================================
  // 1. Total Paid Salary to workers (all payout transactions)
  double get workerTotalPaidSalary =>
      transactions
          .where((t) => t.type == WorkerTransactionType.payout)
          .fold(0.0, (sum, t) => sum + t.amount);

  // 2. Advance Paid / Extra cash given to workers (deductible from salary)
  double get workerTotalAdvancePaidSalary =>
      transactions
          .where((t) => t.type == WorkerTransactionType.advance)
          .fold(0.0, (sum, t) => sum + t.amount);

  // 3. Total Wages Earned across all assigned orders
  double get workerTotalEarnedWages {
    double total = 0.0;
    for (final o in orders) {
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

  // 4. Pending Due Salary across all workers
  // = Earned Wages - Advances Taken - Payouts Given
  double get workerTotalPendingDueSalary {
    final pending = workerTotalEarnedWages - workerTotalAdvancePaidSalary - workerTotalPaidSalary;
    return pending < 0 ? 0.0 : pending;
  }

  // Per-worker detailed summaries
  List<WorkerSalarySummary> get workerSalarySummaries {
    return workers.map((worker) {
      int assignedCount = 0;
      double earnedWages = 0.0;

      for (final o in orders) {
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

      // Sum of advances taken by this worker
      final workerAdvances = transactions
          .where((t) => t.workerId == worker.workerId && t.type == WorkerTransactionType.advance)
          .fold(0.0, (sum, t) => sum + t.amount);

      // Sum of payouts already given
      final workerPayouts = transactions
          .where((t) => t.workerId == worker.workerId && t.type == WorkerTransactionType.payout)
          .fold(0.0, (sum, t) => sum + t.amount);

      // Net salary balance
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
