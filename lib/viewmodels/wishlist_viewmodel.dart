import 'package:flutter/foundation.dart';
import '../models/wishlist_item_model.dart';

class WishlistViewModel extends ChangeNotifier {
  final List<WishlistItem> _items = [];

  List<WishlistItem> get items => _items;

  void addItem(WishlistItem item) {
    // Check if item already exists in wishlist
    final index = _items.indexWhere((e) => e.name == item.name && e.imageUrl == item.imageUrl);
    if (index == -1) {
      _items.add(item);
      notifyListeners();
    }
  }

  void removeItem(WishlistItem item) {
    _items.remove(item);
    notifyListeners();
  }

  bool isInWishlist(String name, String imageUrl) {
    return _items.any((item) => item.name == name && item.imageUrl == imageUrl);
  }

  void clearWishlist() {
    _items.clear();
    notifyListeners();
  }

  void toggleWishlist(WishlistItem item) {
    if (isInWishlist(item.name, item.imageUrl)) {
      removeItem(item);
    } else {
      addItem(item);
    }
  }
}