import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pos_provider.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'product_image.dart';

class BarcodeScannerModal extends StatefulWidget {
  const BarcodeScannerModal({super.key});

  @override
  State<BarcodeScannerModal> createState() => _BarcodeScannerModalState();
}

class _BarcodeScannerModalState extends State<BarcodeScannerModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _codeCtrl = TextEditingController();
  Product? _foundProduct;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _searchBarcode(String code) {
    if (code.trim().isEmpty) return;
    final pos = Provider.of<PosProvider>(context, listen: false);
    final match = pos.products.cast<Product?>().firstWhere(
          (p) => p?.barcode == code.trim() || p?.id == code.trim(),
          orElse: () => null,
        );

    setState(() {
      _foundProduct = match;
      _notFound = match == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pos = Provider.of<PosProvider>(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pindai Barcode Produk',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        'Arahkan kamera atau masukkan nomor SKU/Barcode',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Animated Scanner Box
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Viewfinder lines
                Center(
                  child: Container(
                    width: 220,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Laser line
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Positioned(
                      top: 30 + (_animController.value * 90),
                      child: Container(
                        width: 210,
                        height: 2.5,
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryContainer.withOpacity(0.8),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Positioned(
                  bottom: 12,
                  child: Text(
                    'Posisikan barcode pada area target',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Input Barcode field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Ketik Barcode / SKU (cth: 8991001011)...',
                    hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.onSurfaceVariant),
                  ),
                  onSubmitted: _searchBarcode,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _searchBarcode(_codeCtrl.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cari'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Barcode quick presets
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: pos.products.take(4).map((p) {
              return ActionChip(
                backgroundColor: AppColors.surfaceContainerLow,
                side: BorderSide.none,
                label: Text(
                  '${p.name.split(' ').first}: ${p.barcode}',
                  style: const TextStyle(fontSize: 10, color: AppColors.onSurface),
                ),
                onPressed: () {
                  _codeCtrl.text = p.barcode;
                  _searchBarcode(p.barcode);
                },
              );
            }).toList(),
          ),

          // Result section
          if (_foundProduct != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainerSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondaryContainer),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ProductImage(
                      imageUrl: _foundProduct!.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      iconSize: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _foundProduct!.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${CurrencyFormatter.format(_foundProduct!.sellPrice)} • Stok: ${_foundProduct!.stock} ${_foundProduct!.unit}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      pos.addToCart(_foundProduct!);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${_foundProduct!.name} masuk keranjang!'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('+ Keranjang', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
          ] else if (_notFound) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Barang tidak ditemukan! Pastikan kode barcode terdaftar di katalog.',
                style: TextStyle(color: AppColors.onErrorContainer, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

