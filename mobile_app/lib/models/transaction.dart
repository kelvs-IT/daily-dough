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

  // Step 8 Module Field Aliases
  String get orderId => id;
  String get userId => username.isNotEmpty ? username : customerName;
  double get total => totalAmount;

  factory TransactionRecord.fromJson(String id, Map<String, dynamic> json) {
    final rawUser = json['userId']?.toString() ?? json['username']?.toString() ?? json['customerName']?.toString() ?? '';
    final numVal = (json['total'] is num)
        ? (json['total'] as num).toDouble()
        : ((json['totalAmount'] is num)
            ? (json['totalAmount'] as num).toDouble()
            : double.tryParse(json['total']?.toString() ?? json['totalAmount']?.toString() ?? '0') ?? 0.0);

    return TransactionRecord(
      id: id,
      customerName: json['customerName']?.toString() ?? (rawUser.isNotEmpty ? rawUser : 'Anonymous'),
      username: rawUser,
      address: json['address']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? 'Cash on Delivery',
      totalAmount: numVal,
      status: json['status']?.toString() ?? 'Order Placed',
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      items: json['items'] is List
          ? List<String>.from((json['items'] as List).map((e) => e.toString()))
          : (json['items'] != null ? [json['items'].toString()] : []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': id,
      'userId': userId,
      'customerName': customerName,
      'username': username,
      'address': address,
      'paymentMethod': paymentMethod,
      'total': totalAmount,
      'totalAmount': totalAmount,
      'status': status,
      'timestamp': timestamp,
      'items': items,
    };
  }
}
