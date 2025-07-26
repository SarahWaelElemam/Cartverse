import 'package:flutter/material.dart';
import 'package:fedis/views/home_screen.dart';
import 'package:fedis/views/login_screen.dart';
import 'package:fedis/views/register_screen.dart';
import 'package:fedis/views/about_screen.dart';
import 'package:fedis/views/categories_screen.dart';
import 'package:fedis/views/products_screen.dart';
import 'package:fedis/views/contact_screen.dart';
import 'package:fedis/views/cart_screen.dart';
import 'package:fedis/views/profile_screen.dart';
import 'package:fedis/views/orders_screen.dart';
import 'package:fedis/views/wishlist_screen.dart';
import 'routes.dart';

class CustomRouter {
  static Route<dynamic> allRoutes(RouteSettings settings) {
    try {
      switch (settings.name) {
        case homeScreen:
          return MaterialPageRoute(builder: (_) => const HomeScreen());
        case loginScreen:
          return MaterialPageRoute(builder: (_) =>  LoginScreen());
        case registerScreen:
          return MaterialPageRoute(builder: (_) => const RegisterScreen());
        case aboutScreen:
          return MaterialPageRoute(builder: (_) => const AboutScreen());
        case categoriesScreen:
          return MaterialPageRoute(builder: (_) => const CategoriesScreen());
        case '/contact':
          return MaterialPageRoute(builder: (_) => const ContactScreen());
        case '/cart':
          return MaterialPageRoute(builder: (_) => const CartScreen());
        case '/profile':
          return MaterialPageRoute(builder: (_) => const ProfileScreen());
        case '/orders':
          return MaterialPageRoute(builder: (_) => const OrdersScreen());
        case '/wishlist':
          return MaterialPageRoute(builder: (_) => const WishlistScreen());
        case productsScreen:
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          return MaterialPageRoute(
            builder: (_) => ProductsScreen(category: args['category'] ?? ''),
          );
        default:
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                child: Text('Route ${settings.name} not found'),
              ),
            ),
          );
      }
    } catch (e) {
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('Error loading route: $e'),
          ),
        ),
      );
    }
  }
}