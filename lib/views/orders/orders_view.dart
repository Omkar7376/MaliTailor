import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/responsive/adaptive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/order_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/adaptive_scaffold.dart';
import '../widgets/status_badge.dart';
import 'edit_order_dialog.dart';

class OrdersView extends StatelessWidget {
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderCtrl = Get.find<OrderController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filterTabs = ['All', 'Pending', 'In Progress', 'Ready', 'Delivered'];

    return AdaptiveScaffold(
      currentIndex: 2,
      title: 'Workshop Orders',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          tooltip: 'New Order',
          onPressed: () => Get.toNamed(AppRoutes.newOrder),
        ),
      ],
      body: Padding(
        padding: EdgeInsets.all(AdaptiveLayout.getHorizontalPadding(context)),
        child: Column(
          children: [
            // Filter Tabs & Search Bar Row
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Search bar
                    Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.accentLightBrown),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: orderCtrl.onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search by Order ID, Customer Name, Phone, or Book #...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    // Filter Status Chips
                    Obx(() {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: filterTabs.map((status) {
                            final isSelected = orderCtrl.selectedStatusFilter.value == status;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(status),
                                selected: isSelected,
                                onSelected: (_) => orderCtrl.setStatusFilter(status),
                                selectedColor: AppColors.accentLightBrown,
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.primaryDarkBrown
                                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Orders List
            Expanded(
              child: Obx(() {
                final list = orderCtrl.filteredOrders;

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No orders match this filter',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Change filter status or tap below to record a new order.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => Get.toNamed(AppRoutes.newOrder),
                          icon: const Icon(Icons.add),
                          label: const Text('Create New Order'),
                        ),
                      ],
                    ),
                  );
                }

                return Card(
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (_, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final order = list[index];
                      final isDueSoon = (order.isUrgent || order.deliveryDate.difference(DateTime.now()).inDays <= 2) &&
                          order.status != 'Delivered';
                      final isMobile = AdaptiveLayout.isMobile(context);

                      if (isMobile) {
                        final isSmall = AdaptiveLayout.isSmallMobile(context);
                        return InkWell(
                          onTap: () => Get.toNamed('/orders/${order.orderId}'),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmall ? 10 : 14,
                              vertical: isSmall ? 8 : 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Order ID + Customer Name & Book# + Status
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryDarkBrown.withAlpha(isDark ? 50 : 25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        order.orderId.replaceAll('ORD-', '#'),
                                        style: GoogleFonts.poppins(
                                          color: AppColors.accentLightBrown,
                                          fontWeight: FontWeight.w700,
                                          fontSize: isSmall ? 11 : 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              order.customerName,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: isSmall ? 13 : 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: isDark ? AppColors.darkBorder : AppColors.lightSurfaceCard,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Bk #${order.bookNo}',
                                              style: GoogleFonts.poppins(
                                                fontSize: isSmall ? 9 : 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (isDueSoon) ...[
                                            const SizedBox(width: 4),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.amber.withAlpha(40),
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.amber, width: 0.8),
                                              ),
                                              child: Text(
                                                'URGENT',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 7.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.amber.shade900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    PopupMenuButton<String>(
                                      initialValue: order.status,
                                      tooltip: 'Change Status',
                                      child: StatusBadge(status: order.status, compact: true),
                                      onSelected: (newStatus) {
                                        orderCtrl.updateStatus(order.orderId, newStatus);
                                      },
                                      itemBuilder: (context) => [
                                        'Pending',
                                        'In Progress',
                                        'Ready',
                                        'Delivered',
                                        'Cancelled',
                                      ].map((s) => PopupMenuItem(
                                        value: s,
                                        child: StatusBadge(status: s, compact: true),
                                      )).toList(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${order.orderType} • Due: ${DateFormat('dd MMM yyyy').format(order.deliveryDate)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmall ? 11 : 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                // Bottom Row: Amounts & Quick Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        spacing: isSmall ? 6 : 8,
                                        runSpacing: 2,
                                        children: [
                                          Text(
                                            'Tot: ₹${order.totalAmount.toStringAsFixed(0)}',
                                            style: GoogleFonts.poppins(
                                              fontSize: isSmall ? 10 : 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'Adv: ₹${order.advanceAmount.toStringAsFixed(0)}',
                                            style: GoogleFonts.poppins(
                                              fontSize: isSmall ? 10 : 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'Due: ₹${order.finalPayable.toStringAsFixed(0)}',
                                            style: GoogleFonts.poppins(
                                              fontSize: isSmall ? 10 : 11,
                                              fontWeight: FontWeight.w700,
                                              color: order.finalPayable > 0 ? Colors.redAccent : Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(Icons.send_rounded, color: Color(0xFF25D366), size: 18),
                                      tooltip: 'WhatsApp Alert',
                                      onPressed: () => orderCtrl.sendWhatsAppNotification(order),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.receipt_outlined, size: 18),
                                      tooltip: 'Invoice',
                                      onPressed: () => Get.toNamed('/invoices/${order.orderId}'),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, size: 18),
                                      tooltip: 'Order Actions',
                                      onSelected: (action) async {
                                        if (action == 'edit') {
                                          EditOrderDialog.show(context, order);
                                        } else if (action == 'delete') {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text('Delete Order?'),
                                              content: Text('Delete order ${order.orderId} for "${order.customerName}"?'),
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
                                            await orderCtrl.deleteOrder(order.orderId);
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
                                              Text('Edit Order'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                              SizedBox(width: 8),
                                              Text('Delete Order', style: TextStyle(color: Colors.redAccent)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDarkBrown.withAlpha(isDark ? 50 : 25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            order.orderId.replaceAll('ORD-', '#'),
                            style: GoogleFonts.poppins(
                              color: AppColors.accentLightBrown,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                order.customerName,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
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
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (isDueSoon) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withAlpha(40),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.amber, width: 0.8),
                                ),
                                child: Text(
                                  'URGENT',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${order.orderType} • Delivery: ${DateFormat('dd MMM yyyy').format(order.deliveryDate)}',
                                style: GoogleFonts.poppins(fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Total: ₹${order.totalAmount.toStringAsFixed(0)} | Advance: ₹${order.advanceAmount.toStringAsFixed(0)} | Due: ₹${order.finalPayable.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: order.finalPayable > 0 ? Colors.redAccent : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<String>(
                              initialValue: order.status,
                              tooltip: 'Change Status',
                              child: StatusBadge(status: order.status),
                              onSelected: (newStatus) {
                                orderCtrl.updateStatus(order.orderId, newStatus);
                              },
                              itemBuilder: (context) => [
                                'Pending',
                                'In Progress',
                                'Ready',
                                'Delivered',
                                'Cancelled',
                              ].map((s) {
                                return PopupMenuItem(
                                  value: s,
                                  child: Row(
                                    children: [
                                      StatusBadge(status: s, compact: true),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              icon: const Icon(Icons.send_rounded, color: Color(0xFF25D366), size: 20),
                              tooltip: 'WhatsApp Order Alert',
                              onPressed: () => orderCtrl.sendWhatsAppNotification(order),
                            ),
                            IconButton(
                              icon: const Icon(Icons.receipt_outlined, size: 20),
                              tooltip: 'View Invoice',
                              onPressed: () => Get.toNamed('/invoices/${order.orderId}'),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              tooltip: 'More Actions',
                              onSelected: (action) async {
                                if (action == 'edit') {
                                  EditOrderDialog.show(context, order);
                                } else if (action == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Order?'),
                                      content: Text('Delete order ${order.orderId} for "${order.customerName}"?'),
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
                                    await orderCtrl.deleteOrder(order.orderId);
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
                                      Text('Edit Order Details'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Text('Delete Order', style: TextStyle(color: Colors.redAccent)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => Get.toNamed('/orders/${order.orderId}'),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
