import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/drawer_menu_viewmodel.dart';
import '../../viewmodels/dark_mode.dart';
import '../../models/drawer_menu_item.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DrawerMenuViewModel, DarkModeProvider>(
      builder: (context, menuVM, darkVM, child) {
        final isDark = darkVM.isDarkMode;
        final bgColor = isDark ? Colors.black : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;
        final subTextColor = isDark ? Colors.white70 : Colors.black54;

        return Drawer(
          backgroundColor: bgColor,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: () {
                          menuVM.navigateToPage('/', context);
                        },
                        child: Text(
                          'CARTVERSE',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(
                          Icons.close,
                          color: textColor,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    children: [
                      ...menuVM.menuItems
                          .where((item) => !item.isButton)
                          .map((item) => _buildMenuItem(item, menuVM, context, subTextColor)),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: subTextColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          Icons.favorite_border,
                          color: subTextColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // AUTH AREA
                      menuVM.isLoggedIn
                          ? _buildUserDropdown(context, menuVM, textColor)
                          : Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => menuVM.navigateToPage('/login', context),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.orange),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => menuVM.navigateToPage('/register', context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.network(
                                  'https://cdn.jsdelivr.net/gh/lipis/flag-icons/flags/4x3/us.svg',
                                  width: 20,
                                  height: 15,
                                  errorBuilder: (c, e, st) => Container(
                                    width: 20,
                                    height: 15,
                                    color: Colors.blue,
                                    child: const Icon(
                                      Icons.flag,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                DropdownButton<String>(
                                  value: menuVM.selectedLanguage,
                                  underline: const SizedBox(),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: subTextColor,
                                    size: 16,
                                  ),
                                  dropdownColor: bgColor,
                                  items: ['English', 'Arabic'].map((String lang) {
                                    return DropdownMenuItem<String>(
                                      value: lang,
                                      child: Text(
                                        lang,
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newLang) {
                                    if (newLang != null) {
                                      menuVM.changeLanguage(newLang);
                                    }
                                  },
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: darkVM.toggleDarkMode,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  isDark ? Icons.light_mode : Icons.dark_mode,
                                  color: subTextColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(
      DrawerMenuItem item,
      DrawerMenuViewModel menuVM,
      BuildContext context,
      Color textColor,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          item.title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        onTap: () => menuVM.navigateToPage(item.route, context),
      ),
    );
  }

  // User dropdown for logged-in user
  Widget _buildUserDropdown(BuildContext context, DrawerMenuViewModel menuVM, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: PopupMenuButton<int>(
        offset: const Offset(0, 40),
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Icon(Icons.account_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Welcome, ${menuVM.fullName}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ],
          ),
        ),
        onSelected: (value) async {
          if (value == 1) {
            menuVM.navigateToPage('/profile', context);
          } else if (value == 2) {
            menuVM.navigateToPage('/orders', context);
          } else if (value == 3) {
            await menuVM.logout();
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Row(
              children: const [
                Icon(Icons.person, size: 20),
                SizedBox(width: 8),
                Text('Profile'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Row(
              children: const [
                Icon(Icons.list_alt, size: 20),
                SizedBox(width: 8),
                Text('Orders'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 3,
            child: Row(
              children: const [
                Icon(Icons.logout, size: 20),
                SizedBox(width: 8),
                Text('Logout'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}