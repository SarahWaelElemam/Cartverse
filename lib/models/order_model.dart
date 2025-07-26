import '../models/cart_item_model.dart';

class Order {
  final int orderNumber;
  final List<CartItem> items;
  final double totalPrice;
  final DateTime orderDate;

  Order({
    required this.orderNumber,
    required this.items,
    required this.totalPrice,
    required this.orderDate,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}