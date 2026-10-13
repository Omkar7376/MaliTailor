import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/responsive/adaptive_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/order_controller.dart';
import '../../data/services/pdf_invoice_service.dart';

class InvoiceView extends StatelessWidget {
  const InvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    final orderCtrl = Get.find<OrderController>();
    final authCtrl = Get.find<AuthController>();
    final orderId = Get.parameters['id'] ?? '';
    final order = orderCtrl.allOrders.firstWhereOrNull((o) => o.orderId == orderId);
    final tailor = authCtrl.currentTailor.value;

    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice #$orderId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Invoice PDF (WhatsApp / Apps)',
            onPressed: () async {
              if (order != null) {
                await PdfInvoiceService.sharePdfOnly(order: order, tailor: tailor);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Download / Save PDF to Local Storage',
            onPressed: () async {
              if (order != null) {
                await PdfInvoiceService.downloadPdfLocally(order: order, tailor: tailor);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Invoice',
            onPressed: () async {
              if (order != null) {
                await PdfInvoiceService.printPdf(order: order, tailor: tailor);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AdaptiveLayout.getHorizontalPadding(context)),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Container(
              padding: EdgeInsets.all(AdaptiveLayout.isMobile(context) ? 16 : 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD6C9B9), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: order == null
                  ? const Center(child: Text('Order not found'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.cut, color: AppColors.primaryDarkBrown, size: 24),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          tailor?.shopName.toUpperCase() ?? 'MALI TAILOR',
                                          style: GoogleFonts.cinzel(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryDarkBrown,
                                            letterSpacing: 0.8,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Master Tailor: ${tailor?.ownerName ?? "Mahadev Mali"}',
                                    style: GoogleFonts.poppins(color: Colors.black87, fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Contact: ${tailor?.phone ?? "+91 99609 45720"}',
                                    style: GoogleFonts.poppins(color: Colors.black54, fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3ECE4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.accentLightBrown),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'OFFICIAL RECEIPT',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                      color: AppColors.primaryDarkBrown,
                                    ),
                                  ),
                                  Text(
                                    order.orderId,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDarkBrown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: Color(0xFFD6C9B9), thickness: 1.5),
                        const SizedBox(height: 16),

                        // Customer & Order Info
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BILLED TO:',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.customerName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text('Phone: ${order.customerMobile}',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                                Text('Ledger Book #: ${order.bookNo}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryMediumBrown,
                                    )),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Order Date: ${DateFormat('dd/MM/yyyy').format(order.orderDate)}',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                                Text('Delivery Date: ${DateFormat('dd/MM/yyyy').format(order.deliveryDate)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    )),
                                Text('Status: ${order.status.toUpperCase()}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accentLightBrown,
                                    )),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Itemized Table
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(4),
                            1: FlexColumnWidth(1.5),
                            2: FlexColumnWidth(2),
                            3: FlexColumnWidth(2),
                          },
                          border: TableBorder(
                            horizontalInside: BorderSide(color: Colors.grey.shade200, width: 1),
                          ),
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(color: Color(0xFFF7F4EE)),
                              children: [
                                _tableHeader('Item Description'),
                                _tableHeader('Qty'),
                                _tableHeader('Rate (₹)'),
                                _tableHeader('Subtotal (₹)'),
                              ],
                            ),
                            if (order.shirtQty > 0)
                              TableRow(
                                children: [
                                  _tableCell('Tailored Bespoke Shirt'),
                                  _tableCell('${order.shirtQty}'),
                                  _tableCell('₹${order.shirtRate.toStringAsFixed(0)}'),
                                  _tableCell('₹${order.shirtTotal.toStringAsFixed(0)}'),
                                ],
                              ),
                            if (order.pantQty > 0)
                              TableRow(
                                children: [
                                  _tableCell('Tailored Bespoke Trouser / Pant'),
                                  _tableCell('${order.pantQty}'),
                                  _tableCell('₹${order.pantRate.toStringAsFixed(0)}'),
                                  _tableCell('₹${order.pantTotal.toStringAsFixed(0)}'),
                                ],
                              ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFD6C9B9)),

                        // Payment Details
                        Align(
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: Column(
                              children: [
                                _invoiceRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(0)}'),
                                if (order.discount > 0)
                                  _invoiceRow('Discount', '- ₹${order.discount.toStringAsFixed(0)}',
                                      color: Colors.green),
                                _invoiceRow('Advance Paid', '₹${order.advanceAmount.toStringAsFixed(0)}',
                                    color: Colors.green),
                                const Divider(height: 14),
                                _invoiceRow(
                                  'Balance Due',
                                  '₹${order.finalPayable.toStringAsFixed(0)}',
                                  bold: true,
                                  color: order.finalPayable > 0 ? Colors.redAccent : Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Terms / Stamp
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF9F5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE8DFD3)),
                          ),
                          child: Text(
                            'Terms: Please bring this receipt or quote Ledger Book #${order.bookNo} during delivery. Goods not claimed within 45 days will be disposed of. Alterations free of charge within 7 days of delivery.',
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDarkBrown,
        ),
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  Widget _invoiceRow(String title, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: bold ? 14 : 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: bold ? 16 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
