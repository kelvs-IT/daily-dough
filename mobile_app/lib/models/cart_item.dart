class CartItem {
  final String id;
  final String productName;
  final double price;

  CartItem({
    required this.id,
    required this.productName,
    required this.price,
  });

  factory CartItem.fromJson(String id, Map<String, dynamic> json) {
    return CartItem(
      id: id,
      productName: json['productName']?.toString() ?? json['name']?.toString() ?? 'Item',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'price': price,
    };
  }
}
