import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/pos_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/barcode_scanner_modal.dart';

class AddEditProductDialog extends StatefulWidget {
  final Product? productToEdit;

  const AddEditProductDialog({super.key, this.productToEdit});

  static Future<void> show(BuildContext context, {Product? productToEdit}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AddEditProductDialog(productToEdit: productToEdit),
    );
  }

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  late TextEditingController _barcodeCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _costPriceCtrl;
  late TextEditingController _sellPriceCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _minAlertCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _imageUrlCtrl;

  String _selectedCategory = 'Sembako & Beras';

  final List<String> _categoryOptions = [
    'Sembako & Beras',
    'Minuman Dingin',
    'Rokok & Snack',
    'Bumbu & Dapur',
    'Kebutuhan Rumah Tangga',
  ];

  final List<String> _unitOptions = [
    'pcs',
    'kg',
    'liter',
    'bungkus',
    'botol',
    'karung',
    'renceng',
  ];

  // Presets image catalog
  final List<Map<String, String>> _presetPhotos = [
    {
      'title': 'Beras 5kg',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBRuZErQZsElhZ5HtVYLV_X3So2wxG_xhwG_Qa5zmIw7Ed0QXxEkZ4edxASXVWQ-d3bfO1wkY9ZfJS4KJYf5CXUqupvEKCTMbGI378wYusr9pd3fuXPyg6x0-pWzfagiR-EKI9JDNl8528NFzXXQO2X2QQucGIkM2G9UQfY6aBNb7KsQniLeYQgxhjVMvontRcE9F4djP6hyQjjhWDV8LEEiUE6yfhuGns3jNuG8c8',
    },
    {
      'title': 'Beras 1kg',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCisGrUH6sWBodj1AXT4XF-3E_MLTdfADhPgglwgipPxPumvqSIlHTGJjRz8cFYkMC47mL3VtCgn4C5vRP0bDr94sBT0vUPdlCyp8gKphbFQu3QvGwT_AtbWttdzAGWa7FHRvcivU0LZhEQ2MvRV8GMLTzEZuvw-pdWhUIeMQ6tURuNpRZo_jnuHg4_K-sJluR6F1ZjX1xaWy4gIuXY4yhXwonbv6sfp4EAGmxOFCQ',
    },
    {
      'title': 'Minyak Pouch',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCsr-kz-Ft7hJ4HszOoUAY5Pf3ozooAI1meMBhZYRd9mGvoRBW417pJEIZPB21V5Bdt2_Odb_ILZtDhxIrH6KBUmBEjuyW2GTAqzJR_iTnJ7Mhqk3akUdg09ttfNZJPiBeg6i2z9k8O4os8Vh1HEFMQh5MgpeDdFpo6WG__wQsZ1rBwDBgusHA-PSGXJf621p6slBBEZamGQEKb2Kqaw6ruwKF8X7nVM4WxzVbMHVo',
    },
    {
      'title': 'Chitato',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCDo04YPSIdFJrVxc-I2Fkk9nLhTVRRa4vYuw8r8HyLhZEY9LHAV3NNRS7jnYnNOt2trCfyIJh2OF5Sf2ga7UC8wQGq1o7Yvs3k10wiM7-sJd1za4KxfjhRjOlGzmOVrwhSpH9rQuqyW9GBfo5Ucy9OddJdj_UvwhF5R0Hhj0x5SEzx8mY8O1mj2TuEh75Pe070MP_6HNnKMSXhKw0tqMHXl-mJEKu6uIvDzXEJ1VA',
    },
    {
      'title': 'Djarum Super',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA9uTrasiKZLgJJL8tZE61U5c87krPLPAZnP_Q2ut9jLrJaLO8j4LWVQxBmYTfy0pidiWBD6_mdefm7NYYwHAHO4tofgxv-EANi32oDLkQUv01wPWF_UH61szEJdaGhoEbCHju8flDg4Tjuoy9xmktTN6mFF8YOoTA1vIe3O1xjRuZYKEgFlcNKB8afLFcITscdQs4M7j7EMfqzC19He6HR5IYRh6swf_yxuxXjKaY',
    },
    {
      'title': 'Teh Botol',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDzzfDzzc7d0ZNdiQnKOVE5zpeyTcca9OGHGGMJ9FkuxfS0Ztbn7n_BAiFz0eyEThu_bIMw-we2CMo7wC9lKVCdbgrxpdBz-pYTDunHblrjg-KiWnkBfIXIq36GbJZreiOcIceHfZeevh2UDKhXVo4fyM3gvkJ3BCmTM-4E-knLP_BT2BATstiQbfLlXLKg39Zh7cMh34CNXbhL7nIEbNTKNpLTOGIoLxAht1dfjIQ',
    },
    {
      'title': 'Kopi Renceng',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCHN4aT5DLEiqzP1qkJjxER2olYxxp1eF-VtMjoThvJBUpfZcKkVEnvmwsgv4FJJq4fE6CaRoF9UuB03Y74KpdXLCL22IqDDmW6Oy7pZj_FnU5gRMCmqiDcplpAkveihBtWNARIYyQTkkit8X2YpdGJIemyil_36zFkGT14_e6wliIv0c6fvyBAU_lD71_3_RbJ60VUCLVQKW81pddLpB8Q7ZJuibp6IyBmD7t6YHQ',
    },
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.productToEdit;
    _barcodeCtrl = TextEditingController(text: p?.barcode ?? '');
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _costPriceCtrl =
        TextEditingController(text: p != null ? p.costPrice.toInt().toString() : '');
    _sellPriceCtrl =
        TextEditingController(text: p != null ? p.sellPrice.toInt().toString() : '');
    _stockCtrl = TextEditingController(text: p != null ? p.stock.toString() : '10');
    _minAlertCtrl =
        TextEditingController(text: p != null ? p.minStockAlert.toString() : '5');
    _unitCtrl = TextEditingController(text: p?.unit ?? 'pcs');
    _imageUrlCtrl = TextEditingController(text: p?.imageUrl ?? '');

    if (p != null) {
      _selectedCategory = p.category;
    }
  }

  @override
  void dispose() {
    _barcodeCtrl.dispose();
    _nameCtrl.dispose();
    _costPriceCtrl.dispose();
    _sellPriceCtrl.dispose();
    _stockCtrl.dispose();
    _minAlertCtrl.dispose();
    _unitCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  void _generateRandomBarcode() {
    final rand = DateTime.now().millisecondsSinceEpoch.toString().substring(3);
    setState(() {
      _barcodeCtrl.text = '899$rand';
    });
  }

  void _openScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BarcodeScannerModal(),
    );
  }

  void _openPhotoPicker() {
    final manualUrlCtrl = TextEditingController(text: _imageUrlCtrl.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setPickerState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih / Masukkan Foto Produk',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Manual URL Input
              TextField(
                controller: manualUrlCtrl,
                decoration: InputDecoration(
                  labelText: 'URL Foto Manual',
                  hintText: 'https://...',
                  prefixIcon: const Icon(Icons.link),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      setState(() {
                        _imageUrlCtrl.text = manualUrlCtrl.text.trim();
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              const Text(
                'Atau Pilih Foto Cepat Warung Madura:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),

              // Preset Photos Grid
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _presetPhotos.map((item) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _imageUrlCtrl.text = item['url']!;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 90,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item['url']!,
                              width: 78,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image, size: 24, color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isFormValid =>
      _nameCtrl.text.trim().isNotEmpty && _sellPriceCtrl.text.trim().isNotEmpty;

  void _onSave() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama barang/produk wajib diisi!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_sellPriceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harga jual wajib diisi!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final pos = Provider.of<PosProvider>(context, listen: false);

    final cost = double.tryParse(_costPriceCtrl.text.trim()) ?? 0.0;
    final sell = double.tryParse(_sellPriceCtrl.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 10;
    final minAlert = int.tryParse(_minAlertCtrl.text.trim()) ?? 5;
    final barcode = _barcodeCtrl.text.trim().isEmpty
        ? '899${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}'
        : _barcodeCtrl.text.trim();
    final unit = _unitCtrl.text.trim().isEmpty ? 'pcs' : _unitCtrl.text.trim();

    String imageUrl = _imageUrlCtrl.text.trim();
    if (imageUrl.isEmpty) {
      imageUrl = _presetPhotos.first['url']!;
    }

    if (widget.productToEdit != null) {
      final updated = widget.productToEdit!.copyWith(
        name: _nameCtrl.text.trim(),
        barcode: barcode,
        category: _selectedCategory,
        unit: unit,
        costPrice: cost,
        sellPrice: sell,
        stock: stock,
        minStockAlert: minAlert,
        imageUrl: imageUrl,
      );
      pos.updateProduct(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk "${updated.name}" berhasil diubah!'),
          backgroundColor: AppColors.secondary,
        ),
      );
    } else {
      final newProd = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString().substring(7),
        name: _nameCtrl.text.trim(),
        barcode: barcode,
        category: _selectedCategory,
        unit: unit,
        costPrice: cost,
        sellPrice: sell,
        stock: stock,
        minStockAlert: minAlert,
        imageUrl: imageUrl,
      );
      pos.addProduct(newProd);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk "${newProd.name}" berhasil ditambahkan!'),
          backgroundColor: AppColors.secondary,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 720),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Title
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 14),
                child: Text(
                  widget.productToEdit != null ? 'Edit Produk' : 'Tambah Produk Baru',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              // Scrollable Form Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ==========================================
                      // 1. FOTO PRODUK KASIR BOX
                      // ==========================================
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            // Left Thumbnail
                            GestureDetector(
                              onTap: _openPhotoPicker,
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFFFEDD5)),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: _imageUrlCtrl.text.isNotEmpty
                                    ? Image.network(
                                        _imageUrlCtrl.text,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => _buildEmptyPhotoThumb(),
                                      )
                                    : _buildEmptyPhotoThumb(),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Right Info & Pilih Foto Button
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Foto Produk Kasir',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Akan tampil di kasir agar transaksi tidak salah & keren',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.textMuted,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: _openPhotoPicker,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.photo_library_outlined,
                                              size: 14, color: AppColors.onSurface),
                                          SizedBox(width: 5),
                                          Text(
                                            'Pilih Foto',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ==========================================
                      // 2. KODE BARCODE * + SCANNER & MAGIC ICONS
                      // ==========================================
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _barcodeCtrl,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDecoration(hintText: 'Kode Barcode *'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // QR Scanner Icon (Maroon)
                          GestureDetector(
                            onTap: _openScanner,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.roseTint,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Sparkle Magic Generate Icon (Amber)
                          GestureDetector(
                            onTap: _generateRandomBarcode,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFFD97706),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ==========================================
                      // 3. NAMA BARANG / PRODUK *
                      // ==========================================
                      TextField(
                        controller: _nameCtrl,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDecoration(hintText: 'Nama Barang / Produk *'),
                      ),
                      const SizedBox(height: 12),

                      // ==========================================
                      // 4. KATEGORI PRODUK (DROPDOWN)
                      // ==========================================
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        style: const TextStyle(fontSize: 13, color: AppColors.onSurface),
                        decoration: _inputDecoration(
                          labelText: 'Kategori Produk',
                          floatingLabel: true,
                        ),
                        icon: const Icon(Icons.arrow_drop_down, color: AppColors.onSurfaceVariant),
                        items: _categoryOptions.map((c) {
                          return DropdownMenuItem(value: c, child: Text(c));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedCategory = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // ==========================================
                      // 5. ROW HARGA MODAL & HARGA JUAL
                      // ==========================================
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _costPriceCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDecoration(
                                hintText: 'Harga Modal (Rp)',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _sellPriceCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDecoration(
                                hintText: 'Harga Jual (Rp) *',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ==========================================
                      // 6. ROW STOK SEKARANG & BATAS ALERT
                      // ==========================================
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _stockCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDecoration(
                                labelText: 'Stok Sekarang',
                                floatingLabel: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _minAlertCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                              style: const TextStyle(fontSize: 13),
                              decoration: _inputDecoration(
                                labelText: 'Batas Alert',
                                floatingLabel: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ==========================================
                      // 7. SATUAN (pcs, kg, liter, bungkus, botol)
                      // ==========================================
                      PopupMenuButton<String>(
                        onSelected: (val) {
                          setState(() {
                            _unitCtrl.text = val;
                          });
                        },
                        itemBuilder: (context) => _unitOptions.map((u) {
                          return PopupMenuItem(
                            value: u,
                            child: Text(u, style: const TextStyle(fontSize: 13)),
                          );
                        }).toList(),
                        child: TextField(
                          controller: _unitCtrl,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 13),
                          decoration: _inputDecoration(
                            labelText: 'Satuan (pcs, kg, liter, bungkus, botol)',
                            floatingLabel: true,
                            suffixIcon: const Icon(Icons.arrow_drop_down,
                                color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ==========================================
              // FOOTER ACTIONS: Batal & Simpan Produk
              // ==========================================
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Batal
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFBA1A1A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Simpan Produk Pill
                    ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid
                            ? AppColors.primary
                            : const Color(0xFFE2E8F0),
                        foregroundColor: _isFormValid
                            ? Colors.white
                            : const Color(0xFF64748B),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Simpan Produk',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPhotoThumb() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 26,
          color: Colors.orange.shade700,
        ),
        const SizedBox(height: 2),
        Text(
          'Foto',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade800,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    String? hintText,
    String? labelText,
    bool floatingLabel = false,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      floatingLabelBehavior:
          floatingLabel ? FloatingLabelBehavior.always : FloatingLabelBehavior.auto,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
      labelStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

