import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/order_controller.dart';
import '../../data/models/customer_model.dart';
import '../../routes/app_routes.dart';
import '../widgets/status_badge.dart';
import '../widgets/bottom_card_modal.dart';
import '../../core/responsive/adaptive_layout.dart';

import 'add_customer_dialog.dart';

class CustomerDetailModal extends StatefulWidget {
  final CustomerModel customer;

  const CustomerDetailModal({super.key, required this.customer});

  static void show(BuildContext context, CustomerModel customer) {
    Get.find<CustomerController>().selectCustomer(customer.id);
    showBottomUpCard(
      context: context,
      builder: (ctx) => CustomerDetailModal(customer: customer),
    );
  }

  @override
  State<CustomerDetailModal> createState() => _CustomerDetailModalState();
}

class _CustomerDetailModalState extends State<CustomerDetailModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerCtrl = Get.find<CustomerController>();
    final orderCtrl = Get.find<OrderController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = AdaptiveLayout.isMobile(context);
    final c = widget.customer;

    return Container(
      constraints: BoxConstraints(
        maxHeight: isMobile 
            ? MediaQuery.of(context).size.height * 0.85 
            : 760,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            // Modal Header with Customer Bio
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : AppColors.primaryDarkBrown,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.accentLightBrown,
                    child: Text(
                      c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                c.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentLightBrown.withAlpha(80),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.softGolden),
                              ),
                              child: Text(
                                'Book #${c.bookNo}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.softGolden,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.phone_outlined, size: 12, color: AppColors.softGolden),
                                const SizedBox(width: 4),
                                Text(c.mobile, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.transgender, size: 12, color: AppColors.softGolden),
                                const SizedBox(width: 4),
                                Text(c.gender, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70)),
                              ],
                            ),
                            if (c.address.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 12, color: AppColors.softGolden),
                                  const SizedBox(width: 4),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 140),
                                    child: Text(
                                      c.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.white70),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                        tooltip: 'Edit Customer',
                        onPressed: () {
                          Navigator.of(context).pop();
                          AddCustomerDialog.show(context, customerToEdit: c);
                        },
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                        tooltip: 'Delete Customer',
                        onPressed: () async {
                          final nav = Navigator.of(context);
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Customer?'),
                              content: Text('Are you sure you want to delete "${c.name}"?'),
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
                            nav.pop();
                            await customerCtrl.deleteCustomer(c.id);
                          }
                        },
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab Navigation
            Container(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.accentLightBrown,
                indicatorColor: AppColors.accentLightBrown,
                unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                tabs: const [
                  Tab(icon: Icon(Icons.checkroom), text: 'Shirt Measurements'),
                  Tab(icon: Icon(Icons.straighten), text: 'Pant Measurements'),
                  Tab(icon: Icon(Icons.history), text: 'Order History'),
                ],
              ),
            ),

            // Tab Views Content
            Expanded(
              child: Obx(() {
                if (customerCtrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final shirt = customerCtrl.shirtMeasurement.value;
                final pant = customerCtrl.pantMeasurement.value;
                final orders = customerCtrl.customerOrders;

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Shirt Tab
                    _buildMeasurementTab(
                      context: context,
                      title: 'Shirt Measurements (inches)',
                      items: [
                        _MeasurementEntry('Length (लंबाई)', shirt.length),
                        _MeasurementEntry('Chest (छाती)', shirt.chest),
                        _MeasurementEntry('Shoulder (कंधा)', shirt.shoulder),
                        _MeasurementEntry('Sleeve (आस्तीन)', shirt.sleeve),
                        _MeasurementEntry('Collar (कॉलर)', shirt.collar),
                        _MeasurementEntry('Cuff (कफ)', shirt.cuff),
                        _MeasurementEntry('Bicep (डोला)', shirt.bicep),
                        _MeasurementEntry('Back (पीठ)', shirt.back),
                      ],
                      notes: shirt.notes,
                    ),

                    // Pant Tab
                    _buildMeasurementTab(
                      context: context,
                      title: 'Pant / Trouser Measurements (inches)',
                      items: [
                        _MeasurementEntry('Outside Length (लंबाई)', pant.outsideLength),
                        _MeasurementEntry('Inside Length (अंदर लंबाई)', pant.insideLength),
                        _MeasurementEntry('Waist (कमर)', pant.waist),
                        _MeasurementEntry('Seat/Hip (सीट)', pant.seat),
                        _MeasurementEntry('Thigh (जांघ)', pant.thigh),
                        _MeasurementEntry('Knee (घुटना)', pant.knee),
                        _MeasurementEntry('Bottom (मोरी)', pant.bottom),
                        _MeasurementEntry('Rise/Fly (लटक)', pant.rise),
                      ],
                      notes: pant.notes,
                    ),

                    // Order History Tab
                    orders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.accentLightBrown),
                                const SizedBox(height: 10),
                                Text(
                                  'No previous orders for this customer',
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: orders.length,
                            separatorBuilder: (_, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final o = orders[index];
                              return Card(
                                child: ListTile(
                                  title: Text('Order #${o.orderId} (${o.orderType})'),
                                  subtitle: Text(
                                    'Delivery: ${DateFormat('dd MMM yyyy').format(o.deliveryDate)} • Total: ₹${o.totalAmount.toStringAsFixed(0)}',
                                  ),
                                  trailing: StatusBadge(status: o.status, compact: true),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Get.toNamed('/orders/${o.orderId}');
                                  },
                                ),
                              );
                            },
                          ),
                  ],
                );
              }),
            ),

            // Modal Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        customerCtrl.selectCustomer(c.id);
                        Get.toNamed('/customers/${c.id}');
                      },
                      icon: const Icon(Icons.fullscreen, size: 16),
                      label: const Text('Full Profile', overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        orderCtrl.selectCustomer(c);
                        Get.toNamed(AppRoutes.newOrder);
                      },
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                      label: const Text('New Order', overflow: TextOverflow.ellipsis),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDarkBrown,
                        foregroundColor: AppColors.softGolden,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildMeasurementTab({
    required BuildContext context,
    required String title,
    required List<_MeasurementEntry> items,
    required String notes,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.label,
                      style: GoogleFonts.poppins(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        item.value.isEmpty ? '—' : '${item.value}"',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.accentLightBrown.withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Styling Notes:', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(notes, style: GoogleFonts.poppins(fontSize: 12)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MeasurementEntry {
  final String label;
  final String value;

  _MeasurementEntry(this.label, this.value);
}
