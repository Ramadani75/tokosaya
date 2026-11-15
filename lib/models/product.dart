class Product {
  final String id;
  final String name;
  final String barcode;
  final String category;
  final String unit;
  final double costPrice; // HPP
  final double sellPrice;
  int stock;
  final int minStockAlert;
  final String imageUrl;
  final String supplier;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.category,
    required this.unit,
    required this.costPrice,
    required this.sellPrice,
    required this.stock,
    this.minStockAlert = 5,
    required this.imageUrl,
    this.supplier = 'Distributor Utama',
  });

  double get profitPerUnit => sellPrice - costPrice;

  double get marginPercent => sellPrice > 0 ? (profitPerUnit / sellPrice) * 100 : 0;

  bool get isCriticalStock => stock <= minStockAlert;

  Product copyWith({
    String? id,
    String? name,
    String? barcode,
    String? category,
    String? unit,
    double? costPrice,
    double? sellPrice,
    int? stock,
    int? minStockAlert,
    String? imageUrl,
    String? supplier,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      costPrice: costPrice ?? this.costPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      stock: stock ?? this.stock,
      minStockAlert: minStockAlert ?? this.minStockAlert,
      imageUrl: imageUrl ?? this.imageUrl,
      supplier: supplier ?? this.supplier,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'barcode': barcode,
    'category': category,
    'unit': unit,
    'costPrice': costPrice,
    'sellPrice': sellPrice,
    'stock': stock,
    'minStockAlert': minStockAlert,
    'imageUrl': imageUrl,
    'supplier': supplier,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    barcode: json['barcode'] as String,
    category: json['category'] as String,
    unit: json['unit'] as String,
    costPrice: (json['costPrice'] as num).toDouble(),
    sellPrice: (json['sellPrice'] as num).toDouble(),
    stock: (json['stock'] as num).toInt(),
    minStockAlert: (json['minStockAlert'] as num?)?.toInt() ?? 5,
    imageUrl: json['imageUrl'] as String? ?? '',
    supplier: json['supplier'] as String? ?? 'Distributor Utama',
  );
}

