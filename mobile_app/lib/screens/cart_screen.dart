import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import 'checkout_screen.dart';
import 'login_screen.dart';

class _GroupedItem {
  final String name;
  final double price;
  int quantity;

  double get subtotal => price * quantity;

  _GroupedItem({
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class CartScreen extends StatefulWidget {
  final FirebaseService firebaseService;

  const CartScreen({super.key, required this.firebaseService});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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

  @override
  void initState() {
    super.initState();
    widget.firebaseService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.firebaseService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  Widget _buildItemImage(String name) {
    final asset = _donutAssetMap[name.toLowerCase()];
    if (asset != null) {
      return Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.bakery_dining_rounded, color: Color(0xFFD97706), size: 28),
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
            const Icon(Icons.bakery_dining_rounded, color: Color(0xFFD97706), size: 28),
      );
    }

    return const Center(
      child: Icon(Icons.bakery_dining_rounded, color: Color(0xFFD97706), size: 30),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Part E Scenario 1: Access Control Check
    if (!widget.firebaseService.isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Cart Items'),
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
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please Login First',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF64748B),
                        ),
                      ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

    final cartItems = widget.firebaseService.cartItems;
    final totalAmount = widget.firebaseService.cartTotal;

    // Group cart items by product name
    final Map<String, _GroupedItem> groupedMap = {};
    for (final item in cartItems) {
      if (groupedMap.containsKey(item.productName)) {
        groupedMap[item.productName]!.quantity++;
      } else {
        groupedMap[item.productName] = _GroupedItem(
          name: item.productName,
          price: item.price,
          quantity: 1,
        );
      }
    }
    final groupedList = groupedMap.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Cart Items'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              tooltip: 'Clear Cart',
              icon: const Icon(Icons.delete_sweep_outlined, color: Color(0xFFDC2626)),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Cart?'),
                    content: const Text('Are you sure you want to remove all items from your cart?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await widget.firebaseService.clearCart();
                }
              },
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add products from the store to proceed to checkout.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Browse Products'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...groupedList.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            // Product Image on the left
                            Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _buildItemImage(item.name),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Product name and red price in the center
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Color(0xFF0F172A),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₱${item.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Quantity controls on the right
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () => widget.firebaseService.removeFromCart(item.name),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFCBD5E1)),
                                    ),
                                    child: const Icon(Icons.remove, size: 16, color: Color(0xFF475569)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    final prod = Product(
                                      id: 'prod_${item.name.toLowerCase().replaceAll(' ', '_')}',
                                      name: item.name,
                                      price: item.price,
                                      imageUrl: _donutAssetMap[item.name.toLowerCase()] ?? '',
                                    );
                                    widget.firebaseService.addToCart(prod);
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFCBD5E1)),
                                    ),
                                    child: const Icon(Icons.add, size: 16, color: Color(0xFF475569)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 14),
                // Order Summary Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                            ),
                            Text(
                              '₱${totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total to pay',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              '₱${totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Prominent Checkout Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CheckoutScreen(firebaseService: widget.firebaseService),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF69438),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.lock_rounded, size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Checkout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
