import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/responsive/adaptive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/order_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/adaptive_scaffold.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/status_badge.dart';
import '../customers/add_customer_dialog.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardCtrl = Get.find<DashboardController>();
    final authCtrl = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = AdaptiveLayout.isDesktop(context);
    final isTablet = AdaptiveLayout.isTablet(context);

    return AdaptiveScaffold(
      currentIndex: 0,
      title: 'Workshop Dashboard',
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AdaptiveLayout.getHorizontalPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner Card
            Obx(() {
              final tailor = authCtrl.currentTailor.value;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF2E241B), const Color(0xFF3F3326)]
                        : [AppColors.primaryDarkBrown, const Color(0xFF4D3622)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accentLightBrown.withAlpha(50),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.accentLightBrown.withAlpha(100)),
                                ),
                                child: Text(
                                  'Mahadev Mali',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: AppColors.softGolden,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tailor?.shopName ?? 'Mali Tailor',
                            style: GoogleFonts.poppins(
                              fontSize: isDesktop ? 24 : 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Welcome back, ${tailor?.ownerName ?? "Master Tailor"}. Here is your workshop overview today.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.softGolden.withAlpha(220),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDesktop || isTablet)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.architecture_rounded, color: AppColors.softGolden, size: 40),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Live Metrics Counter Grid
            Text(
              'Real-Time Workshop Metrics',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
              ),
            ),
            const SizedBox(height: 12),

            Obx(() {
              final cols = AdaptiveLayout.getGridColumnCount(context, mobile: 2, tablet: 2, desktop: 4);
              return GridView.count(
                crossAxisCount: cols,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isDesktop ? 1.4 : (isTablet ? 1.5 : 1.3),
                children: [
                  StatCard(
                    title: 'Total Customers',
                    value: '${dashboardCtrl.totalCustomersCount}',
                    icon: Icons.people_alt_outlined,
                    accentColor: AppColors.accentLightBrown,
                    subtitle: 'Ledger Records',
                    onTap: () => Get.toNamed(AppRoutes.customers),
                  ),
                  StatCard(
                    title: 'Active Orders',
                    value: '${dashboardCtrl.activeOrdersCount}',
                    icon: Icons.schedule_outlined,
                    accentColor: AppColors.statusInProgress,
                    subtitle: 'In Workshop',
                    onTap: () => Get.toNamed(AppRoutes.orders),
                  ),
                  StatCard(
                    title: 'Pending Orders',
                    value: '${dashboardCtrl.pendingDeliveriesCount}',
                    icon: Icons.hourglass_top_rounded,
                    accentColor: AppColors.statusPending,
                    subtitle: 'Awaiting / Due',
                    onTap: () {
                      final orderCtrl = Get.find<OrderController>();
                      orderCtrl.setStatusFilter('Pending');
                      Get.toNamed(AppRoutes.orders);
                    },
                  ),
                  StatCard(
                    title: 'Delivered Today',
                    value: '${dashboardCtrl.deliveredTodayCount}',
                    icon: Icons.check_circle_outline,
                    accentColor: AppColors.statusDelivered,
                    subtitle: 'Completed',
                    onTap: () => Get.toNamed(AppRoutes.orders),
                  ),
                ],
              );
            }),

            // Quick Actions Section (Shown on Desktop/Tablet web views, hidden on Mobile where bottom bar already exists)
            if (!AdaptiveLayout.isMobile(context)) ...[
              const SizedBox(height: 28),
              Text(
                'Quick Workshop Operations',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: AdaptiveLayout.getGridColumnCount(context, mobile: 1, tablet: 2, desktop: 3),
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isDesktop ? 3.0 : 3.2,
                children: [
                  QuickActionCard(
                    title: 'New Customer',
                    icon: Icons.person_add_alt_1_outlined,
                    color: AppColors.accentLightBrown,
                    onTap: () => AddCustomerDialog.show(context),
                  ),
                  QuickActionCard(
                    title: 'Customers Directory',
                    icon: Icons.contacts_outlined,
                    color: AppColors.secondaryMediumBrown,
                    onTap: () => Get.toNamed(AppRoutes.customers),
                  ),
                  QuickActionCard(
                    title: 'Create New Order',
                    icon: Icons.add_shopping_cart_outlined,
                    color: AppColors.tealAccent,
                    onTap: () => Get.toNamed(AppRoutes.newOrder),
                  ),
                  QuickActionCard(
                    title: 'Orders & Deliveries',
                    icon: Icons.local_shipping_outlined,
                    color: AppColors.statusPending,
                    onTap: () => Get.toNamed(AppRoutes.orders),
                  ),
                  QuickActionCard(
                    title: 'Workshop Staff & Cutters',
                    icon: Icons.badge_outlined,
                    color: AppColors.statusInProgress,
                    onTap: () => Get.toNamed(AppRoutes.workers),
                  ),
                  QuickActionCard(
                    title: 'Urgent Deliveries',
                    icon: Icons.timer_outlined,
                    color: AppColors.statusCancelled,
                    onTap: () => Get.toNamed(AppRoutes.orders),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 32),

            // Recent Orders Header & List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Recent Workshop Orders',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.orders),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accentLightBrown,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Obx(() {
              final recent = dashboardCtrl.recentOrders;
              if (recent.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No orders created yet. Tap "Create New Order" to start!',
                        style: GoogleFonts.poppins(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recent.length,
                  separatorBuilder: (_, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final order = recent[index];
                    final isDueSoon = order.deliveryDate.difference(DateTime.now()).inDays <= 2 &&
                        order.status != 'Delivered';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDarkBrown.withAlpha(isDark ? 50 : 20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          order.orderType == 'Shirt'
                              ? Icons.checkroom
                              : (order.orderType == 'Pant' ? Icons.straighten : Icons.dry_cleaning),
                          color: AppColors.accentLightBrown,
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              order.customerName,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkBorder : AppColors.lightSurfaceCard,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Book #${order.bookNo}',
                              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (isDueSoon) ...[
                            const SizedBox(width: 6),
                            const Tooltip(
                              message: 'Urgent Delivery Due',
                              child: Icon(Icons.warning_amber_rounded, size: 16, color: Colors.amber),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        '#${order.orderId.replaceAll('ORD-', '')} • Due: ${DateFormat('dd MMM').format(order.deliveryDate)} • ₹${order.totalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StatusBadge(status: order.status, compact: true),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 16),
                        ],
                      ),
                      onTap: () => Get.toNamed('/orders/${order.orderId}'),
                    );
                  },
                ),
              );
            }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
