class WishlistItem {
  final String name;
  final double price;
  final String imageUrl;
  final String? stock;

  WishlistItem({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.stock,
  });

  WishlistItem copyWith({
    String? name,
    double? price,
    String? imageUrl,
    String? stock,
  }) {
    return WishlistItem(
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WishlistItem &&
        other.name == name &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => name.hashCode ^ imageUrl.hashCode;
}