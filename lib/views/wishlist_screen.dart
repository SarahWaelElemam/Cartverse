import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fedis/viewmodels/wishlist_viewmodel.dart';
import 'package:fedis/viewmodels/cart_viewmodel.dart';
import 'widgets/custom_drawer.dart';
import 'widgets/custom_footer.dart';
import 'widgets/success_dialog.dart';
import 'package:fedis/models/cart_item_model.dart';
import 'package:fedis/models/wishlist_item_model.dart';
import 'package:easy_localization/easy_localization.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text('wishlist'.tr()),
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
      body: Consumer<WishlistViewModel>(
        builder: (context, wishlistViewModel, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          if (wishlistViewModel.items.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: isDark ? Colors.grey[850] : const Color(0xFFF5F5F5),
                    child: Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: isDark ? Colors.pink[200] : Colors.pinkAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'wishlist_empty'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 60),
                  const CustomFooter(),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'your_wishlist'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: wishlistViewModel.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = wishlistViewModel.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image_not_supported),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.price.toStringAsFixed(2)} EGP',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                        color: Color(0xFFb88e2f),
                                      ),
                                    ),
                                    if (item.stock != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'product_stock'.tr(args: [item.stock!]),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                children: [
                                  Consumer<CartViewModel>(
                                    builder: (context, cartViewModel, child) {
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFb88e2f),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          minimumSize: const Size(60, 30),
                                        ),
                                        onPressed: () {
                                          // Add to cart
                                          cartViewModel.addItem(CartItem(
                                            name: item.name,
                                            price: item.price,
                                            imageUrl: item.imageUrl,
                                          ));

                                          // Show success dialog
                                          showDialog(
                                            context: context,
                                            builder: (_) => SuccessDialog(
                                              titleKey: 'cart_success_title',
                                              messageKey: 'cart_success_message',
                                              messageArgs: [item.name],
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'add_to_cart'.tr(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      minimumSize: const Size(60, 30),
                                    ),
                                    onPressed: () {
                                      wishlistViewModel.removeItem(item);
                                    },
                                    child: Text(
                                      'remove'.tr(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
}
