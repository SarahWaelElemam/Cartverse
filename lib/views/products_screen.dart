import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../viewmodels/dark_mode.dart';
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
                      '$category Products',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    products.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'There are no products now.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                        :Wrap(
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
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => SuccessDialog(
                                              title: 'Added to Wishlist',
                                              message: '${product['title']} has been added to your wishlist.',
                                            ),
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          child: const Icon(
                                            Icons.favorite_border,
                                            color: Color(0xFFb88e2f),
                                            size: 20,
                                          ),
                                        ),
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
                                        product['title']!,
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
                                        'You can add ${product['stock']} items',
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
                                            showDialog(
                                              context: context,
                                              builder: (_) => SuccessDialog(
                                                title: 'Added to Cart!',
                                                message: '${product['title']} has been added to your cart.',
                                              ),
                                            );
                                          },
                                          child: const Text('Add to Cart'),
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
      case 'men':
        return [
          {
            'title': 'Striped shirt',
            'price': '949.00',
            'stock': '3',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886184/Cartverse/z3xv3jtyrsgufh9ek5p8.jpg',
          },
          {
            'title': 'Cotton Hoodie',
            'price': '1200.00',
            'stock': '5',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737885895/Cartverse/srsrzcnhyektvc0l5jfr.jpg',
          },
          {
            'title': 'Dress Shirt',
            'price': '1800.00',
            'stock': '4',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886187/Cartverse/ubpfrhbdo0e32fmaibvl.jpg',
          },
          {
            'title': 'Flannel Shirt',
            'price': '1050.00',
            'stock': '2',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886184/Cartverse/zp6uvg4u5gbalpffueec.jpg',
          },
        ];
      case 'women':
        return [
          {
            'title': 'Brown Coat',
            'price': '2100.00',
            'stock': '2',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886185/Cartverse/iophov43gvx3abpaurov.jpg',
          },
          {
            'title': 'Black Jacket',
            'price': '1300.00',
            'stock': '3',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737885895/Cartverse/tsfuikevxfjqmvqk3qsf.jpg',
          },
          {
            'title': 'Long Coat',
            'price': '2000.00',
            'stock': '5',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886185/Cartverse/z8kumfeaj1vi9e2idja7.jpg',
          },

          {
            'title': 'Jeans Jacket',
            'price': '1100.00',
            'stock': '4',
            'image': 'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886184/Cartverse/gxhew5uvajqpuecidss8.jpg',
          },
        ];
      case 'sport':
        return [
          {
            'title': 'Regular Fit Football Shirt',
            'price': '449.00',
            'stock': '5',
            'image': 'https://cdn-eu.dynamicyield.com/api/9876644/images/1dda9ae79a671__h_m-w40-06102022-7416b-1x1.jpg',
          },
        ];
      case 'kids':
        return []; // will display no products now
      default:
        return [];
    }
  }

}
