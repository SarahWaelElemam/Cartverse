class DrawerMenuItem {
  final String titleKey; // Now stores the translation key, not plain text!
  final String route;
  final bool isButton;
  final bool isPrimary;

  DrawerMenuItem({
    required this.titleKey,
    required this.route,
    this.isButton = false,
    this.isPrimary = false,
  });
}

class DrawerMenuData {
  static List<DrawerMenuItem> getMenuItems() {
    return [
      DrawerMenuItem(titleKey: 'categories', route: '/categories'),
      DrawerMenuItem(titleKey: 'about', route: '/about'),
      DrawerMenuItem(titleKey: 'contact', route: '/contact'),
      DrawerMenuItem(titleKey: 'login', route: '/login', isButton: true),
      DrawerMenuItem(titleKey: 'register', route: '/register', isButton: true, isPrimary: true),
    ];
  }
}