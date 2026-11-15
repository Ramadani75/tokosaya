import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/transaction.dart';
import '../models/store_profile.dart';
import '../models/printer_settings.dart';

class PosProvider extends ChangeNotifier {
  List<Product> _products = [];
  final List<CartItem> _cart = [];
  List<PosTransaction> _transactions = [];

  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  // Checkout states
  String _selectedPaymentMethod = 'Tunai'; // 'Tunai', 'QRIS', 'Transfer'
  double _cashPaid = 100000;
  bool _includePlastic = true;
  final double _plasticFee = 500;

  // Settings
  StoreProfile _storeProfile = StoreProfile();
  PrinterSettings _printerSettings = PrinterSettings();

  // Active transaction for receipt screen
  PosTransaction? _lastCompletedTransaction;

  // Analytics filter
  String _analyticsTimeFilter = 'Hari Ini'; // 'Hari Ini', '7 Hari', 'Bulan Ini', 'Semua'

  PosProvider() {
    _initData();
  }

  // Getters
  List<Product> get products => _products;
  List<CartItem> get cart => _cart;
  List<PosTransaction> get transactions => _transactions;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  double get cashPaid => _cashPaid;
  bool get includePlastic => _includePlastic;
  double get plasticFee => _plasticFee;
  StoreProfile get storeProfile => _storeProfile;
  PrinterSettings get printerSettings => _printerSettings;
  PosTransaction? get lastCompletedTransaction => _lastCompletedTransaction;
  String get analyticsTimeFilter => _analyticsTimeFilter;

  // Category list
  final List<String> categories = [
    'Semua',
    'Sembako & Beras',
    'Minuman Dingin',
    'Rokok & Snack',
    'Bumbu & Dapur',
  ];

  // Filtered Products
  List<Product> get filteredProducts {
    return _products.where((p) {
      final matchesCategory =
          _selectedCategory == 'Semua' || p.category == _selectedCategory;
      final q = _searchQuery.toLowerCase().trim();
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.barcode.toLowerCase().contains(q) ||
          p.supplier.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  // Stock alerts
  List<Product> get criticalStockProducts =>
      _products.where((p) => p.isCriticalStock).toList();

  int get totalSkuCount => _products.length;

  double get totalInventoryAssetValue =>
      _products.fold(0.0, (sum, p) => sum + (p.costPrice * p.stock));

  // Cart calculations
  int get cartTotalQuantity =>
      _cart.fold(0, (sum, item) => sum + item.quantity);

  double get cartSubtotal =>
      _cart.fold(0.0, (sum, item) => sum + item.subtotal);

  double get cartTotalAmount =>
      cartSubtotal + (_includePlastic && _cart.isNotEmpty ? _plasticFee : 0.0);

  double get changeAmount =>
      _selectedPaymentMethod == 'Tunai' ? (_cashPaid - cartTotalAmount) : 0.0;

  // Initialization & Defaults
  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Load Store Profile
    final profileStr = prefs.getString('store_profile');
    if (profileStr != null) {
      try {
        _storeProfile = StoreProfile.fromJson(jsonDecode(profileStr));
      } catch (_) {}
    }

    // 2. Load Printer Settings
    final printerStr = prefs.getString('printer_settings');
    if (printerStr != null) {
      try {
        _printerSettings = PrinterSettings.fromJson(jsonDecode(printerStr));
      } catch (_) {}
    }

    // 3. Load Products
    final productsStr = prefs.getString('products_data');
    if (productsStr != null) {
      try {
        final List<dynamic> list = jsonDecode(productsStr);
        _products = list.map((e) => Product.fromJson(e)).toList();
        _ensureSampleCriticalProducts();
      } catch (_) {
        _loadDefaultProducts();
      }
    } else {
      _loadDefaultProducts();
    }

    // 4. Load Transactions
    final trxStr = prefs.getString('transactions_data');
    if (trxStr != null) {
      try {
        final List<dynamic> list = jsonDecode(trxStr);
        _transactions = list.map((e) => PosTransaction.fromJson(e)).toList();
      } catch (_) {
        _loadDefaultTransactions();
      }
    } else {
      _loadDefaultTransactions();
    }

    notifyListeners();
  }

  void _ensureSampleCriticalProducts() {
    bool changed = false;
    if (!_products.any((p) => p.name.contains('Bensin Pertalite'))) {
      _products.insert(
        0,
        Product(
          id: '007001',
          name: 'Bensin Pertalite Botol 1L',
          barcode: '8997001001',
          category: 'Kebutuhan Umum',
          unit: 'botol',
          costPrice: 10000,
          sellPrice: 12000,
          stock: 2, // Critical alert!
          minStockAlert: 5,
          imageUrl: '',
          supplier: 'Agen BBM Eceran',
        ),
      );
      changed = true;
    }
    if (!_products.any((p) => p.name.contains('Telur Ayam Negeri'))) {
      _products.insert(
        1,
        Product(
          id: '007002',
          name: 'Telur Ayam Negeri 1kg',
          barcode: '8997001002',
          category: 'Sembako & Beras',
          unit: 'kg',
          costPrice: 25000,
          sellPrice: 28000,
          stock: 3, // Critical alert!
          minStockAlert: 5,
          imageUrl: '',
          supplier: 'Peternak Blitar',
        ),
      );
      changed = true;
    }
    if (changed) {
      _saveProducts();
    }
  }

  void _loadDefaultProducts() {
    _products = [
      Product(
        id: '007001',
        name: 'Bensin Pertalite Botol 1L',
        barcode: '8997001001',
        category: 'Kebutuhan Umum',
        unit: 'botol',
        costPrice: 10000,
        sellPrice: 12000,
        stock: 2, // Critical alert!
        minStockAlert: 5,
        imageUrl: '',
        supplier: 'Agen BBM Eceran',
      ),
      Product(
        id: '007002',
        name: 'Telur Ayam Negeri 1kg',
        barcode: '8997001002',
        category: 'Sembako & Beras',
        unit: 'kg',
        costPrice: 25000,
        sellPrice: 28000,
        stock: 3, // Critical alert!
        minStockAlert: 5,
        imageUrl: '',
        supplier: 'Peternak Blitar',
      ),
      Product(
        id: '001011',
        name: 'Beras Ramos Wangi 5kg',
        barcode: '8991001011',
        category: 'Sembako & Beras',
        unit: 'karung',
        costPrice: 60000,
        sellPrice: 68000,
        stock: 2, // Critical alert!
        minStockAlert: 5,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBRuZErQZsElhZ5HtVYLV_X3So2wxG_xhwG_Qa5zmIw7Ed0QXxEkZ4edxASXVWQ-d3bfO1wkY9ZfJS4KJYf5CXUqupvEKCTMbGI378wYusr9pd3fuXPyg6x0-pWzfagiR-EKI9JDNl8528NFzXXQO2X2QQucGIkM2G9UQfY6aBNb7KsQniLeYQgxhjVMvontRcE9F4djP6hyQjjhWDV8LEEiUE6yfhuGns3jNuG8c8',
        supplier: 'Beras Subur Makmur',
      ),
      Product(
        id: '001028',
        name: 'Beras Setra Ramos 1kg',
        barcode: '8991001028',
        category: 'Sembako & Beras',
        unit: 'kg',
        costPrice: 12800,
        sellPrice: 14500,
        stock: 25,
        minStockAlert: 5,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCisGrUH6sWBodj1AXT4XF-3E_MLTdfADhPgglwgipPxPumvqSIlHTGJjRz8cFYkMC47mL3VtCgn4C5vRP0bDr94sBT0vUPdlCyp8gKphbFQu3QvGwT_AtbWttdzAGWa7FHRvcivU0LZhEQ2MvRV8GMLTzEZuvw-pdWhUIeMQ6tURuNpRZo_jnuHg4_K-sJluR6F1ZjX1xaWy4gIuXY4yhXwonbv6sfp4EAGmxOFCQ',
        supplier: 'Bulog Retail',
      ),
      Product(
        id: '330014',
        name: 'Chitato Sapi Panggang 68g',
        barcode: '8993300140',
        category: 'Rokok & Snack',
        unit: 'bks',
        costPrice: 9500,
        sellPrice: 11500,
        stock: 12,
        minStockAlert: 5,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCDo04YPSIdFJrVxc-I2Fkk9nLhTVRRa4vYuw8r8HyLhZEY9LHAV3NNRS7jnYnNOt2trCfyIJh2OF5Sf2ga7UC8wQGq1o7Yvs3k10wiM7-sJd1za4KxfjhRjOlGzmOVrwhSpH9rQuqyW9GBfo5Ucy9OddJdj_UvwhF5R0Hhj0x5SEzx8mY8O1mj2TuEh75Pe070MP_6HNnKMSXhKw0tqMHXl-mJEKu6uIvDzXEJ1VA',
        supplier: 'Indofood Sukses Makmur',
      ),
      Product(
        id: '001022',
        name: 'Djarum Super 12',
        barcode: '8991001022',
        category: 'Rokok & Snack',
        unit: 'bungkus',
        costPrice: 22500,
        sellPrice: 24500,
        stock: 14,
        minStockAlert: 5,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuA9uTrasiKZLgJJL8tZE61U5c87krPLPAZnP_Q2ut9jLrJaLO8j4LWVQxBmYTfy0pidiWBD6_mdefm7NYYwHAHO4tofgxv-EANi32oDLkQUv01wPWF_UH61szEJdaGhoEbCHju8flDg4Tjuoy9xmktTN6mFF8YOoTA1vIe3O1xjRuZYKEgFlcNKB8afLFcITscdQs4M7j7EMfqzC19He6HR5IYRh6swf_yxuxXjKaY',
        supplier: 'PT Djarum Kudus',
      ),
      Product(
        id: '002011',
        name: 'Minyak Goreng Bimoli 2L',
        barcode: '8992002011',
        category: 'Sembako & Beras',
        unit: 'pouch',
        costPrice: 32000,
        sellPrice: 36000,
        stock: 9,
        minStockAlert: 5,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCsr-kz-Ft7hJ4HszOoUAY5Pf3ozooAI1meMBhZYRd9mGvoRBW417pJEIZPB21V5Bdt2_Odb_ILZtDhxIrH6KBUmBEjuyW2GTAqzJR_iTnJ7Mhqk3akUdg09ttfNZJPiBeg6i2z9k8O4os8Vh1HEFMQh5MgpeDdFpo6WG__wQsZ1rBwDBgusHA-PSGXJf621p6slBBEZamGQEKb2Kqaw6ruwKF8X7nVM4WxzVbMHVo',
        supplier: 'Salim Ivomas Pratama',
      ),
      Product(
        id: '004011',
        name: 'Teh Pucuk Harum 350ml',
        barcode: '8994004011',
        category: 'Minuman Dingin',
        unit: 'botol',
        costPrice: 3100,
        sellPrice: 4000,
        stock: 36,
        minStockAlert: 10,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDzzfDzzc7d0ZNdiQnKOVE5zpeyTcca9OGHGGMJ9FkuxfS0Ztbn7n_BAiFz0eyEThu_bIMw-we2CMo7wC9lKVCdbgrxpdBz-pYTDunHblrjg-KiWnkBfIXIq36GbJZreiOcIceHfZeevh2UDKhXVo4fyM3gvkJ3BCmTM-4E-knLP_BT2BATstiQbfLlXLKg39Zh7cMh34CNXbhL7nIEbNTKNpLTOGIoLxAht1dfjIQ',
        supplier: 'Mayora Beverages',
      ),
      Product(
        id: '004012',
        name: 'Le Minerale 600ml (Dingin)',
        barcode: '8994004012',
        category: 'Minuman Dingin',
        unit: 'botol',
        costPrice: 2600,
        sellPrice: 3500,
        stock: 48,
        minStockAlert: 12,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCsr-kz-Ft7hJ4HszOoUAY5Pf3ozooAI1meMBhZYRd9mGvoRBW417pJEIZPB21V5Bdt2_Odb_ILZtDhxIrH6KBUmBEjuyW2GTAqzJR_iTnJ7Mhqk3akUdg09ttfNZJPiBeg6i2z9k8O4os8Vh1HEFMQh5MgpeDdFpo6WG__wQsZ1rBwDBgusHA-PSGXJf621p6slBBEZamGQEKb2Kqaw6ruwKF8X7nVM4WxzVbMHVo',
        supplier: 'Mayora Beverages',
      ),
      Product(
        id: '005011',
        name: 'Indomie Goreng Spesial',
        barcode: '8995005011',
        category: 'Sembako & Beras',
        unit: 'bks',
        costPrice: 2900,
        sellPrice: 3500,
        stock: 65,
        minStockAlert: 20,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBRuZErQZsElhZ5HtVYLV_X3So2wxG_xhwG_Qa5zmIw7Ed0QXxEkZ4edxASXVWQ-d3bfO1wkY9ZfJS4KJYf5CXUqupvEKCTMbGI378wYusr9pd3fuXPyg6x0-pWzfagiR-EKI9JDNl8528NFzXXQO2X2QQucGIkM2G9UQfY6aBNb7KsQniLeYQgxhjVMvontRcE9F4djP6hyQjjhWDV8LEEiUE6yfhuGns3jNuG8c8',
        supplier: 'Indofood Sukses Makmur',
      ),
      Product(
        id: '006011',
        name: 'Kopi Kapal Api Special Mix',
        barcode: '8996006011',
        category: 'Bumbu & Dapur',
        unit: 'renceng',
        costPrice: 11800,
        sellPrice: 14000,
        stock: 18,
        minStockAlert: 5,
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuCHN4aT5DLEiqzP1qkJjxER2olYxxp1eF-VtMjoThvJBUpfZcKkVEnvmwsgv4FJJq4fE6CaRoF9UuB03Y74KpdXLCL22IqDDmW6Oy7pZj_FnU5gRMCmqiDcplpAkveihBtWNARIYyQTkkit8X2YpdGJIemyil_36zFkGT14_e6wliIv0c6fvyBAU_lD71_3_RbJ60VUCLVQKW81pddLpB8Q7ZJuibp6IyBmD7t6YHQ',
        supplier: 'Santos Jaya Abadi',
      ),
    ];
    _saveProducts();
  }

  void _loadDefaultTransactions() {
    final now = DateTime.now();
    _transactions = [
      PosTransaction(
        id: 'TRX-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-0001',
        invoiceNumber: 'TR-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-0001',
        timestamp: now.subtract(const Duration(hours: 4)),
        cashierName: 'Cak Arip',
        items: [
          CartItem(
            product: _products.firstWhere((p) => p.id == '001028'),
            quantity: 1,
          ),
          CartItem(
            product: _products.firstWhere((p) => p.id == '330014'),
            quantity: 2,
          ),
        ],
        subtotal: 37500,
        plasticFee: 500,
        totalAmount: 38000,
        paymentMethod: 'Tunai',
        cashPaid: 50000,
        changeAmount: 12000,
        totalCost: 31800,
      ),
      PosTransaction(
        id: 'TRX-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-0002',
        invoiceNumber: 'TR-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-0002',
        timestamp: now.subtract(const Duration(hours: 3, minutes: 15)),
        cashierName: 'Cak Arip',
        items: [
          CartItem(
            product: _products.firstWhere((p) => p.id == '001022'),
            quantity: 2,
          ),
        ],
        subtotal: 49000,
        plasticFee: 0,
        totalAmount: 49000,
        paymentMethod: 'QRIS',
        cashPaid: 49000,
        changeAmount: 0,
        totalCost: 45000,
      ),
      PosTransaction(
        id: 'TRX-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-0003',
        invoiceNumber: 'TR-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-0003',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
        cashierName: 'Cak Arip',
        items: [
          CartItem(
            product: _products.firstWhere((p) => p.id == '004011'),
            quantity: 3,
          ),
          CartItem(
            product: _products.firstWhere((p) => p.id == '005011'),
            quantity: 4,
          ),
        ],
        subtotal: 26000,
        plasticFee: 500,
        totalAmount: 26500,
        paymentMethod: 'Tunai',
        cashPaid: 30000,
        changeAmount: 3500,
        totalCost: 20900,
      ),
      PosTransaction(
        id: 'TRX-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-0004',
        invoiceNumber: 'TR-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-0004',
        timestamp: now.subtract(const Duration(minutes: 30)),
        cashierName: 'Cak Arip',
        items: [
          CartItem(
            product: _products.firstWhere((p) => p.id == '002011'),
            quantity: 1,
          ),
          CartItem(
            product: _products.firstWhere((p) => p.id == '006011'),
            quantity: 1,
          ),
        ],
        subtotal: 50000,
        plasticFee: 500,
        totalAmount: 50500,
        paymentMethod: 'Transfer',
        cashPaid: 50500,
        changeAmount: 0,
        totalCost: 43800,
      ),
    ];
    _saveTransactions();
  }

  // Persistence Helpers
  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_products.map((e) => e.toJson()).toList());
    await prefs.setString('products_data', jsonStr);
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(_transactions.map((e) => e.toJson()).toList());
    await prefs.setString('transactions_data', jsonStr);
  }

  Future<void> saveStoreProfile(StoreProfile profile) async {
    _storeProfile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('store_profile', jsonEncode(_storeProfile.toJson()));
    notifyListeners();
  }

  Future<void> savePrinterSettings(PrinterSettings settings) async {
    _printerSettings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('printer_settings', jsonEncode(_printerSettings.toJson()));
    notifyListeners();
  }

  // Search & Filter
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Cart Operations
  void addToCart(Product product) {
    final index = _cart.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      if (_cart[index].quantity < product.stock) {
        _cart[index].quantity++;
      }
    } else {
      if (product.stock > 0) {
        _cart.add(CartItem(product: product, quantity: 1));
      }
    }
    // Update cash default if current cash is less than cart total
    if (_cashPaid < cartTotalAmount) {
      _cashPaid = _roundToNextDenom(cartTotalAmount);
    }
    notifyListeners();
  }

  void decrementCartItem(String productId) {
    final index = _cart.indexWhere((item) => item.product.id == productId);
    if (index != -1) {
      if (_cart[index].quantity > 1) {
        _cart[index].quantity--;
      } else {
        _cart.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _cashPaid = 0;
    notifyListeners();
  }

  void togglePlastic(bool? value) {
    _includePlastic = value ?? true;
    notifyListeners();
  }

  // Checkout Actions
  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    if (method != 'Tunai') {
      _cashPaid = cartTotalAmount;
    } else {
      if (_cashPaid < cartTotalAmount) {
        _cashPaid = _roundToNextDenom(cartTotalAmount);
      }
    }
    notifyListeners();
  }

  void setCashPaid(double amount) {
    _cashPaid = amount;
    notifyListeners();
  }

  void addExactCash(double extra) {
    _cashPaid += extra;
    notifyListeners();
  }

  double _roundToNextDenom(double amount) {
    if (amount <= 50000) return 50000;
    if (amount <= 100000) return 100000;
    if (amount <= 150000) return 150000;
    if (amount <= 200000) return 200000;
    return (amount / 50000).ceil() * 50000.0;
  }

  // Complete Order
  PosTransaction completeTransaction() {
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final countTrx = _transactions.length + 1;
    final trxNumber = countTrx.toString().padLeft(4, '0');

    final trxId = 'TRX-$dateStr-$trxNumber';
    final invNumber = 'TR-$dateStr-$trxNumber';

    final totalCost = _cart.fold(0.0, (sum, item) => sum + item.totalCost);

    final transaction = PosTransaction(
      id: trxId,
      invoiceNumber: invNumber,
      timestamp: now,
      cashierName: _storeProfile.cashierName,
      items: List.from(_cart),
      subtotal: cartSubtotal,
      plasticFee: _includePlastic ? _plasticFee : 0,
      totalAmount: cartTotalAmount,
      paymentMethod: _selectedPaymentMethod,
      cashPaid: _selectedPaymentMethod == 'Tunai' ? _cashPaid : cartTotalAmount,
      changeAmount: changeAmount > 0 ? changeAmount : 0,
      totalCost: totalCost,
    );

    // Deduct stocks
    for (final cartItem in _cart) {
      final pIndex =
          _products.indexWhere((p) => p.id == cartItem.product.id);
      if (pIndex != -1) {
        _products[pIndex].stock =
            (_products[pIndex].stock - cartItem.quantity).clamp(0, 99999);
      }
    }

    _transactions.insert(0, transaction);
    _lastCompletedTransaction = transaction;

    _saveProducts();
    _saveTransactions();
    _cart.clear();

    notifyListeners();
    return transaction;
  }

  // Inventory Actions
  void quickRestock(String productId, int addAmount) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _products[index].stock += addAmount;
      _saveProducts();
      notifyListeners();
    }
  }

  void addProduct(Product newProduct) {
    _products.add(newProduct);
    _saveProducts();
    notifyListeners();
  }

  void updateProduct(Product updatedProduct) {
    final index = _products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      _products[index] = updatedProduct;
      _saveProducts();
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    _saveProducts();
    notifyListeners();
  }

  // Analytics Helpers
  void setAnalyticsTimeFilter(String filter) {
    _analyticsTimeFilter = filter;
    notifyListeners();
  }

  List<PosTransaction> get filteredTransactions {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    if (_analyticsTimeFilter == 'Hari Ini') {
      return _transactions
          .where((t) => t.timestamp.isAfter(todayStart))
          .toList();
    } else if (_analyticsTimeFilter == '7 Hari') {
      final sevenDaysAgo = todayStart.subtract(const Duration(days: 7));
      return _transactions
          .where((t) => t.timestamp.isAfter(sevenDaysAgo))
          .toList();
    } else if (_analyticsTimeFilter == 'Bulan Ini') {
      final startOfMonth = DateTime(now.year, now.month, 1);
      return _transactions
          .where((t) => t.timestamp.isAfter(startOfMonth))
          .toList();
    }
    return _transactions;
  }

  double get analyticsTotalOmset =>
      filteredTransactions.fold(0.0, (sum, t) => sum + t.totalAmount);

  double get analyticsTotalCost =>
      filteredTransactions.fold(0.0, (sum, t) => sum + t.totalCost);

  double get analyticsNetProfit => analyticsTotalOmset - analyticsTotalCost;

  double get analyticsProfitMargin => analyticsTotalOmset > 0
      ? (analyticsNetProfit / analyticsTotalOmset) * 100
      : 0;

  double get analyticsAOV => filteredTransactions.isNotEmpty
      ? analyticsTotalOmset / filteredTransactions.length
      : 0;

  int get analyticsTotalTransactions => filteredTransactions.length;

  Map<String, double> get paymentDistribution {
    double tunai = 0;
    double qris = 0;
    double transfer = 0;

    for (final t in filteredTransactions) {
      if (t.paymentMethod == 'Tunai') {
        tunai += t.totalAmount;
      } else if (t.paymentMethod == 'QRIS') {
        qris += t.totalAmount;
      } else if (t.paymentMethod == 'Transfer') {
        transfer += t.totalAmount;
      }
    }

    final total = tunai + qris + transfer;
    if (total == 0) {
      return {'Tunai': 65.0, 'QRIS': 28.0, 'Transfer': 7.0};
    }
    return {
      'Tunai': (tunai / total) * 100,
      'QRIS': (qris / total) * 100,
      'Transfer': (transfer / total) * 100,
    };
  }

  List<Map<String, dynamic>> get topSellingProducts {
    final Map<String, int> qtyMap = {};
    final Map<String, double> revMap = {};
    final Map<String, Product> prodMap = {};

    for (final t in filteredTransactions) {
      for (final item in t.items) {
        qtyMap[item.product.id] =
            (qtyMap[item.product.id] ?? 0) + item.quantity;
        revMap[item.product.id] =
            (revMap[item.product.id] ?? 0) + item.subtotal;
        prodMap[item.product.id] = item.product;
      }
    }

    final list = qtyMap.entries.map((entry) {
      final p = prodMap[entry.key]!;
      return {
        'product': p,
        'quantity': entry.value,
        'revenue': revMap[entry.key] ?? 0.0,
      };
    }).toList();

    list.sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));
    return list;
  }

  // Mini Dashboard metrics for Kasir screen (Hari ini)
  double get todayOmset {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _transactions
        .where((t) => t.timestamp.isAfter(todayStart))
        .fold(0.0, (sum, t) => sum + t.totalAmount);
  }

  int get todayTransactionCount {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _transactions
        .where((t) => t.timestamp.isAfter(todayStart))
        .length;
  }
}

