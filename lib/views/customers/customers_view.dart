import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/responsive/adaptive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/customer_controller.dart';
import '../widgets/adaptive_scaffold.dart';
import 'add_customer_dialog.dart';
import 'customer_detail_modal.dart';

class CustomersView extends StatelessWidget {
  const CustomersView({super.key});

  @override
  Widget build(BuildContext context) {
    final customerCtrl = Get.find<CustomerController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveScaffold(
      currentIndex: 1,
      title: 'Customer Directory',
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add_alt_1),
          tooltip: 'Add Customer',
          onPressed: () => AddCustomerDialog.show(context),
        ),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddCustomerDialog.show(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer'),
        backgroundColor: AppColors.primaryDarkBrown,
        foregroundColor: AppColors.softGolden,
      ),
      body: Padding(
        padding: EdgeInsets.all(AdaptiveLayout.getHorizontalPadding(context)),
        child: Column(
          children: [
            // Search Bar & Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.accentLightBrown),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        onChanged: customerCtrl.onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search by Customer Name, Mobile Number, or Ledger Book #...',
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
                    Obx(() {
                      if (customerCtrl.searchQuery.value.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => customerCtrl.onSearchChanged(''),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer List
            Expanded(
              child: Obx(() {
                final list = customerCtrl.filteredCustomers;

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search_outlined,
                          size: 64,
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No customers found',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.softGolden : AppColors.primaryDarkBrown,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try searching by another keyword or add a new customer.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
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
                      final customer = list[index];

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AdaptiveLayout.isSmallMobile(context) ? 10 : 18,
                          vertical: AdaptiveLayout.isSmallMobile(context) ? 4 : 8,
                        ),
                        leading: CircleAvatar(
                          radius: AdaptiveLayout.isSmallMobile(context) ? 18 : 22,
                          backgroundColor: AppColors.primaryDarkBrown.withAlpha(isDark ? 60 : 25),
                          child: Text(
                            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                            style: GoogleFonts.poppins(
                              color: AppColors.accentLightBrown,
                              fontWeight: FontWeight.w700,
                              fontSize: AdaptiveLayout.isSmallMobile(context) ? 14 : 16,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                customer.name,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AdaptiveLayout.isSmallMobile(context) ? 13.5 : 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentLightBrown.withAlpha(isDark ? 50 : 30),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.accentLightBrown.withAlpha(90),
                                ),
                              ),
                              child: Text(
                                'Bk #${customer.bookNo}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.softGolden : AppColors.secondaryMediumBrown,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 14),
                              const SizedBox(width: 4),
                              Text(customer.mobile, style: GoogleFonts.poppins(fontSize: 12)),
                              const SizedBox(width: 14),
                              if (customer.address.isNotEmpty) ...[
                                const Icon(Icons.location_on_outlined, size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    customer.address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(fontSize: 12),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              tooltip: 'Customer Options',
                              onSelected: (action) async {
                                if (action == 'edit') {
                                  AddCustomerDialog.show(context, customerToEdit: customer);
                                } else if (action == 'delete') {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Customer?'),
                                      content: Text('Are you sure you want to delete "${customer.name}"? This action cannot be undone.'),
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
                                    await customerCtrl.deleteCustomer(customer.id);
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
                                      Text('Edit Details'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Text('Delete Customer', style: TextStyle(color: Colors.redAccent)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          CustomerDetailModal.show(context, customer);
                        },
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
