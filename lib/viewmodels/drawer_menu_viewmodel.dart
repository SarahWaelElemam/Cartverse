import 'package:flutter/material.dart';
import '../models/drawer_menu_item.dart';
import '../utils/cache_helper.dart';

class DrawerMenuViewModel extends ChangeNotifier {
  bool _isMenuOpen = false;
  String _selectedLanguage = 'English';
  Locale _currentLocale = const Locale('en');
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  bool _isLoggedIn = false;

  Future<void> initialize() async {
    _isLoggedIn = CacheHelper.getBool('isLoggedIn') ?? false;
    _firstName = CacheHelper.getString('firstName') ?? '';
    _lastName = CacheHelper.getString('lastName') ?? '';
    _email = CacheHelper.getString('email') ?? 'sarah@gmail.com'; // Default email
    await loadSavedLanguage();
    notifyListeners();
  }

  Future<void> loadSavedLanguage() async {
    try {
      final savedLang = CacheHelper.getString("language") ?? 'en';
      _selectedLanguage = savedLang == 'ar' ? 'Arabic' : 'English';
      _currentLocale = Locale(savedLang);
      notifyListeners();
    } catch (e) {
      _currentLocale = const Locale('en');
      notifyListeners();
    }
  }

  bool get isLoggedIn => _isLoggedIn;
  String get fullName => '$_firstName $_lastName'.trim();
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get selectedLanguage => _selectedLanguage;
  Locale get currentLocale => _currentLocale;
  List<DrawerMenuItem> get menuItems => DrawerMenuData.getMenuItems();

  void changeLanguage(String language) {
    _selectedLanguage = language;
    _currentLocale = language == 'Arabic' ? const Locale('ar') : const Locale('en');
    CacheHelper.setString('language', language == 'Arabic' ? 'ar' : 'en');
    notifyListeners();
  }

  void login(String firstName, String lastName, [String? email]) {
    _isLoggedIn = true;
    _firstName = firstName;
    _lastName = lastName;
    _email = email ?? 'sarah@gmail.com';
    CacheHelper.setBool('isLoggedIn', true);
    CacheHelper.setString('firstName', firstName);
    CacheHelper.setString('lastName', lastName);
    CacheHelper.setString('email', _email);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _firstName = '';
    _lastName = '';
    _email = '';
    await CacheHelper.clear();
    notifyListeners();
  }

  void navigateToPage(String route, BuildContext context) {
    Navigator.of(context).pushNamed(route);
  }
}