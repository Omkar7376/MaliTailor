import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/customer_controller.dart';

class AddCustomerView extends StatefulWidget {
  const AddCustomerView({super.key});

  @override
  State<AddCustomerView> createState() => _AddCustomerViewState();
}

class _AddCustomerViewState extends State<AddCustomerView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _bookNoController = TextEditingController();
  final _addressController = TextEditingController();
  String _gender = 'Male';

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _bookNoController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerCtrl = Get.find<CustomerController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Customer'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentLightBrown.withAlpha(isDark ? 50 : 30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.person_add_outlined, color: AppColors.accentLightBrown),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customer Ledger Entry',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Record physical ledger book # & client details',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Book Number Field
                      TextFormField(
                        controller: _bookNoController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Physical Record Book Number (खाता नंबर)',
                          prefixIcon: Icon(Icons.menu_book_outlined, size: 20),
                          hintText: 'e.g. 108 or B-24',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter book number' : null,
                      ),
                      const SizedBox(height: 16),

                      // Customer Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Full Name',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                          hintText: 'e.g. Rajesh Kumar',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter customer name' : null,
                      ),
                      const SizedBox(height: 16),

                      // Mobile Phone
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Phone Number',
                          prefixIcon: Icon(Icons.phone_outlined, size: 20),
                          hintText: '+91 98765 43210',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Enter phone number' : null,
                      ),
                      const SizedBox(height: 16),

                      // Gender selector
                      DropdownButtonFormField<String>(
                        initialValue: _gender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: Icon(Icons.transgender, size: 20),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male (पुरुष)')),
                          DropdownMenuItem(value: 'Female', child: Text('Female (महिला)')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _gender = val);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Address / Area (Optional)',
                          prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                          hintText: 'e.g. Flat 402, Shivaji Nagar',
                        ),
                      ),
                      const SizedBox(height: 28),

                      Obx(() {
                        return ElevatedButton.icon(
                          onPressed: customerCtrl.isLoading.value
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    await customerCtrl.addCustomer(
                                      name: _nameController.text,
                                      mobile: _mobileController.text,
                                      bookNo: _bookNoController.text,
                                      gender: _gender,
                                      address: _addressController.text,
                                    );
                                    Get.back();
                                  }
                                },
                          icon: const Icon(Icons.check),
                          label: Text(
                            'Save Customer to Ledger',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: AppColors.primaryDarkBrown,
                            foregroundColor: AppColors.softGolden,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
