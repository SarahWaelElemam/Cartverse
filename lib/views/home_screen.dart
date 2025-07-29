import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../viewmodels/drawer_menu_viewmodel.dart';
import 'widgets/custom_drawer.dart';
import 'widgets/custom_footer.dart';
import 'products_screen.dart'; // <-- Make sure this import exists

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.5);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> products = [
    {
      'titleKey': 'product_cotton_hoodie',
      'price': '1200.00 EGP',
      'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886184/Cartverse/zp6uvg4u5gbalpffueec.jpg'
    },
    {
      'titleKey': 'product_dress_shirt',
      'price': '1800.00 EGP',
      'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886187/Cartverse/ubpfrhbdo0e32fmaibvl.jpg'
    },
    {
      'titleKey': 'product_flannel_shirt',
      'price': '1050.00 EGP',
      'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737885895/Cartverse/srsrzcnhyektvc0l5jfr.jpg'
    },
    {
      'titleKey': 'product_striped_shirt',
      'price': '949.00 EGP',
      'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886184/Cartverse/z3xv3jtyrsgufh9ek5p8.jpg'
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients && mounted) {
        setState(() {
          _currentPage = (_currentPage + 1) % products.length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text(
          'appTitle'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            // Hero Section
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: 'https://cart-verse.netlify.app/assets/hero-CJhwK5Io.jpg',
                  fit: BoxFit.cover,
                  height: 500,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: theme.colorScheme.surfaceVariant,
                    height: 500,
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.error,
                    color: theme.colorScheme.error,
                  ),
                ),
                SizedBox(
                  height: 500,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'winter_2025'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFFFFD700),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'enjoy_our_luxury_collection'.tr(),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: const [
                              Shadow(
                                blurRadius: 6.0,
                                color: Colors.black87,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/categories');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'shop_now'.tr(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // New Arrivals Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  Text(
                    'new_arrivals'.tr(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'discover_latest_trends'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 280,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const ProductsScreen(category: 'category_men'),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius:
                                      const BorderRadius.vertical(top: Radius.circular(12)),
                                      child: CachedNetworkImage(
                                        imageUrl: product['image']!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        placeholder: (context, url) => Center(
                                          child: CircularProgressIndicator(
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Icon(
                                          Icons.error,
                                          color: theme.colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product['titleKey']!.tr(),
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product['price']!,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Promo Banner
            Container(
              height: 280,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                      'https://cart-verse.netlify.app/assets/banner3-D9-KlIGm.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'get_20_off'.tr(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'signup_enjoy_discounts'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/categories');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 14,
                          ),
                        ),
                        child: Text(
                          'shop_now'.tr(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Section
            CustomFooter(),
          ],
        ),
      ),
    );
  }
}