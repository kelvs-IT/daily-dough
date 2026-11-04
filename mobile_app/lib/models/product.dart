class Product {
  final String id;
  final String name;
  final double price;
  final String details;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.details = '',
    this.imageUrl = '',
  });

  factory Product.fromJson(String id, Map<String, dynamic> json) {
    return Product(
      id: id,
      name: json['name']?.toString() ?? json['productName']?.toString() ?? 'Unnamed Product',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      details: json['details']?.toString() ?? json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'details': details,
      'imageUrl': imageUrl,
    };
  }
}
