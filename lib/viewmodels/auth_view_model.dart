import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/login_model.dart';
import '../models/register_model.dart';
import '../utils/urls.dart';
import '../utils/cache_helper.dart';
import '../viewmodels/drawer_menu_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import '../viewmodels/orders_viewmodel.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Initialize auth state from cache
  Future<void> initializeAuth(BuildContext context) async {
    try {
      final token = CacheHelper.getString('token');
      final isLoggedIn = CacheHelper.getBool('isLoggedIn') ?? false;
      final firstName = CacheHelper.getString('firstName');
      final lastName = CacheHelper.getString('lastName');
      final email = CacheHelper.getString('email');
      final userId = CacheHelper.getInt('userId');

      if (isLoggedIn && token != null && token.isNotEmpty) {
        _currentUser = User(
          id: userId,
          firstName: firstName,
          lastName: lastName,
          email: email,
        );

        // Update drawer menu state
        if (context.mounted) {
          Provider.of<DrawerMenuViewModel>(context, listen: false).login(
            firstName ?? '',
            lastName ?? '',
          );

          // Load user-specific data
          await _loadUserData(context);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error initializing auth: $e');
      await logout(context);
    }
  }

  Future<void> login(String email, String password, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://cartverse-data.onrender.com/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: convert.jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final loginModel = LoginModel.fromJson(convert.jsonDecode(response.body));
        _currentUser = loginModel.user;
        await _saveLoginData(loginModel, context);
        await _loadUserData(context);
        await _showLoginSuccessDialog(context, loginModel.user?.firstName);
      } else if (response.statusCode == 401) {
        _errorMessage = 'Invalid email or password';
        _showSnackBar(context, _errorMessage!, Colors.red);
      } else {
        final errorData = convert.jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Login failed. Please try again.';
        _showSnackBar(context, _errorMessage!, Colors.red);
      }
    } on http.ClientException catch (e) {
      _errorMessage = 'Network error. Please check your connection.';
      _showSnackBar(context, _errorMessage!, Colors.red);
    } catch (e) {
      print('Login Error: $e');
      _errorMessage = 'Login failed. Please try again.';
      _showSnackBar(context, _errorMessage!, Colors.red);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> _saveLoginData(LoginModel loginModel, BuildContext context) async {
    try {
      await Future.wait([
        CacheHelper.setString('token', loginModel.accessToken ?? ''),
        CacheHelper.setString('firstName', loginModel.user?.firstName ?? ''),
        CacheHelper.setString('lastName', loginModel.user?.lastName ?? ''),
        CacheHelper.setString('email', loginModel.user?.email ?? ''),
        CacheHelper.setInt('userId', loginModel.user?.id ?? 0),
        CacheHelper.setBool('isLoggedIn', true),
      ]);

      // Update drawer menu state
      if (context.mounted) {
        Provider.of<DrawerMenuViewModel>(context, listen: false).login(
          loginModel.user?.firstName ?? '',
          loginModel.user?.lastName ?? '',
        );
      }
    } catch (e) {
      throw Exception('Failed to save login data: $e');
    }
  }

  Future<void> register(
      String firstName,
      String lastName,
      String email,
      String password,
      BuildContext context,
      ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://cartverse-data.onrender.com/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: convert.jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Success case
        _showSnackBar(context, 'Registration successful! Please login.', Colors.green);
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else if (response.statusCode == 409) {
        // Email already exists case
        final errorData = convert.jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Email is already registered.';
        _showSnackBar(context, _errorMessage!, Colors.red);
      } else {
        // Other error cases
        try {
          final errorData = convert.jsonDecode(response.body);
          _errorMessage = errorData['message'] ?? 'Registration failed. Please try again.';
        } catch (e) {
          _errorMessage = 'Registration failed (${response.statusCode}). Please try again.';
        }
        _showSnackBar(context, _errorMessage!, Colors.red);
      }
    } on http.ClientException catch (e) {
      _errorMessage = 'Network error. Please check your connection.';
      _showSnackBar(context, _errorMessage!, Colors.red);
    } catch (e) {
      print('Registration Error: $e');
      _errorMessage = 'Registration failed. Please try again.';
      _showSnackBar(context, _errorMessage!, Colors.red);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      // Clear local data
      if (context.mounted) {
        Provider.of<CartViewModel>(context, listen: false).clearCart();
        Provider.of<WishlistViewModel>(context, listen: false).clearWishlist();
        Provider.of<OrdersViewModel>(context, listen: false).clearOrders();
        Provider.of<DrawerMenuViewModel>(context, listen: false).logout();
      }

      // Clear cache
      await CacheHelper.clear();

      _currentUser = null;
      _errorMessage = null;
      notifyListeners();

      // Navigate to home
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      print('Logout Error: $e');
    }
  }

  Future<void> _loadUserData(BuildContext context) async {
    if (_currentUser?.id == null || !context.mounted) return;

    try {
      // Load user orders and wishlist
      await Future.wait([
        Provider.of<OrdersViewModel>(context, listen: false).loadUserOrders(_currentUser!.id!),
        Provider.of<WishlistViewModel>(context, listen: false).loadUserWishlist(_currentUser!.id!),
      ]);
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _showLoginSuccessDialog(BuildContext context, String? firstName) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Login Successful'),
        content: Text('Welcome back, ${firstName ?? 'User'}!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // Navigate to home
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color bgColor) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: bgColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}