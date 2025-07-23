import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/login_model.dart';
import '../models/register_model.dart';
import '../utils/urls.dart';
import '../utils/cache_helper.dart';
import '../viewmodels/drawer_menu_viewmodel.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password, BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.https(Api.baseUrl, '/login'),
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
        try {
          final data = convert.jsonDecode(response.body);
          print('Parsed Login Data: $data');

          if (data == null || data is! Map<String, dynamic>) {
            throw Exception('Invalid response format');
          }

          if (data['user'] == null) {
            throw Exception('User data not found in response');
          }

          final loginModel = LoginModel.fromJson(data);
          await _saveLoginData(loginModel, context);

          // Show success dialog and navigate after user closes it
          await _showLoginSuccessDialog(context, loginModel.user?.firstName);
        } catch (parseError) {
          print('JSON Parse Error: $parseError');
          _errorMessage = 'Failed to process server response';
          _showSnackBar(context, _errorMessage!, Colors.red);
        }
      } else {
        try {
          final errorData = convert.jsonDecode(response.body);
          _errorMessage = errorData['message'] ?? 'Login failed with status: ${response.statusCode}';
        } catch (e) {
          _errorMessage = 'Login failed with status: ${response.statusCode}';
        }
        _showSnackBar(context, _errorMessage!, Colors.red);
      }
    } on http.ClientException catch (e) {
      _errorMessage = 'Network error: ${e.message}';
      _showSnackBar(context, _errorMessage!, Colors.red);
    } catch (e) {
      print('Login Error: $e');
      _errorMessage = 'Login failed: ${e.toString()}';
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
      var response = await http.post(
        Uri.https(Api.baseUrl, '/register'),
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

      // Handle redirect responses
      if (response.statusCode == 307 || response.statusCode == 308) {
        final redirectUrl = response.headers['location'];
        if (redirectUrl != null) {
          response = await http.post(
            Uri.parse(redirectUrl),
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
          );
        }
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = convert.jsonDecode(response.body);
        RegisterModel.fromJson(data); // Validate response

        _showSnackBar(context, 'Registration successful! Please login with your credentials.', Colors.green);

        // Navigate to login screen after successful registration
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        final errorData = convert.jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Registration failed';
        _showSnackBar(context, _errorMessage!, Colors.red);
      }
    } on http.ClientException catch (e) {
      _errorMessage = 'Network error: ${e.message}';
      _showSnackBar(context, _errorMessage!, Colors.red);
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
      _showSnackBar(context, _errorMessage!, Colors.red);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _showLoginSuccessDialog(BuildContext context, String? firstName) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Login Successful'),
        content: Text('Welcome, ${firstName ?? 'User'}!'),
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
}