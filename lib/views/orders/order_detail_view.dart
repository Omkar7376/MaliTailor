import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/responsive/adaptive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/order_controller.dart';
import '../widgets/status_badge.dart';
import 'edit_order_dialog.dart';

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderCtrl = Get.find<OrderController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderId = Get.parameters['id'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #$orderId', style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Order',
            onPressed: () {
              final order = orderCtrl.allOrders.firstWhereOrNull((o) => o.orderId == orderId);
              if (order != null) {
                EditOrderDialog.show(context, order);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete Order',
            onPressed: () async {
              final order = orderCtrl.allOrders.firstWhereOrNull((o) => o.orderId == orderId);
              if (order != null) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Order?'),
                    content: Text('Are you sure you want to delete order $orderId for "${order.customerName}"?'),
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
                  final ok = await orderCtrl.deleteOrder(orderId);
                  if (ok) {
                    Get.back();
                  }
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'View Invoice',
            onPressed: () => Get.toNamed('/invoices/$orderId'),
          ),
        ],
      ),
      body: Obx(() {
        final order = orderCtrl.allOrders.firstWhereOrNull((o) => o.orderId == orderId);
        if (order == null) {
          return const Center(child: Text('Order not found'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(AdaptiveLayout.getHorizontalPadding(context)),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Order Hero & Customer Card (Compact Atelier Header)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1.2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.orderId,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.3,
                                        color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd MMM yyyy, hh:mm a').format(order.orderDate),
                                      style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              StatusBadge(status: order.status),
                            ],
                          ),
                          const Divider(height: 18),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primaryDarkBrown.withAlpha(isDark ? 60 : 30),
                                child: Text(
                                  order.customerName.isNotEmpty ? order.customerName[0].toUpperCase() : 'C',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
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
                                      order.customerName,
                                      style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      order.customerMobile,
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurfaceCard : const Color(0xFFFBF7F0),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.accentLightBrown.withAlpha(120)),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Book #', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w500)),
                                    Text(
                                      '#${order.bookNo}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2. Garment Breakdown & Financial Summary Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1.2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.accentLightBrown.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.receipt_long_rounded, color: AppColors.accentLightBrown, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Garments & Billing',
                                  style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (order.shirtQty > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.checkroom, color: AppColors.accentLightBrown, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Shirt × ${order.shirtQty}',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '₹${order.shirtTotal.toStringAsFixed(0)}',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5),
                                  ),
                                ],
                              ),
                            ),
                          if (order.pantQty > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.straighten, color: Color(0xFF0D9488), size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Pant / Trouser × ${order.pantQty}',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '₹${order.pantTotal.toStringAsFixed(0)}',
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13.5),
                                  ),
                                ],
                              ),
                            ),
                          const Divider(height: 18),
                          _summaryRow('Subtotal', '₹${order.totalAmount.toStringAsFixed(0)}'),
                          if (order.discount > 0)
                            _summaryRow('Discount', '- ₹${order.discount.toStringAsFixed(0)}', color: Colors.green),
                          _summaryRow('Advance Paid', '₹${order.advanceAmount.toStringAsFixed(0)}', color: Colors.green),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: order.finalPayable > 0
                                  ? (isDark ? Colors.red.withAlpha(25) : const Color(0xFFFEF2F2))
                                  : (isDark ? Colors.green.withAlpha(25) : const Color(0xFFF0FDF4)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: order.finalPayable > 0
                                    ? Colors.redAccent.withAlpha(90)
                                    : Colors.green.withAlpha(90),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    order.finalPayable > 0 ? 'Balance Due' : 'Paid in Full',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: order.finalPayable > 0 ? Colors.redAccent : Colors.green,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '₹${order.finalPayable.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: order.finalPayable > 0 ? Colors.redAccent : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. Workshop Status & Assignment Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        width: 1.2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.statusPending.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.architecture_rounded, color: AppColors.statusPending, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Workshop & Delivery',
                                  style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Target Delivery Banner
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.event_available_rounded, size: 18, color: AppColors.accentLightBrown),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Target Delivery', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600)),
                                      Text(
                                        DateFormat('dd MMMM yyyy').format(order.deliveryDate),
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Tailor Assignments (Clean wrap)
                          if (order.shirtWorkerName != null) ...[
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                const Icon(Icons.cut, size: 14, color: AppColors.accentLightBrown),
                                Text('Shirt Tailor: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                                Text(order.shirtWorkerName!, style: GoogleFonts.poppins(fontSize: 12)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentLightBrown.withAlpha(25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Wage: ₹${order.shirtWorkerWage.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentLightBrown),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                          if (order.pantWorkerName != null) ...[
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                const Icon(Icons.straighten, size: 14, color: Color(0xFF0D9488)),
                                Text('Pant Tailor: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                                Text(order.pantWorkerName!, style: GoogleFonts.poppins(fontSize: 12)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D9488).withAlpha(25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Wage: ₹${order.pantWorkerWage.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                          if (order.shirtWorkerName == null && order.pantWorkerName == null) ...[
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                const Icon(Icons.badge_outlined, size: 14),
                                Text('Assigned: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12)),
                                Text(order.assignedWorkerName ?? 'Not Assigned', style: GoogleFonts.poppins(fontSize: 12)),
                                if (order.workerWage > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentLightBrown.withAlpha(25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Wage: ₹${order.workerWage.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentLightBrown),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],

                          if (order.note.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('Note: ${order.note}', style: GoogleFonts.poppins(fontStyle: FontStyle.italic, fontSize: 11.5, color: Colors.grey.shade600)),
                          ],
                          const SizedBox(height: 14),

                          // Quick Actions (WhatsApp, Invoice, Status Dropdown)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => orderCtrl.sendWhatsAppNotification(order),
                                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 15),
                                label: const Text('WhatsApp', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => Get.toNamed('/invoices/${order.orderId}'),
                                icon: const Icon(Icons.receipt_long_rounded, size: 15),
                                label: const Text('Invoice', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              PopupMenuButton<String>(
                                initialValue: order.status,
                                onSelected: (s) => orderCtrl.updateStatus(order.orderId, s),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                                    border: Border.all(color: AppColors.accentLightBrown),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.tune_rounded, size: 15, color: AppColors.accentLightBrown),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Status: ${order.status}',
                                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                itemBuilder: (context) => [
                                  'Pending',
                                  'In Progress',
                                  'Ready',
                                  'Delivered',
                                  'Cancelled',
                                ].map((s) => PopupMenuItem(value: s, child: Text(s))).toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              fontSize: bold ? 15 : 13,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              fontSize: bold ? 16 : 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
