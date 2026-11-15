import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pos_provider.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/barcode_scanner_modal.dart';
import 'add_edit_product_dialog.dart';

class StokScreen extends StatefulWidget {
  const StokScreen({super.key});

  @override
  State<StokScreen> createState() => _StokScreenState();
}

class _StokScreenState extends State<StokScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _activeFilter = 'all'; // 'all', 'critical', 'sembako', 'minuman', 'rokok'

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddOrEditProductDialog(BuildContext context, {Product? product}) {
    AddEditProductDialog.show(context, productToEdit: product);
  }

  void _showQuickRestockDialog(BuildContext context, Product product) {
    final pos = Provider.of<PosProvider>(context, listen: false);
    final qtyCtrl = TextEditingController(text: '10');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.local_shipping, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Restok Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              'Stok saat ini: ${product.stock} ${product.unit}',
              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Jumlah Tambahan (${product.unit})',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: [5, 10, 20, 50].map((n) {
                return ActionChip(
                  label: Text('+$n'),
                  onPressed: () => qtyCtrl.text = n.toString(),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final add = int.tryParse(qtyCtrl.text) ?? 0;
              if (add > 0) {
                pos.quickRestock(product.id, add);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Stok ${product.name} bertambah $add!'),
                    backgroundColor: AppColors.secondary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Konfirmasi Restok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pos = Provider.of<PosProvider>(context);

    // Apply local filter tab
    List<Product> displayList = pos.products.where((p) {
      if (_activeFilter == 'critical') return p.isCriticalStock;
      if (_activeFilter == 'sembako') return p.category.contains('Sembako');
      if (_activeFilter == 'minuman') return p.category.contains('Minuman');
      if (_activeFilter == 'rokok') return p.category.contains('Rokok');
      return true;
    }).toList();

    if (_searchCtrl.text.isNotEmpty) {
      final q = _searchCtrl.text.toLowerCase().trim();
      displayList = displayList.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.barcode.toLowerCase().contains(q) ||
            p.supplier.toLowerCase().contains(q);
      }).toList();
    }

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Sub-Header Title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'LIVE INVENTORY',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Inventaris & Stok Warung',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

        // Bento Summary Strip (Total SKU, Kritis, Nilai Modal)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Total SKU
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total SKU',
                              style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                            ),
                            Icon(Icons.inventory_2_outlined, size: 14, color: AppColors.onSurfaceVariant),
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${pos.totalSkuCount}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const TextSpan(
                                text: ' item',
                                style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Kritis Menipis
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kritis',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                            Icon(Icons.warning, size: 14, color: AppColors.error),
                          ],
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${pos.criticalStockProducts.length}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onErrorContainer,
                                ),
                              ),
                              const TextSpan(
                                text: ' perlu restok',
                                style: TextStyle(fontSize: 10, color: AppColors.onErrorContainer),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Nilai Modal
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nilai Modal',
                              style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                            ),
                            Icon(Icons.payments_outlined, size: 14, color: AppColors.secondary),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.formatCompact(pos.totalInventoryAssetValue),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Critical Restock Alert Banner (if any)
        if (pos.criticalStockProducts.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.amberBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.amberBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notification_important, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Perhatian: Stok Kritis!',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onTertiaryFixed,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Sisa ${pos.criticalStockProducts.first.stock}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${pos.criticalStockProducts.first.name} tersisa ${pos.criticalStockProducts.first.stock} ${pos.criticalStockProducts.first.unit} (Min. ${pos.criticalStockProducts.first.minStockAlert}). Segera hubungi supplier ${pos.criticalStockProducts.first.supplier}.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.onTertiaryFixedVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _showQuickRestockDialog(context, pos.criticalStockProducts.first),
                                icon: const Icon(Icons.local_shipping, size: 14),
                                label: const Text('Restok Cepat', style: TextStyle(fontSize: 11)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.tertiary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Menghubungi supplier ${pos.criticalStockProducts.first.supplier}...')),
                                  );
                                },
                                icon: const Icon(Icons.call, size: 14, color: AppColors.onTertiaryFixed),
                                label: const Text('Hubungi', style: TextStyle(fontSize: 11, color: AppColors.onTertiaryFixed)),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                              ),
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

        // Search & Barcode Input
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6),
                ],
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.search, size: 18, color: AppColors.textMuted),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() {}),
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Cari nama barang, barcode, supplier...',
                        hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const BarcodeScannerModal(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.barcode_reader, size: 18, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Filter Pills Scroller
        SliverToBoxAdapter(
          child: Container(
            height: 44,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterPill('all', 'Semua (${pos.products.length})', Icons.apps),
                const SizedBox(width: 8),
                _buildFilterPill('critical', 'Kritis (${pos.criticalStockProducts.length})', Icons.error_outline, isError: true),
                const SizedBox(width: 8),
                _buildFilterPill('sembako', 'Sembako', Icons.rice_bowl),
                const SizedBox(width: 8),
                _buildFilterPill('minuman', 'Minuman', Icons.local_drink),
                const SizedBox(width: 8),
                _buildFilterPill('rokok', 'Rokok & Snack', Icons.cookie),
              ],
            ),
          ),
        ),

        // Detailed Item Cards List
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
          sliver: displayList.isEmpty
              ? SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: const Text('Tidak ada item pada filter ini.'),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = displayList[index];
                      return _buildInventoryCard(context, pos, product);
                    },
                    childCount: displayList.length,
                  ),
                ),
        ),
      ],
    ),
    // Floating Button + Tambah Produk di Pinggir Bawah Layar
    Positioned(
      right: 16,
      bottom: 20,
      child: GestureDetector(
        onTap: () => _showAddOrEditProductDialog(context),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    ),
  ],
);
  }

  Widget _buildFilterPill(String id, String label, IconData icon, {bool isError = false}) {
    final isActive = _activeFilter == id;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? (isError ? AppColors.error : AppColors.primary)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : AppColors.borderLight,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive
                  ? Colors.white
                  : (isError ? AppColors.error : AppColors.onSurfaceVariant),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : (isError ? AppColors.error : AppColors.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard(BuildContext context, PosProvider pos, Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status left bar
            Container(
              width: 5,
              color: product.isCriticalStock ? AppColors.error : Colors.transparent,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Image, Title, Stock Pill
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            product.imageUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              width: 44,
                              height: 44,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.inventory_2, color: Colors.grey, size: 22),
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
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${product.category} • SKU: #${product.id} • ${product.supplier}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Stock Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: product.isCriticalStock
                                ? AppColors.errorContainer
                                : AppColors.secondaryContainerSoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${product.stock} ${product.unit}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: product.isCriticalStock
                                  ? AppColors.onErrorContainer
                                  : AppColors.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Price & Margin Breakdown Row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Modal (HPP)', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                              Text(
                                CurrencyFormatter.format(product.costPrice),
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Harga Jual', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                              Text(
                                CurrencyFormatter.format(product.sellPrice),
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Margin Laba', style: TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                              Text(
                                '+${CurrencyFormatter.format(product.profitPerUnit)} (${product.marginPercent.toStringAsFixed(1)}%)',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.secondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Fast Action Buttons: Restok Cepat, Edit, Hapus
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showQuickRestockDialog(context, product),
                          icon: const Icon(Icons.add_shopping_cart, size: 14, color: AppColors.secondary),
                          label: const Text('Restok', style: TextStyle(fontSize: 11.5, color: AppColors.secondary)),
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        ),
                        TextButton.icon(
                          onPressed: () => _showAddOrEditProductDialog(context, product: product),
                          icon: const Icon(Icons.edit, size: 14, color: AppColors.onSurfaceVariant),
                          label: const Text('Edit', style: TextStyle(fontSize: 11.5, color: AppColors.onSurfaceVariant)),
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus Produk?'),
                                content: Text('Apakah Anda yakin ingin menghapus "${product.name}"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                                  ElevatedButton(
                                    onPressed: () {
                                      pos.deleteProduct(product.id);
                                      Navigator.pop(ctx);
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

