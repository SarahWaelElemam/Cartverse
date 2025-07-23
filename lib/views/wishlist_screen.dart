import 'package:flutter/material.dart';

class WishlistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wishlist')),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: Image.network(
                'https://res.cloudinary.com/dnka30e3s/image/upload/v1737886184/Cartverse/z3xv3jtyrsgufh9ek5p8.jpg',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text('Product ${index + 1}'),
              subtitle: Text('\$99.99'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}