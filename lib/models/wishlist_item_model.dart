class WishlistItem {
  final String? id; // Changed to nullable
  final String name;
  final String? titleKey;
  final double price;
  final String imageUrl;
  final String? stock;

  WishlistItem({
    this.id, // Made optional
    required this.name,
    this.titleKey,
    required this.price,
    required this.imageUrl,
    this.stock,
  });

  WishlistItem copyWith({
    String? name,
    String? titleKey,
    double? price,
    String? imageUrl,
    String? stock,
    String? id,
  }) {
    return WishlistItem(
      name: name ?? this.name,
      titleKey: titleKey ?? this.titleKey,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      id: id ?? this.id,
    );
  }

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? '',
      titleKey: json['titleKey']?.toString(), // Add this line
      price: (json['price'] is String)
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price']?.toDouble() ?? 0.0),
      imageUrl: json['imageUrl']?.toString() ?? '',
      stock: json['stock']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'titleKey': titleKey, // Add this line
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WishlistItem &&
        other.id == id && // Compare by ID if available
        other.titleKey == titleKey &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => id?.hashCode ?? (titleKey ?? name).hashCode ^ imageUrl.hashCode;
}