class Product {
  final String id;
  final String name;
  final double price;
  final String details;
  final String imageUrl;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.details = '',
    this.imageUrl = '',
    this.stock = 50,
  });

  // Step 7 Module Field Aliases
  String get productName => name;
  String get description => details;

  factory Product.fromJson(String id, Map<String, dynamic> json) {
    return Product(
      id: id,
      name: json['productName']?.toString() ?? json['name']?.toString() ?? 'Unnamed Product',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      details: json['description']?.toString() ?? json['details']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString() ?? '',
      stock: (json['stock'] is num)
          ? (json['stock'] as num).toInt()
          : int.tryParse(json['stock']?.toString() ?? '50') ?? 50,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'productName': name,
      'price': price,
      'details': details,
      'description': details,
      'imageUrl': imageUrl,
      'stock': stock,
    };
  }
}
