import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/order_model.dart';
import '../models/tailor_model.dart';

class PdfInvoiceService {
  static Future<pw.Document> generateInvoicePdf({
    required OrderModel order,
    required TailorModel? tailor,
  }) async {
    final pdf = pw.Document();

    final shopName = tailor?.shopName.isNotEmpty == true ? tailor!.shopName : 'Mali Tailor';
    final ownerName = tailor?.ownerName.isNotEmpty == true ? tailor!.ownerName : 'Mahadev Mali';
    final phone = tailor?.phone.isNotEmpty == true ? tailor!.phone : '+91 99609 45720';

    final primaryColor = PdfColor.fromHex('#322213');
    final accentColor = PdfColor.fromHex('#BA8E5F');
    final lightBg = PdfColor.fromHex('#FDFBF7');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColor.fromHex('#D6C9B9'), width: 1.5),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          shopName.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Master Tailor: $ownerName',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          'Contact: $phone',
                          style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: pw.BoxDecoration(
                        color: lightBg,
                        border: pw.Border.all(color: accentColor),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'OFFICIAL RECEIPT',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor),
                          ),
                          pw.Text(
                            order.orderId,
                            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: primaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 18),
                pw.Divider(color: PdfColor.fromHex('#D6C9B9')),
                pw.SizedBox(height: 14),

                // Customer & Order Info
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('BILLED TO:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                        pw.SizedBox(height: 2),
                        pw.Text(order.customerName, style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Phone: ${order.customerMobile}', style: const pw.TextStyle(fontSize: 11)),
                        pw.Text('Ledger Book #: ${order.bookNo}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Order Date: ${DateFormat('dd/MM/yyyy').format(order.orderDate)}', style: const pw.TextStyle(fontSize: 11)),
                        pw.Text('Delivery Date: ${DateFormat('dd/MM/yyyy').format(order.deliveryDate)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Status: ${order.status.toUpperCase()}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: accentColor)),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Itemized Table
                pw.Table(
                  border: pw.TableBorder(horizontalInside: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: lightBg),
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Item Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Qty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Rate (INR)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11))),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Subtotal (INR)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11))),
                      ],
                    ),
                    if (order.shirtQty > 0)
                      pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Tailored Bespoke Shirt', style: const pw.TextStyle(fontSize: 11))),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${order.shirtQty}', style: const pw.TextStyle(fontSize: 11))),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('INR ${order.shirtRate.toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 11))),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('INR ${order.shirtTotal.toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 11))),
                        ],
                      ),
                    if (order.pantQty > 0)
                      pw.TableRow(
                        children: [
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Tailored Bespoke Pant / Trouser', style: const pw.TextStyle(fontSize: 11))),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${order.pantQty}', style: const pw.TextStyle(fontSize: 11))),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('INR ${order.pantRate.toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 11))),
                          pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('INR ${order.pantTotal.toStringAsFixed(0)}', style: const pw.TextStyle(fontSize: 11))),
                        ],
                      ),
                  ],
                ),

                pw.SizedBox(height: 16),
                pw.Divider(color: PdfColor.fromHex('#D6C9B9')),

                // Payment Summary
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Container(
                    width: 240,
                    child: pw.Column(
                      children: [
                        _pdfRow('Total Amount', 'INR ${order.totalAmount.toStringAsFixed(0)}'),
                        if (order.discount > 0)
                          _pdfRow('Discount', '- INR ${order.discount.toStringAsFixed(0)}', color: PdfColors.green800),
                        _pdfRow('Advance Paid', 'INR ${order.advanceAmount.toStringAsFixed(0)}', color: PdfColors.green800),
                        pw.Divider(height: 10),
                        _pdfRow(
                          'Balance Due',
                          'INR ${order.finalPayable.toStringAsFixed(0)}',
                          bold: true,
                          color: order.finalPayable > 0 ? PdfColors.red800 : PdfColors.green800,
                        ),
                      ],
                    ),
                  ),
                ),

                pw.Spacer(),

                // Terms footer
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: lightBg,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                    border: pw.Border.all(color: PdfColor.fromHex('#E8DFD3')),
                  ),
                  child: pw.Text(
                    'Terms: Please bring this receipt or quote Ledger Book #${order.bookNo} during delivery. Goods not claimed within 45 days will be disposed of. Alterations free of charge within 7 days of delivery.',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  static pw.Widget _pdfRow(String title, String value, {bool bold = false, PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: bold ? 12 : 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontSize: bold ? 13 : 11, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color)),
        ],
      ),
    );
  }

  static Future<void> printPdf({
    required OrderModel order,
    required TailorModel? tailor,
  }) async {
    final pdf = await generateInvoicePdf(order: order, tailor: tailor);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${order.orderId}.pdf',
    );
  }

  static Future<void> downloadPdfLocally({
    required OrderModel order,
    required TailorModel? tailor,
  }) async {
    final pdf = await generateInvoicePdf(order: order, tailor: tailor);
    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Invoice_${order.orderId}.pdf',
    );
  }

  static Future<void> sharePdfOnly({
    required OrderModel order,
    required TailorModel? tailor,
  }) async {
    final pdf = await generateInvoicePdf(order: order, tailor: tailor);
    final bytes = await pdf.save();

    try {
      // First try native file share (works on Android / iOS / Web with Web Share API)
      final xFile = XFile.fromData(
        bytes,
        mimeType: 'application/pdf',
        name: 'Invoice_${order.orderId}.pdf',
      );
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
        ),
      );
      if (result.status == ShareResultStatus.unavailable) {
        // Fallback for browsers without Web Share Files support
        await Printing.sharePdf(
          bytes: bytes,
          filename: 'Invoice_${order.orderId}.pdf',
        );
      }
    } catch (_) {
      // Fallback
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Invoice_${order.orderId}.pdf',
      );
    }
  }
}
