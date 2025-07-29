import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fedis/viewmodels/cart_viewmodel.dart';
import 'package:fedis/viewmodels/orders_viewmodel.dart';
import 'widgets/custom_drawer.dart';
import 'widgets/custom_footer.dart';
import 'package:fedis/models/cart_item_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // Helper method to get translated name
  String _getTranslatedName(CartItem item, BuildContext context) {
    // If titleKey exists, use it for translation, otherwise fallback to name
    if (item.titleKey != null && item.titleKey!.isNotEmpty) {
      return item.titleKey!.tr();
    }
    return item.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        title: Text('your_cart'.tr()),
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
      body: Consumer<CartViewModel>(
        builder: (context, cartViewModel, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          if (cartViewModel.items.isEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: isDark ? Colors.grey[850] : const Color(0xFFF5F5F5),
                    child: Icon(
                      Icons.remove_shopping_cart,
                      size: 80,
                      color: isDark ? Colors.red[200] : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'cart_empty'.tr(),
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
                      'your_cart'.tr(),
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
                  itemCount: cartViewModel.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = cartViewModel.items[index];

                    // Get the maximum stock available for this product
                    final maxStock = item.titleKey != null
                        ? cartViewModel.getAvailableStock(item.titleKey!)
                        : 10; // fallback to 10 if no titleKey

                    // Create quantity options based on available stock
                    final quantityOptions = List.generate(
                      maxStock.clamp(1, 10), // Limit to max 10 for UI purposes
                          (i) => i + 1,
                    );

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
                                      _getTranslatedName(item, context),
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
                                    const SizedBox(height: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'quantity'.tr(),
                                              style: TextStyle(
                                                color: isDark ? Colors.white70 : Colors.black87,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '(${'stock'.tr()}: $maxStock)',
                                              style: TextStyle(
                                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                                fontSize: 11,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: 80,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: DropdownButton<int>(
                                            value: item.quantity.clamp(1, maxStock),
                                            underline: const SizedBox(),
                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                            isExpanded: true,
                                            items: quantityOptions
                                                .map((val) => DropdownMenuItem(
                                              value: val,
                                              child: Text(val.toString()),
                                            ))
                                                .toList(),
                                            onChanged: (newQty) {
                                              if (newQty != null) {
                                                cartViewModel.updateQuantity(item, newQty);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                children: [
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
                                      cartViewModel.removeItem(item);
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
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'total'.tr() + ':',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            '${cartViewModel.totalPrice.toStringAsFixed(2)} EGP',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFFb88e2f),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${cartViewModel.totalPrice.toStringAsFixed(2)} EGP',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFFb88e2f),
                            ),
                          ),
                          Consumer<OrdersViewModel>(
                            builder: (context, ordersViewModel, child) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFb88e2f),
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                onPressed: ordersViewModel.isLoading
                                    ? null
                                    : () async {
                                  // Create copies of cart items with translated names for the order
                                  final orderItems = cartViewModel.items
                                      .map((item) => CartItem(
                                    name: _getTranslatedName(item, context), // Use translated name
                                    titleKey: item.titleKey,
                                    price: item.price,
                                    imageUrl: item.imageUrl,
                                    quantity: item.quantity,
                                  ))
                                      .toList();
                                  final orderTotal = cartViewModel.totalPrice;

                                  // Show loading dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );

                                  try {
                                    // Add order to orders list
                                    final success = await ordersViewModel.addOrder(
                                      orderItems,
                                      orderTotal,
                                    );

                                    // Close loading dialog
                                    Navigator.of(context).pop();

                                    if (success) {
                                      // Reduce stock for ordered items BEFORE clearing cart
                                      cartViewModel.reduceStock(orderItems);

                                      // Clear the cart only after successful order placement and stock reduction
                                      cartViewModel.clearCart();

                                      // Show success message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('order_success'.tr()),
                                          backgroundColor: const Color(0xFFb88e2f),
                                        ),
                                      );
                                    } else {
                                      // Show error message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(ordersViewModel.errorMessage ?? 'Failed to place order'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    // Close loading dialog
                                    Navigator.of(context).pop();

                                    // Show error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to place order: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                child: ordersViewModel.isLoading
                                    ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                                    : Text(
                                  'place_order'.tr(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
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
}