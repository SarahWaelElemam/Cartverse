import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../viewmodels/dark_mode.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../models/cart_item_model.dart';
import '../models/wishlist_item_model.dart';
import '../utils/cache_helper.dart';
import 'widgets/custom_drawer.dart';
import 'widgets/custom_footer.dart';
import 'widgets/success_dialog.dart';

class ProductsScreen extends StatefulWidget {
  final String category;
  const ProductsScreen({super.key, required this.category});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize stock when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStock();
    });
  }

  void _initializeStock() {
    final products = _getProductsByCategory(widget.category);
    final stockMap = <String, int>{};

    for (final product in products) {
      final stock = int.tryParse(product['stock'] ?? '0') ?? 0;
      stockMap[product['titleKey']!] = stock;
    }

    if (mounted) {
      Provider.of<CartViewModel>(context, listen: false).initializeStock(stockMap);
    }
  }

  // Helper method to check if user is logged in
  bool _isUserLoggedIn() {
    final token = CacheHelper.getString('token');
    final userId = CacheHelper.getInt('userId');
    return token != null && token.isNotEmpty && userId != null;
  }

  // Helper method to show login prompt dialog
  void _showLoginPromptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SuccessDialog(
        titleKey: 'login_required'.tr(),
        messageKey: 'login_first_message'.tr(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkModeProvider>(context).isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;

    // Check if current locale is RTL (Arabic)
    final isRTL = Localizations.localeOf(context).languageCode == 'ar';

    final products = _getProductsByCategory(widget.category);

    return Scaffold(
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              padding: EdgeInsets.only(
                left: isRTL ? 0 : 20,
                right: isRTL ? 20 : 0,
                top: 15,
              ),
              alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
              color: isDark ? Colors.black : Colors.white,
              child: Builder(
                builder: (context) => GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Icon(Icons.menu, color: textColor, size: 28),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      '${widget.category.tr()} ${'products'.tr()}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    products.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'no_products'.tr(),
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                        : Wrap(
                      spacing: 16,
                      runSpacing: 20,
                      children: products.map((product) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 24,
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                      child: CachedNetworkImage(
                                        imageUrl: product['image']!,
                                        height: 160,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: isRTL ? null : 8,
                                      left: isRTL ? 8 : null,
                                      child: Consumer<WishlistViewModel>(
                                        builder: (context, wishlistViewModel, child) {
                                          final isInWishlist = wishlistViewModel.isInWishlist(
                                            product['titleKey']!,
                                            product['image']!,
                                          );

                                          return GestureDetector(
                                            onTap: () {
                                              // Check if user is logged in
                                              if (!_isUserLoggedIn()) {
                                                _showLoginPromptDialog(context);
                                                return;
                                              }

                                              final wishlistItem = WishlistItem(
                                                id: '${product['titleKey']}_${product['image']}', // Create a unique ID
                                                name: product['titleKey']!.tr(), // Fallback name
                                                titleKey: product['titleKey']!, // Translation key
                                                price: double.tryParse(product['price']!) ?? 0,
                                                imageUrl: product['image']!,
                                                stock: product['stock'],
                                              );

                                              // Store the current state before toggling
                                              final wasInWishlist = isInWishlist;

                                              // Toggle wishlist
                                              wishlistViewModel.toggleWishlist(wishlistItem);

                                              // Show appropriate dialog based on the previous state
                                              showDialog(
                                                context: context,
                                                builder: (_) => SuccessDialog(
                                                  titleKey: wasInWishlist
                                                      ? 'product_removed'.tr()
                                                      : 'wishlist_success_title'.tr(),
                                                  messageKey: wasInWishlist
                                                      ? 'item_removed_from_wishlist'.tr()
                                                      : 'wishlist_success_message'.tr(args: [product['titleKey']!.tr()]),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                              child: Icon(
                                                isInWishlist ? Icons.favorite : Icons.favorite_border,
                                                color: const Color(0xFFb88e2f),
                                                size: 20,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['titleKey']!.tr(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${product['price']} ${'currency'.tr()}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Consumer<CartViewModel>(
                                        builder: (context, cartViewModel, child) {
                                          final availableStock = cartViewModel.getAvailableStock(product['titleKey']!);
                                          return Text(
                                            'product_stock'.tr(args: [availableStock.toString()]),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: availableStock > 0 ? Colors.grey : Colors.red,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 10),
                                      // Enhanced Add to Cart Section with Quantity Controls
                                      Consumer<CartViewModel>(
                                        builder: (context, cartViewModel, child) {
                                          final productTitleKey = product['titleKey']!;
                                          final productImage = product['image']!;
                                          final cartItem = cartViewModel.getCartItem(productTitleKey, productImage);
                                          final currentQuantity = cartItem?.quantity ?? 0;
                                          final isInCart = cartItem != null;
                                          final availableStock = cartViewModel.getAvailableStock(productTitleKey);
                                          final canAddMore = cartViewModel.canAddItem(productTitleKey, productImage);

                                          // If no stock available, show out of stock
                                          if (availableStock <= 0) {
                                            return Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: Colors.red, width: 1),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'out_of_stock'.tr(),
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          return AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            constraints: const BoxConstraints(
                                              minWidth: double.infinity,
                                            ),
                                            child: isInCart
                                                ? Container(
                                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFb88e2f).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: const Color(0xFFb88e2f),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Quantity controls row
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      // Decrease button
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (!_isUserLoggedIn()) {
                                                            _showLoginPromptDialog(context);
                                                            return;
                                                          }

                                                          if (currentQuantity > 1) {
                                                            cartViewModel.updateQuantity(cartItem!, currentQuantity - 1);
                                                          } else {
                                                            cartViewModel.removeItem(cartItem!);
                                                          }
                                                        },
                                                        child: Container(
                                                          width: 26,
                                                          height: 26,
                                                          decoration: BoxDecoration(
                                                            color: const Color(0xFFb88e2f),
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: const Icon(
                                                            Icons.remove,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      // Quantity display with animation
                                                      Expanded(
                                                        child: AnimatedSwitcher(
                                                          duration: const Duration(milliseconds: 200),
                                                          child: Container(
                                                            key: ValueKey(currentQuantity),
                                                            child: Column(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Text(
                                                                  currentQuantity.toString(),
                                                                  style: const TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: Color(0xFFb88e2f),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'in_cart'.tr(),
                                                                  style: const TextStyle(
                                                                    fontSize: 9,
                                                                    color: Color(0xFFb88e2f),
                                                                  ),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Increase button
                                                      GestureDetector(
                                                        onTap: canAddMore ? () {
                                                          if (!_isUserLoggedIn()) {
                                                            _showLoginPromptDialog(context);
                                                            return;
                                                          }

                                                          final newItem = CartItem(
                                                            name: productTitleKey.tr(), // Fallback name
                                                            titleKey: productTitleKey, // Translation key
                                                            price: double.tryParse(product['price']!) ?? 0,
                                                            imageUrl: productImage,
                                                          );
                                                          cartViewModel.addItem(newItem);
                                                        } : null,
                                                        child: Container(
                                                          width: 26,
                                                          height: 26,
                                                          decoration: BoxDecoration(
                                                            color: canAddMore
                                                                ? const Color(0xFFb88e2f)
                                                                : Colors.grey,
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: const Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Remove from cart button
                                                  GestureDetector(
                                                    onTap: () {
                                                      cartViewModel.removeItem(cartItem!);
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('removed_from_cart'.tr(args: [productTitleKey.tr()])),
                                                          backgroundColor: Colors.red,
                                                          duration: const Duration(seconds: 2),
                                                        ),
                                                      );
                                                    },
                                                    child: Text(
                                                      'remove_from_cart'.tr(),
                                                      style: const TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                                : SizedBox(
                                              width: double.infinity, // Ensure full width
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFFb88e2f),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                ),
                                                onPressed: () {
                                                  // Check if user is logged in
                                                  if (!_isUserLoggedIn()) {
                                                    _showLoginPromptDialog(context);
                                                    return;
                                                  }

                                                  final cartProvider = Provider.of<CartViewModel>(context, listen: false);
                                                  cartProvider.addItem(CartItem(
                                                    name: productTitleKey.tr(), // Fallback name
                                                    titleKey: productTitleKey, // Translation key
                                                    price: double.tryParse(product['price']!) ?? 0,
                                                    imageUrl: productImage,
                                                  ));

                                                  // Show success snackbar instead of dialog for better UX
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('added_to_cart'.tr(args: [productTitleKey.tr()])),
                                                      backgroundColor: const Color(0xFFb88e2f),
                                                      duration: const Duration(seconds: 2),
                                                      behavior: SnackBarBehavior.floating,
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min, // Prevent overflow
                                                  children: [
                                                    const Icon(Icons.add_shopping_cart, size: 16),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        'add_to_cart'.tr(),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                    // 👇 Footer with full width
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF1C1C1C),
                      child: const CustomFooter(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getProductsByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'category_men':
        return [
          {
            'titleKey': 'product_striped_shirt',
            'price': '949.00',
            'stock': '3',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886184/Cartverse/z3xv3jtyrsgufh9ek5p8.jpg',
          },
          {
            'titleKey': 'product_cotton_hoodie',
            'price': '1200.00',
            'stock': '5',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737885895/Cartverse/srsrzcnhyektvc0l5jfr.jpg',
          },
          {
            'titleKey': 'product_dress_shirt',
            'price': '1800.00',
            'stock': '4',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886187/Cartverse/ubpfrhbdo0e32fmaibvl.jpg',
          },
          {
            'titleKey': 'product_flannel_shirt',
            'price': '1050.00',
            'stock': '2',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886184/Cartverse/zp6uvg4u5gbalpffueec.jpg',
          },
        ];
      case 'category_women':
        return [
          {
            'titleKey': 'product_brown_coat',
            'price': '2100.00',
            'stock': '2',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886185/Cartverse/iophov43gvx3abpaurov.jpg',
          },
          {
            'titleKey': 'product_black_jacket',
            'price': '1300.00',
            'stock': '3',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737885895/Cartverse/tsfuikevxfjqmvqk3qsf.jpg',
          },
          {
            'titleKey': 'product_long_coat',
            'price': '2000.00',
            'stock': '5',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886185/Cartverse/z8kumfeaj1vi9e2idja7.jpg',
          },
          {
            'titleKey': 'product_jeans_jacket',
            'price': '1100.00',
            'stock': '4',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886184/Cartverse/gxhew5uvajqpuecidss8.jpg',
          },
        ];
      case 'category_sport':
        return [
          {
            'titleKey': 'product_football_shirt',
            'price': '449.00',
            'stock': '5',
            'image': 'https://cdn-eu.dynamicyield.com/api/9876644/images/1dda9ae79a671__h_m-w40-06102022-7416b-1x1.jpg',
          },
        ];
      case 'category_kids':
        return [];
      default:
        return [];
    }
  }
}