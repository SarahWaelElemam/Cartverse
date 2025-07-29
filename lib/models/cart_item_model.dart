class CartItem {
  final String name; // Keep for backward compatibility
  final String? titleKey; // Add this for translation key
  final double price;
  final String imageUrl;
  final int quantity;

  CartItem({
    required this.name,
    this.titleKey, // Add this parameter
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  CartItem copyWith({
    String? name,
    String? titleKey,
    double? price,
    String? imageUrl,
    int? quantity,
  }) {
    return CartItem(
      name: name ?? this.name,
      titleKey: titleKey ?? this.titleKey,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json['name']?.toString() ?? '',
      titleKey: json['titleKey']?.toString(), // Add this line
      price: (json['price'] is String)
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price']?.toDouble() ?? 0.0),
      imageUrl: json['imageUrl']?.toString() ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'titleKey': titleKey, // Add this line
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }
}