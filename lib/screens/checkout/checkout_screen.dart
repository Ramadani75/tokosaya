import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/pos_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../receipt/receipt_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _cashController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final pos = Provider.of<PosProvider>(context, listen: false);
    _cashController.text = pos.cashPaid.toInt().toString();
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  void _onCashPreset(double amount) {
    final pos = Provider.of<PosProvider>(context, listen: false);
    pos.setCashPaid(amount);
    _cashController.text = amount.toInt().toString();
  }

  void _onAddExactCash(double extra) {
    final pos = Provider.of<PosProvider>(context, listen: false);
    pos.addExactCash(extra);
    _cashController.text = pos.cashPaid.toInt().toString();
  }

  void _handleManualCash(String val) {
    final parsed = double.tryParse(val) ?? 0.0;
    final pos = Provider.of<PosProvider>(context, listen: false);
    pos.setCashPaid(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final pos = Provider.of<PosProvider>(context);
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm:ss').format(now);
    final total = pos.cartTotalAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Transaksi',
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
        actions: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryFixed, width: 2),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ],
      ),
      body: pos.cart.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  const Text('Keranjang Belanja Kosong', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali ke Kasir'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Transaksi Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryFixed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      '#TRX-BARU',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryContainerSoft,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.circle, color: AppColors.secondary, size: 6),
                                          SizedBox(width: 4),
                                          Text(
                                            'Menunggu Bayar',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.onSecondaryContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Kasir: ${pos.storeProfile.cashierName}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Waktu POS',
                              style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                            ),
                            Text(
                              timeStr,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Ringkasan Pesanan (Order Items)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Rincian Belanja (${pos.cart.length} Jenis)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryFixed,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${pos.cartTotalQuantity} pcs',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Item List with image thumbnails & controls
                        ...pos.cart.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.product.imageUrl,
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 38,
                                      height: 38,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.inventory_2, size: 20, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${item.product.unit} • ${item.quantity}x @${CurrencyFormatter.format(item.product.sellPrice)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => pos.decrementCartItem(item.product.id),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.remove, size: 14, color: AppColors.onSurface),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => pos.addToCart(item.product),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Icon(Icons.add, size: 14, color: AppColors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  CurrencyFormatter.format(item.subtotal),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const Divider(height: 18),

                        // Subtotal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal Barang',
                              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                            ),
                            Text(
                              CurrencyFormatter.format(pos.cartSubtotal),
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Plastic bag switch
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'Kantong Plastik Ramah Lingkungan',
                                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.eco, size: 14, color: AppColors.secondary),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  pos.includePlastic ? CurrencyFormatter.format(pos.plasticFee) : 'Rp0',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                  height: 24,
                                  child: Switch(
                                    value: pos.includePlastic,
                                    onChanged: pos.togglePlastic,
                                    activeColor: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Big Total Tagihan Box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TOTAL TAGIHAN',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: AppColors.onPrimaryFixed,
                                    ),
                                  ),
                                  Text(
                                    '${pos.cart.length} produk (${pos.cartTotalQuantity} pcs)',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.onPrimaryFixedVariant,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                CurrencyFormatter.format(total),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pilihan Metode Pembayaran
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.payment, color: AppColors.primary, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Metode Pembayaran',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Tabs
                        Row(
                          children: [
                            // Tunai
                            Expanded(
                              child: _buildPaymentMethodTab(
                                context,
                                id: 'Tunai',
                                label: 'Tunai',
                                sublabel: 'Cash POS',
                                icon: Icons.payments,
                                isSelected: pos.selectedPaymentMethod == 'Tunai',
                                onTap: () => pos.setPaymentMethod('Tunai'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // QRIS
                            Expanded(
                              child: _buildPaymentMethodTab(
                                context,
                                id: 'QRIS',
                                label: 'QRIS',
                                sublabel: 'Semua Bank',
                                icon: Icons.qr_code_2,
                                isSelected: pos.selectedPaymentMethod == 'QRIS',
                                onTap: () => pos.setPaymentMethod('QRIS'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Transfer
                            Expanded(
                              child: _buildPaymentMethodTab(
                                context,
                                id: 'Transfer',
                                label: 'Transfer',
                                sublabel: 'BCA / Mandiri',
                                icon: Icons.account_balance,
                                isSelected: pos.selectedPaymentMethod == 'Transfer',
                                onTap: () => pos.setPaymentMethod('Transfer'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Detail according to payment method
                  if (pos.selectedPaymentMethod == 'Tunai') ...[
                    // Tunai Flow: Cash input & Quick Buttons & Kembalian
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.price_check, color: AppColors.secondary, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Uang Diterima Pelanggan',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryContainerSoft,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Tepat & Cepat',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Big Cash Input Display
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Rp',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _cashController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.onSurface,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    onChanged: _handleManualCash,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.backspace_outlined, size: 20, color: AppColors.onSurfaceVariant),
                                  onPressed: () {
                                    _cashController.text = '0';
                                    _handleManualCash('0');
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Fast Cash Shortcut Buttons
                          const Text(
                            'Tombol Cepat Uang Lembaran:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 2.1,
                            children: [
                              _buildCashShortcut(
                                title: 'UANG PAS',
                                amount: total,
                                isHighlight: pos.cashPaid == total,
                                onTap: () => _onCashPreset(total),
                              ),
                              _buildCashShortcut(
                                title: 'LEMBARAN',
                                amount: 50000,
                                isHighlight: pos.cashPaid == 50000,
                                onTap: () => _onCashPreset(50000),
                              ),
                              _buildCashShortcut(
                                title: 'POPULER',
                                amount: 100000,
                                isHighlight: pos.cashPaid == 100000,
                                onTap: () => _onCashPreset(100000),
                              ),
                              _buildCashShortcut(
                                title: '2 LEMBAR',
                                amount: 150000,
                                isHighlight: pos.cashPaid == 150000,
                                onTap: () => _onCashPreset(150000),
                              ),
                              _buildCashShortcut(
                                title: '2x 100 RIBU',
                                amount: 200000,
                                isHighlight: pos.cashPaid == 200000,
                                onTap: () => _onCashPreset(200000),
                              ),
                              InkWell(
                                onTap: () => _onAddExactCash(10000),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '+10 RIBU',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        '+Rp10.000',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Kembalian Card (Emerald Green Delight Card)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainerSoft,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.secondaryContainer),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.currency_exchange, color: AppColors.secondary, size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          'KEMBALIAN KASIR',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: pos.changeAmount >= 0 ? AppColors.secondary : AppColors.error,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        pos.changeAmount >= 0 ? 'Wajib Diberikan' : 'Uang Kurang!',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      pos.changeAmount >= 0
                                          ? CurrencyFormatter.format(pos.changeAmount)
                                          : '- ${CurrencyFormatter.format(pos.changeAmount.abs())}',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: pos.changeAmount >= 0 ? AppColors.secondary : AppColors.error,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    Icon(
                                      pos.changeAmount >= 0 ? Icons.verified : Icons.error,
                                      color: pos.changeAmount >= 0 ? AppColors.secondary : AppColors.error,
                                      size: 24,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.secondary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          CurrencyFormatter.getChangeBreakdownHint(pos.changeAmount),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.onSecondaryContainer,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (pos.selectedPaymentMethod == 'QRIS') ...[
                    // QRIS Flow
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Pindai QRIS Standar BI',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: QrImageView(
                              data: '00020101021226670016ID.CO.MADURA.POS01189360000201100425204581253033605802ID5916WARUNG CAK ARIP6007JAKARTA62070703A0154${total.toInt()}6304',
                              version: QrVersions.auto,
                              size: 180.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            CurrencyFormatter.format(total),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tunjukkan kode QR kepada pembeli. Notifikasi konfirmasi pembayaran otomatis.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Transfer Flow
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rekening Transfer Warung',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          _buildBankItem('BCA', '8820-1928-33', 'A.N. CAK ARIP'),
                          const SizedBox(height: 8),
                          _buildBankItem('Mandiri', '1370-0091-8822', 'A.N. CAK ARIP'),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Selesaikan Transaksi Button
                  ElevatedButton(
                    onPressed: (pos.selectedPaymentMethod == 'Tunai' && pos.changeAmount < 0)
                        ? null
                        : () {
                            final trx = pos.completeTransaction();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReceiptScreen(transaction: trx),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.print, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Selesaikan Transaksi (${CurrencyFormatter.format(total)}) ✓',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Ubah Belanja Button
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.edit_note, size: 18, color: AppColors.onSurfaceVariant),
                    label: const Text(
                      'Ubah Belanja / Kembali',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentMethodTab(
    BuildContext context, {
    required String id,
    required String label,
    required String sublabel,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryContainer.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.onSurface,
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 9.5,
                color: isSelected ? Colors.white.withOpacity(0.85) : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashShortcut({
    required String title,
    required double amount,
    required bool isHighlight,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isHighlight ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isHighlight ? AppColors.primaryFixed : AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              CurrencyFormatter.format(amount),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isHighlight ? Colors.white : AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankItem(String bank, String account, String holder) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bank,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                account,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
              Text(
                holder,
                style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Nomor rekening $bank disalin!'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

