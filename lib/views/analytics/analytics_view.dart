import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/responsive/adaptive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/analytics_controller.dart';
import '../../controllers/worker_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/worker_model.dart';
import '../../data/models/worker_transaction_model.dart';
import '../widgets/adaptive_scaffold.dart';
import '../widgets/bottom_card_modal.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  void _showUpdatePieceRatesDialog(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final shirtWageCtrl = TextEditingController(
      text: authCtrl.workerShirtWage.value.toStringAsFixed(0),
    );
    final pantWageCtrl = TextEditingController(
      text: authCtrl.workerPantWage.value.toStringAsFixed(0),
    );
    final formKey = GlobalKey<FormState>();

    showBottomUpCard(
      context: context,
      maxHeightFactor: 0.65,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.tune, color: AppColors.accentLightBrown, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Update Piece Rates',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set the standard wage given to workers per shirt and pant. Updated rates will apply to all new orders going forward.',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: shirtWageCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Worker Shirt Wage (₹ per piece) *',
                      prefixIcon: Icon(Icons.cut, size: 20),
                      hintText: '130',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter shirt wage rate';
                      final val = double.tryParse(v);
                      if (val == null || val < 0) return 'Enter a valid rate';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: pantWageCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Worker Pant Wage (₹ per piece) *',
                      prefixIcon: Icon(Icons.straighten, size: 20),
                      hintText: '150',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter pant wage rate';
                      final val = double.tryParse(v);
                      if (val == null || val < 0) return 'Enter a valid rate';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final sWage = double.parse(shirtWageCtrl.text.trim());
                              final pWage = double.parse(pantWageCtrl.text.trim());
                              Navigator.pop(ctx);
                              await authCtrl.updateWageRates(sWage, pWage);
                            }
                          },
                          child: const Text('Save Rates'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRecordAdvanceDialog(BuildContext context, WorkerModel worker) {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final workerCtrl = Get.find<WorkerController>();

    showBottomUpCard(
      context: context,
      maxHeightFactor: 0.65,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.money_off, color: Color(0xFFD97706)),
                          const SizedBox(width: 8),
                          Text(
                            'Record Advance Cash',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Worker: ${worker.name} (${worker.role})',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Note: This cash amount will be automatically deducted from their piece-rate order salary.',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Advance Amount Taken (₹) *',
                      prefixIcon: Icon(Icons.currency_rupee, size: 20),
                      hintText: '500',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter amount';
                      final val = double.tryParse(v);
                      if (val == null || val <= 0) return 'Enter a valid positive amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Reason / Note (Optional)',
                      prefixIcon: Icon(Icons.notes, size: 20),
                      hintText: 'e.g. Festival advance, emergency cash',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final amt = double.parse(amountCtrl.text.trim());
                              workerCtrl.recordAdvance(
                                workerId: worker.workerId,
                                workerName: worker.name,
                                amount: amt,
                                note: noteCtrl.text.trim(),
                              );
                              Navigator.pop(ctx);
                            }
                          },
                          child: const Text('Record Advance'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showSettleSalaryDialog(BuildContext context, WorkerSalarySummary summary) {
    final amountCtrl = TextEditingController(
      text: summary.netPendingSalary > 0 ? summary.netPendingSalary.toStringAsFixed(0) : '0',
    );
    final noteCtrl = TextEditingController(text: 'Salary settlement payment');
    final formKey = GlobalKey<FormState>();
    final workerCtrl = Get.find<WorkerController>();

    showBottomUpCard(
      context: context,
      maxHeightFactor: 0.70,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.payments, color: Color(0xFF16A34A)),
                          const SizedBox(width: 8),
                          Text(
                            'Settle & Pay Salary',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Staff: ${summary.worker.name}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text('Total Earned: ₹${summary.totalWagesEarned.toStringAsFixed(0)}'),
                  Text(
                    'Advance Taken: -₹${summary.totalAdvanceTaken.toStringAsFixed(0)}',
                    style: const TextStyle(color: Color(0xFFD97706)),
                  ),
                  Text(
                    'Net Pending: ₹${summary.netPendingSalary.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Payout Amount (₹) *',
                      prefixIcon: Icon(Icons.currency_rupee, size: 20),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter amount';
                      final val = double.tryParse(v);
                      if (val == null || val <= 0) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Payout Description',
                      prefixIcon: Icon(Icons.edit_note, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final amt = double.parse(amountCtrl.text.trim());
                              workerCtrl.recordPayout(
                                workerId: summary.worker.workerId,
                                workerName: summary.worker.name,
                                amount: amt,
                                note: noteCtrl.text.trim(),
                              );
                              Navigator.pop(ctx);
                            }
                          },
                          child: const Text('Pay Salary'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditTransactionDialog(BuildContext context, WorkerTransactionModel tx) {
    final amountCtrl = TextEditingController(text: tx.amount.toStringAsFixed(0));
    final noteCtrl = TextEditingController(text: tx.note);
    final formKey = GlobalKey<FormState>();
    final workerCtrl = Get.find<WorkerController>();
    WorkerTransactionType selectedType = tx.type;

    showBottomUpCard(
      context: context,
      maxHeightFactor: 0.65,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.edit_note, color: AppColors.accentLightBrown),
                              const SizedBox(width: 8),
                              Text(
                                'Edit Payment Record',
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Worker: ${tx.workerName}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<WorkerTransactionType>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Payment Category',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: WorkerTransactionType.advance,
                            child: Text('Advance Cash (Deducted from salary)'),
                          ),
                          DropdownMenuItem(
                            value: WorkerTransactionType.payout,
                            child: Text('Salary Payout (Settlement)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedType = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: amountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount (₹) *',
                          prefixIcon: Icon(Icons.currency_rupee, size: 20),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter amount';
                          final val = double.tryParse(v);
                          if (val == null || val <= 0) return 'Enter a valid amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: noteCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Description / Reason',
                          prefixIcon: Icon(Icons.notes, size: 20),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  final newAmt = double.parse(amountCtrl.text.trim());
                                  workerCtrl.updateTransaction(
                                    tx.copyWith(
                                      amount: newAmt,
                                      type: selectedType,
                                      note: noteCtrl.text.trim(),
                                    ),
                                  );
                                  Navigator.pop(ctx);
                                }
                              },
                              child: const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteTransaction(
    BuildContext context,
    WorkerTransactionModel tx,
  ) async {
    final workerCtrl = Get.find<WorkerController>();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment Record?'),
        content: Text(
          'Delete ${tx.type == WorkerTransactionType.advance ? "advance" : "payout"} record of ₹${tx.amount.toStringAsFixed(0)} for "${tx.workerName}"? This will restore their salary balance calculation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Record', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await workerCtrl.deleteTransaction(tx.transactionId, tx.workerName, tx.amount);
    }
  }

  void _showWorkerTransactionHistoryDialog(
    BuildContext context,
    WorkerModel worker,
    AnalyticsController ctrl,
  ) {
    showBottomUpCard(
      context: context,
      maxHeightFactor: 0.85,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Obx(() {
          final txs = ctrl.transactions
              .where((t) => t.workerId == worker.workerId)
              .toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${worker.name} - Payment History',
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Update amounts or remove incorrect payment entries',
                            style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const Divider(height: 20),
                if (txs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Text(
                        'No advances or salary payments recorded yet for ${worker.name}.',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: txs.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tx = txs[index];
                        final isAdvance = tx.type == WorkerTransactionType.advance;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          leading: CircleAvatar(
                            backgroundColor: (isAdvance ? const Color(0xFFD97706) : const Color(0xFF16A34A)).withAlpha(30),
                            child: Icon(
                              isAdvance ? Icons.money_off : Icons.payments,
                              color: isAdvance ? const Color(0xFFD97706) : const Color(0xFF16A34A),
                              size: 20,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                isAdvance ? 'Advance Cash Taken' : 'Salary Payout Given',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: (isAdvance ? const Color(0xFFD97706) : const Color(0xFF16A34A)).withAlpha(25),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '₹${tx.amount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: isAdvance ? const Color(0xFFD97706) : const Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (tx.note.isNotEmpty)
                                Text(tx.note, style: GoogleFonts.poppins(fontSize: 12)),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(tx.date),
                                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                tooltip: 'Edit Payment',
                                onPressed: () => _showEditTransactionDialog(context, tx),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                tooltip: 'Delete Payment',
                                onPressed: () => _confirmDeleteTransaction(context, tx),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final analyticsCtrl = Get.put(AnalyticsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveScaffold(
      currentIndex: 4,
      title: 'Accounts & Income Analysis',
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AdaptiveLayout.getHorizontalPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Control Bar: Toggle (Admin vs Worker) + Time Range Filters
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 650;

                final toggleSwitcher = Obx(() {
                  final mode = analyticsCtrl.viewMode.value;
                  return Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceCard : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      mainAxisSize: isNarrow ? MainAxisSize.max : MainAxisSize.min,
                      children: [
                        _ToggleOption(
                          icon: Icons.admin_panel_settings,
                          label: 'Admin Income',
                          isSelected: mode == AnalysisViewMode.admin,
                          onTap: () => analyticsCtrl.setViewMode(AnalysisViewMode.admin),
                        ),
                        const SizedBox(width: 4),
                        _ToggleOption(
                          icon: Icons.engineering,
                          label: 'Worker Salary',
                          isSelected: mode == AnalysisViewMode.worker,
                          onTap: () => analyticsCtrl.setViewMode(AnalysisViewMode.worker),
                        ),
                      ],
                    ),
                  );
                });

                final timeChips = Obx(() {
                  final currentFilter = analyticsCtrl.selectedFilter.value;
                  final customRange = analyticsCtrl.customDateRange.value;
                  final isCustom = customRange != null;

                  return Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _FilterChip(
                        label: 'Weekly',
                        isSelected: currentFilter == TimeFilter.weekly && !isCustom,
                        onSelected: () => analyticsCtrl.setFilter(TimeFilter.weekly),
                      ),
                      _FilterChip(
                        label: 'Monthly',
                        isSelected: currentFilter == TimeFilter.monthly && !isCustom,
                        onSelected: () => analyticsCtrl.setFilter(TimeFilter.monthly),
                      ),
                      _FilterChip(
                        label: 'Yearly',
                        isSelected: currentFilter == TimeFilter.yearly && !isCustom,
                        onSelected: () => analyticsCtrl.setFilter(TimeFilter.yearly),
                      ),
                      _FilterChip(
                        label: 'All Time',
                        isSelected: currentFilter == TimeFilter.allTime && !isCustom,
                        onSelected: () => analyticsCtrl.setFilter(TimeFilter.allTime),
                      ),
                      // Custom Date Range Picker Action Chip
                      ActionChip(
                        avatar: Icon(
                          Icons.date_range_rounded,
                          size: 16,
                          color: isCustom ? AppColors.softGolden : AppColors.accentLightBrown,
                        ),
                        label: Text(
                          isCustom
                              ? '${DateFormat('dd MMM').format(customRange.start)} - ${DateFormat('dd MMM').format(customRange.end)}'
                              : 'Custom',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: isCustom ? FontWeight.w700 : FontWeight.w500,
                            color: isCustom ? Colors.white : (isDark ? AppColors.softGolden : AppColors.primaryDarkBrown),
                          ),
                        ),
                        backgroundColor: isCustom
                            ? AppColors.primaryDarkBrown
                            : (isDark ? AppColors.darkSurfaceCard : Colors.white),
                        side: BorderSide(
                          color: isCustom ? AppColors.softGolden : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            initialDateRange: customRange ??
                                DateTimeRange(
                                  start: DateTime.now().subtract(const Duration(days: 30)),
                                  end: DateTime.now(),
                                ),
                          );
                          if (picked != null) {
                            analyticsCtrl.setCustomDateRange(picked);
                          }
                        },
                      ),
                    ],
                  );
                });

                final monthSlider = Obx(() {
                  final currentFilter = analyticsCtrl.selectedFilter.value;
                  final customRange = analyticsCtrl.customDateRange.value;

                  // Only show month slider when in Monthly mode or viewing month-specific data
                  if (currentFilter != TimeFilter.monthly || customRange != null) {
                    return const SizedBox.shrink();
                  }

                  final selectedDate = analyticsCtrl.selectedMonthDate.value;
                  final monthYearStr = DateFormat('MMMM yyyy').format(selectedDate);
                  final isCurrentMonth = selectedDate.year == DateTime.now().year && selectedDate.month == DateTime.now().month;

                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          tooltip: 'Previous Month',
                          onPressed: () => analyticsCtrl.previousMonth(),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.accentLightBrown),
                            const SizedBox(width: 8),
                            Text(
                              monthYearStr,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                              ),
                            ),
                            if (isCurrentMonth) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentLightBrown.withAlpha(40),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Current',
                                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accentLightBrown),
                                ),
                              ),
                            ],
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          tooltip: 'Next Month',
                          onPressed: () => analyticsCtrl.nextMonth(),
                        ),
                      ],
                    ),
                  );
                });

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      toggleSwitcher,
                      const SizedBox(height: 12),
                      timeChips,
                      monthSlider,
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        toggleSwitcher,
                        timeChips,
                      ],
                    ),
                    monthSlider,
                  ],
                );
              },
            ),

            const SizedBox(height: 22),

            // Dynamic Body: Admin Analysis OR Worker Analysis
            Obx(() {
              final mode = analyticsCtrl.viewMode.value;
              return mode == AnalysisViewMode.admin
                  ? _buildAdminAnalysis(context, analyticsCtrl, isDark)
                  : _buildWorkerAnalysis(context, analyticsCtrl, isDark);
            }),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // ADMIN VIEW
  // =========================================================================
  Widget _buildAdminAnalysis(BuildContext context, AnalyticsController ctrl, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle & Rule explanation with update action
        Obx(() {
          final authCtrl = Get.find<AuthController>();
          final shirtWage = authCtrl.workerShirtWage.value;
          final pantWage = authCtrl.workerPantWage.value;
          final shirtProfit = 350.0 - shirtWage;
          final pantProfit = 400.0 - pantWage;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentLightBrown.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accentLightBrown.withAlpha(80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.accentLightBrown, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pricing Rule: Shirt (₹350) gives Worker ₹${shirtWage.toStringAsFixed(0)} & Admin Profit ₹${shirtProfit.toStringAsFixed(0)}. Pant (₹400) gives Worker ₹${pantWage.toStringAsFixed(0)} & Admin Profit ₹${pantProfit.toStringAsFixed(0)}.',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showUpdatePieceRatesDialog(context),
                  icon: const Icon(Icons.tune, size: 14),
                  label: const Text('Edit Rates', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: AppColors.accentLightBrown,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 18),

        // Admin KPI Cards: Total Income, Total Pending Due, Admin Net Profit
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 750;
            return GridView.count(
              crossAxisCount: isWide ? 3 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isWide ? 2.3 : 3.0,
              children: [
                // 1. Total Income / Total Billing
                _MetricCard(
                  title: 'Admin Total Income / Billing',
                  value: '₹${NumberFormat('#,##,###').format(ctrl.adminTotalIncome)}',
                  subtitle: '${ctrl.totalOrderCount} total orders (${ctrl.deliveredOrderCount} delivered)',
                  icon: Icons.account_balance_wallet,
                  badgeText: 'Total Billing',
                  accentColor: AppColors.accentLightBrown,
                  bgGradient: LinearGradient(
                    colors: [
                      AppColors.primaryDarkBrown,
                      AppColors.primaryDarkBrown.withAlpha(210),
                    ],
                  ),
                  textColor: Colors.white,
                ),

                // 2. Total Pending Payment Due Income
                _MetricCard(
                  title: 'Total Pending Payment Due',
                  value: '₹${NumberFormat('#,##,###').format(ctrl.adminPendingPaymentDue)}',
                  subtitle: 'Client balance due upon delivery',
                  icon: Icons.pending_actions,
                  badgeText: 'Pending Due',
                  accentColor: const Color(0xFFDC2626),
                  bgGradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF7F1D1D), const Color(0xFF450A0A)]
                        : [const Color(0xFFFEE2E2), const Color(0xFFFECACA)],
                  ),
                  textColor: isDark ? Colors.white : const Color(0xFF7F1D1D),
                ),

                // 3. Admin Net Profit
                _MetricCard(
                  title: 'Admin Net Profit (Margin)',
                  value: '₹${NumberFormat('#,##,###').format(ctrl.adminNetProfit)}',
                  subtitle: 'After deducting ₹${ctrl.totalWorkerWagesForOrders.toStringAsFixed(0)} worker piece-rate costs',
                  icon: Icons.trending_up,
                  badgeText: 'Net Profit',
                  accentColor: const Color(0xFF16A34A),
                  bgGradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF14532D), const Color(0xFF052E16)]
                        : [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)],
                  ),
                  textColor: isDark ? Colors.white : const Color(0xFF14532D),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 28),

        // Admin Order-by-Order Profit Breakdown Table
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 6,
          children: [
            Text(
              'Order Profit & Worker Cost Breakdown',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A).withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Advance: ₹${ctrl.adminAdvanceCollected.toStringAsFixed(0)}',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF16A34A)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (ctrl.filteredOrders.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No orders found for the selected timeframe.')),
            ),
          )
        else
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ctrl.filteredOrders.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final order = ctrl.filteredOrders[idx];
                final orderProfit = order.totalAmount - order.workerWage - order.discount;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;

                      if (isMobile) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '#${order.orderId} - ${order.customerName}',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${order.totalAmount.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${order.shirtQty} Shirts • ${order.pantQty} Pants | Staff: ${order.workerDisplayName}',
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD97706).withAlpha(25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Wage: ₹${order.workerWage.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFD97706)),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16A34A).withAlpha(25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Profit: ₹${orderProfit.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (order.finalPayable > 0 ? const Color(0xFFDC2626) : Colors.green).withAlpha(25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Due: ₹${order.finalPayable.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: order.finalPayable > 0 ? const Color(0xFFDC2626) : Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }

                      // Tablet & Desktop Row
                      return Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '#${order.orderId} - ${order.customerName}',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                                ),
                                Text(
                                  '${order.shirtQty} Shirt(s) • ${order.pantQty} Pant(s) • Book #${order.bookNo}',
                                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.workerDisplayName,
                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                Text('Worker Wage: ₹${order.workerWage.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFFD97706))),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total: ₹${order.totalAmount.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Due: ₹${order.finalPayable.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: order.finalPayable > 0 ? const Color(0xFFDC2626) : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16A34A).withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Profit: ₹${orderProfit.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // =========================================================================
  // WORKER VIEW
  // =========================================================================
  Widget _buildWorkerAnalysis(BuildContext context, AnalyticsController ctrl, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle explanation
        Obx(() {
          final authCtrl = Get.find<AuthController>();
          final shirtWage = authCtrl.workerShirtWage.value;
          final pantWage = authCtrl.workerPantWage.value;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withAlpha(25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF0D9488).withAlpha(80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.badge_outlined, color: Color(0xFF0D9488), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Worker Wage Credit: Shirt = ₹${shirtWage.toStringAsFixed(0)}/piece, Pant = ₹${pantWage.toStringAsFixed(0)}/piece. Cash advances taken are deducted from net payable salary.',
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showUpdatePieceRatesDialog(context),
                  icon: const Icon(Icons.tune, size: 14),
                  label: const Text('Edit Rates', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 18),

        // Worker KPI Cards: Total Paid Salary, Pending Due Salary, Advance Paid Salary
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 750;
            return GridView.count(
              crossAxisCount: isWide ? 3 : 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isWide ? 2.3 : 3.0,
              children: [
                // 1. Total Paid Salary
                _MetricCard(
                  title: 'Total Paid Salary',
                  value: '₹${NumberFormat('#,##,###').format(ctrl.workerTotalPaidSalary)}',
                  subtitle: 'Total payouts disbursed to staff',
                  icon: Icons.check_circle_outline,
                  badgeText: 'Disbursed',
                  accentColor: const Color(0xFF16A34A),
                  bgGradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF14532D), const Color(0xFF052E16)]
                        : [const Color(0xFFDCFCE7), const Color(0xFFBBF7D0)],
                  ),
                  textColor: isDark ? Colors.white : const Color(0xFF14532D),
                ),

                // 2. Pending Due Salary
                _MetricCard(
                  title: 'Pending Due Salary',
                  value: '₹${NumberFormat('#,##,###').format(ctrl.workerTotalPendingDueSalary)}',
                  subtitle: 'Earned order wages minus advances',
                  icon: Icons.pending_actions,
                  badgeText: 'Net Due',
                  accentColor: const Color(0xFF0284C7),
                  bgGradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF075985), const Color(0xFF0C4A6E)]
                        : [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)],
                  ),
                  textColor: isDark ? Colors.white : const Color(0xFF075985),
                ),

                // 3. Advance Paid Salary (Extra cash taken)
                _MetricCard(
                  title: 'Advance Paid / Extra Cash',
                  value: '₹${NumberFormat('#,##,###').format(ctrl.workerTotalAdvancePaidSalary)}',
                  subtitle: 'Minus from worker salary balance',
                  icon: Icons.money_off,
                  badgeText: 'Advance Taken',
                  accentColor: const Color(0xFFD97706),
                  bgGradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF78350F), const Color(0xFF451A03)]
                        : [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)],
                  ),
                  textColor: isDark ? Colors.white : const Color(0xFF78350F),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 28),

        // Per-Worker Detailed Salary Ledger
        Text(
          'Worker-Wise Ledger & Payout Settlement',
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
          ),
        ),

        const SizedBox(height: 12),

        if (ctrl.workerSalarySummaries.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No staff registered.')),
            ),
          )
        else
          Column(
            children: ctrl.workerSalarySummaries.map((s) {
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 650;

                      if (isMobile) {
                        final isSmall = MediaQuery.of(context).size.width <= 380;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Worker Header & Role Badge
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primaryDarkBrown.withAlpha(isDark ? 60 : 30),
                                  child: Text(
                                    s.worker.name.isNotEmpty ? s.worker.name[0].toUpperCase() : 'W',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: AppColors.accentLightBrown,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.worker.name,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${s.worker.role} • ${s.totalOrdersAssigned} Orders',
                                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(Icons.history_rounded, color: AppColors.accentLightBrown, size: 20),
                                  tooltip: 'History & Logs',
                                  onPressed: () => _showWorkerTransactionHistoryDialog(context, s.worker, ctrl),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Clean 3-part Financial Metrics Container
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _StatColumn(
                                      label: 'Earned',
                                      value: '₹${s.totalWagesEarned.toStringAsFixed(0)}',
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  Container(height: 28, width: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: _StatColumn(
                                        label: 'Advance',
                                        value: '-₹${s.totalAdvanceTaken.toStringAsFixed(0)}',
                                        color: const Color(0xFFD97706),
                                      ),
                                    ),
                                  ),
                                  Container(height: 28, width: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: _StatColumn(
                                        label: 'Net Due',
                                        value: '₹${s.netPendingSalary.toStringAsFixed(0)}',
                                        color: const Color(0xFF16A34A),
                                        isBold: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Professional Full-Width Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showRecordAdvanceDialog(context, s.worker),
                                    icon: const Icon(Icons.money_off, size: 15),
                                    label: Text(
                                      isSmall ? 'Advance' : 'Give Advance',
                                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFD97706),
                                      side: const BorderSide(color: Color(0xFFD97706), width: 1.2),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showSettleSalaryDialog(context, s),
                                    icon: const Icon(Icons.payments_rounded, size: 15),
                                    label: Text(
                                      isSmall ? 'Pay' : 'Pay Salary',
                                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF16A34A),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }

                      // Desktop / Tablet layout
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.accentLightBrown.withAlpha(40),
                            child: Text(
                              s.worker.name.isNotEmpty ? s.worker.name[0] : 'W',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.accentLightBrown,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.worker.name,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                                Text(
                                  '${s.worker.role} • ${s.worker.phone}',
                                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  '${s.totalOrdersAssigned} Orders Assigned',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.accentLightBrown,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: _StatColumn(
                              label: 'Earned Wages',
                              value: '₹${NumberFormat('#,##,###').format(s.totalWagesEarned)}',
                              color: Colors.blueAccent,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: _StatColumn(
                              label: 'Advance Taken (-)',
                              value: '-₹${NumberFormat('#,##,###').format(s.totalAdvanceTaken)}',
                              color: const Color(0xFFD97706),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: _StatColumn(
                              label: 'Net Due Salary',
                              value: '₹${NumberFormat('#,##,###').format(s.netPendingSalary)}',
                              color: const Color(0xFF16A34A),
                              isBold: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _showRecordAdvanceDialog(context, s.worker),
                                icon: const Icon(Icons.money_off, size: 16),
                                label: const Text('Advance'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFD97706),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _showSettleSalaryDialog(context, s),
                                icon: const Icon(Icons.payments, size: 16),
                                label: const Text('Pay Salary'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () => _showWorkerTransactionHistoryDialog(context, s.worker, ctrl),
                                icon: const Icon(Icons.history, size: 16),
                                label: const Text('History'),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// Helper Widgets
class _ToggleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentLightBrown : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.accentLightBrown,
      labelStyle: GoogleFonts.poppins(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        fontSize: 12,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final String badgeText;
  final Color accentColor;
  final Gradient bgGradient;
  final Color textColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.badgeText,
    required this.accentColor,
    required this.bgGradient,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: bgGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor.withAlpha(220),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
          Row(
            children: [
              Icon(icon, size: 14, color: textColor.withAlpha(180)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: textColor.withAlpha(200),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isBold;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
