// File: lib/models/drawer_menu_item.dart
// Folder: models

class DrawerMenuItem {
  final String title;
  final String route;
  final bool isButton;
  final bool isPrimary;

  DrawerMenuItem({
    required this.title,
    required this.route,
    this.isButton = false,
    this.isPrimary = false,
  });
}

class DrawerMenuData {
  static List<DrawerMenuItem> getMenuItems() {
    return [
      DrawerMenuItem(title: 'Categories', route: '/categories'),
      DrawerMenuItem(title: 'About', route: '/about'),
      DrawerMenuItem(title: 'Contact', route: '/contact'),
      DrawerMenuItem(title: 'Login', route: '/login', isButton: true),
      DrawerMenuItem(title: 'Register', route: '/register', isButton: true, isPrimary: true),
    ];
  }
}