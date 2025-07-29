import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';

class CartViewModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  // Track stock for each product (titleKey -> available stock)
  final Map<String, int> _productStock = {};

  List<CartItem> get items => _items;

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // Initialize stock for products
  void initializeStock(Map<String, int> initialStock) {
    _productStock.clear();
    _productStock.addAll(initialStock);
    notifyListeners();
  }

  // Get available stock for a product
  int getAvailableStock(String titleKey) {
    return _productStock[titleKey] ?? 0;
  }

  // Get current quantity in cart for a product
  int getCurrentCartQuantity(String titleKey, String imageUrl) {
    final item = getCartItem(titleKey, imageUrl);
    return item?.quantity ?? 0;
  }

  // Get maximum quantity that can be added (stock - current cart quantity)
  int getMaxAddableQuantity(String titleKey, String imageUrl) {
    final availableStock = getAvailableStock(titleKey);
    final currentInCart = getCurrentCartQuantity(titleKey, imageUrl);
    return (availableStock - currentInCart).clamp(0, availableStock);
  }

  // Check if we can add more of this item
  bool canAddItem(String titleKey, String imageUrl) {
    return getMaxAddableQuantity(titleKey, imageUrl) > 0;
  }

  void addItem(CartItem item) {
    if (item.titleKey == null) return;

    // Check if we can add this item
    if (!canAddItem(item.titleKey!, item.imageUrl)) {
      return; // Cannot add more items
    }

    // If the item already exists, just increment its quantity
    final index = _items.indexWhere((e) =>
    (e.titleKey != null && item.titleKey != null && e.titleKey == item.titleKey) &&
        e.imageUrl == item.imageUrl);

    if (index != -1) {
      final newQuantity = _items[index].quantity + 1;
      final maxAllowed = getAvailableStock(item.titleKey!);

      if (newQuantity <= maxAllowed) {
        _items[index] = _items[index].copyWith(quantity: newQuantity);
      }
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void updateQuantity(CartItem item, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(item);
      return;
    }

    if (item.titleKey == null) return;

    // Check if new quantity exceeds available stock
    final maxAllowed = getAvailableStock(item.titleKey!);
    final clampedQuantity = newQuantity.clamp(1, maxAllowed);

    final index = _items.indexOf(item);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: clampedQuantity);
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Reduce stock when order is placed
  void reduceStock(List<CartItem> orderItems) {
    for (final item in orderItems) {
      if (item.titleKey != null) {
        final currentStock = _productStock[item.titleKey!] ?? 0;
        _productStock[item.titleKey!] = (currentStock - item.quantity).clamp(0, currentStock);
      }
    }

    // Remove items from cart if they exceed new stock limits
    _items.removeWhere((cartItem) {
      if (cartItem.titleKey == null) return false;
      final availableStock = getAvailableStock(cartItem.titleKey!);
      return cartItem.quantity > availableStock;
    });

    // Update quantities for remaining items if they exceed new stock limits
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.titleKey != null) {
        final availableStock = getAvailableStock(item.titleKey!);
        if (item.quantity > availableStock) {
          _items[i] = item.copyWith(quantity: availableStock.clamp(0, item.quantity));
        }
      }
    }

    notifyListeners();
  }

  // Updated to use titleKey for comparison
  bool isInCart(String titleKey, String imageUrl) {
    return _items.any((item) => item.titleKey == titleKey && item.imageUrl == imageUrl);
  }

  // Updated to use titleKey for comparison
  CartItem? getCartItem(String titleKey, String imageUrl) {
    try {
      return _items.firstWhere((item) => item.titleKey == titleKey && item.imageUrl == imageUrl);
    } catch (e) {
      return null;
    }
  }
}