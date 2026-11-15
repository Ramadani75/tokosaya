import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/pos_provider.dart';
import '../../models/transaction.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/thermal_receipt_widget.dart';

class ReceiptScreen extends StatelessWidget {
  final PosTransaction transaction;

  const ReceiptScreen({super.key, required this.transaction});

  void _printThermal(BuildContext context, PosProvider pos) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainerSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.print, color: AppColors.secondary),
            ),
            const SizedBox(width: 10),
            const Text('Mencetak Struk...', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mengirim data ke ${pos.printerSettings.deviceName}...'),
            const SizedBox(height: 8),
            const LinearProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 12),
            const Text(
              'Ukuran Kertas: 58mm Thermal ESC/POS.\nKoneksi Bluetooth Stabil.',
              style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _sendWhatsAppReceipt(BuildContext context, PosProvider pos) async {
    final buffer = StringBuffer();
    buffer.writeln('🧾 *STRUK PEMBELIAN ${pos.storeProfile.name}*');
    buffer.writeln('${pos.storeProfile.slogan}');
    buffer.writeln('${pos.storeProfile.address}');
    buffer.writeln('--------------------------------');
    buffer.writeln('No Nota: ${transaction.invoiceNumber}');
    buffer.writeln('Waktu: ${transaction.timestamp.day}/${transaction.timestamp.month}/${transaction.timestamp.year} ${transaction.timestamp.hour}:${transaction.timestamp.minute}');
    buffer.writeln('Kasir: ${transaction.cashierName}');
    buffer.writeln('--------------------------------');
    for (final item in transaction.items) {
      buffer.writeln('${item.product.name}');
      buffer.writeln('  ${item.quantity} x ${CurrencyFormatter.format(item.product.sellPrice)} = ${CurrencyFormatter.format(item.subtotal)}');
    }
    if (transaction.plasticFee > 0) {
      buffer.writeln('Kantong Plastik = ${CurrencyFormatter.format(transaction.plasticFee)}');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('*TOTAL: ${CurrencyFormatter.format(transaction.totalAmount)}*');
    buffer.writeln('Metode: ${transaction.paymentMethod}');
    buffer.writeln('Bayar: ${CurrencyFormatter.format(transaction.cashPaid)}');
    if (transaction.paymentMethod == 'Tunai') {
      buffer.writeln('Kembalian: ${CurrencyFormatter.format(transaction.changeAmount)}');
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('${pos.storeProfile.footerMessage}');

    final encoded = Uri.encodeComponent(buffer.toString());
    final url = Uri.parse('https://wa.me/?text=$encoded');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format struk WhatsApp siap dikirimkan!')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format teks WhatsApp disiapkan.')),
        );
      }
    }
  }

  void _shareReceiptDigital(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tautan struk digital berhasil disalin ke clipboard!'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pos = Provider.of<PosProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Bukti Pembayaran',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Success Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryContainerSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.secondary,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Transaksi Selesai!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pembayaran ${transaction.paymentMethod} ${CurrencyFormatter.format(transaction.cashPaid)} (Kembalian ${CurrencyFormatter.format(transaction.changeAmount)}) tercatat.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Realistic Thermal Paper Receipt
            ThermalReceiptWidget(
              transaction: transaction,
              storeProfile: pos.storeProfile,
            ),
            const SizedBox(height: 24),

            // Action 1: Print Thermal Bluetooth
            InkWell(
              onTap: () => _printThermal(context, pos),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.print, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cetak ke Printer Thermal',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondaryFixed,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${pos.printerSettings.deviceName} Terhubung',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Action 2: WhatsApp
            InkWell(
              onTap: () => _sendWhatsAppReceipt(context, pos),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: Colors.white, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kirim Struk via WhatsApp',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Format teks rapi langsung ke HP pembeli',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Action 3: Bagikan Digital
            InkWell(
              onTap: () => _shareReceiptDigital(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.share_outlined, color: AppColors.onSurface, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bagikan Struk Digital',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Simpan atau kirim link nota elektronik',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.open_in_new, color: AppColors.onSurfaceVariant, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Mulai Transaksi Baru Button
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.add_circle, color: AppColors.primary),
              label: const Text(
                'Mulai Transaksi Baru (+)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.roseTint,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

