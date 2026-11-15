import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/store_profile.dart';
import '../models/cart_item.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class ThermalReceiptWidget extends StatelessWidget {
  final PosTransaction? transaction;
  final StoreProfile storeProfile;
  final List<CartItem>? previewItems;
  final double? previewTotal;

  const ThermalReceiptWidget({
    super.key,
    this.transaction,
    required this.storeProfile,
    this.previewItems,
    this.previewTotal,
  });

  @override
  Widget build(BuildContext context) {
    final items = transaction?.items ?? previewItems ?? [];
    final total = transaction?.totalAmount ?? previewTotal ?? 0.0;
    final subtotal = transaction?.subtotal ?? (previewTotal ?? 0.0);
    final plastic = transaction?.plasticFee ?? 500;
    final cashPaid = transaction?.cashPaid ?? total;
    final change = transaction?.changeAmount ?? 0.0;
    final method = transaction?.paymentMethod ?? 'Tunai';
    final invNumber = transaction?.invoiceNumber ?? 'TR-20261109-0042';
    final dateFormatted = transaction != null
        ? '${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(transaction!.timestamp)} WIB'
        : '09 Nov 2026, 20:41 WIB';
    final cashier = transaction?.cashierName ?? storeProfile.cashierName;

    return Column(
      children: [
        // Top paper body
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Store Avatar & Name
              Center(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logo_warung.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.storefront, color: AppColors.primary, size: 24),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                storeProfile.name.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                storeProfile.slogan,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                storeProfile.address,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10.5,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Telp/WA: ${storeProfile.phone}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              // Dashed divider
              _buildDashedLine(),
              const SizedBox(height: 8),

              // Metadata Transaksi
              _buildMetaRow('No. Nota', invNumber, isMono: true),
              const SizedBox(height: 4),
              _buildMetaRow('Waktu', dateFormatted),
              const SizedBox(height: 4),
              _buildMetaRow('Kasir', '$cashier (Staff)'),
              const SizedBox(height: 4),
              _buildMetaRow('Metode', method),
              const SizedBox(height: 8),

              // Dashed divider
              _buildDashedLine(),
              const SizedBox(height: 10),

              // Purchased items
              ...items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              '${item.quantity} x ${CurrencyFormatter.format(item.product.sellPrice)}',
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(item.subtotal),
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Plastic bag
              if (plastic > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kantong Plastik Ramah Lingkungan',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(plastic),
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 11,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 4),
              _buildDashedLine(),
              const SizedBox(height: 8),

              // Subtotal & Financials
              _buildFinanceRow('Subtotal Belanja', CurrencyFormatter.format(subtotal)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL TAGIHAN',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(total),
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildFinanceRow('Bayar ($method)', CurrencyFormatter.format(cashPaid)),
              if (method == 'Tunai') ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kembalian',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(change),
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              _buildDashedLine(),
              const SizedBox(height: 12),

              // Footer Message
              Center(
                child: Text(
                  storeProfile.footerMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Crisp Barcode Simulation
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 40,
                      width: 220,
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _generateSimulatedBarcode(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      invNumber.replaceAll('-', ''),
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 11,
                        letterSpacing: 2,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Serrated / Zig-zag paper tear bottom edge
        CustomPaint(
          size: const Size(double.infinity, 12),
          painter: SerratedEdgePainter(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dashCount = (constraints.maxWidth / 7).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: 4,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFCCCCCC)),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildMetaRow(String label, String value, {bool isMono = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 11,
            fontWeight: isMono ? FontWeight.bold : FontWeight.w500,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  List<Widget> _generateSimulatedBarcode() {
    final pattern = [
      3, 1, 1, 2, 1, 3, 2, 1, 1, 3, 1, 2, 2, 1, 3, 1, 1, 2, 1, 3, 2, 1, 3, 1, 1, 2, 3, 1, 2, 1
    ];
    final list = <Widget>[];
    for (int i = 0; i < pattern.length; i++) {
      final width = pattern[i].toDouble();
      final isBlack = i % 2 == 0;
      list.add(
        Container(
          width: width * 1.5,
          height: 38,
          color: isBlack ? Colors.black : Colors.transparent,
        ),
      );
    }
    return list;
  }
}

class SerratedEdgePainter extends CustomPainter {
  final Color color;

  SerratedEdgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);

    const triangleWidth = 12.0;
    const triangleHeight = 8.0;
    final count = (size.width / triangleWidth).ceil();

    for (int i = 0; i < count; i++) {
      final startX = i * triangleWidth;
      path.lineTo(startX + (triangleWidth / 2), triangleHeight);
      path.lineTo(startX + triangleWidth, 0);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

