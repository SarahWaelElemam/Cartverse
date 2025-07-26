import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../viewmodels/dark_mode.dart';
import '../viewmodels/wishlist_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../models/cart_item_model.dart';
import '../models/wishlist_item_model.dart';
import 'widgets/custom_drawer.dart';
import 'widgets/custom_footer.dart';
import 'widgets/success_dialog.dart';

class ProductsScreen extends StatelessWidget {
  final String category;
  const ProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<DarkModeProvider>(context).isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black;

    final products = _getProductsByCategory(category);

    return Scaffold(
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.only(left: 20, top: 15),
              alignment: Alignment.centerLeft,
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
                      '${category.tr()} ${'products'.tr()}',
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
                                      right: 8,
                                      child: Consumer<WishlistViewModel>(
                                        builder: (context, wishlistViewModel, child) {
                                          final isInWishlist = wishlistViewModel.isInWishlist(
                                            product['titleKey']!.tr(),
                                            product['image']!,
                                          );

                                          return GestureDetector(
                                            onTap: () {
                                              final wishlistItem = WishlistItem(
                                                name: product['titleKey']!.tr(),
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
                                                      ? 'wishlist_remove_title'
                                                      : 'wishlist_success_title',
                                                  messageKey: wasInWishlist
                                                      ? 'wishlist_remove_message'
                                                      : 'wishlist_success_message',
                                                  messageArgs: [product['titleKey']!.tr()],
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
                                        '${product['price']} EGP',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'product_stock'.tr(args: [product['stock'] ?? '0']),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFb88e2f),
                                          ),
                                          onPressed: () {
                                            final cartProvider = Provider.of<CartViewModel>(context, listen: false);
                                            cartProvider.addItem(CartItem(
                                              name: product['titleKey']!.tr(),
                                              price: double.tryParse(product['price']!) ?? 0,
                                              imageUrl: product['image']!,
                                            ));

                                            showDialog(
                                              context: context,
                                              builder: (_) => SuccessDialog(
                                                titleKey: 'cart_success_title',
                                                messageKey: 'cart_success_message',
                                                messageArgs: [product['titleKey']!.tr()],
                                              ),
                                            );
                                          },
                                          child: Text('add_to_cart'.tr()),
                                        ),
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