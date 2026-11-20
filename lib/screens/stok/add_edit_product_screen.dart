import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pos_provider.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/barcode_scanner_modal.dart';
import '../../widgets/product_image.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? productToEdit;

  const AddEditProductScreen({super.key, this.productToEdit});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _barcodeController;
  late TextEditingController _costPriceController;
  late TextEditingController _sellPriceController;
  late TextEditingController _stockController;
  late TextEditingController _minAlertController;
  late TextEditingController _supplierController;
  late TextEditingController _imageUrlController;

  String _selectedCategory = 'Sembako & Beras';
  String _selectedUnit = 'pcs'; // pcs, kg, bungkus, liter, botol

  final List<String> _units = ['pcs', 'kg', 'bungkus', 'liter', 'botol'];

  final List<String> _categories = [
    'Sembako & Beras',
    'Minuman Dingin',
    'Rokok & Snack',
    'Bumbu & Dapur',
    'Kebutuhan Umum',
  ];

  // Presets image catalog for quick selection
  final List<Map<String, String>> _presetPhotos = [
    {
      'title': 'Bimoli 2L',
      'url': 'assets/images/minyak_bimoli.jpg',
    },
    {
      'title': 'Teh Pucuk',
      'url': 'assets/images/teh_pucuk.webp',
    },
    {
      'title': 'Le Minerale',
      'url': 'assets/images/le_minerale.jpg',
    },
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
      'title': 'Snack Chitato',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCDo04YPSIdFJrVxc-I2Fkk9nLhTVRRa4vYuw8r8HyLhZEY9LHAV3NNRS7jnYnNOt2trCfyIJh2OF5Sf2ga7UC8wQGq1o7Yvs3k10wiM7-sJd1za4KxfjhRjOlGzmOVrwhSpH9rQuqyW9GBfo5Ucy9OddJdj_UvwhF5R0Hhj0x5SEzx8mY8O1mj2TuEh75Pe070MP_6HNnKMSXhKw0tqMHXl-mJEKu6uIvDzXEJ1VA',
    },
    {
      'title': 'Rokok Djarum',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA9uTrasiKZLgJJL8tZE61U5c87krPLPAZnP_Q2ut9jLrJaLO8j4LWVQxBmYTfy0pidiWBD6_mdefm7NYYwHAHO4tofgxv-EANi32oDLkQUv01wPWF_UH61szEJdaGhoEbCHju8flDg4Tjuoy9xmktTN6mFF8YOoTA1vIe3O1xjRuZYKEgFlcNKB8afLFcITscdQs4M7j7EMfqzC19He6HR5IYRh6swf_yxuxXjKaY',
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

    _nameController = TextEditingController(text: p?.name ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _costPriceController =
        TextEditingController(text: p != null ? p.costPrice.toInt().toString() : '');
    _sellPriceController =
        TextEditingController(text: p != null ? p.sellPrice.toInt().toString() : '');
    _stockController =
        TextEditingController(text: p != null ? p.stock.toString() : '10');
    _minAlertController =
        TextEditingController(text: p != null ? p.minStockAlert.toString() : '5');
    _supplierController =
        TextEditingController(text: p?.supplier ?? 'Distributor Utama');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');

    if (p != null) {
      _selectedCategory = p.category;
      if (_units.contains(p.unit.toLowerCase())) {
        _selectedUnit = p.unit.toLowerCase();
      } else {
        _selectedUnit = 'pcs';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _costPriceController.dispose();
    _sellPriceController.dispose();
    _stockController.dispose();
    _minAlertController.dispose();
    _supplierController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _generateRandomBarcode() {
    final rand = DateTime.now().millisecondsSinceEpoch.toString().substring(3);
    setState(() {
      _barcodeController.text = '899$rand';
    });
  }

  void _scanBarcode() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BarcodeScannerModal(),
    );
  }

  double get _currentCost => double.tryParse(_costPriceController.text) ?? 0.0;
  double get _currentSell => double.tryParse(_sellPriceController.text) ?? 0.0;
  double get _currentProfit => _currentSell - _currentCost;
  double get _currentMarginPercent =>
      _currentSell > 0 ? (_currentProfit / _currentSell) * 100 : 0.0;

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final pos = Provider.of<PosProvider>(context, listen: false);

    final cost = double.tryParse(_costPriceController.text.trim()) ?? 0.0;
    final sell = double.tryParse(_sellPriceController.text.trim()) ?? 0.0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;
    final minAlert = int.tryParse(_minAlertController.text.trim()) ?? 5;
    final barcode = _barcodeController.text.trim().isEmpty
        ? '899${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}'
        : _barcodeController.text.trim();

    String imageUrl = _imageUrlController.text.trim();
    if (imageUrl.isEmpty) {
      imageUrl = _presetPhotos.first['url']!;
    }

    if (widget.productToEdit != null) {
      final updated = widget.productToEdit!.copyWith(
        name: _nameController.text.trim(),
        barcode: barcode,
        category: _selectedCategory,
        unit: _selectedUnit,
        costPrice: cost,
        sellPrice: sell,
        stock: stock,
        minStockAlert: minAlert,
        supplier: _supplierController.text.trim(),
        imageUrl: imageUrl,
      );
      pos.updateProduct(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk "${updated.name}" berhasil diperbarui!'),
          backgroundColor: AppColors.secondary,
        ),
      );
    } else {
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString().substring(7),
        name: _nameController.text.trim(),
        barcode: barcode,
        category: _selectedCategory,
        unit: _selectedUnit,
        costPrice: cost,
        sellPrice: sell,
        stock: stock,
        minStockAlert: minAlert,
        supplier: _supplierController.text.trim(),
        imageUrl: imageUrl,
      );
      pos.addProduct(newProduct);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk baru "${newProduct.name}" berhasil ditambahkan!'),
          backgroundColor: AppColors.secondary,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productToEdit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Rincian Produk' : 'Tambah Produk Baru',
          style: const TextStyle(
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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _saveProduct,
              icon: const Icon(Icons.check, size: 18, color: AppColors.primary),
              label: const Text(
                'Simpan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================
              // BAGIAN 1: FOTO PRODUK
              // ==========================================
              _buildSectionCard(
                title: 'Foto Produk',
                icon: Icons.image_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderLight, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _imageUrlController.text.isNotEmpty
                                ? ProductImage(
                                    imageUrl: _imageUrlController.text,
                                    fit: BoxFit.contain,
                                    iconSize: 36,
                                  )
                                : const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo_outlined,
                                            size: 36, color: AppColors.textMuted),
                                        SizedBox(height: 4),
                                        Text(
                                          'Foto Kosong',
                                          style: TextStyle(
                                              fontSize: 10, color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          if (_imageUrlController.text.isNotEmpty)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => setState(() => _imageUrlController.clear()),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Manual URL Input
                    TextFormField(
                      controller: _imageUrlController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        labelText: 'Masukkan URL Foto Produk (Manual)',
                        hintText: 'https://...',
                        prefixIcon: const Icon(Icons.link, size: 18),
                        suffixIcon: _imageUrlController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () => setState(() => _imageUrlController.clear()),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Preset Quick Pick Photos
                    const Text(
                      'Pilih Cepat dari Preset Foto Warung:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _presetPhotos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final item = _presetPhotos[idx];
                          final isSelected = _imageUrlController.text == item['url'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _imageUrlController.text = item['url']!;
                              });
                            },
                            child: Container(
                              width: 64,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.roseTint
                                    : AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.borderLight,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: ProductImage(
                                        imageUrl: item['url']!,
                                        fit: BoxFit.cover,
                                        iconSize: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['title']!,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.onSurface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ==========================================
              // BAGIAN 2: IDENTITAS BARANG
              // ==========================================
              _buildSectionCard(
                title: 'Identitas Barang',
                icon: Icons.inventory_2_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Produk
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Barang / Produk *',
                        hintText: 'cth: Beras Setra Ramos 1kg, Chitato Sapi',
                        prefixIcon: Icon(Icons.shopping_bag_outlined, size: 18),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama barang wajib diisi!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Kategori Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Kategori Produk *',
                        prefixIcon: Icon(Icons.category_outlined, size: 18),
                      ),
                      items: _categories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCategory = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Satuan Pilihan (pcs, kg, bungkus, liter, botol)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pilih Satuan Produk *',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Satuan: $_selectedUnit',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Satuan Chips Selector
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _units.map((unit) {
                        final isSelected = _selectedUnit == unit;
                        return ChoiceChip(
                          label: Text(
                            unit,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.onSurface,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceContainerLow,
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() => _selectedUnit = unit);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ==========================================
              // BAGIAN 3: BARCODE & SKU
              // ==========================================
              _buildSectionCard(
                title: 'Barcode Produk',
                icon: Icons.barcode_reader,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _barcodeController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              labelText: 'Kode Barcode / Nomor SKU *',
                              hintText: 'cth: 8991001028',
                              prefixIcon: Icon(Icons.qr_code, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _scanBarcode,
                            icon: const Icon(Icons.qr_code_scanner, size: 16),
                            label: const Text('Pindai Kamera', style: TextStyle(fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _generateRandomBarcode,
                            icon: const Icon(Icons.auto_awesome, size: 16),
                            label: const Text('Buat Acak (899...)',
                                style: TextStyle(fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surfaceContainerHigh,
                              foregroundColor: AppColors.onSurface,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ==========================================
              // BAGIAN 4: HARGA & MARGIN LABA
              // ==========================================
              _buildSectionCard(
                title: 'Harga Modal & Harga Jual',
                icon: Icons.price_change_outlined,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Harga Modal
                        Expanded(
                          child: TextFormField(
                            controller: _costPriceController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Harga Modal (HPP) *',
                              prefixText: 'Rp ',
                              hintText: '12000',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Harga Jual
                        Expanded(
                          child: TextFormField(
                            controller: _sellPriceController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Harga Jual Konsumen *',
                              prefixText: 'Rp ',
                              hintText: '14500',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Live Profit Calculation Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _currentProfit >= 0
                            ? AppColors.secondaryContainerSoft
                            : AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _currentProfit >= 0
                              ? AppColors.secondaryContainer
                              : AppColors.error,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _currentProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                                color: _currentProfit >= 0
                                    ? AppColors.secondary
                                    : AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimasi Margin Laba',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: _currentProfit >= 0
                                          ? AppColors.onSecondaryContainer
                                          : AppColors.onErrorContainer,
                                    ),
                                  ),
                                  Text(
                                    _currentProfit >= 0
                                        ? '+${CurrencyFormatter.format(_currentProfit)} / $_selectedUnit'
                                        : '${CurrencyFormatter.format(_currentProfit)} (Rugi)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: _currentProfit >= 0
                                          ? AppColors.secondary
                                          : AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _currentProfit >= 0
                                  ? AppColors.secondary
                                  : AppColors.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${_currentMarginPercent.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ==========================================
              // BAGIAN 5: STOK & BATAS PERINGATAN (ALERT)
              // ==========================================
              _buildSectionCard(
                title: 'Stok & Batas Peringatan (Alert)',
                icon: Icons.inventory_outlined,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Stok Sekarang
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Stok Sekarang *',
                              suffixText: _selectedUnit,
                              hintText: '10',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Batas Alert Min
                        Expanded(
                          child: TextFormField(
                            controller: _minAlertController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Batas Alert Minimum *',
                              suffixText: _selectedUnit,
                              hintText: '5',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Helper alert description
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.amberBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, size: 16, color: AppColors.amberWarning),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Sistem akan otomatis memberi tanda peringatan jika stok tersisa <= ${_minAlertController.text.isNotEmpty ? _minAlertController.text : "5"} $_selectedUnit.',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.onTertiaryFixedVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Supplier Input
                    TextFormField(
                      controller: _supplierController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Supplier / Pemasok (Opsional)',
                        hintText: 'cth: PT Indofood, Agen Beras Subur',
                        prefixIcon: Icon(Icons.storefront_outlined, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ==========================================
              // TOMBOL SIMPAN
              // ==========================================
              ElevatedButton.icon(
                onPressed: _saveProduct,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: Text(
                  isEdit ? 'Simpan Perubahan Produk' : 'Simpan Produk Baru ✓',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.roseTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

