import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fedis/viewmodels/drawer_menu_viewmodel.dart';
import 'widgets/custom_drawer.dart';
import 'widgets/custom_footer.dart';
import 'orders_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedIndex = 0; // 0 for Account Info, 1 for Orders

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text('profile'.tr()),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
        ),
        titleTextStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        elevation: 0,
      ),
      body: Consumer<DrawerMenuViewModel>(
        builder: (context, drawerViewModel, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Card(
                    elevation: 0,
                    color: const Color(0xFFF5F5DC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double availableWidth = constraints.maxWidth;
                          double sidebarWidth = availableWidth < 400 ? 100 : 120;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: sidebarWidth,
                                child: Column(
                                  children: [
                                    _buildSidebarItem(
                                      'account_info'.tr(),
                                      0,
                                      selectedIndex == 0,
                                      availableWidth < 400,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSidebarItem(
                                      'orders'.tr(),
                                      1,
                                      selectedIndex == 1,
                                      availableWidth < 400,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: selectedIndex == 0
                                    ? _buildAccountInfo(drawerViewModel)
                                    : _buildOrdersContent(),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const CustomFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSidebarItem(String title, int index, bool isSelected, bool isSmallScreen) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: isSmallScreen ? 8 : 16,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB8860B) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfo(DrawerMenuViewModel drawerViewModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'account_info'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoField('first_name'.tr(), drawerViewModel.firstName),
          const SizedBox(height: 12),
          _buildInfoField('last_name'.tr(), drawerViewModel.lastName),
          const SizedBox(height: 12),
          _buildInfoField('email'.tr(), 'sarah@gmail.com'), // Add your dynamic email if available
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8DC),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Wrap(
            children: [
              Text(
                '$label: ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB8860B),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrdersContent() {
    return const OrdersContent();
  }
}
