import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/responsive/adaptive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/order_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/measurement_input_card.dart';
import '../widgets/status_badge.dart';
import 'add_customer_dialog.dart';

class CustomerDetailView extends StatefulWidget {
  const CustomerDetailView({super.key});

  @override
  State<CustomerDetailView> createState() => _CustomerDetailViewState();
}

class _CustomerDetailViewState extends State<CustomerDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final customerCtrl = Get.find<CustomerController>();
  final orderCtrl = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // If ID was passed in route parameters, always load measurements freshly
    final id = Get.parameters['id'];
    if (id != null && id.isNotEmpty) {
      customerCtrl.selectCustomer(id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = AdaptiveLayout.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(customerCtrl.selectedCustomer.value?.name ?? 'Customer Profile')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Customer Details',
            onPressed: () {
              final c = customerCtrl.selectedCustomer.value;
              if (c != null) {
                AddCustomerDialog.show(context, customerToEdit: c);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete Customer',
            onPressed: () async {
              final c = customerCtrl.selectedCustomer.value;
              if (c != null) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Customer?'),
                    content: Text('Are you sure you want to delete "${c.name}"? This action cannot be undone.'),
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
                  final ok = await customerCtrl.deleteCustomer(c.id);
                  if (ok) {
                    Get.back();
                  }
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            tooltip: 'Create Order for this Customer',
            onPressed: () {
              final c = customerCtrl.selectedCustomer.value;
              if (c != null) {
                orderCtrl.selectCustomer(c);
                Get.toNamed(AppRoutes.newOrder);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (customerCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final customer = customerCtrl.selectedCustomer.value;
        if (customer == null) {
          return const Center(child: Text('Customer not found.'));
        }

        return Column(
          children: [
            // Customer Header Profile Card
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AdaptiveLayout.getHorizontalPadding(context),
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryDarkBrown,
                    child: Text(
                      customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                      style: GoogleFonts.poppins(
                        color: AppColors.softGolden,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              customer.name,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.accentLightBrown.withAlpha(isDark ? 60 : 40),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.accentLightBrown),
                              ),
                              child: Text(
                                'Ledger Book #${customer.bookNo}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.softGolden : AppColors.secondaryMediumBrown,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 14, color: AppColors.accentLightBrown),
                            const SizedBox(width: 4),
                            Text(customer.mobile, style: GoogleFonts.poppins(fontSize: 13)),
                            const SizedBox(width: 16),
                            const Icon(Icons.badge, size: 14, color: AppColors.accentLightBrown),
                            const SizedBox(width: 4),
                            Text(customer.gender, style: GoogleFonts.poppins(fontSize: 13)),
                            if (customer.address.isNotEmpty) ...[
                              const SizedBox(width: 16),
                              const Icon(Icons.location_on, size: 14, color: AppColors.accentLightBrown),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  customer.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar: Shirt Measurements, Pant Measurements, Order History
            Container(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.accentLightBrown,
                indicatorColor: AppColors.accentLightBrown,
                unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                tabs: const [
                  Tab(icon: Icon(Icons.checkroom, size: 20), text: 'Shirt'),
                  Tab(icon: Icon(Icons.straighten, size: 20), text: 'Pant'),
                  Tab(icon: Icon(Icons.history, size: 20), text: 'Orders'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildShirtTab(context, isDesktop),
                  _buildPantTab(context, isDesktop),
                  _buildOrdersHistoryTab(context),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // --- Shirt Measurement Tab ---
  Widget _buildShirtTab(BuildContext context, bool isDesktop) {
    return Obx(() {
      final shirt = customerCtrl.shirtMeasurement.value;

      return SingleChildScrollView(
        padding: EdgeInsets.all(AdaptiveLayout.getHorizontalPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Bespoke Shirt Dimensions (Inches)',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: customerCtrl.isSavingMeasurement.value
                      ? null
                      : () => customerCtrl.saveShirt(shirt),
                  icon: const Icon(Icons.save_outlined, size: 16),
                  label: const Text('Save Shirt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkBrown,
                    foregroundColor: AppColors.softGolden,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Measurement Inputs Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final int cols = width > 1200
                    ? 4
                    : width > 750
                        ? 3
                        : 2;
                // Height of card is ~72px, calculate aspect ratio so cards hug children snugly
                final cardWidth = (width - ((cols - 1) * 12)) / cols;
                final childAspectRatio = (cardWidth / 74).clamp(1.8, 5.0);

                return GridView.count(
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: childAspectRatio,
                  children: [
                MeasurementInputCard(
                  label: 'Length (लंबाई)',
                  value: shirt.length,
                  onChanged: (v) => customerCtrl.shirtMeasurement.value = shirt.copyWith(length: v),
                ),
                MeasurementInputCard(
                  label: 'Chest (छाती)',
                  value: shirt.chest,
                  onChanged: (v) => customerCtrl.shirtMeasurement.value = shirt.copyWith(chest: v),
                ),
                MeasurementInputCard(
                  label: 'Shoulder (कंधा)',
                  value: shirt.shoulder,
                  onChanged: (v) => customerCtrl.shirtMeasurement.value = shirt.copyWith(shoulder: v),
                ),
                MeasurementInputCard(
                  label: 'Sleeve (आस्तीन)',
                  value: shirt.sleeve,
                  onChanged: (v) => customerCtrl.shirtMeasurement.value = shirt.copyWith(sleeve: v),
                ),
                MeasurementInputCard(
                  label: 'Collar (कॉलर)',
                  value: shirt.collar,
                  onChanged: (v) => customerCtrl.shirtMeasurement.value = shirt.copyWith(collar: v),
                ),
                MeasurementInputCard(
                  label: 'Cuff (कफ)',
                  value: shirt.cuff,
                  onChanged: (v) => customerCtrl.shirtMeasurement.value = shirt.copyWith(cuff: v),
                ),
                MeasurementInputCard(
                  label: 'Bicep (डोला)',
                  value: shirt.bicep,
                  onChanged: (v) => customerCtrl.shirtMeasurement.value = shirt.copyWith(bicep: v),
                ),
                MeasurementInputCard(
                  label: 'Back (पीठ)',
                  value: shirt.back,
                  onChanged: (v) => customerCtrl.shirtMeasurement.value = shirt.copyWith(back: v),
                ),
                MeasurementInputCard(
                  label: 'Front 1 (छाती 1)',
                  value: shirt.front1,
                  onChanged: (v) => customerCtrl.shirtMeasurement.value = shirt.copyWith(front1: v),
                ),
                MeasurementInputCard(
                  label: 'Front 2 (पेट 2)',
                  value: shirt.front2,
                  onChanged: (v) => customerCtrl.shirtMeasurement.value = shirt.copyWith(front2: v),
                ),
                MeasurementInputCard(
                  label: 'Front 3 (कमर 3)',
                  value: shirt.front3,
                  onChanged: (v) => customerCtrl.shirtMeasurement.value = shirt.copyWith(front3: v),
                ),
              ],
            );
          },
        ),

            const SizedBox(height: 20),

            // Notes / Fitting Instructions
            TextFormField(
              initialValue: shirt.notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Special Cutting / Collar / Pocket Notes',
                hintText: 'e.g. Slim fit collar, french cuffs, single flap pocket on left...',
              ),
              onChanged: (v) => customerCtrl.shirtMeasurement.value = shirt.copyWith(notes: v),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
    });
  }

  // --- Pant Measurement Tab ---
  Widget _buildPantTab(BuildContext context, bool isDesktop) {
    return Obx(() {
      final pant = customerCtrl.pantMeasurement.value;

      return SingleChildScrollView(
        padding: EdgeInsets.all(AdaptiveLayout.getHorizontalPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Bespoke Pant / Trouser Dimensions (Inches)',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: customerCtrl.isSavingMeasurement.value
                      ? null
                      : () => customerCtrl.savePant(pant),
                  icon: const Icon(Icons.save_outlined, size: 16),
                  label: const Text('Save Pant'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkBrown,
                    foregroundColor: AppColors.softGolden,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Inputs Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final int cols = width > 1200
                    ? 4
                    : width > 750
                        ? 3
                        : 2;
                final cardWidth = (width - ((cols - 1) * 12)) / cols;
                final childAspectRatio = (cardWidth / 74).clamp(1.8, 5.0);

                return GridView.count(
                  crossAxisCount: cols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: childAspectRatio,
                  children: [
                MeasurementInputCard(
                  label: 'Outside Length (लंबाई)',
                  value: pant.outsideLength,
                  onChanged: (v) => customerCtrl.pantMeasurement.value = pant.copyWith(outsideLength: v),
                ),
                MeasurementInputCard(
                  label: 'Inside Length (अंदर लंबाई)',
                  value: pant.insideLength,
                  onChanged: (v) => customerCtrl.pantMeasurement.value = pant.copyWith(insideLength: v),
                ),
                MeasurementInputCard(
                  label: 'Waist (कमर)',
                  value: pant.waist,
                  onChanged: (v) => customerCtrl.pantMeasurement.value = pant.copyWith(waist: v),
                ),
                MeasurementInputCard(
                  label: 'Seat / Hip (हिप/सीट)',
                  value: pant.seat,
                  onChanged: (v) => customerCtrl.pantMeasurement.value = pant.copyWith(seat: v),
                ),
                MeasurementInputCard(
                  label: 'Thigh (जांघ)',
                  value: pant.thigh,
                  onChanged: (v) => customerCtrl.pantMeasurement.value = pant.copyWith(thigh: v),
                ),
                MeasurementInputCard(
                  label: 'Knee (घुटना)',
                  value: pant.knee,
                  onChanged: (v) => customerCtrl.pantMeasurement.value = pant.copyWith(knee: v),
                ),
                MeasurementInputCard(
                  label: 'Bottom (मोरी/बॉटम)',
                  value: pant.bottom,
                  onChanged: (v) => customerCtrl.pantMeasurement.value = pant.copyWith(bottom: v),
                ),
                MeasurementInputCard(
                  label: 'Rise / Fly (लटक/राइज)',
                  value: pant.rise,
                  onChanged: (v) => customerCtrl.pantMeasurement.value = pant.copyWith(rise: v),
                ),
              ],
            );
          },
        ),

            const SizedBox(height: 20),

            TextFormField(
              initialValue: pant.notes,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Special Trouser Cut Notes',
                hintText: 'e.g. Cross pocket, single pleat, pencil bottom, elastic side tabs...',
              ),
              onChanged: (v) => customerCtrl.pantMeasurement.value = pant.copyWith(notes: v),
            ),
            const SizedBox(height: 30),
          ],
        ),
      );
    });
  }

  // --- Order History Tab ---
  Widget _buildOrdersHistoryTab(BuildContext context) {
    return Obx(() {
      final orders = customerCtrl.customerOrders;

      if (orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long_outlined, size: 54, color: AppColors.accentLightBrown),
              const SizedBox(height: 12),
              Text(
                'No orders placed yet for this customer',
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final c = customerCtrl.selectedCustomer.value;
                  if (c != null) {
                    orderCtrl.selectCustomer(c);
                    Get.toNamed(AppRoutes.newOrder);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New Order'),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.all(AdaptiveLayout.getHorizontalPadding(context)),
        itemCount: orders.length,
        separatorBuilder: (_, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final o = orders[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Order #${o.orderId} (${o.orderType})',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: o.status, compact: true),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Delivery: ${DateFormat('dd MMM yyyy').format(o.deliveryDate)}',
                      style: GoogleFonts.poppins(fontSize: 11),
                    ),
                    Text(
                      'Total: ₹${o.totalAmount.toStringAsFixed(0)} | Due: ₹${o.finalPayable.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: o.finalPayable > 0 ? Colors.redAccent : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => Get.toNamed('/orders/${o.orderId}'),
            ),
          );
        },
      );
    });
  }
}
