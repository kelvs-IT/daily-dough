import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';
import 'cart_screen.dart';
import '../screens/login_screen.dart';
import 'order_tracking_screen.dart';
import 'product_detail_screen.dart';

class PromoItem {
  final String imageAsset;
  final String title;
  final String description;

  const PromoItem({
    required this.imageAsset,
    required this.title,
    required this.description,
  });
}

const List<PromoItem> kHomePromotions = [
  PromoItem(
    imageAsset: 'assets/images/home/bavarian.png',
    title: 'Bavarian Cheese Donut Box',
    description:
        'Soft, powdered donuts filled with rich and creamy cheese Bavarian custard. Freshly prepared and perfect for sharing with family and friends.',
  ),
  PromoItem(
    imageAsset: 'assets/images/home/glazed donut.png',
    title: 'Signature Glazed Donut Trio',
    description:
        'Enjoy a colorful trio featuring our Strawberry Sprinkle, Glazed Cheese, and classic Chocolate Glazed donuts in one delightful treat.',
  ),
  PromoItem(
    imageAsset: 'assets/images/home/pistachio.png',
    title: 'Pistachio Dream Glazed Donuts',
    description:
        'Indulge in smooth, creamy pistachio glaze topped with crunchy crushed pistachios on our signature soft and fluffy donuts.',
  ),
];

class TreatItem {
  final String name;
  final double price;
  final String assetPath;
  final String description;

  const TreatItem({
    required this.name,
    required this.price,
    required this.assetPath,
    this.description = '',
  });
}

const List<TreatItem> kTreatProducts = [
  TreatItem(
    name: 'Pistachio',
    price: 49.0,
    assetPath: 'assets/images/pistachio.png',
    description:
        'A delicious donut coated with creamy pistachio glaze and topped with crushed pistachios.',
  ),
  TreatItem(
    name: 'Matcha Donut',
    price: 39.0,
    assetPath: 'assets/images/matcha_donut.png',
    description:
        'Soft ring donut dipped in vibrant green matcha glaze with white chocolate drizzle.',
  ),
  TreatItem(
    name: 'Blueberry Donut',
    price: 60.0,
    assetPath: 'assets/images/blueberry_donut.png',
    description:
        'Glazed donut topped with rich blueberry icing and fresh blueberries.',
  ),
  TreatItem(
    name: 'Choco Butternut',
    price: 39.0,
    assetPath: 'assets/images/choco_butternut.png',
    description:
        'Classic cake donut generously coated with rich chocolate and crunchy butternut crumbles.',
  ),
  TreatItem(
    name: 'Strawberry Sprinkle Glazed',
    price: 39.0,
    assetPath: 'assets/images/strawberry_sprinkle_glazed.png',
    description:
        'A classic donut with sweet strawberry glaze and colorful sprinkles.',
  ),
  TreatItem(
    name: 'Chocolate Glazed',
    price: 39.0,
    assetPath: 'assets/images/chocolate_glazed.png',
    description:
        'Soft golden donut dipped in decadent chocolate glaze with a delicate white swirl.',
  ),
  TreatItem(
    name: 'Glazed Cheese',
    price: 39.0,
    assetPath: 'assets/images/glazed_cheese.png',
    description:
        'Sweet glazed donut topped with savory shredded cheese for the perfect balance of flavors.',
  ),
  TreatItem(
    name: 'Cappuccino',
    price: 69.0,
    assetPath: 'assets/images/Cappuccino.png',
    description:
        'Rich espresso layered with steamed milk and thick velvety foam.',
  ),
  TreatItem(
    name: 'Caramel Macchiato',
    price: 99.0,
    assetPath: 'assets/images/Caramel Macchiato.png',
    description:
        'Freshly steamed milk with vanilla-flavored syrup, marked with espresso and topped with caramel drizzle.',
  ),
  TreatItem(
    name: 'Hot Americano',
    price: 69.0,
    assetPath: 'assets/images/Hot Americano.png',
    description:
        'Espresso shots topped with hot water create a light layer of crema and deep rich flavor.',
  ),
  TreatItem(
    name: 'Hot Cafe Latte',
    price: 99.0,
    assetPath: 'assets/images/Hot Cafe Latte.png',
    description:
        'Smooth espresso balanced with steamed milk and a light layer of foam.',
  ),
  TreatItem(
    name: 'Iced Americano',
    price: 66.0,
    assetPath: 'assets/images/Iced Americano.png',
    description:
        'Bold espresso shots combined with cold water and ice for a crisp, refreshing coffee.',
  ),
  TreatItem(
    name: 'Iced Cafe Latte',
    price: 99.0,
    assetPath: 'assets/images/Iced Cafe Latte.png',
    description:
        'Freshly brewed espresso poured over chilled milk and ice.',
  ),
  TreatItem(
    name: 'Spanish Latte',
    price: 69.0,
    assetPath: 'assets/images/Spanish Latte.png',
    description:
        'A sweet and creamy espresso drink infused with condensed milk and steamed milk.',
  ),
];

class ProductsScreen extends StatefulWidget {
  final FirebaseService firebaseService;
  final int initialIndex;

  const ProductsScreen({
    super.key,
    required this.firebaseService,
    this.initialIndex = 0,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    widget.firebaseService.addListener(_onServiceUpdate);
    widget.firebaseService.fetchCustomerOrders();
  }

  @override
  void dispose() {
    widget.firebaseService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  String _getAppBarTitle(bool isAdmin) {
    if (_currentIndex == 2) {
      return 'My Orders';
    } else {
      return 'Daily Dough';
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.firebaseService.currentUsername;
    final isAdmin = widget.firebaseService.isAdmin;
    final cartItemCount = widget.firebaseService.cartItems.length;

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      const NavigationDestination(
        icon: Icon(Icons.bakery_dining_outlined),
        selectedIcon: Icon(Icons.bakery_dining_rounded),
        label: 'Treats',
      ),
      const NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long_rounded),
        label: 'Orders',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person_rounded),
        label: 'Profile',
      ),
    ];

    if (_currentIndex >= destinations.length) {
      _currentIndex = 0;
    }

    final isOrdersActive = _currentIndex == 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: _getAppBarTitle(isAdmin) == 'Daily Dough'
            ? Image.asset(
                'assets/images/daily_dough.png',
                height: 32,
                fit: BoxFit.contain,
              )
            : Text(_getAppBarTitle(isAdmin)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
        actions: [
          if (isOrdersActive)
            IconButton(
              tooltip: 'Refresh Orders',
              icon: const Icon(Icons.refresh),
              onPressed: () => widget.firebaseService.fetchCustomerOrders(),
            ),
          // Top-right Cart button
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Cart',
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CartScreen(firebaseService: widget.firebaseService),
                    ),
                  );
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF83256),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildCurrentView(username, isAdmin),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 1) {
            widget.firebaseService.fetchProducts();
          }
        },
        destinations: destinations,
      ),
    );
  }

  Widget _buildCurrentView(String username, bool isAdmin) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildTreatsTab();
      case 2:
        return _buildOrdersTab();
      case 3:
        return _buildProfileTab(username, false);
      default:
        return const SizedBox.shrink();
    }
  }

  // --- Home Tab (Promotional Feed - McDonald's Style) ---
  Widget _buildHomeTab() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          itemCount: kHomePromotions.length,
          itemBuilder: (context, index) {
            final promo = kHomePromotions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 20),
              elevation: 2,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    promo.imageAsset,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(Icons.broken_image_rounded, size: 48, color: Color(0xFF94A3B8)),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promo.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          promo.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData iconData;

    switch (status.trim().toLowerCase()) {
      case 'order placed':
      case 'placed':
        bgColor = const Color(0xFFFEF3C7);
        borderColor = const Color(0xFFFDE68A);
        textColor = const Color(0xFFB45309);
        iconData = Icons.inventory_2_outlined;
        break;
      case 'preparing food':
      case 'prepares food':
      case 'preparing':
        bgColor = const Color(0xFFFFF7ED);
        borderColor = const Color(0xFFFED7AA);
        textColor = const Color(0xFFC2410C);
        iconData = Icons.restaurant_outlined;
        break;
      case 'ready for delivery':
      case 'ready':
        bgColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFFBFDBFE);
        textColor = const Color(0xFF1D4ED8);
        iconData = Icons.takeout_dining_outlined;
        break;
      case 'out for delivery':
        bgColor = const Color(0xFFEEF2FF);
        borderColor = const Color(0xFFC7D2FE);
        textColor = const Color(0xFF4338CA);
        iconData = Icons.two_wheeler_outlined;
        break;
      case 'order delivered':
      case 'delivered':
        bgColor = const Color(0xFFDCFCE7);
        borderColor = const Color(0xFF86EFAC);
        textColor = const Color(0xFF15803D);
        iconData = Icons.check_circle_rounded;
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        borderColor = const Color(0xFFCBD5E1);
        textColor = const Color(0xFF475569);
        iconData = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // --- Orders Tab (Displaying Customer's Actual Orders & Delivered Status) ---
  Widget _buildOrdersTab() {
    final orders = widget.firebaseService.transactions;

    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 56,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No Orders Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Place an order from Treats or your Cart to view your order history and delivery status here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _currentIndex = 1); // Switch to Treats
                },
                icon: const Icon(Icons.bakery_dining_rounded),
                label: const Text('Browse Treats'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF69438),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => widget.firebaseService.fetchCustomerOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            color: Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingScreen(
                      firebaseService: widget.firebaseService,
                      order: order,
                    ),
                  ),
                ).then((_) {
                  if (mounted) setState(() {});
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.receipt_outlined, size: 16, color: Color(0xFF64748B)),
                            const SizedBox(width: 6),
                            Text(
                              order.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        _buildStatusBadge(order.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.timestamp,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                    const Divider(height: 20),
                    ...order.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              const Icon(Icons.bakery_dining_rounded, size: 16, color: Color(0xFFD97706)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Payment: ${order.paymentMethod}',
                              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                            ),
                            if (order.paymentMethod == 'GCash') ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'GCash',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '₱${order.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderTrackingScreen(
                                firebaseService: widget.firebaseService,
                                order: order,
                              ),
                            ),
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                        icon: const Icon(Icons.timeline_rounded, size: 16),
                        label: const Text(
                          'Track Order Progress',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE15B2D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Profile Tab (Reference Image Design) ---
  Widget _buildProfileTab(String username, bool isAdmin) {
    final orders = widget.firebaseService.transactions;
    final fullName = widget.firebaseService.profileFullName;
    final email = widget.firebaseService.profileEmail;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF6F0),
      body: RefreshIndicator(
        color: const Color(0xFF624B1D),
        onRefresh: () async {
          await widget.firebaseService.fetchUserProfile();
          await widget.firebaseService.fetchCustomerOrders();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                // 1. Top Header: Daily Dough Branding & Donut/Settings Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Daily Dough',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'serif',
                            color: Color(0xFF3E1F0F),
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '☕ - COFFEE • DONUTS -',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Color(0xFF7C4B2E),
                          ),
                        ),
                      ],
                    ),
                    // Donut graphic with settings gear icon
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/chocolate_glazed.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.bakery_dining_rounded, size: 48, color: Color(0xFFD97706)),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => _showChangePasswordModal(context),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(
                                Icons.settings_rounded,
                                size: 16,
                                color: Color(0xFF4A2511),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 2. Profile Card
                Card(
                  elevation: 1,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _showEditProfileModal(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          // Avatar with edit pencil badge
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF7E8D8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 38,
                                    color: Color(0xFF4A2511),
                                  ),
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFE5D5C5), width: 1.5),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.edit_rounded,
                                    size: 12,
                                    color: Color(0xFF4A2511),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          // Name, Email & Role Badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isAdmin ? Icons.admin_panel_settings_rounded : Icons.workspace_premium_rounded,
                                        size: 13,
                                        color: const Color(0xFFB45309),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isAdmin ? 'Admin' : 'Customer',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFB45309),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 24,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Quick Stats Summary Bar (Orders, Rewards, Wallet Balance)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9EFE3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  child: Row(
                    children: [
                      // Total Orders
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_rounded, size: 20, color: Color(0xFF6E3E1C)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${orders.length}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF291B15),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text(
                                    'Total Orders',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF7C4B2E)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 28, color: const Color(0xFFE5D5C5)),
                      // Rewards
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded, size: 22, color: Color(0xFFE58A1F)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    '0',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF291B15),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Rewards',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF7C4B2E)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 28, color: const Color(0xFFE5D5C5)),
                      // Wallet Balance
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.account_balance_wallet_rounded, size: 20, color: Color(0xFF6E3E1C)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    '₱0.00',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF291B15),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Wallet Balance',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF7C4B2E)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // 4. Grouped Menu Card
                Card(
                  elevation: 1,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        _buildProfileMenuItem(
                          icon: Icons.inventory_2_outlined,
                          iconColor: const Color(0xFFB45309),
                          title: 'My Orders',
                          subtitle: 'Track your orders and delivery status',
                          onTap: () {
                            setState(() => _currentIndex = 2); // Switch to Orders tab
                          },
                        ),
                        const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                        _buildProfileMenuItem(
                          icon: Icons.star_rounded,
                          iconColor: const Color(0xFFEA580C),
                          title: 'My Rewards',
                          subtitle: 'Check your rewards and points',
                          onTap: () => _showRewardsModal(context),
                        ),
                        const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                        _buildProfileMenuItem(
                          icon: Icons.credit_card_rounded,
                          iconColor: const Color(0xFF4A2511),
                          title: 'Payment Methods',
                          subtitle: 'Manage your payment options',
                          onTap: () => _showPaymentMethodsModal(context),
                        ),
                        const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                        _buildProfileMenuItem(
                          icon: Icons.location_on_rounded,
                          iconColor: const Color(0xFFB45309),
                          title: 'Addresses',
                          subtitle: 'Manage your delivery addresses',
                          onTap: () => _showAddressesModal(context),
                        ),
                        const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                        _buildProfileMenuItem(
                          icon: Icons.headset_mic_rounded,
                          iconColor: const Color(0xFF6E3E1C),
                          title: 'Help & Support',
                          subtitle: 'Get help or contact us',
                          onTap: () => _showHelpSupportModal(context),
                        ),
                        const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
                        _buildProfileMenuItem(
                          icon: Icons.info_rounded,
                          iconColor: const Color(0xFF4A2511),
                          title: 'About Daily Dough',
                          subtitle: 'Learn more about us',
                          onTap: () => _showAboutModal(context),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // 5. Prominent Coffee-Brown Log Out Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      widget.firebaseService.logout();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => LoginScreen(firebaseService: widget.firebaseService),
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A2511),
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Icon(icon, size: 22, color: iconColor),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  // --- Profile Sheet Dialogs ---
  void _showEditProfileModal(BuildContext context) {
    final nameCtrl = TextEditingController(text: widget.firebaseService.profileFullName);
    final emailCtrl = TextEditingController(text: widget.firebaseService.profileEmail);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email Address *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final newName = nameCtrl.text.trim();
                        final newEmail = emailCtrl.text.trim();
                        if (newName.isEmpty || newEmail.isEmpty) return;

                        setModalState(() => isSaving = true);
                        await widget.firebaseService.updateUserProfile(
                          fullName: newName,
                          email: newEmail,
                        );
                        if (!mounted || !ctx.mounted) return;
                        Navigator.pop(ctx);
                        setState(() {});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                            backgroundColor: Color(0xFF15803D),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A2511),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isSaving ? 'Saving...' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordModal(BuildContext context) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    String? errorMsg;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              if (errorMsg != null) ...[
                const SizedBox(height: 8),
                Text(errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: oldPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_reset_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: confirmPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        setModalState(() {
                          isSaving = true;
                          errorMsg = null;
                        });

                        final res = await widget.firebaseService.changePassword(
                          oldPassword: oldPassCtrl.text,
                          newPassword: newPassCtrl.text,
                          confirmPassword: confirmPassCtrl.text,
                        );

                        if (res['success'] == true) {
                          if (!mounted || !ctx.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password changed successfully!'),
                              backgroundColor: Color(0xFF15803D),
                            ),
                          );
                        } else {
                          setModalState(() {
                            isSaving = false;
                            errorMsg = res['error'];
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A2511),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isSaving ? 'Updating...' : 'Update Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddressesModal(BuildContext context) {
    final addrCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final addresses = widget.firebaseService.userAddresses;

          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Delivery Addresses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),
                if (addresses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No saved delivery addresses yet.', style: TextStyle(color: Color(0xFF64748B))),
                  )
                else
                  ...addresses.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final addr = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFFB45309)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(addr, style: const TextStyle(fontSize: 13))),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                            onPressed: () async {
                              await widget.firebaseService.deleteUserAddress(idx);
                              setModalState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: addrCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Add new address...',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final txt = addrCtrl.text.trim();
                        if (txt.isNotEmpty) {
                          await widget.firebaseService.saveUserAddress(txt);
                          addrCtrl.clear();
                          setModalState(() {});
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A2511),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPaymentMethodsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment Methods', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.payments_outlined, color: Color(0xFF15803D)),
              title: const Text('Cash on Delivery (COD)'),
              subtitle: const Text('Pay with cash upon order arrival'),
              trailing: const Chip(label: Text('Active', style: TextStyle(fontSize: 11, color: Colors.white)), backgroundColor: Color(0xFF15803D)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.phone_android_rounded, color: Color(0xFF0284C7)),
              title: const Text('GCash'),
              subtitle: const Text('Fast e-wallet checkout'),
              trailing: const Chip(label: Text('Active', style: TextStyle(fontSize: 11, color: Colors.white)), backgroundColor: Color(0xFF0284C7)),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.credit_card_rounded, color: Color(0xFF4A2511)),
              title: const Text('Credit / Debit Card'),
              subtitle: const Text('Visa & Mastercard supported at checkout'),
              trailing: const Chip(label: Text('Active', style: TextStyle(fontSize: 11, color: Colors.white)), backgroundColor: Color(0xFF4A2511)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Color(0xFFFEF3C7), shape: BoxShape.circle),
              child: const Icon(Icons.star_rounded, size: 48, color: Color(0xFFE58A1F)),
            ),
            const SizedBox(height: 16),
            const Text('Daily Dough Rewards', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Earn loyalty stars with every freshly baked donut and coffee order! Rewards redemption will be unlocked in the upcoming loyalty update.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A2511),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpSupportModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Help & Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            const ListTile(
              leading: Icon(Icons.email_outlined, color: Color(0xFF6E3E1C)),
              title: Text('Customer Care Email'),
              subtitle: Text('support@dailydough.com'),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.access_time_rounded, color: Color(0xFF6E3E1C)),
              title: Text('Store Operating Hours'),
              subtitle: Text('Monday – Sunday: 7:00 AM – 9:00 PM'),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.location_city_rounded, color: Color(0xFF6E3E1C)),
              title: Text('Baking Hub'),
              subtitle: Text('Morong, Rizal, Philippines'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/daily_dough.png',
              height: 48,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            const Text('About Daily Dough', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Version 1.0.0 (Lab 07 Firebase Integration)', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            const Text(
              'Daily represents freshly brewed coffee.\nDough represents freshly handcrafted donuts.\n\nCrafted with passion to bring artisan sweets and warm beverages to your doorstep.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF334155), height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_done_rounded, size: 16, color: Color(0xFF15803D)),
                  const SizedBox(width: 6),
                  Text(
                    'Firebase RTDB: ${widget.firebaseService.lastFirebaseStatus}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A2511),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  List<TreatItem> get _displayTreats {
    final list = <TreatItem>[];
    final defaultNames = <String>{};

    for (final def in kTreatProducts) {
      defaultNames.add(def.name.toLowerCase());
      final fbMatch = widget.firebaseService.products.cast<Product?>().firstWhere(
            (p) => p?.name.toLowerCase() == def.name.toLowerCase(),
            orElse: () => null,
          );
      if (fbMatch != null) {
        list.add(TreatItem(
          name: fbMatch.name,
          price: fbMatch.price,
          assetPath: fbMatch.imageUrl.isNotEmpty ? fbMatch.imageUrl : def.assetPath,
          description: fbMatch.details.isNotEmpty ? fbMatch.details : def.description,
        ));
      } else {
        list.add(def);
      }
    }

    for (final p in widget.firebaseService.products) {
      if (!defaultNames.contains(p.name.toLowerCase())) {
        list.add(TreatItem(
          name: p.name,
          price: p.price,
          assetPath: p.imageUrl.isNotEmpty ? p.imageUrl : 'assets/images/pistachio.png',
          description: p.details,
        ));
      }
    }

    return list;
  }

  Widget _buildTreatItemImage(String path) {
    final clean = path.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return Image.network(
        clean,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.bakery_dining_rounded, size: 64, color: Color(0xFFD97706)),
      );
    }
    return Image.asset(
      clean.isNotEmpty ? clean : 'assets/images/pistachio.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.bakery_dining_rounded, size: 64, color: Color(0xFFD97706)),
    );
  }

  Widget _buildTreatsTab() {
    final treats = _displayTreats;
    return RefreshIndicator(
      color: const Color(0xFF624B1D),
      onRefresh: () => widget.firebaseService.fetchProducts(),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: treats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.92,
        ),
        itemBuilder: (context, index) {
          final item = treats[index];
          return _buildTreatCard(item);
        },
      ),
    );
  }

  Widget _buildTreatCard(TreatItem item) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                firebaseService: widget.firebaseService,
                item: item,
              ),
            ),
          ).then((_) {
            if (mounted) setState(() {});
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Hero(
                    tag: 'treat_${item.name}',
                    child: _buildTreatItemImage(item.assetPath),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
