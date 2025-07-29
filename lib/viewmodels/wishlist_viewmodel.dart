import 'dart:convert' as convert;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/wishlist_item_model.dart';
import '../utils/urls.dart';
import '../utils/cache_helper.dart';
import 'package:easy_localization/easy_localization.dart';
class WishlistViewModel extends ChangeNotifier {
  final List<WishlistItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<WishlistItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load user wishlist from server
  Future<void> loadUserWishlist(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = CacheHelper.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.https(Api.baseUrl, '/wishlist', {'userId': userId.toString()}),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print('Load Wishlist Response Status: ${response.statusCode}');
      print('Load Wishlist Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = convert.jsonDecode(response.body);
        _items.clear();

        if (data is List) {
          for (var itemJson in data) {
            try {
              final item = WishlistItem.fromJson(itemJson);
              _items.add(item);
            } catch (e) {
              print('Error parsing wishlist item: $e');
            }
          }
        }
      } else if (response.statusCode == 404) {
        // No wishlist items found - this is ok
        _items.clear();
      } else {
        throw Exception('Failed to load wishlist: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading user wishlist: $e');
      _errorMessage = 'Failed to load wishlist: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add item to wishlist and sync with server
  Future<bool> addItem(WishlistItem item) async {
    final userId = CacheHelper.getInt('userId');
    final token = CacheHelper.getString('token');

    if (userId == null || token == null || token.isEmpty) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    // Check if item already exists in wishlist using titleKey
    final index = _items.indexWhere((e) =>
    (e.titleKey != null && item.titleKey != null && e.titleKey == item.titleKey) &&
        e.imageUrl == item.imageUrl);
    if (index != -1) {
      return true; // Item already in wishlist
    }

    try {
      final itemData = {
        'userId': userId,
        'name': item.name,
        'titleKey': item.titleKey, // Add this line
        'price': item.price,
        'imageUrl': item.imageUrl,
        'stock': item.stock,
      };

      final response = await http.post(
        Uri.https(Api.baseUrl, '/wishlist'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: convert.jsonEncode(itemData),
      ).timeout(const Duration(seconds: 30));

      print('Add Wishlist Item Response Status: ${response.statusCode}');
      print('Add Wishlist Item Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        _items.add(item);
        notifyListeners();
        return true;
      } else {
        final errorData = convert.jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to add item to wishlist';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error adding item to wishlist: $e');
      _errorMessage = 'Failed to add item to wishlist: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Remove item from wishlist and sync with server
  Future<bool> removeItem(WishlistItem item) async {
    final userId = CacheHelper.getInt('userId');
    final token = CacheHelper.getString('token');

    if (userId == null || token == null || token.isEmpty) {
      _errorMessage = 'login_required'.tr();
      notifyListeners();
      return false;
    }

    if (item.id == null || item.id!.isEmpty) {
      _errorMessage = 'product_removed'.tr();
      notifyListeners();
      return false;
    }

    try {
      final response = await http.delete(
        Uri.https(Api.baseUrl, '/wishlist/${item.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print('Remove Wishlist Item Response Status: ${response.statusCode}');
      print('Remove Wishlist Item Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        _items.removeWhere((e) => e.id == item.id);
        notifyListeners();

        // Show success message
        _errorMessage = 'item_removed_from_wishlist'.tr();
        notifyListeners();
        return true;
      } else if (response.statusCode == 404) {
        _errorMessage = 'product_removed'.tr();
        _items.removeWhere((e) => e.id == item.id);
        notifyListeners();
        return true; // Item was already removed
      } else {
        final errorData = convert.jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to remove item from wishlist';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error removing item from wishlist: $e');
      _errorMessage = 'Failed to remove item from wishlist: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }
  // Updated to use titleKey for comparison
  bool isInWishlist(String titleKey, String imageUrl) {
    return _items.any((item) => item.titleKey == titleKey && item.imageUrl == imageUrl);
  }

  void clearWishlist() {
    _items.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void toggleWishlist(WishlistItem item) {
    if (_items.any((i) => i == item)) {
      _items.removeWhere((i) => i == item);
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}