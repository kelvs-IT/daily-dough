class TransactionRecord {
  final String id;
  final String customerName;
  final String username;
  final String address;
  final String paymentMethod;
  final double totalAmount;
  final String status;
  final String timestamp;
  final List<String> items;

  TransactionRecord({
    required this.id,
    required this.customerName,
    this.username = '',
    required this.address,
    required this.paymentMethod,
    required this.totalAmount,
    this.status = 'Order Placed',
    required this.timestamp,
    this.items = const [],
  });

  factory TransactionRecord.fromJson(String id, Map<String, dynamic> json) {
    return TransactionRecord(
      id: id,
      customerName: json['customerName']?.toString() ?? 'Anonymous',
      username: json['username']?.toString() ?? json['customerName']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? 'Cash on Delivery',
      totalAmount: (json['totalAmount'] is num)
          ? (json['totalAmount'] as num).toDouble()
          : double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      status: json['status']?.toString() ?? 'Order Placed',
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      items: json['items'] is List
          ? List<String>.from((json['items'] as List).map((e) => e.toString()))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerName': customerName,
      'username': username,
      'address': address,
      'paymentMethod': paymentMethod,
      'totalAmount': totalAmount,
      'status': status,
      'timestamp': timestamp,
      'items': items,
    };
  }
}
