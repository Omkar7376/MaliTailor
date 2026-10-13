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
        title: Text('Order #$orderId'),
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
                  // Order Header Banner
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.orderId,
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                                    ),
                                  ),
                                  Text(
                                    'Placed on ${DateFormat('dd MMMM yyyy').format(order.orderDate)}',
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                ],
                              ),
                              StatusBadge(status: order.status),
                            ],
                          ),
                          const Divider(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Customer Name', style: GoogleFonts.poppins(fontSize: 11)),
                                  Text(
                                    order.customerName,
                                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  Text('Phone: ${order.customerMobile}', style: GoogleFonts.poppins(fontSize: 12)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.accentLightBrown.withAlpha(30),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.accentLightBrown),
                                ),
                                child: Column(
                                  children: [
                                    Text('Ledger Book', style: GoogleFonts.poppins(fontSize: 10)),
                                    Text(
                                      '#${order.bookNo}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
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

                  const SizedBox(height: 18),

                  // Garment Details & Pricing Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Garment Items & Billing Details',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 14),
                          if (order.shirtQty > 0)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.checkroom, color: AppColors.accentLightBrown),
                              title: Text('Shirt (Qty: ${order.shirtQty})'),
                              trailing: Text(
                                '₹${order.shirtTotal.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                          if (order.pantQty > 0)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.straighten, color: AppColors.accentLightBrown),
                              title: Text('Pant / Trouser (Qty: ${order.pantQty})'),
                              trailing: Text(
                                '₹${order.pantTotal.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                          const Divider(),
                          _summaryRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(0)}'),
                          if (order.discount > 0)
                            _summaryRow('Discount', '- ₹${order.discount.toStringAsFixed(0)}', color: Colors.green),
                          _summaryRow('Advance Paid', '₹${order.advanceAmount.toStringAsFixed(0)}', color: Colors.green),
                          const Divider(),
                          _summaryRow(
                            'Balance Due',
                            '₹${order.finalPayable.toStringAsFixed(0)}',
                            bold: true,
                            color: order.finalPayable > 0 ? Colors.redAccent : Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Workshop Details & Quick Action Buttons
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workshop Actions & Status',
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          // Shirt Worker
                          if (order.shirtWorkerName != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.cut, size: 16, color: AppColors.accentLightBrown),
                                const SizedBox(width: 8),
                                Text('Shirt Tailor: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                Text(order.shirtWorkerName!),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentLightBrown.withAlpha(25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Wage: ₹${order.shirtWorkerWage.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentLightBrown),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],

                          // Pant Worker
                          if (order.pantWorkerName != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.straighten, size: 16, color: Color(0xFF0D9488)),
                                const SizedBox(width: 8),
                                Text('Pant Tailor: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                Text(order.pantWorkerName!),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D9488).withAlpha(25),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Wage: ₹${order.pantWorkerWage.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],

                          // Fallback single worker
                          if (order.shirtWorkerName == null && order.pantWorkerName == null) ...[
                            Row(
                              children: [
                                const Icon(Icons.badge_outlined, size: 16),
                                const SizedBox(width: 8),
                                Text('Assigned Staff: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                Text(order.assignedWorkerName ?? 'Not Assigned Yet'),
                                if (order.workerWage > 0) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentLightBrown.withAlpha(25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Wage: ₹${order.workerWage.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentLightBrown),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.event, size: 16),
                              const SizedBox(width: 8),
                              Text('Delivery Date: ', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              Text(DateFormat('dd MMMM yyyy').format(order.deliveryDate)),
                            ],
                          ),
                          if (order.note.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Note: ${order.note}', style: GoogleFonts.poppins(fontStyle: FontStyle.italic)),
                          ],
                          const SizedBox(height: 20),

                          // Action Buttons: Change Status, Send WhatsApp, View Invoice
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => orderCtrl.sendWhatsAppNotification(order),
                                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                                label: const Text('Send WhatsApp Alert'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF25D366),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => Get.toNamed('/invoices/${order.orderId}'),
                                icon: const Icon(Icons.receipt_long, size: 18),
                                label: const Text('Digital Invoice'),
                              ),
                              PopupMenuButton<String>(
                                initialValue: order.status,
                                onSelected: (s) => orderCtrl.updateStatus(order.orderId, s),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.accentLightBrown),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.edit, size: 16, color: AppColors.accentLightBrown),
                                      const SizedBox(width: 6),
                                      Text('Change Status: ${order.status}'),
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

                  const SizedBox(height: 40),
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
