import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/worker_controller.dart';
import '../../data/models/order_model.dart';
import '../widgets/bottom_card_modal.dart';

class EditOrderDialog extends StatefulWidget {
  final OrderModel order;

  const EditOrderDialog({super.key, required this.order});

  static Future<bool?> show(BuildContext context, OrderModel order) {
    return showBottomUpCard<bool>(
      context: context,
      isDismissible: false,
      maxHeightFactor: 0.92,
      builder: (context) => EditOrderDialog(order: order),
    );
  }

  @override
  State<EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<EditOrderDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _customerNameCtrl;
  late final TextEditingController _customerMobileCtrl;
  late final TextEditingController _bookNoCtrl;
  late final TextEditingController _shirtQtyCtrl;
  late final TextEditingController _shirtRateCtrl;
  late final TextEditingController _pantQtyCtrl;
  late final TextEditingController _pantRateCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _advanceCtrl;
  late final TextEditingController _notesCtrl;

  late String _status;
  late String _orderType;
  late DateTime _deliveryDate;
  String? _assignedWorkerId;
  String? _assignedWorkerName;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final o = widget.order;
    _customerNameCtrl = TextEditingController(text: o.customerName);
    _customerMobileCtrl = TextEditingController(text: o.customerMobile);
    _bookNoCtrl = TextEditingController(text: o.bookNo);
    _shirtQtyCtrl = TextEditingController(text: o.shirtQty.toString());
    _shirtRateCtrl = TextEditingController(text: o.shirtRate.toStringAsFixed(0));
    _pantQtyCtrl = TextEditingController(text: o.pantQty.toString());
    _pantRateCtrl = TextEditingController(text: o.pantRate.toStringAsFixed(0));
    _discountCtrl = TextEditingController(text: o.discount.toStringAsFixed(0));
    _advanceCtrl = TextEditingController(text: o.advanceAmount.toStringAsFixed(0));
    _notesCtrl = TextEditingController(text: o.note);

    _status = o.status;
    _orderType = o.orderType;
    _deliveryDate = o.deliveryDate;
    _isUrgent = o.isUrgent;
    _assignedWorkerId = o.assignedWorkerId;
    _assignedWorkerName = o.assignedWorkerName;
    _shirtWorkerId = o.shirtWorkerId;
    _shirtWorkerName = o.shirtWorkerName;
    _pantWorkerId = o.pantWorkerId;
    _pantWorkerName = o.pantWorkerName;
  }

  late bool _isUrgent;

  String? _shirtWorkerId;
  String? _shirtWorkerName;
  String? _pantWorkerId;
  String? _pantWorkerName;

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _customerMobileCtrl.dispose();
    _bookNoCtrl.dispose();
    _shirtQtyCtrl.dispose();
    _shirtRateCtrl.dispose();
    _pantQtyCtrl.dispose();
    _pantRateCtrl.dispose();
    _discountCtrl.dispose();
    _advanceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _shirtTotal =>
      (int.tryParse(_shirtQtyCtrl.text) ?? 0) * (double.tryParse(_shirtRateCtrl.text) ?? 0.0);
  double get _pantTotal =>
      (int.tryParse(_pantQtyCtrl.text) ?? 0) * (double.tryParse(_pantRateCtrl.text) ?? 0.0);
  double get _totalAmount => _shirtTotal + _pantTotal;
  double get _discount => double.tryParse(_discountCtrl.text) ?? 0.0;
  double get _advance => double.tryParse(_advanceCtrl.text) ?? 0.0;
  double get _balanceDue {
    final net = _totalAmount - _discount - _advance;
    return net < 0 ? 0 : net;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final orderCtrl = Get.find<OrderController>();
      final updatedOrder = widget.order.copyWith(
        customerName: _customerNameCtrl.text.trim(),
        customerMobile: _customerMobileCtrl.text.trim(),
        bookNo: _bookNoCtrl.text.trim(),
        status: _status,
        orderType: _orderType,
        deliveryDate: _deliveryDate,
        shirtQty: int.tryParse(_shirtQtyCtrl.text) ?? 0,
        shirtRate: double.tryParse(_shirtRateCtrl.text) ?? 0.0,
        shirtTotal: _shirtTotal,
        pantQty: int.tryParse(_pantQtyCtrl.text) ?? 0,
        pantRate: double.tryParse(_pantRateCtrl.text) ?? 0.0,
        pantTotal: _pantTotal,
        totalAmount: _totalAmount,
        discount: _discount,
        advanceAmount: _advance,
        finalPayable: _balanceDue,
        note: _notesCtrl.text.trim(),
        assignedWorkerId: _assignedWorkerId,
        assignedWorkerName: _assignedWorkerName,
        shirtWorkerId: _shirtWorkerId,
        shirtWorkerName: _shirtWorkerName,
        pantWorkerId: _pantWorkerId,
        pantWorkerName: _pantWorkerName,
        isUrgent: _isUrgent,
        updatedAt: DateTime.now(),
      );

      final ok = await orderCtrl.updateOrder(updatedOrder);
      if (ok && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update order: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workerCtrl = Get.find<WorkerController>();

    return Column(
      children: [
        // Modal Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceCard : AppColors.primaryDarkBrown,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentLightBrown,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_document, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Order ${widget.order.orderId}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Modify garment quantities, rate, status, or delivery date',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.softGolden,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),

        // Scrollable Form Body
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer & Ledger
                  Text(
                    'Customer & Order Information',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accentLightBrown),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _customerNameCtrl,
                          decoration: const InputDecoration(labelText: 'Customer Name *', isDense: true),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _bookNoCtrl,
                          decoration: const InputDecoration(labelText: 'Ledger #', isDense: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _customerMobileCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Mobile Number *', isDense: true),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Status & Garment Type
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _status,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Order Status', isDense: true),
                          items: ['Pending', 'In Progress', 'Ready', 'Delivered', 'Cancelled'].map((s) {
                            return DropdownMenuItem(value: s, child: Text(s));
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _status = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _orderType,
                          isExpanded: true,
                          decoration: const InputDecoration(labelText: 'Garment Type', isDense: true),
                          items: const [
                            DropdownMenuItem(value: 'Both', child: Text('Shirt & Pant')),
                            DropdownMenuItem(value: 'Shirt', child: Text('Shirt Only')),
                            DropdownMenuItem(value: 'Pant', child: Text('Pant Only')),
                            DropdownMenuItem(value: 'Suit', child: Text('Suit')),
                            DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _orderType = v);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Delivery Date
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _deliveryDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 120)),
                      );
                      if (picked != null) {
                        setState(() => _deliveryDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: AppColors.accentLightBrown),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Target Delivery Date', style: GoogleFonts.poppins(fontSize: 10)),
                              Text(DateFormat('dd MMMM yyyy').format(_deliveryDate), style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
                            ],
                          ),
                          const Spacer(),
                          if (_isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withAlpha(30),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.redAccent, width: 0.8),
                              ),
                              child: Text(
                                '⚡ URGENT',
                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.redAccent),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Urgent Toggle Switch Card
                  Container(
                    decoration: BoxDecoration(
                      color: _isUrgent
                          ? Colors.redAccent.withAlpha(isDark ? 35 : 20)
                          : (isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isUrgent ? Colors.redAccent : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        width: _isUrgent ? 1.5 : 1,
                      ),
                    ),
                    child: SwitchListTile(
                      value: _isUrgent,
                      activeTrackColor: Colors.redAccent.withAlpha(150),
                      thumbColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected) ? Colors.redAccent : null,
                      ),
                      dense: true,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      secondary: Icon(
                        Icons.bolt,
                        color: _isUrgent ? Colors.redAccent : Colors.grey,
                        size: 24,
                      ),
                      title: Text(
                        'Mark as Urgent Order (तातडीची ऑर्डर)',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: _isUrgent ? Colors.redAccent : null,
                        ),
                      ),
                      subtitle: Text(
                        'Prioritize order in workshop queue with urgent alert badge',
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                      onChanged: (val) {
                        setState(() => _isUrgent = val);
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Garment Quantities & Pricing
                  Text(
                    'Garment Pricing & Quantities',
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accentLightBrown),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _shirtQtyCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: 'Shirt Qty',
                            isDense: true,
                            prefixIcon: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 18),
                              splashRadius: 16,
                              onPressed: () {
                                final current = int.tryParse(_shirtQtyCtrl.text) ?? 0;
                                if (current > 0) {
                                  setState(() => _shirtQtyCtrl.text = (current - 1).toString());
                                }
                              },
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.accentLightBrown),
                              splashRadius: 16,
                              onPressed: () {
                                final current = int.tryParse(_shirtQtyCtrl.text) ?? 0;
                                setState(() => _shirtQtyCtrl.text = (current + 1).toString());
                              },
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _shirtRateCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Shirt Rate (₹)', isDense: true),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _pantQtyCtrl,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            labelText: 'Pant Qty',
                            isDense: true,
                            prefixIcon: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 18),
                              splashRadius: 16,
                              onPressed: () {
                                final current = int.tryParse(_pantQtyCtrl.text) ?? 0;
                                if (current > 0) {
                                  setState(() => _pantQtyCtrl.text = (current - 1).toString());
                                }
                              },
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF0D9488)),
                              splashRadius: 16,
                              onPressed: () {
                                final current = int.tryParse(_pantQtyCtrl.text) ?? 0;
                                setState(() => _pantQtyCtrl.text = (current + 1).toString());
                              },
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _pantRateCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Pant Rate (₹)', isDense: true),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _discountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Discount (₹)', isDense: true),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _advanceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Advance Paid (₹)', isDense: true),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Assigned Worker Section
                  Obx(() {
                    final workers = workerCtrl.workers;
                    final hasShirt = (int.tryParse(_shirtQtyCtrl.text) ?? 0) > 0;
                    final hasPant = (int.tryParse(_pantQtyCtrl.text) ?? 0) > 0;

                    if (hasShirt && hasPant) {
                      return Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: _shirtWorkerId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Shirt Tailor (₹${Get.find<AuthController>().workerShirtWage.value.toStringAsFixed(0)}/pc)',
                              isDense: true,
                              prefixIcon: const Icon(Icons.cut, size: 18),
                            ),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('No Shirt Tailor')),
                              ...workers.map((w) => DropdownMenuItem(value: w.workerId, child: Text('${w.name} (${w.role})', overflow: TextOverflow.ellipsis))),
                            ],
                            onChanged: (id) {
                              setState(() {
                                _shirtWorkerId = id;
                                _shirtWorkerName = id != null ? workers.firstWhereOrNull((w) => w.workerId == id)?.name : null;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            initialValue: _pantWorkerId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Pant Tailor (₹${Get.find<AuthController>().workerPantWage.value.toStringAsFixed(0)}/pc)',
                              isDense: true,
                              prefixIcon: const Icon(Icons.straighten, size: 18),
                            ),
                            items: [
                              const DropdownMenuItem(value: null, child: Text('No Pant Tailor')),
                              ...workers.map((w) => DropdownMenuItem(value: w.workerId, child: Text('${w.name} (${w.role})', overflow: TextOverflow.ellipsis))),
                            ],
                            onChanged: (id) {
                              setState(() {
                                _pantWorkerId = id;
                                _pantWorkerName = id != null ? workers.firstWhereOrNull((w) => w.workerId == id)?.name : null;
                              });
                            },
                          ),
                        ],
                      );
                    }

                    return DropdownButtonFormField<String>(
                      initialValue: _assignedWorkerId ?? _shirtWorkerId ?? _pantWorkerId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Assigned Tailor / Karigar', isDense: true),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Unassigned')),
                        ...workers.map((w) {
                          return DropdownMenuItem(
                            value: w.workerId,
                            child: Text('${w.name} (${w.role})', overflow: TextOverflow.ellipsis),
                          );
                        }),
                      ],
                      onChanged: (id) {
                        setState(() {
                          _assignedWorkerId = id;
                          final match = id != null ? workers.firstWhereOrNull((w) => w.workerId == id) : null;
                          _assignedWorkerName = match?.name;
                          if (hasShirt) {
                            _shirtWorkerId = id;
                            _shirtWorkerName = match?.name;
                          }
                          if (hasPant) {
                            _pantWorkerId = id;
                            _pantWorkerName = match?.name;
                          }
                        });
                      },
                    );
                  }),

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Order Notes & Instructions', isDense: true),
                  ),

                  const SizedBox(height: 16),

                  // Real-time Total summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3B2E20) : const Color(0xFFF3ECE4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.accentLightBrown),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('Total Bill', style: GoogleFonts.poppins(fontSize: 10)),
                            Text('₹${_totalAmount.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16)),
                          ],
                        ),
                        Container(height: 28, width: 1, color: Colors.grey.withAlpha(80)),
                        Column(
                          children: [
                            Text('Advance', style: GoogleFonts.poppins(fontSize: 10)),
                            Text('₹${_advance.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.green)),
                          ],
                        ),
                        Container(height: 28, width: 1, color: Colors.grey.withAlpha(80)),
                        Column(
                          children: [
                            Text('Due', style: GoogleFonts.poppins(fontSize: 10)),
                            Text('₹${_balanceDue.toStringAsFixed(0)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 16, color: _balanceDue > 0 ? Colors.redAccent : Colors.green)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Action Buttons Footer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submitForm,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check, size: 18),
                  label: Text(_isSaving ? 'Updating...' : 'Update Order', overflow: TextOverflow.ellipsis),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkBrown,
                    foregroundColor: AppColors.softGolden,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
