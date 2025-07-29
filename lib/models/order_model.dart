// Updated Order Model
import '../models/cart_item_model.dart';

class Order {
  final String? id;
  final int orderNumber;
  final int? userId;
  final List<CartItem> items;
  final double totalPrice;
  final DateTime orderDate;

  Order({
    this.id,
    required this.orderNumber,
    this.userId,
    required this.items,
    required this.totalPrice,
    required this.orderDate,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString(),
      orderNumber: json['orderNumber'] ?? 0,
      userId: json['userId'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalPrice: (json['totalPrice'] is String)
          ? double.tryParse(json['totalPrice']) ?? 0.0
          : (json['totalPrice']?.toDouble() ?? 0.0),
      orderDate: json['orderDate'] != null
          ? DateTime.parse(json['orderDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'orderDate': orderDate.toIso8601String(),
    };
  }
}