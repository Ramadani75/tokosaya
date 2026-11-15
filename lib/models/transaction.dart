import 'cart_item.dart';

class PosTransaction {
  final String id;
  final String invoiceNumber;
  final DateTime timestamp;
  final String cashierName;
  final List<CartItem> items;
  final double subtotal;
  final double plasticFee;
  final double totalAmount;
  final String paymentMethod; // 'Tunai' | 'QRIS' | 'Transfer'
  final double cashPaid;
  final double changeAmount;
  final double totalCost;

  PosTransaction({
    required this.id,
    required this.invoiceNumber,
    required this.timestamp,
    required this.cashierName,
    required this.items,
    required this.subtotal,
    this.plasticFee = 500,
    required this.totalAmount,
    required this.paymentMethod,
    required this.cashPaid,
    required this.changeAmount,
    required this.totalCost,
  });

  double get profit => totalAmount - totalCost - plasticFee;
  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toJson() => {
    'id': id,
    'invoiceNumber': invoiceNumber,
    'timestamp': timestamp.toIso8601String(),
    'cashierName': cashierName,
    'items': items.map((e) => e.toJson()).toList(),
    'subtotal': subtotal,
    'plasticFee': plasticFee,
    'totalAmount': totalAmount,
    'paymentMethod': paymentMethod,
    'cashPaid': cashPaid,
    'changeAmount': changeAmount,
    'totalCost': totalCost,
  };

  factory PosTransaction.fromJson(Map<String, dynamic> json) => PosTransaction(
    id: json['id'] as String,
    invoiceNumber: json['invoiceNumber'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    cashierName: json['cashierName'] as String,
    items: (json['items'] as List<dynamic>)
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    subtotal: (json['subtotal'] as num).toDouble(),
    plasticFee: (json['plasticFee'] as num?)?.toDouble() ?? 500,
    totalAmount: (json['totalAmount'] as num).toDouble(),
    paymentMethod: json['paymentMethod'] as String,
    cashPaid: (json['cashPaid'] as num).toDouble(),
    changeAmount: (json['changeAmount'] as num).toDouble(),
    totalCost: (json['totalCost'] as num).toDouble(),
  );
}

