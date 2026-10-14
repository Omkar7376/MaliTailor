import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/responsive/adaptive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/worker_controller.dart';
import '../../data/models/worker_model.dart';
import '../widgets/bottom_card_modal.dart';
import '../widgets/adaptive_scaffold.dart';

class WorkersView extends StatelessWidget {
  const WorkersView({super.key});

  void _showUpdatePieceRatesDialog(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final shirtWageCtrl = TextEditingController(text: authCtrl.workerShirtWage.value.toStringAsFixed(0));
    final pantWageCtrl = TextEditingController(text: authCtrl.workerPantWage.value.toStringAsFixed(0));
    final formKey = GlobalKey<FormState>();

    showBottomUpCard(
      context: context,
      maxHeightFactor: 0.65,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'These standard rates are automatically applied to all new orders. Existing orders remain unchanged.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: shirtWageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Shirt Piece Rate (₹ per piece) *',
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
                    labelText: 'Pant Piece Rate (₹ per piece) *',
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
        );
      },
    );
  }

  void _showWorkerFormDialog(
    BuildContext context,
    WorkerController workerCtrl, {
    WorkerModel? workerToEdit,
  }) {
    final nameCtrl = TextEditingController(text: workerToEdit?.name ?? '');
    final phoneCtrl = TextEditingController(text: workerToEdit?.phone ?? '');
    final roleCtrl = TextEditingController(text: workerToEdit?.role ?? '');
    final formKey = GlobalKey<FormState>();
    final isEditing = workerToEdit != null;

    showBottomUpCard(
      context: context,
      maxHeightFactor: 0.72,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Workshop Staff' : 'Add Workshop Staff',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Staff Name',
                    hintText: 'e.g. Master Rafiq / Suresh Karigar',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+91 98765 43210',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter phone' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: roleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Role / Designation',
                    hintText: 'e.g. Shirt Maker, Pant Maker, Master Cutter, Karigar...',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter role (e.g. Shirt Maker / Pant Maker)' : null,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildSuggestionChip('Shirt Maker', roleCtrl),
                    _buildSuggestionChip('Pant Maker', roleCtrl),
                    _buildSuggestionChip('Master Cutter', roleCtrl),
                    _buildSuggestionChip('Karigar', roleCtrl),
                    _buildSuggestionChip('Finisher', roleCtrl),
                  ],
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
                            final name = nameCtrl.text.trim();
                            final phone = phoneCtrl.text.trim();
                            final role = roleCtrl.text.trim();

                            if (isEditing) {
                              workerCtrl.updateWorker(
                                workerToEdit.copyWith(
                                  name: name,
                                  phone: phone,
                                  role: role,
                                ),
                              );
                            } else {
                              workerCtrl.addWorker(
                                name: name,
                                phone: phone,
                                role: role,
                              );
                            }
                            Navigator.pop(ctx);
                          }
                        },
                        child: Text(isEditing ? 'Save Changes' : 'Add Staff'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionChip(String label, TextEditingController controller) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      onPressed: () {
        controller.text = label;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final workerCtrl = Get.find<WorkerController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveScaffold(
      currentIndex: 3,
      title: 'Workshop Staff & Cutters',
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add),
          tooltip: 'Add Staff Member',
          onPressed: () => _showWorkerFormDialog(context, workerCtrl),
        ),
      ],
      body: Padding(
        padding: EdgeInsets.all(AdaptiveLayout.getHorizontalPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Worker Piece Rates Chart & Admin Update Banner
            Obx(() {
              final authCtrl = Get.find<AuthController>();
              final shirtRate = authCtrl.workerShirtWage.value;
              final pantRate = authCtrl.workerPantWage.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF2C2216), const Color(0xFF1E1710)]
                        : [const Color(0xFFFBF7F0), const Color(0xFFF3ECE1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.accentLightBrown.withAlpha(isDark ? 100 : 160),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 50 : 15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 400;
                        if (isCompact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentLightBrown.withAlpha(35),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.price_change_outlined, color: AppColors.accentLightBrown, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Piece-Rate Chart (कामगार दर)',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                                          ),
                                        ),
                                        Text(
                                          'Rates applied to future orders',
                                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton.icon(
                                  onPressed: () => _showUpdatePieceRatesDialog(context),
                                  icon: const Icon(Icons.edit, size: 14),
                                  label: const Text('Update Rates'),
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    side: const BorderSide(color: AppColors.accentLightBrown),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentLightBrown.withAlpha(35),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.price_change_outlined, color: AppColors.accentLightBrown, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Workshop Piece-Rate Chart (कामगार दर पत्रक)',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                                    ),
                                  ),
                                  Text(
                                    'Standard rates applied to future orders created by admin',
                                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _showUpdatePieceRatesDialog(context),
                              icon: const Icon(Icons.edit, size: 15),
                              label: const Text('Update Rates'),
                              style: OutlinedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                side: const BorderSide(color: AppColors.accentLightBrown),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.accentLightBrown.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.accentLightBrown.withAlpha(60)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.cut, size: 22, color: AppColors.accentLightBrown),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Shirt Piece Rate',
                                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                      Text(
                                        '₹${shirtRate.toStringAsFixed(0)} / piece',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? Colors.amber.shade200 : AppColors.primaryDarkBrown,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D9488).withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF0D9488).withAlpha(60)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.straighten, size: 22, color: Color(0xFF0D9488)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pant Piece Rate',
                                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                      Text(
                                        '₹${pantRate.toStringAsFixed(0)} / piece',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? const Color(0xFF5EEAD4) : const Color(0xFF0F766E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Staff & Workers',
                    style: GoogleFonts.poppins(
                      fontSize: AdaptiveLayout.isSmallMobile(context) ? 16 : 18,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _showWorkerFormDialog(context, workerCtrl),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Staff'),
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.symmetric(
                      horizontal: AdaptiveLayout.isSmallMobile(context) ? 10 : 16,
                      vertical: AdaptiveLayout.isSmallMobile(context) ? 8 : 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Obx(() {
                final list = workerCtrl.workers;

                if (list.isEmpty) {
                  return const Center(child: Text('No staff members registered yet.'));
                }

                return GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: list.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        AdaptiveLayout.getGridColumnCount(context, mobile: 1, tablet: 2, desktop: 3),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.2,
                  ),
                  itemBuilder: (context, index) {
                    final worker = list[index];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.primaryDarkBrown.withAlpha(isDark ? 50 : 25),
                              child: Text(
                                worker.name.isNotEmpty ? worker.name[0].toUpperCase() : 'W',
                                style: GoogleFonts.poppins(
                                  color: AppColors.accentLightBrown,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    worker.name,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    worker.role,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.accentLightBrown,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    worker.phone,
                                    style: GoogleFonts.poppins(fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              tooltip: 'Staff Options',
                              onSelected: (action) async {
                                if (action == 'edit') {
                                  _showWorkerFormDialog(
                                    context,
                                    workerCtrl,
                                    workerToEdit: worker,
                                  );
                                } else if (action == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Remove Staff Member?'),
                                      content: Text('Are you sure you want to remove "${worker.name}"? This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await workerCtrl.deleteWorker(worker.workerId, worker.name);
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 18),
                                      SizedBox(width: 8),
                                      Text('Edit Details'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Text('Remove Staff', style: TextStyle(color: Colors.redAccent)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
