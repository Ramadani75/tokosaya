import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pos_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pos = Provider.of<PosProvider>(context);

    final omset = pos.analyticsTotalOmset;
    final netProfit = pos.analyticsNetProfit;
    final margin = pos.analyticsProfitMargin;
    final costHpp = pos.analyticsTotalCost;
    final aov = pos.analyticsAOV;
    final count = pos.analyticsTotalTransactions;
    final dist = pos.paymentDistribution;
    final topSelling = pos.topSellingProducts;

    final tunaiPct = dist['Tunai'] ?? 65.0;
    final qrisPct = dist['QRIS'] ?? 28.0;
    final transferPct = dist['Transfer'] ?? 7.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header & Real-time Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Pembaruan Real-Time • Shift Pagi-Malam',
                        style: TextStyle(fontSize: 10.5, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Laporan Kinerja & Keuangan',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data transaksi analitik disegarkan!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.sync, color: AppColors.onSurfaceVariant, size: 20),
                style: IconButton.styleFrom(backgroundColor: AppColors.surfaceContainerLow),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Segmented Time Filter
          Row(
            children: ['Hari Ini', '7 Hari', 'Bulan Ini', 'Semua'].map((filter) {
              final isSel = pos.analyticsTimeFilter == filter;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => pos.setAnalyticsTimeFilter(filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                          color: isSel ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Main Financial Hero Card (Maroon Gradient)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryContainer,
                  Color(0xFF5A0019),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.account_balance_wallet, size: 14, color: AppColors.secondaryFixed),
                          SizedBox(width: 6),
                          Text(
                            'OMSET KOTOR',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              color: AppColors.secondaryFixed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.trending_up, size: 14, color: AppColors.secondaryFixed),
                          SizedBox(width: 4),
                          Text(
                            '+18.4%',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryFixed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  CurrencyFormatter.format(omset),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count Nota Penjualan Terselesaikan (${pos.analyticsTimeFilter})',
                  style: const TextStyle(fontSize: 12, color: AppColors.primaryFixed),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shift Standby Warung Madura',
                        style: TextStyle(fontSize: 10.5, color: Colors.white70),
                      ),
                      Text(
                        'Toko Buka 24 Jam',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.tertiaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2-Column Secondary Financial Metrics (Laba Bersih & Total HPP)
          Row(
            children: [
              // Laba Bersih
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainerSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.savings_outlined, size: 16, color: AppColors.secondary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainerSoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Margin ${margin.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Laba Bersih', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(netProfit),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.secondary),
                      ),
                      const Text('Est. Keuntungan Toko', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Total Modal (HPP)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.inventory_outlined, size: 16, color: AppColors.onSurfaceVariant),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${(100 - margin).clamp(0, 100).toStringAsFixed(1)}% Omset',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Total Modal (HPP)', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(costHpp),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                      ),
                      const Text('Harga Beli Distributor', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Average Order Value (AOV) Strip Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.tertiaryFixed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_basket_outlined, color: AppColors.onTertiaryFixed, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rata-rata Nilai Belanja (AOV)',
                        style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                      Row(
                        children: [
                          Text(
                            CurrencyFormatter.format(aov),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                          ),
                          const Text(' / transaksi', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 14, color: AppColors.secondary),
                    SizedBox(width: 2),
                    Text('2.8 item', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payment Methods Breakdown Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
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
                        Icon(Icons.payments_outlined, color: AppColors.primary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Distribusi Pembayaran',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('3 Metode Aktif', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Multi-Segment Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 10,
                    child: Row(
                      children: [
                        Expanded(
                          flex: (tunaiPct * 10).round().clamp(1, 1000),
                          child: Container(color: AppColors.primaryContainer),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: (qrisPct * 10).round().clamp(1, 1000),
                          child: Container(color: AppColors.secondary),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: (transferPct * 10).round().clamp(1, 1000),
                          child: Container(color: AppColors.tertiary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Breakdown Labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPaymentPill('Tunai', '${tunaiPct.toStringAsFixed(0)}%', AppColors.primaryContainer),
                    _buildPaymentPill('QRIS', '${qrisPct.toStringAsFixed(0)}%', AppColors.secondary),
                    _buildPaymentPill('Transfer', '${transferPct.toStringAsFixed(0)}%', AppColors.tertiary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Top Best-Selling Products Leaderboard
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.emoji_events_outlined, color: AppColors.primary, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Peringkat Barang Terlaris',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (topSelling.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('Belum ada data barang terjual.')),
                  )
                else
                  ...topSelling.take(5).toList().asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final item = entry.value;
                    final product = item['product'];
                    final qty = item['quantity'] as int;
                    final rev = item['revenue'] as double;

                    Color rankColor = AppColors.surfaceContainerHigh;
                    Color rankTextColor = AppColors.onSurface;
                    if (rank == 1) {
                      rankColor = const Color(0xFFFFD700);
                      rankTextColor = Colors.black;
                    } else if (rank == 2) {
                      rankColor = const Color(0xFFC0C0C0);
                      rankTextColor = Colors.black;
                    } else if (rank == 3) {
                      rankColor = const Color(0xFFCD7F32);
                      rankTextColor = Colors.white;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: rankColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$rank',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: rankTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${product.category} • $qty ${product.unit} terjual',
                                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(rev),
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPill(String name, String pct, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$name $pct',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        ),
      ],
    );
  }
}

