import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class OrdersViewModel extends ChangeNotifier {
  final List<Order> _orders = [];
  int _nextOrderNumber = 1;

  List<Order> get orders => _orders;

  void addOrder(List<CartItem> items, double totalPrice) {
    final order = Order(
      orderNumber: _nextOrderNumber++,
      items: List.from(items), // Create a copy of the items
      totalPrice: totalPrice,
      orderDate: DateTime.now(),
    );

    _orders.insert(0, order); // Add new orders at the beginning
    notifyListeners();
  }

  Order? getOrder(int orderNumber) {
    try {
      return _orders.firstWhere((order) => order.orderNumber == orderNumber);
    } catch (e) {
      return null;
    }
  }
}