import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import '../services/firebase_service.dart';
import 'login_screen.dart';
import 'order_tracking_screen.dart';
import 'products_screen.dart';

class _GroupedCartItem {
  final String name;
  final double price;
  int quantity;

  double get subtotal => price * quantity;

  _GroupedCartItem({
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class CheckoutScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  const CheckoutScreen({super.key, required this.firebaseService});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  // Steps: 0 = Details & Payment, 1 = Review & Confirm, 2 = Success
  int _currentStep = 0;

  String _selectedPaymentMethod = 'Cash on Delivery';
  String? _errorMessage;
  bool _isProcessing = false;
  TransactionRecord? _savedTransaction;

  static const Map<String, String> _donutAssetMap = {
    'pistachio': 'assets/images/pistachio.png',
    'matcha donut': 'assets/images/matcha_donut.png',
    'blueberry donut': 'assets/images/blueberry_donut.png',
    'choco butternut': 'assets/images/choco_butternut.png',
    'strawberry sprinkle glazed': 'assets/images/strawberry_sprinkle_glazed.png',
    'chocolate glazed': 'assets/images/chocolate_glazed.png',
    'glazed cheese': 'assets/images/glazed_cheese.png',
    'cappuccino': 'assets/images/Cappuccino.png',
    'caramel macchiato': 'assets/images/Caramel Macchiato.png',
    'hot americano': 'assets/images/Hot Americano.png',
    'hot cafe latte': 'assets/images/Hot Cafe Latte.png',
    'iced americano': 'assets/images/Iced Americano.png',
    'iced cafe latte': 'assets/images/Iced Cafe Latte.png',
    'spanish latte': 'assets/images/Spanish Latte.png',
  };

  final List<Map<String, dynamic>> _paymentOptions = [
    {
      'title': 'Credit card',
      'subtitle': 'Visa, Mastercard, JCB',
      'icon': Icons.credit_card_rounded,
      'color': Color(0xFF2563EB),
    },
    {
      'title': 'Cash on Delivery',
      'subtitle': 'Pay when your order arrives',
      'icon': Icons.payments_outlined,
      'color': Color(0xFFEA580C),
    },
    {
      'title': 'GCash',
      'subtitle': 'Mobile e-Wallet payment',
      'icon': Icons.phone_android_rounded,
      'color': Color(0xFF0284C7),
    },
  ];

  @override
  void initState() {
    super.initState();
    final currentUsername = widget.firebaseService.currentUsername;
    final fullName = widget.firebaseService.profileFullName;
    final addresses = widget.firebaseService.userAddresses;

    _nameController.text = (fullName.isNotEmpty && fullName != 'Customer')
        ? fullName
        : (currentUsername.isNotEmpty ? currentUsername : 'Juan Dela Cruz');
    _addressController.text = addresses.isNotEmpty
        ? addresses.first
        : '123 Rizal St, Morong, Rizal';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Widget _buildItemThumbnail(String name) {
    final asset = _donutAssetMap[name.toLowerCase()];
    if (asset != null) {
      return Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.bakery_dining_rounded, color: Color(0xFFD97706), size: 24),
      );
    }

    final productMatch = widget.firebaseService.products.firstWhere(
      (p) => p.name.trim().toLowerCase() == name.trim().toLowerCase(),
      orElse: () => Product(id: '', name: '', price: 0),
    );

    if (productMatch.imageUrl.trim().startsWith('http')) {
      return Image.network(
        productMatch.imageUrl.trim(),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.bakery_dining_rounded, color: Color(0xFFD97706), size: 24),
      );
    }

    return const Center(
      child: Icon(Icons.bakery_dining_rounded, color: Color(0xFFD97706), size: 24),
    );
  }

  List<_GroupedCartItem> _getGroupedCartItems() {
    final cartItems = widget.firebaseService.cartItems;
    final Map<String, _GroupedCartItem> map = {};
    for (final item in cartItems) {
      if (map.containsKey(item.productName)) {
        map[item.productName]!.quantity++;
      } else {
        map[item.productName] = _GroupedCartItem(
          name: item.productName,
          price: item.price,
          quantity: 1,
        );
      }
    }
    return map.values.toList();
  }

  void _handleNextToReview() {
    final customerName = _nameController.text.trim();
    final address = _addressController.text.trim();

    setState(() {
      _errorMessage = null;
    });

    if (customerName.isEmpty || address.isEmpty) {
      setState(() {
        _errorMessage = 'Validation Error: Please fill in your name and delivery address.';
      });
      return;
    }

    if (widget.firebaseService.cartItems.isEmpty) {
      setState(() {
        _errorMessage = 'Cart is empty. Please add items before checking out.';
      });
      return;
    }

    setState(() {
      _currentStep = 1;
    });
  }

  Future<void> _handleConfirmOrder() async {
    final customerName = _nameController.text.trim();
    final address = _addressController.text.trim();

    setState(() {
      _errorMessage = null;
      _isProcessing = true;
    });

    final res = await widget.firebaseService.processCheckout(
      customerName: customerName,
      address: address,
      paymentMethod: _selectedPaymentMethod,
    );

    if (!mounted) return;

    setState(() => _isProcessing = false);

    if (res['success'] == true) {
      setState(() {
        _savedTransaction = res['transaction'] as TransactionRecord?;
        _currentStep = 2; // Success screen
      });
    } else {
      setState(() {
        _errorMessage = res['error'] ?? 'Transaction failed. Your cart was preserved.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.firebaseService.isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Checkout'),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.gpp_bad_rounded, size: 56, color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Access Denied',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C)),
                      ),
                      const SizedBox(height: 8),
                      const Text('Please Login First', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => LoginScreen(firebaseService: widget.firebaseService),
                            ),
                          );
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Go to Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_currentStep == 2) {
      return _buildSuccessScreen();
    } else if (_currentStep == 1) {
      return _buildReviewScreen();
    } else {
      return _buildStep1Screen();
    }
  }

  // --- Step 1: Order Details & Payment Selection ---
  Widget _buildStep1Screen() {
    final groupedItems = _getGroupedCartItems();
    final totalAmount = widget.firebaseService.cartTotal;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Color(0xFFB91C1C),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                // 1. Customer & Delivery Information
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Delivery Information',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Customer Name *',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Delivery Address *',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                        ),
                        if (widget.firebaseService.userAddresses.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(Icons.bookmark_border_rounded, size: 14, color: Color(0xFF64748B)),
                              SizedBox(width: 4),
                              Text(
                                'Saved Addresses (tap to select):',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: widget.firebaseService.userAddresses.map((addr) {
                              final isSelected = _addressController.text.trim() == addr.trim();
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _addressController.text = addr;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF624B1D) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF624B1D) : const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.place,
                                        size: 13,
                                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        addr,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? Colors.white : const Color(0xFF1E293B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Order Summary
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Divider(height: 20),
                        ...groupedItems.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _buildItemThumbnail(item.name),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                        Text(
                                          '₱${item.price.toStringAsFixed(0)} x ${item.quantity}',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₱${item.subtotal.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(
                              '₱${totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Payment Method Selection (Cards with Radio Buttons matching Reference Image)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 12),
                        ..._paymentOptions.map((opt) {
                          final title = opt['title'] as String;
                          final isSelected = _selectedPaymentMethod == title;
                          return InkWell(
                            onTap: () {
                              setState(() => _selectedPaymentMethod = title);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFF97316) : Colors.grey.shade300,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    margin: const EdgeInsets.only(left: 4, right: 12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? const Color(0xFFEA580C) : const Color(0xFF94A3B8),
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFEA580C),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (opt['color'] as Color).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(opt['icon'] as IconData, color: opt['color'] as Color, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Text(
                                          opt['subtitle'] as String,
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Prominent Orange Next Button
                ElevatedButton(
                  onPressed: _handleNextToReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF69438),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Step 2: Order Confirmation & Details Screen ---
  Widget _buildReviewScreen() {
    final groupedItems = _getGroupedCartItems();
    final totalAmount = widget.firebaseService.cartTotal;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Confirm Order'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _currentStep = 0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Review Order Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Text('Recipient: ${_nameController.text.trim()}', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Address: ${_addressController.text.trim()}')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.payment_outlined, size: 18, color: Color(0xFF64748B)),
                            const SizedBox(width: 8),
                            Text('Payment Method: $_selectedPaymentMethod', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const Divider(height: 24),
                        const Text('Items to Deliver:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        ...groupedItems.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.name} x${item.quantity}', style: const TextStyle(fontSize: 14)),
                                  Text('₱${item.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total to Pay:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              '₱${totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isProcessing ? null : _handleConfirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF69438),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Confirm Order',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isProcessing ? null : () => setState(() => _currentStep = 0),
                  child: const Text('Back to Edit Details', style: TextStyle(color: Color(0xFF64748B))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Step 3: Success Screen (Matching Screen 3 of Reference Image) ---
  Widget _buildSuccessScreen() {
    final tx = _savedTransaction;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Order Status'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular Thumbs-Up Badge (matching Screen 3 reference design)
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF83256).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF83256),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.thumb_up_alt_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Order Confirmed! Your order has been placed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 24),

                // Order Details Card
                if (tx != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tx.id,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tx.status,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text('Customer: ${tx.customerName}', style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('Payment: ${tx.paymentMethod}', style: const TextStyle(fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('Items: ${tx.items.join(', ')}', style: const TextStyle(fontSize: 13)),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Paid:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(
                              '₱${tx.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFDC2626)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                ],

                // Action Buttons
                if (tx != null) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingScreen(
                            firebaseService: widget.firebaseService,
                            order: tx,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.timeline_rounded, size: 18),
                    label: const Text('Track Order Progress', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE15B2D),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => ProductsScreen(
                          firebaseService: widget.firebaseService,
                          initialIndex: 2, // Navigate directly to Orders tab
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF69438),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('View All Orders', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => ProductsScreen(
                          firebaseService: widget.firebaseService,
                          initialIndex: 0, // Navigate to Home
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    minimumSize: const Size(double.infinity, 48),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back to Home', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
