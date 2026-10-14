import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/customer_controller.dart';
import '../../data/models/shirt_measurement_model.dart';
import '../../data/models/pant_measurement_model.dart';

import '../../data/models/customer_model.dart';

import '../widgets/bottom_card_modal.dart';

enum MeasurementOption { none, shirtOnly, pantOnly, both }

class AddCustomerDialog extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> customerData)? onSave;
  final CustomerModel? customerToEdit;

  const AddCustomerDialog({super.key, this.onSave, this.customerToEdit});

  static Future<bool?> show(
    BuildContext context, {
    Future<void> Function(Map<String, dynamic>)? onSave,
    CustomerModel? customerToEdit,
  }) {
    return showBottomUpCard<bool>(
      context: context,
      isDismissible: false,
      maxHeightFactor: 0.92,
      builder: (context) => AddCustomerDialog(
        onSave: onSave,
        customerToEdit: customerToEdit,
      ),
    );
  }

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();

  // Basic info
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bookNoController;
  late final TextEditingController _addressController;
  String _selectedGender = 'Male';

  // Measurement selection option: None, Shirt Only, Pant Only, Both Shirt & Pant
  MeasurementOption _measurementOption = MeasurementOption.both;

  @override
  void initState() {
    super.initState();
    final c = widget.customerToEdit;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.mobile ?? '');
    _bookNoController = TextEditingController(text: c?.bookNo ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _selectedGender = c?.gender ?? 'Male';
    if (c != null) {
      _measurementOption = MeasurementOption.none;
    }
  }

  // Shirt measurements
  final _shirtLengthController = TextEditingController();
  final _chestController = TextEditingController();
  final _shoulderController = TextEditingController();
  final _backController = TextEditingController();
  final _sleeveController = TextEditingController();
  final _bicepController = TextEditingController();
  final _collarController = TextEditingController();
  final _cuffController = TextEditingController();
  final _front1Controller = TextEditingController();
  final _front2Controller = TextEditingController();
  final _front3Controller = TextEditingController();
  final _shirtNotesController = TextEditingController();

  // Pant measurements
  final _pantLengthController = TextEditingController();
  final _insideLengthController = TextEditingController();
  final _pantWaistController = TextEditingController();
  final _hipController = TextEditingController();
  final _thighController = TextEditingController();
  final _kneeController = TextEditingController();
  final _bottomController = TextEditingController();
  final _riseController = TextEditingController();
  final _pantNotesController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bookNoController.dispose();
    _addressController.dispose();

    _shirtLengthController.dispose();
    _chestController.dispose();
    _shoulderController.dispose();
    _backController.dispose();
    _sleeveController.dispose();
    _bicepController.dispose();
    _collarController.dispose();
    _cuffController.dispose();
    _front1Controller.dispose();
    _front2Controller.dispose();
    _front3Controller.dispose();
    _shirtNotesController.dispose();

    _pantLengthController.dispose();
    _insideLengthController.dispose();
    _pantWaistController.dispose();
    _hipController.dispose();
    _thighController.dispose();
    _kneeController.dispose();
    _bottomController.dispose();
    _riseController.dispose();
    _pantNotesController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final customerCtrl = Get.find<CustomerController>();

    try {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final bookNo = _bookNoController.text.trim();
      final address = _addressController.text.trim();

      if (widget.customerToEdit != null) {
        // Edit existing customer
        final updated = widget.customerToEdit!.copyWith(
          name: name,
          mobile: phone,
          bookNo: bookNo,
          gender: _selectedGender,
          address: address,
          updatedAt: DateTime.now(),
        );
        final ok = await customerCtrl.updateCustomer(updated);
        if (ok && mounted) {
          Navigator.of(context).pop(true);
        }
        return;
      }

      // 1. Add Customer record to customers subcollection
      final created = await customerCtrl.addCustomer(
        name: name,
        mobile: phone,
        bookNo: bookNo,
        gender: _selectedGender,
        address: address,
      );

      if (created != null) {
        customerCtrl.selectedCustomer.value = created;

        // 2. Save Shirt measurement to: tailors/{tailorId}/customers/{customerId}/measurements/shirt
        if (_measurementOption == MeasurementOption.shirtOnly ||
            _measurementOption == MeasurementOption.both) {
          final shirt = ShirtMeasurementModel(
            length: _shirtLengthController.text.trim(),
            chest: _chestController.text.trim(),
            shoulder: _shoulderController.text.trim(),
            back: _backController.text.trim(),
            sleeve: _sleeveController.text.trim(),
            bicep: _bicepController.text.trim(),
            collar: _collarController.text.trim(),
            cuff: _cuffController.text.trim(),
            front1: _front1Controller.text.trim(),
            front2: _front2Controller.text.trim(),
            front3: _front3Controller.text.trim(),
            notes: _shirtNotesController.text.trim(),
            updatedAt: DateTime.now(),
          );
          await customerCtrl.saveShirt(shirt);
        }

        // 3. Save Pant measurement to: tailors/{tailorId}/customers/{customerId}/measurements/pant
        if (_measurementOption == MeasurementOption.pantOnly ||
            _measurementOption == MeasurementOption.both) {
          final pant = PantMeasurementModel(
            outsideLength: _pantLengthController.text.trim(),
            insideLength: _insideLengthController.text.trim(),
            waist: _pantWaistController.text.trim(),
            seat: _hipController.text.trim(),
            thigh: _thighController.text.trim(),
            knee: _kneeController.text.trim(),
            bottom: _bottomController.text.trim(),
            rise: _riseController.text.trim(),
            notes: _pantNotesController.text.trim(),
            updatedAt: DateTime.now(),
          );
          await customerCtrl.savePant(pant);
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', 'Failed to add customer: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hasShirt = _measurementOption == MeasurementOption.shirtOnly ||
        _measurementOption == MeasurementOption.both;
    final hasPant = _measurementOption == MeasurementOption.pantOnly ||
        _measurementOption == MeasurementOption.both;

    return Column(
      children: [
        // Header
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
                child: Icon(
                  widget.customerToEdit != null ? Icons.edit_note_rounded : Icons.person_add_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.customerToEdit != null ? 'Edit Customer' : 'Add New Customer',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.customerToEdit != null
                          ? 'Update ledger & contact details'
                          : 'Record ledger details and choose measurement types',
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

            // Form Body
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width <= 380 ? 14 : 24,
                    vertical: 16,
                  ),
                  children: [
                    _buildSectionHeader('Customer Information & Ledger'),
                    const SizedBox(height: 14),

                    // Full Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Customer Full Name *',
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: 'e.g. Ramesh Patil',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter customer name' : null,
                    ),
                    const SizedBox(height: 14),

                    // Phone & Book No
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number *',
                              prefixIcon: Icon(Icons.phone_outlined),
                              hintText: '+91 98765 43210',
                              isDense: true,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter phone number' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _bookNoController,
                            decoration: const InputDecoration(
                              labelText: 'Book # *',
                              prefixIcon: Icon(Icons.menu_book),
                              hintText: '108',
                              isDense: true,
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter book #' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Gender & Address
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedGender,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              isDense: true,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Male', child: Text('Male')),
                              DropdownMenuItem(value: 'Female', child: Text('Female')),
                              DropdownMenuItem(value: 'Other', child: Text('Other')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedGender = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Address / Area',
                              prefixIcon: Icon(Icons.location_on_outlined),
                              hintText: 'e.g. Pune',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- Measurement Selection Options ---
                    _buildSectionHeader('Choose Measurements to Record'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceCard : AppColors.lightSurfaceCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            avatar: const Icon(Icons.checkroom, size: 16),
                            label: const Text('Shirt Only'),
                            selected: _measurementOption == MeasurementOption.shirtOnly,
                            onSelected: (selected) {
                              if (selected) setState(() => _measurementOption = MeasurementOption.shirtOnly);
                            },
                            selectedColor: AppColors.accentLightBrown,
                            labelStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: _measurementOption == MeasurementOption.shirtOnly
                                  ? AppColors.primaryDarkBrown
                                  : null,
                            ),
                          ),
                          ChoiceChip(
                            avatar: const Icon(Icons.straighten, size: 16),
                            label: const Text('Pant Only'),
                            selected: _measurementOption == MeasurementOption.pantOnly,
                            onSelected: (selected) {
                              if (selected) setState(() => _measurementOption = MeasurementOption.pantOnly);
                            },
                            selectedColor: AppColors.accentLightBrown,
                            labelStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: _measurementOption == MeasurementOption.pantOnly
                                  ? AppColors.primaryDarkBrown
                                  : null,
                            ),
                          ),
                          ChoiceChip(
                            avatar: const Icon(Icons.dry_cleaning, size: 16),
                            label: const Text('Both Shirt & Pant'),
                            selected: _measurementOption == MeasurementOption.both,
                            onSelected: (selected) {
                              if (selected) setState(() => _measurementOption = MeasurementOption.both);
                            },
                            selectedColor: AppColors.accentLightBrown,
                            labelStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: _measurementOption == MeasurementOption.both
                                  ? AppColors.primaryDarkBrown
                                  : null,
                            ),
                          ),
                          ChoiceChip(
                            avatar: const Icon(Icons.close, size: 16),
                            label: const Text('No Measurements Now'),
                            selected: _measurementOption == MeasurementOption.none,
                            onSelected: (selected) {
                              if (selected) setState(() => _measurementOption = MeasurementOption.none);
                            },
                            selectedColor: AppColors.accentLightBrown,
                            labelStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: _measurementOption == MeasurementOption.none
                                  ? AppColors.primaryDarkBrown
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Shirt Measurements Section
                    if (hasShirt) ...[
                      const Divider(height: 28),
                      Row(
                        children: [
                          const Icon(Icons.checkroom, color: AppColors.accentLightBrown, size: 18),
                          const SizedBox(width: 8),
                          _buildSectionHeader('Shirt Measurements (Inches)'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildMeasurementInput('Length (लंबाई)', _shirtLengthController),
                          _buildMeasurementInput('Chest (छाती)', _chestController),
                          _buildMeasurementInput('Shoulder (कंधा)', _shoulderController),
                          _buildMeasurementInput('Back (बैक)', _backController),
                          _buildMeasurementInput('Collor (कॉलर)', _collarController),
                          _buildMeasurementInput('Sleeve (आस्तीन)', _sleeveController),
                          _buildMeasurementInput('Bicep (बाइसेप)', _bicepController),
                          _buildMeasurementInput('Cuff (कफ)', _cuffController),
                          _buildMeasurementInput('Front1 (फ्रंट1)', _front1Controller),
                          _buildMeasurementInput('Front2 (फ्रंट2)', _front2Controller),
                          _buildMeasurementInput('Front3 (फ्रंट3)', _front3Controller),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _shirtNotesController,
                        decoration: const InputDecoration(
                          labelText: 'Shirt Styling Notes',
                          hintText: 'e.g. Slim collar, french cuffs, etc.',
                        ),
                      ),
                    ],

                    // Pant Measurements Section
                    if (hasPant) ...[
                      const Divider(height: 28),
                      Row(
                        children: [
                          const Icon(Icons.straighten, color: AppColors.accentLightBrown, size: 18),
                          const SizedBox(width: 8),
                          _buildSectionHeader('Pant / Trouser Measurements (Inches)'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildMeasurementInput('Length (लंबाई)', _pantLengthController),
                          _buildMeasurementInput('Inside (अंदर लंबाई)', _insideLengthController),
                          _buildMeasurementInput('Waist (कमर)', _pantWaistController),
                          _buildMeasurementInput('Seat/Hip (सीट)', _hipController),
                          _buildMeasurementInput('Thigh (जांघ)', _thighController),
                          _buildMeasurementInput('Knee (घुटना)', _kneeController),
                          _buildMeasurementInput('Bottom (मोरी)', _bottomController),
                          _buildMeasurementInput('Rise/Fly (लटक)', _riseController),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pantNotesController,
                        decoration: const InputDecoration(
                          labelText: 'Pant Cut Notes',
                          hintText: 'e.g. Pencil cut, cross pockets, etc.',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

        // Footer Buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : (widget.customerToEdit != null ? 'Update Customer' : 'Save Customer to Ledger'),
                    overflow: TextOverflow.ellipsis,
                  ),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.accentLightBrown,
      ),
    );
  }

  Widget _buildMeasurementInput(String label, TextEditingController controller) {
    return SizedBox(
      width: 120,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
      ),
    );
  }
}
