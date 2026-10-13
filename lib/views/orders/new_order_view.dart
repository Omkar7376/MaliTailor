import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/responsive/adaptive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/customer_controller.dart';
import '../../controllers/worker_controller.dart';

class NewOrderView extends StatefulWidget {
  const NewOrderView({super.key});

  @override
  State<NewOrderView> createState() => _NewOrderViewState();
}

class _NewOrderViewState extends State<NewOrderView> {
  final orderCtrl = Get.find<OrderController>();
  final customerCtrl = Get.find<CustomerController>();
  final workerCtrl = Get.find<WorkerController>();

  late TextEditingController _nameController;
  late TextEditingController _bookController;
  late TextEditingController _mobileController;
  late TextEditingController _shirtQtyController;
  late TextEditingController _shirtRateController;
  late TextEditingController _pantQtyController;
  late TextEditingController _pantRateController;
  late TextEditingController _discountController;
  late TextEditingController _advanceController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: orderCtrl.customerName.value);
    _bookController = TextEditingController(text: orderCtrl.bookNo.value);
    _mobileController = TextEditingController(text: orderCtrl.customerMobile.value);
    _shirtQtyController = TextEditingController(text: orderCtrl.shirtQty.value.toString());
    _shirtRateController = TextEditingController(text: orderCtrl.shirtRate.value.toStringAsFixed(0));
    _pantQtyController = TextEditingController(text: orderCtrl.pantQty.value.toString());
    _pantRateController = TextEditingController(text: orderCtrl.pantRate.value.toStringAsFixed(0));
    _discountController = TextEditingController(text: orderCtrl.discount.value.toStringAsFixed(0));
    _advanceController = TextEditingController(text: orderCtrl.advanceAmount.value.toStringAsFixed(0));
    _noteController = TextEditingController(text: orderCtrl.orderNote.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bookController.dispose();
    _mobileController.dispose();
    _shirtQtyController.dispose();
    _shirtRateController.dispose();
    _pantQtyController.dispose();
    _pantRateController.dispose();
    _discountController.dispose();
    _advanceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _syncCustomerSelection() {
    _nameController.text = orderCtrl.customerName.value;
    _bookController.text = orderCtrl.bookNo.value;
    _mobileController.text = orderCtrl.customerMobile.value;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Tailoring Order'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AdaptiveLayout.getHorizontalPadding(context)),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Customer Selection / Quick Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentLightBrown.withAlpha(isDark ? 50 : 30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.person, color: AppColors.accentLightBrown, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Customer Information',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Dropdown to choose existing customer
                        Obx(() {
                          final customers = customerCtrl.allCustomers;
                          return DropdownButtonFormField<String>(
                            initialValue: orderCtrl.selectedCustomerForOrder.value?.id,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Choose from Existing Customers',
                              prefixIcon: Icon(Icons.contacts_outlined),
                            ),
                            items: customers.map((c) {
                              return DropdownMenuItem(
                                value: c.id,
                                child: Text(
                                  '${c.name} (Book #${c.bookNo} - ${c.mobile})',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (selectedId) {
                              if (selectedId != null) {
                                final cust = customers.firstWhere((c) => c.id == selectedId);
                                orderCtrl.selectCustomer(cust);
                                _syncCustomerSelection();
                              }
                            },
                          );
                        }),

                        const SizedBox(height: 16),

                        // Customer Details Form Fields
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Customer Name *',
                                  prefixIcon: Icon(Icons.badge_outlined, size: 20),
                                  hintText: 'e.g. Ramesh Patel',
                                ),
                                onChanged: (v) => orderCtrl.customerName.value = v,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _bookController,
                                decoration: const InputDecoration(
                                  labelText: 'Ledger #',
                                  prefixIcon: Icon(Icons.menu_book, size: 20),
                                  hintText: '108',
                                ),
                                onChanged: (v) => orderCtrl.bookNo.value = v,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Mobile Phone Number *',
                            prefixIcon: Icon(Icons.phone_outlined, size: 20),
                            hintText: '+91 98765 43210',
                          ),
                          onChanged: (v) => orderCtrl.customerMobile.value = v,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Order Items & Live Calculations Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.tealAccent.withAlpha(isDark ? 50 : 30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.cut, color: AppColors.tealAccent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Garment Items & Reactive Pricing',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Order Type Selector
                        Obx(() {
                          return DropdownButtonFormField<String>(
                            initialValue: orderCtrl.orderType.value,
                            decoration: const InputDecoration(
                              labelText: 'Order Garment Type',
                              prefixIcon: Icon(Icons.checkroom),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Both', child: Text('Shirt & Pant (Both)')),
                              DropdownMenuItem(value: 'Shirt', child: Text('Shirt Only')),
                              DropdownMenuItem(value: 'Pant', child: Text('Pant / Trouser Only')),
                              DropdownMenuItem(value: 'Suit', child: Text('Three Piece / Suit')),
                              DropdownMenuItem(value: 'Custom', child: Text('Custom Garment')),
                            ],
                            onChanged: (v) {
                              if (v != null) orderCtrl.orderType.value = v;
                            },
                          );
                        }),

                        const SizedBox(height: 20),

                        // Shirt Row
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _shirtQtyController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  labelText: 'Shirt Qty',
                                  prefixIcon: IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    tooltip: 'Decrease Shirt Qty',
                                    splashRadius: 18,
                                    onPressed: () {
                                      final current = int.tryParse(_shirtQtyController.text) ?? orderCtrl.shirtQty.value;
                                      if (current > 0) {
                                        final next = current - 1;
                                        _shirtQtyController.text = next.toString();
                                        orderCtrl.shirtQty.value = next;
                                        orderCtrl.autoUpdateWorkerWage();
                                      }
                                    },
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.accentLightBrown),
                                    tooltip: 'Increase Shirt Qty',
                                    splashRadius: 18,
                                    onPressed: () {
                                      final current = int.tryParse(_shirtQtyController.text) ?? orderCtrl.shirtQty.value;
                                      final next = current + 1;
                                      _shirtQtyController.text = next.toString();
                                      orderCtrl.shirtQty.value = next;
                                      orderCtrl.autoUpdateWorkerWage();
                                    },
                                  ),
                                ),
                                onChanged: (v) {
                                  orderCtrl.shirtQty.value = int.tryParse(v) ?? 0;
                                  orderCtrl.autoUpdateWorkerWage();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _shirtRateController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Shirt Rate (₹)'),
                                onChanged: (v) => orderCtrl.shirtRate.value = double.tryParse(v) ?? 0.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Shirt Subtotal', style: GoogleFonts.poppins(fontSize: 9), overflow: TextOverflow.ellipsis),
                                        Text(
                                          '₹${orderCtrl.shirtTotal.toStringAsFixed(0)}',
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Pant Row
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _pantQtyController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  labelText: 'Pant Qty',
                                  prefixIcon: IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    tooltip: 'Decrease Pant Qty',
                                    splashRadius: 18,
                                    onPressed: () {
                                      final current = int.tryParse(_pantQtyController.text) ?? orderCtrl.pantQty.value;
                                      if (current > 0) {
                                        final next = current - 1;
                                        _pantQtyController.text = next.toString();
                                        orderCtrl.pantQty.value = next;
                                        orderCtrl.autoUpdateWorkerWage();
                                      }
                                    },
                                  ),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF0D9488)),
                                    tooltip: 'Increase Pant Qty',
                                    splashRadius: 18,
                                    onPressed: () {
                                      final current = int.tryParse(_pantQtyController.text) ?? orderCtrl.pantQty.value;
                                      final next = current + 1;
                                      _pantQtyController.text = next.toString();
                                      orderCtrl.pantQty.value = next;
                                      orderCtrl.autoUpdateWorkerWage();
                                    },
                                  ),
                                ),
                                onChanged: (v) {
                                  orderCtrl.pantQty.value = int.tryParse(v) ?? 0;
                                  orderCtrl.autoUpdateWorkerWage();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _pantRateController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Pant Rate (₹)'),
                                onChanged: (v) => orderCtrl.pantRate.value = double.tryParse(v) ?? 0.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Pant Subtotal', style: GoogleFonts.poppins(fontSize: 9), overflow: TextOverflow.ellipsis),
                                        Text(
                                          '₹${orderCtrl.pantTotal.toStringAsFixed(0)}',
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),

                        // Discount & Advance Inputs
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _discountController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Discount (₹)',
                                  prefixIcon: Icon(Icons.discount_outlined),
                                ),
                                onChanged: (v) => orderCtrl.discount.value = double.tryParse(v) ?? 0.0,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _advanceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Advance Paid (₹)',
                                  prefixIcon: Icon(Icons.payments_outlined),
                                ),
                                onChanged: (v) => orderCtrl.advanceAmount.value = double.tryParse(v) ?? 0.0,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Real-Time Net Summary Banner
                        Obx(() {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF3B2E20) : const Color(0xFFF3ECE4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.accentLightBrown),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text('Total Amount', style: GoogleFonts.poppins(fontSize: 11), overflow: TextOverflow.ellipsis),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '₹${orderCtrl.totalAmount.toStringAsFixed(0)}',
                                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(height: 32, width: 1, color: AppColors.accentLightBrown.withAlpha(100)),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text('Advance Paid', style: GoogleFonts.poppins(fontSize: 11), overflow: TextOverflow.ellipsis),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '₹${orderCtrl.advanceAmount.value.toStringAsFixed(0)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(height: 32, width: 1, color: AppColors.accentLightBrown.withAlpha(100)),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text('Balance Due', style: GoogleFonts.poppins(fontSize: 11), overflow: TextOverflow.ellipsis),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '₹${orderCtrl.finalPayable.toStringAsFixed(0)}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w800,
                                            color: orderCtrl.finalPayable > 0 ? Colors.redAccent : Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Delivery Date & Workshop Staff Assignment Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.statusPending.withAlpha(isDark ? 50 : 30),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.calendar_today, color: AppColors.statusPending, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Delivery Date & Assignment',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Delivery Date Picker Button
                        Obx(() {
                          final date = orderCtrl.deliveryDate.value;
                          final isUrgent = orderCtrl.isUrgentDelivery;

                          return InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: date,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 120)),
                              );
                              if (picked != null) {
                                orderCtrl.deliveryDate.value = picked;
                              }
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isUrgent ? Colors.redAccent : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                  width: isUrgent ? 1.5 : 1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event,
                                    color: isUrgent ? Colors.redAccent : AppColors.accentLightBrown,
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Target Delivery Date', style: GoogleFonts.poppins(fontSize: 11)),
                                      Text(
                                        DateFormat('EEEE, dd MMMM yyyy').format(date),
                                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  if (isUrgent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withAlpha(30),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.redAccent),
                                      ),
                                      child: Text(
                                        '⚡ URGENT DELIVERY ALERT',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 12),

                        // Mark as Urgent Toggle Switch
                        Obx(() {
                          final isMarked = orderCtrl.isUrgent.value;

                          return Container(
                            decoration: BoxDecoration(
                              color: isMarked
                                  ? Colors.redAccent.withAlpha(isDark ? 35 : 20)
                                  : (isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isMarked
                                    ? Colors.redAccent
                                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                width: isMarked ? 1.5 : 1,
                              ),
                            ),
                            child: SwitchListTile(
                              value: isMarked,
                              activeTrackColor: Colors.redAccent.withAlpha(150),
                              thumbColor: WidgetStateProperty.resolveWith(
                                (states) => states.contains(WidgetState.selected) ? Colors.redAccent : null,
                              ),
                              dense: true,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              secondary: Icon(
                                Icons.bolt,
                                color: isMarked ? Colors.redAccent : Colors.grey,
                                size: 24,
                              ),
                              title: Text(
                                'Mark as Urgent Order (तातडीची ऑर्डर)',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isMarked ? Colors.redAccent : null,
                                ),
                              ),
                              subtitle: Text(
                                'Prioritize in workshop queue and mark with urgent status badge',
                                style: GoogleFonts.poppins(fontSize: 11),
                              ),
                              onChanged: (val) {
                                orderCtrl.isUrgent.value = val;
                              },
                            ),
                          );
                        }),

                        const SizedBox(height: 16),

                        // Section: Separate Workers for Shirt & Pant
                        Obx(() {
                          final workers = workerCtrl.workers;
                          final hasShirt = orderCtrl.shirtQty.value > 0;
                          final hasPant = orderCtrl.pantQty.value > 0;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Shirt Tailor / Karigar Selection
                              if (hasShirt) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentLightBrown.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.accentLightBrown.withAlpha(80)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.cut, size: 18, color: AppColors.accentLightBrown),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Shirt Karigar / Tailor',
                                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                                          ),
                                          const Spacer(),
                                          Text(
                                            'Wage: ₹${orderCtrl.workerShirtWageRate.toStringAsFixed(0)} × ${orderCtrl.shirtQty.value}',
                                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      DropdownButtonFormField<String>(
                                        initialValue: orderCtrl.shirtWorkerId.value.isEmpty ? null : orderCtrl.shirtWorkerId.value,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Choose Worker for Shirt',
                                          prefixIcon: Icon(Icons.person_pin),
                                        ),
                                        items: workers.map((w) {
                                          return DropdownMenuItem(
                                            value: w.workerId,
                                            child: Text(
                                              '${w.name} (${w.role})',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (id) {
                                          if (id != null) {
                                            orderCtrl.shirtWorkerId.value = id;
                                            final w = workers.firstWhere((x) => x.workerId == id);
                                            orderCtrl.shirtWorkerName.value = w.name;
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],

                              // 2. Pant Tailor / Karigar Selection
                              if (hasPant) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D9488).withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFF0D9488).withAlpha(80)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.straighten, size: 18, color: Color(0xFF0D9488)),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Pant Karigar / Tailor',
                                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700),
                                          ),
                                          const Spacer(),
                                          Text(
                                            'Wage: ₹${orderCtrl.workerPantWageRate.toStringAsFixed(0)} × ${orderCtrl.pantQty.value}',
                                            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      DropdownButtonFormField<String>(
                                        initialValue: orderCtrl.pantWorkerId.value.isEmpty ? null : orderCtrl.pantWorkerId.value,
                                        isExpanded: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Choose Worker for Pant',
                                          prefixIcon: Icon(Icons.person_pin),
                                        ),
                                        items: workers.map((w) {
                                          return DropdownMenuItem(
                                            value: w.workerId,
                                            child: Text(
                                              '${w.name} (${w.role})',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (id) {
                                          if (id != null) {
                                            orderCtrl.pantWorkerId.value = id;
                                            final w = workers.firstWhere((x) => x.workerId == id);
                                            orderCtrl.pantWorkerName.value = w.name;
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          );
                        }),

                        const SizedBox(height: 16),

                        // Note Field
                        TextField(
                          controller: _noteController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Special Order Instructions / Fabric Details',
                            hintText: 'e.g. Fabric delivered by customer, urgent delivery for wedding event.',
                          ),
                          onChanged: (v) => orderCtrl.orderNote.value = v,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Save Order Button
                Obx(() {
                  return ElevatedButton.icon(
                    onPressed: orderCtrl.isLoading.value
                        ? null
                        : () async {
                            // Ensure text field values are synced to reactive state
                            orderCtrl.customerName.value = _nameController.text.trim();
                            orderCtrl.customerMobile.value = _mobileController.text.trim();
                            orderCtrl.bookNo.value = _bookController.text.trim();
                            orderCtrl.orderNote.value = _noteController.text.trim();
                            orderCtrl.shirtQty.value = int.tryParse(_shirtQtyController.text) ?? orderCtrl.shirtQty.value;
                            orderCtrl.shirtRate.value = double.tryParse(_shirtRateController.text) ?? orderCtrl.shirtRate.value;
                            orderCtrl.pantQty.value = int.tryParse(_pantQtyController.text) ?? orderCtrl.pantQty.value;
                            orderCtrl.pantRate.value = double.tryParse(_pantRateController.text) ?? orderCtrl.pantRate.value;
                            orderCtrl.discount.value = double.tryParse(_discountController.text) ?? orderCtrl.discount.value;
                            orderCtrl.advanceAmount.value = double.tryParse(_advanceController.text) ?? orderCtrl.advanceAmount.value;
                            orderCtrl.autoUpdateWorkerWage();

                            final success = await orderCtrl.createOrder();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Order created and saved successfully!'),
                                  backgroundColor: Color(0xFF16A34A),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              Navigator.of(context).pop(true);
                            }
                          },
                    icon: orderCtrl.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: Text(
                      orderCtrl.isLoading.value ? 'Recording Order...' : 'Confirm & Record Order',
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: AppColors.primaryDarkBrown,
                      foregroundColor: AppColors.softGolden,
                    ),
                  );
                }),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
