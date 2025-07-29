import 'dart:convert' as convert;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../utils/urls.dart';
import '../utils/cache_helper.dart';

class OrdersViewModel extends ChangeNotifier {
  final List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load user orders from server
  Future<void> loadUserOrders(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = CacheHelper.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.https(Api.baseUrl, '/orders', {'userId': userId.toString()}),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print('Load Orders Response Status: ${response.statusCode}');
      print('Load Orders Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = convert.jsonDecode(response.body);
        _orders.clear();

        if (data is List) {
          for (var orderJson in data) {
            try {
              // Ensure items are properly parsed
              if (orderJson['items'] != null) {
                final items = <CartItem>[];
                for (var itemJson in orderJson['items']) {
                  try {
                    final item = CartItem.fromJson(itemJson);
                    items.add(item);
                  } catch (e) {
                    print('Error parsing item: $e');
                    print('Item JSON: $itemJson');
                  }
                }

                // Create order with parsed items
                final order = Order(
                  id: orderJson['id']?.toString(),
                  orderNumber: orderJson['orderNumber'] ?? 0,
                  userId: orderJson['userId'],
                  items: items,
                  totalPrice: (orderJson['totalPrice'] is String)
                      ? double.tryParse(orderJson['totalPrice']) ?? 0.0
                      : (orderJson['totalPrice']?.toDouble() ?? 0.0),
                  orderDate: orderJson['orderDate'] != null
                      ? DateTime.parse(orderJson['orderDate'])
                      : DateTime.now(),
                );
                _orders.add(order);
              } else {
                // Fallback to Order.fromJson if items structure is different
                final order = Order.fromJson(orderJson);
                _orders.add(order);
              }
            } catch (e) {
              print('Error parsing order: $e');
              print('Order JSON: $orderJson');
            }
          }
        }

        // Sort orders by date (newest first)
        _orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      } else if (response.statusCode == 404) {
        // No orders found - this is ok
        _orders.clear();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading user orders: $e');
      _errorMessage = 'Failed to load orders: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new order and sync with server
  Future<bool> addOrder(List<CartItem> items, double totalPrice) async {
    final userId = CacheHelper.getInt('userId');
    final token = CacheHelper.getString('token');

    if (userId == null || token == null || token.isEmpty) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create order data with properly serialized items
      final orderData = {
        'userId': userId,
        'items': items.map((item) => item.toJson()).toList(),
        'totalPrice': totalPrice,
        'orderDate': DateTime.now().toIso8601String(),
      };

      print('Sending order data: ${convert.jsonEncode(orderData)}');

      final response = await http.post(
        Uri.https(Api.baseUrl, '/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: convert.jsonEncode(orderData),
      ).timeout(const Duration(seconds: 30));

      print('Add Order Response Status: ${response.statusCode}');
      print('Add Order Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = convert.jsonDecode(response.body);

        // Create local order object with the actual items
        final order = Order(
          id: responseData['id']?.toString(),
          orderNumber: responseData['orderNumber'] ?? _getNextOrderNumber(),
          userId: userId,
          items: List<CartItem>.from(items), // Create a copy of the items
          totalPrice: totalPrice,
          orderDate: DateTime.now(),
        );

        _orders.insert(0, order); // Add new orders at the beginning

        // Force a reload from server to ensure consistency
        Future.delayed(const Duration(seconds: 1), () {
          loadUserOrders(userId);
        });

        notifyListeners();
        return true;
      } else {
        final errorData = convert.jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to create order';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error adding order: $e');
      _errorMessage = 'Failed to create order: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Order? getOrder(int orderNumber) {
    try {
      return _orders.firstWhere((order) => order.orderNumber == orderNumber);
    } catch (e) {
      return null;
    }
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearOrders() {
    _orders.clear();
    _errorMessage = null;
    notifyListeners();
  }

  int _getNextOrderNumber() {
    if (_orders.isEmpty) return 1;
    return _orders.map((o) => o.orderNumber).reduce((a, b) => a > b ? a : b) + 1;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Add method to refresh orders
  Future<void> refreshOrders() async {
    final userId = CacheHelper.getInt('userId');
    if (userId != null) {
      await loadUserOrders(userId);
    }
  }
}