import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/transaction.dart';

class FirebaseService extends ChangeNotifier {
  static const String databaseUrl =
      'https://dailydough-5480d-default-rtdb.firebaseio.com';

  bool _isLoggedIn = false;
  String _currentUsername = '';
  bool _isFirebaseConnected = false;
  String _lastFirebaseStatus = 'Checking...';

  final List<Product> _cachedProducts = [];
  final List<CartItem> _cachedCart = [];
  final List<TransactionRecord> _cachedTransactions = [];

  String _profileFullName = '';
  String _profileEmail = '';
  String _profilePhone = '';
  String _profileAvatar = '';
  final List<String> _userAddresses = [];

  bool get isLoggedIn => _isLoggedIn;
  String get currentUsername => _currentUsername;
  bool get isFirebaseConnected => _isFirebaseConnected;
  String get lastFirebaseStatus => _lastFirebaseStatus;

  String get profileFullName => _profileFullName.isNotEmpty
      ? _profileFullName
      : (isAdmin
          ? 'Admin User'
          : (_currentUsername.isNotEmpty
              ? '${_currentUsername[0].toUpperCase()}${_currentUsername.substring(1)}'
              : 'Customer'));

  String get profileEmail => _profileEmail.isNotEmpty
      ? _profileEmail
      : (_currentUsername.isNotEmpty ? '$_currentUsername@example.com' : 'customer@example.com');

  String get profilePhone => _profilePhone;
  String get profileAvatar => _profileAvatar;
  List<String> get userAddresses => List.unmodifiable(_userAddresses);

  List<Product> get products => List.unmodifiable(_cachedProducts);
  List<CartItem> get cartItems => List.unmodifiable(_cachedCart);
  List<TransactionRecord> get transactions => List.unmodifiable(_cachedTransactions);

  double get cartTotal =>
      _cachedCart.fold(0.0, (sum, item) => sum + item.price);

  FirebaseService() {
    _initDefaultProducts();
    checkFirebaseConnection();
    fetchProducts();
  }

  void _initDefaultProducts() {
    _cachedProducts.addAll([
      Product(id: 'treat_pistachio', name: 'Pistachio', price: 49.0, details: 'A delicious donut coated with creamy pistachio glaze and topped with crushed pistachios.', imageUrl: 'assets/images/pistachio.png'),
      Product(id: 'treat_matcha_donut', name: 'Matcha Donut', price: 39.0, details: 'Soft ring donut dipped in vibrant green matcha glaze with white chocolate drizzle.', imageUrl: 'assets/images/matcha_donut.png'),
      Product(id: 'treat_blueberry_donut', name: 'Blueberry Donut', price: 60.0, details: 'Glazed donut topped with rich blueberry icing and fresh blueberries.', imageUrl: 'assets/images/blueberry_donut.png'),
      Product(id: 'treat_choco_butternut', name: 'Choco Butternut', price: 39.0, details: 'Classic cake donut generously coated with rich chocolate and crunchy butternut crumbles.', imageUrl: 'assets/images/choco_butternut.png'),
      Product(id: 'treat_strawberry_sprinkle_glazed', name: 'Strawberry Sprinkle Glazed', price: 39.0, details: 'A classic donut with sweet strawberry glaze and colorful sprinkles.', imageUrl: 'assets/images/strawberry_sprinkle_glazed.png'),
      Product(id: 'treat_chocolate_glazed', name: 'Chocolate Glazed', price: 39.0, details: 'Soft golden donut dipped in decadent chocolate glaze with a delicate white swirl.', imageUrl: 'assets/images/chocolate_glazed.png'),
      Product(id: 'treat_glazed_cheese', name: 'Glazed Cheese', price: 39.0, details: 'Sweet glazed donut topped with savory shredded cheese for the perfect balance of flavors.', imageUrl: 'assets/images/glazed_cheese.png'),
      Product(id: 'treat_cappuccino', name: 'Cappuccino', price: 69.0, details: 'Rich espresso layered with steamed milk and thick velvety foam.', imageUrl: 'assets/images/Cappuccino.png'),
      Product(id: 'treat_caramel_macchiato', name: 'Caramel Macchiato', price: 99.0, details: 'Freshly steamed milk with vanilla-flavored syrup, marked with espresso and topped with caramel drizzle.', imageUrl: 'assets/images/Caramel Macchiato.png'),
      Product(id: 'treat_hot_americano', name: 'Hot Americano', price: 69.0, details: 'Espresso shots topped with hot water create a light layer of crema and deep rich flavor.', imageUrl: 'assets/images/Hot Americano.png'),
      Product(id: 'treat_hot_cafe_latte', name: 'Hot Cafe Latte', price: 99.0, details: 'Smooth espresso balanced with steamed milk and a light layer of foam.', imageUrl: 'assets/images/Hot Cafe Latte.png'),
      Product(id: 'treat_iced_americano', name: 'Iced Americano', price: 66.0, details: 'Bold espresso shots combined with cold water and ice for a crisp, refreshing coffee.', imageUrl: 'assets/images/Iced Americano.png'),
      Product(id: 'treat_iced_cafe_latte', name: 'Iced Cafe Latte', price: 99.0, details: 'Freshly brewed espresso poured over chilled milk and ice.', imageUrl: 'assets/images/Iced Cafe Latte.png'),
      Product(id: 'treat_spanish_latte', name: 'Spanish Latte', price: 69.0, details: 'A sweet and creamy espresso drink infused with condensed milk and steamed milk.', imageUrl: 'assets/images/Spanish Latte.png'),
    ]);
  }

  Future<void> checkFirebaseConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$databaseUrl/.json?shallow=true'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        _isFirebaseConnected = true;
        _lastFirebaseStatus = 'Online (Read/Write Allowed)';
      } else if (response.statusCode == 401 || response.body.contains('Permission denied')) {
        _isFirebaseConnected = true;
        _lastFirebaseStatus = 'Connected (Rules Require Auth)';
      } else {
        _isFirebaseConnected = false;
        _lastFirebaseStatus = 'HTTP ${response.statusCode}';
      }
    } catch (e) {
      _isFirebaseConnected = false;
      _lastFirebaseStatus = 'Unreachable / Offline';
    }
    notifyListeners();
  }

  // --- Authentication (Part B) ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    final cleanUser = username.trim();
    final cleanPass = password.trim();

    if (cleanUser.isEmpty) {
      return {'success': false, 'error': 'Username cannot be empty'};
    }
    if (cleanPass.isEmpty) {
      return {'success': false, 'error': 'Password cannot be empty'};
    }

    // Check Firebase /users if accessible
    bool authenticated = false;
    String authenticatedUsername = cleanUser;
    String? foundFullName;
    String? foundEmail;

    try {
      final res = await http
          .get(Uri.parse('$databaseUrl/users.json'))
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200 && res.body != 'null') {
        final Map<String, dynamic> data = json.decode(res.body);
        for (var entry in data.values) {
          if (entry is Map) {
            final uName = entry['username']?.toString().trim() ?? '';
            final uEmail = entry['email']?.toString().trim() ?? '';
            final uPass = entry['password']?.toString().trim() ?? '';

            // Match either username or email
            if ((uName.toLowerCase() == cleanUser.toLowerCase() ||
                 (cleanUser.contains('@') && uEmail.toLowerCase() == cleanUser.toLowerCase())) &&
                uPass == cleanPass) {
              authenticated = true;
              authenticatedUsername = uName.isNotEmpty ? uName : cleanUser;
              foundFullName = entry['fullName']?.toString();
              foundEmail = entry['email']?.toString();
              break;
            }
          }
        }
      }
    } catch (_) {}

    // Check Firebase /customers node if registered via Sign Up
    if (!authenticated) {
      try {
        final res = await http
            .get(Uri.parse('$databaseUrl/customers.json'))
            .timeout(const Duration(seconds: 4));

        if (res.statusCode == 200 && res.body != 'null') {
          final Map<String, dynamic> data = json.decode(res.body);
          for (var entry in data.values) {
            if (entry is Map) {
              final cEmail = entry['email']?.toString().trim() ?? '';
              final cPass = entry['password']?.toString().trim() ?? '';
              final cUsername = entry['username']?.toString().trim() ?? '';

              if ((cEmail.toLowerCase() == cleanUser.toLowerCase() ||
                   (cUsername.isNotEmpty && cUsername.toLowerCase() == cleanUser.toLowerCase())) &&
                  cPass == cleanPass) {
                authenticated = true;
                authenticatedUsername = cUsername.isNotEmpty
                    ? cUsername
                    : (entry['fullName']?.toString().trim().split(' ').first.toLowerCase() ?? cleanUser);
                foundFullName = entry['fullName']?.toString();
                foundEmail = entry['email']?.toString();
                break;
              }
            }
          }
        }
      } catch (_) {}
    }

    // Fallback/Standard expected student credentials per Lab 07 PDF (Page 4: admin / admin123)
    if (!authenticated) {
      if ((cleanUser == 'admin' && cleanPass == 'admin123') ||
          (cleanUser == 'lenie' && cleanPass == 'lenie123')) {
        authenticated = true;
        authenticatedUsername = cleanUser;
      }
    }

    if (authenticated) {
      _isLoggedIn = true;
      _currentUsername = authenticatedUsername;
      if (foundFullName != null && foundFullName.isNotEmpty) {
        _profileFullName = foundFullName;
      }
      if (foundEmail != null && foundEmail.isNotEmpty) {
        _profileEmail = foundEmail;
      }
      await fetchCart();
      await fetchCustomerOrders();
      await fetchUserProfile();
      notifyListeners();
      return {'success': true};
    } else {
      return {'success': false, 'error': 'Invalid Username or Password'};
    }
  }

  void logout() {
    _isLoggedIn = false;
    _currentUsername = '';
    _profileFullName = '';
    _profileEmail = '';
    _profilePhone = '';
    _profileAvatar = '';
    _userAddresses.clear();
    _cachedCart.clear();
    _cachedTransactions.clear();
    notifyListeners();
  }

  // --- Customer Registration (Sign Up) ---
  Future<Map<String, dynamic>> registerCustomer({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final cleanName = fullName.trim();
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();
    final cleanConfirm = confirmPassword.trim();

    // 1. Validation
    if (cleanName.isEmpty) {
      return {'success': false, 'error': 'Full name is required.'};
    }
    if (cleanEmail.isEmpty) {
      return {'success': false, 'error': 'Email address is required.'};
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(cleanEmail)) {
      return {'success': false, 'error': 'Please enter a valid email address.'};
    }
    if (cleanPassword.isEmpty) {
      return {'success': false, 'error': 'Password is required.'};
    }
    if (cleanPassword.length < 6) {
      return {'success': false, 'error': 'Password must be at least 6 characters.'};
    }
    if (cleanPassword != cleanConfirm) {
      return {'success': false, 'error': 'Passwords do not match.'};
    }

    // 2. Check if email/username already registered in Firebase
    try {
      final res = await http
          .get(Uri.parse('$databaseUrl/users.json'))
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200 && res.body != 'null') {
        final Map<String, dynamic> data = json.decode(res.body);
        for (var entry in data.values) {
          if (entry is Map &&
              (entry['email']?.toString().toLowerCase() == cleanEmail.toLowerCase() ||
               entry['username']?.toString().toLowerCase() == cleanEmail.toLowerCase())) {
            return {'success': false, 'error': 'An account with this email already exists.'};
          }
        }
      }
    } catch (_) {}

    try {
      final res = await http
          .get(Uri.parse('$databaseUrl/customers.json'))
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200 && res.body != 'null') {
        final Map<String, dynamic> data = json.decode(res.body);
        for (var entry in data.values) {
          if (entry is Map &&
              entry['email']?.toString().toLowerCase() == cleanEmail.toLowerCase()) {
            return {'success': false, 'error': 'An account with this email already exists.'};
          }
        }
      }
    } catch (_) {}

    // Derive a clean username from email or name
    final usernameDerived = cleanEmail.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');

    final timestamp = DateTime.now().toIso8601String();
    final customerData = {
      'fullName': cleanName,
      'email': cleanEmail,
      'username': usernameDerived.isNotEmpty ? usernameDerived : cleanName.toLowerCase().replaceAll(' ', '_'),
      'password': cleanPassword,
      'accountType': 'Customer',
      'createdAt': timestamp,
      'avatar': '',
      'phone': '',
    };

    // 3. Save to Firebase Realtime Database under /customers and /users
    try {
      // Create under /customers
      final customerRes = await http.post(
        Uri.parse('$databaseUrl/customers.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(customerData),
      ).timeout(const Duration(seconds: 5));

      // Also create under /users for unified authentication compatibility
      await http.post(
        Uri.parse('$databaseUrl/users.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': customerData['username'],
          'email': cleanEmail,
          'password': cleanPassword,
          'fullName': cleanName,
        }),
      ).timeout(const Duration(seconds: 5));

      // Also initialize their profile node
      final profileUser = customerData['username'].toString().toLowerCase();
      await http.put(
        Uri.parse('$databaseUrl/user_profiles/$profileUser.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fullName': cleanName,
          'email': cleanEmail,
          'phone': '',
          'avatar': '',
          'addresses': [],
        }),
      ).timeout(const Duration(seconds: 5));

      if (customerRes.statusCode == 200) {
        return {'success': true, 'message': 'Account created successfully!'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Failed to connect to Firebase. Please try again.'};
    }

    return {'success': true, 'message': 'Account created successfully!'};
  }

  // --- Products (Part A & C) ---
  Future<void> fetchProducts() async {
    try {
      final res = await http
          .get(Uri.parse('$databaseUrl/products.json'))
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200 && res.body != 'null') {
        final dynamic data = json.decode(res.body);
        final List<Product> fetched = [];

        if (data is Map) {
          data.forEach((k, v) {
            if (v is Map<String, dynamic>) {
              fetched.add(Product.fromJson(k, v));
            } else if (v is Map) {
              fetched.add(Product.fromJson(k, Map<String, dynamic>.from(v)));
            }
          });
        }
        if (fetched.isNotEmpty) {
          for (final p in fetched) {
            final existingIdx = _cachedProducts.indexWhere(
              (cp) => cp.name.toLowerCase() == p.name.toLowerCase() || cp.id == p.id,
            );
            if (existingIdx != -1) {
              _cachedProducts[existingIdx] = p;
            } else {
              _cachedProducts.add(p);
            }
          }
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  bool get isAdmin => _currentUsername.trim().toLowerCase() == 'admin';

  // --- Product CRUD Operations (Admin Only) ---
  Future<bool> addProduct({
    required String name,
    required double price,
    String details = '',
    String imageUrl = '',
  }) async {
    final newProductMap = {
      'name': name.trim(),
      'price': price,
      'details': details.trim(),
      'imageUrl': imageUrl.trim(),
    };

    try {
      final res = await http.post(
        Uri.parse('$databaseUrl/products.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newProductMap),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final decoded = json.decode(res.body);
        final String newId = decoded['name'] ?? 'prod_${DateTime.now().millisecondsSinceEpoch}';
        _cachedProducts.insert(0, Product(id: newId, name: name, price: price, details: details, imageUrl: imageUrl.trim()));
        notifyListeners();
        return true;
      }
    } catch (_) {}

    // Local fallback if offline
    final String fallbackId = 'prod_${DateTime.now().millisecondsSinceEpoch}';
    _cachedProducts.insert(0, Product(id: fallbackId, name: name, price: price, details: details, imageUrl: imageUrl.trim()));
    notifyListeners();
    return true;
  }

  Future<bool> updateProduct({
    required String id,
    required String name,
    required double price,
    String details = '',
    String imageUrl = '',
  }) async {
    final updateMap = {
      'name': name.trim(),
      'price': price,
      'details': details.trim(),
      'imageUrl': imageUrl.trim(),
    };

    try {
      await http.patch(
        Uri.parse('$databaseUrl/products/$id.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updateMap),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}

    final index = _cachedProducts.indexWhere((p) => p.id == id);
    if (index != -1) {
      _cachedProducts[index] = Product(id: id, name: name, price: price, details: details, imageUrl: imageUrl.trim());
      notifyListeners();
    }
    return true;
  }

  Future<bool> deleteProduct(String id) async {
    try {
      await http.delete(
        Uri.parse('$databaseUrl/products/$id.json'),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}

    _cachedProducts.removeWhere((p) => p.id == id);
    notifyListeners();
    return true;
  }

  String _getUserCartUrl() {
    final user = _currentUsername.trim().toLowerCase();
    if (user.isEmpty) return '$databaseUrl/cart.json';
    return '$databaseUrl/carts/$user.json';
  }

  // --- Cart Operations (Part C) ---
  int getProductQuantity(String productName) {
    return _cachedCart.where((item) => item.productName.trim().toLowerCase() == productName.trim().toLowerCase()).length;
  }

  Future<bool> addToCart(Product product) async {
    final newItem = CartItem(
      id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
      productName: product.name,
      price: product.price,
    );

    _cachedCart.add(newItem);
    notifyListeners();

    // Sync to user-isolated Firebase node /carts/{username}
    try {
      final res = await http.post(
        Uri.parse(_getUserCartUrl()),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newItem.toJson()),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final decoded = json.decode(res.body);
        if (decoded is Map && decoded['name'] != null) {
          final realId = decoded['name'].toString();
          final idx = _cachedCart.indexOf(newItem);
          if (idx != -1) {
            _cachedCart[idx] = CartItem(id: realId, productName: newItem.productName, price: newItem.price);
          }
        }
      }
    } catch (_) {}

    return true;
  }

  Future<bool> removeFromCart(String productName) async {
    final index = _cachedCart.lastIndexWhere((item) => item.productName.trim().toLowerCase() == productName.trim().toLowerCase());
    if (index == -1) return false;

    final removedItem = _cachedCart.removeAt(index);
    notifyListeners();

    final user = _currentUsername.trim().toLowerCase();
    if (user.isNotEmpty) {
      try {
        if (!removedItem.id.startsWith('cart_')) {
          await http.delete(
            Uri.parse('$databaseUrl/carts/$user/${removedItem.id}.json'),
          ).timeout(const Duration(seconds: 4));
        } else {
          // Re-sync cart to clear any inconsistency
          await http.delete(Uri.parse(_getUserCartUrl())).timeout(const Duration(seconds: 4));
          for (final item in _cachedCart) {
            await http.post(
              Uri.parse(_getUserCartUrl()),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(item.toJson()),
            ).timeout(const Duration(seconds: 2));
          }
        }
      } catch (_) {}
    }

    return true;
  }

  Future<void> setProductQuantity(Product product, int targetQuantity) async {
    final currentQty = getProductQuantity(product.name);
    if (targetQuantity > currentQty) {
      for (int i = 0; i < (targetQuantity - currentQty); i++) {
        await addToCart(product);
      }
    } else if (targetQuantity < currentQty) {
      for (int i = 0; i < (currentQty - targetQuantity); i++) {
        await removeFromCart(product.name);
      }
    }
  }

  Future<void> fetchCart() async {
    final user = _currentUsername.trim().toLowerCase();
    if (user.isEmpty) {
      _cachedCart.clear();
      notifyListeners();
      return;
    }

    try {
      final res = await http
          .get(Uri.parse(_getUserCartUrl()))
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200 && res.body != 'null') {
        final dynamic data = json.decode(res.body);
        final List<CartItem> fetched = [];

        if (data is Map) {
          data.forEach((k, v) {
            if (v is Map) {
              fetched.add(CartItem.fromJson(k, Map<String, dynamic>.from(v)));
            }
          });
        }
        _cachedCart.clear();
        _cachedCart.addAll(fetched);
        notifyListeners();
      } else {
        _cachedCart.clear();
        notifyListeners();
      }
    } catch (_) {}
  }

  // --- Transaction Processing (Part D & F) ---
  Future<void> fetchCustomerOrders() async {
    final user = _currentUsername.trim().toLowerCase();
    if (user.isEmpty) {
      _cachedTransactions.clear();
      notifyListeners();
      return;
    }

    try {
      final res = await http
          .get(Uri.parse('$databaseUrl/transactions.json'))
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200 && res.body != 'null') {
        final dynamic data = json.decode(res.body);
        final List<TransactionRecord> fetched = [];

        if (data is Map) {
          data.forEach((k, v) {
            if (v is Map) {
              final record = TransactionRecord.fromJson(k, Map<String, dynamic>.from(v));
              if (isAdmin) {
                fetched.add(record);
              } else {
                final txUser = record.username.trim().toLowerCase();
                final txCust = record.customerName.trim().toLowerCase();
                if (txUser == user || txCust == user) {
                  fetched.add(record);
                }
              }
            }
          });
        }
        fetched.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        _cachedTransactions.clear();
        _cachedTransactions.addAll(fetched);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    if (!isAdmin) {
      return false; // Security guard: Only admin can change the progress stage
    }
    final index = _cachedTransactions.indexWhere((t) => t.id == orderId);
    if (index != -1) {
      final oldTx = _cachedTransactions[index];
      final updatedTx = TransactionRecord(
        id: oldTx.id,
        customerName: oldTx.customerName,
        username: oldTx.username,
        address: oldTx.address,
        paymentMethod: oldTx.paymentMethod,
        totalAmount: oldTx.totalAmount,
        status: newStatus,
        timestamp: oldTx.timestamp,
        items: oldTx.items,
      );
      _cachedTransactions[index] = updatedTx;
      notifyListeners();

      try {
        await http.patch(
          Uri.parse('$databaseUrl/transactions/$orderId.json'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'status': newStatus}),
        ).timeout(const Duration(seconds: 4));
      } catch (_) {}

      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> processCheckout({
    required String customerName,
    required String address,
    required String paymentMethod,
  }) async {
    if (customerName.trim().isEmpty ||
        address.trim().isEmpty ||
        paymentMethod.trim().isEmpty) {
      return {'success': false, 'error': 'Validation Error: All fields are required.'};
    }

    if (_cachedCart.isEmpty) {
      return {'success': false, 'error': 'Cart is empty!'};
    }

    final double computedTotal = cartTotal;

    // Group items to list with quantities
    final Map<String, int> qtyMap = {};
    for (final item in _cachedCart) {
      qtyMap[item.productName] = (qtyMap[item.productName] ?? 0) + 1;
    }
    final List<String> itemSummaries = qtyMap.entries.map((e) => '${e.key} x${e.value}').toList();

    final tx = TransactionRecord(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      customerName: customerName.trim(),
      username: _currentUsername.trim(),
      address: address.trim(),
      paymentMethod: paymentMethod.trim(),
      totalAmount: computedTotal,
      status: 'Order Placed',
      timestamp: DateTime.now().toIso8601String(),
      items: itemSummaries,
    );

    // Save to Firebase /transactions
    bool saveSuccess = false;
    try {
      final res = await http.post(
        Uri.parse('$databaseUrl/transactions.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(tx.toJson()),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        saveSuccess = true;
      }
    } catch (_) {}

    if (saveSuccess || !_isFirebaseConnected) {
      _cachedTransactions.insert(0, tx);
      if (address.trim().isNotEmpty && !_userAddresses.contains(address.trim())) {
        saveUserAddress(address.trim());
      }
      await clearCart();
      return {
        'success': true,
        'transaction': tx,
      };
    } else {
      return {
        'success': false,
        'error': 'Failed to save order to Firebase. Your cart has been preserved.',
      };
    }
  }

  Future<void> clearCart() async {
    _cachedCart.clear();
    notifyListeners();

    try {
      await http.delete(Uri.parse(_getUserCartUrl())).timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  // --- Profile & Account Management ---
  Future<void> fetchUserProfile() async {
    final user = _currentUsername.trim().toLowerCase();
    if (user.isEmpty) return;

    try {
      final res = await http
          .get(Uri.parse('$databaseUrl/user_profiles/$user.json'))
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200 && res.body != 'null') {
        final dynamic data = json.decode(res.body);
        if (data is Map) {
          _profileFullName = data['fullName']?.toString() ?? '';
          _profileEmail = data['email']?.toString() ?? '';
          _profilePhone = data['phone']?.toString() ?? '';
          _profileAvatar = data['avatar']?.toString() ?? '';

          if (data['addresses'] is List) {
            _userAddresses.clear();
            for (var addr in data['addresses']) {
              if (addr != null && addr.toString().trim().isNotEmpty) {
                _userAddresses.add(addr.toString().trim());
              }
            }
          }
        }
      }
    } catch (_) {}

    // Check /customers node if fullName or email is still empty
    if (_profileFullName.isEmpty || _profileEmail.isEmpty) {
      try {
        final res = await http
            .get(Uri.parse('$databaseUrl/customers.json'))
            .timeout(const Duration(seconds: 4));
        if (res.statusCode == 200 && res.body != 'null') {
          final dynamic data = json.decode(res.body);
          if (data is Map) {
            for (var entry in data.values) {
              if (entry is Map &&
                  (entry['username']?.toString().toLowerCase() == user ||
                   entry['email']?.toString().toLowerCase() == user)) {
                if (_profileFullName.isEmpty && entry['fullName'] != null) {
                  _profileFullName = entry['fullName'].toString();
                }
                if (_profileEmail.isEmpty && entry['email'] != null) {
                  _profileEmail = entry['email'].toString();
                }
                if (_profilePhone.isEmpty && entry['phone'] != null) {
                  _profilePhone = entry['phone'].toString();
                }
                break;
              }
            }
          }
        }
      } catch (_) {}
    }

    // Fallback: Populate default address from last completed transaction if empty
    if (_userAddresses.isEmpty && _cachedTransactions.isNotEmpty) {
      final lastAddr = _cachedTransactions.first.address.trim();
      if (lastAddr.isNotEmpty) {
        _userAddresses.add(lastAddr);
      }
    }
    notifyListeners();
  }

  Future<bool> updateUserProfile({
    String? fullName,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    final user = _currentUsername.trim().toLowerCase();
    if (user.isEmpty) return false;

    if (fullName != null) _profileFullName = fullName.trim();
    if (email != null) _profileEmail = email.trim();
    if (phone != null) _profilePhone = phone.trim();
    if (avatar != null) _profileAvatar = avatar.trim();

    notifyListeners();

    try {
      await http.patch(
        Uri.parse('$databaseUrl/user_profiles/$user.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fullName': _profileFullName,
          'email': _profileEmail,
          'phone': _profilePhone,
          'avatar': _profileAvatar,
        }),
      ).timeout(const Duration(seconds: 4));

      // Also sync to /customers if present
      final custRes = await http
          .get(Uri.parse('$databaseUrl/customers.json'))
          .timeout(const Duration(seconds: 4));
      if (custRes.statusCode == 200 && custRes.body != 'null') {
        final Map<String, dynamic> custData = json.decode(custRes.body);
        for (var entry in custData.entries) {
          if (entry.value is Map &&
              (entry.value['username']?.toString().toLowerCase() == user ||
               entry.value['email']?.toString().toLowerCase() == user)) {
            await http.patch(
              Uri.parse('$databaseUrl/customers/${entry.key}.json'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'fullName': _profileFullName,
                'email': _profileEmail,
                'phone': _profilePhone,
                'avatar': _profileAvatar,
              }),
            ).timeout(const Duration(seconds: 3));
            break;
          }
        }
      }
      return true;
    } catch (_) {
      return true; // Local changes preserved
    }
  }

  Future<bool> saveUserAddress(String address) async {
    final clean = address.trim();
    if (clean.isEmpty) return false;

    if (!_userAddresses.contains(clean)) {
      _userAddresses.add(clean);
      notifyListeners();
    }

    final user = _currentUsername.trim().toLowerCase();
    if (user.isEmpty) return true;

    try {
      await http.put(
        Uri.parse('$databaseUrl/user_profiles/$user/addresses.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_userAddresses),
      ).timeout(const Duration(seconds: 4));
    } catch (_) {}

    return true;
  }

  Future<bool> deleteUserAddress(int index) async {
    if (index >= 0 && index < _userAddresses.length) {
      _userAddresses.removeAt(index);
      notifyListeners();

      final user = _currentUsername.trim().toLowerCase();
      if (user.isEmpty) return true;

      try {
        await http.put(
          Uri.parse('$databaseUrl/user_profiles/$user/addresses.json'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(_userAddresses),
        ).timeout(const Duration(seconds: 4));
      } catch (_) {}

      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final cleanOld = oldPassword.trim();
    final cleanNew = newPassword.trim();
    final cleanConfirm = confirmPassword.trim();

    if (cleanOld.isEmpty) {
      return {'success': false, 'error': 'Please enter your current password.'};
    }
    if (cleanNew.isEmpty) {
      return {'success': false, 'error': 'New password cannot be empty.'};
    }
    if (cleanNew.length < 6) {
      return {'success': false, 'error': 'New password must be at least 6 characters.'};
    }
    if (cleanNew != cleanConfirm) {
      return {'success': false, 'error': 'New passwords do not match.'};
    }

    final user = _currentUsername.trim().toLowerCase();
    bool oldPasswordValid = false;
    String? userKey;

    try {
      final res = await http
          .get(Uri.parse('$databaseUrl/users.json'))
          .timeout(const Duration(seconds: 4));

      if (res.statusCode == 200 && res.body != 'null') {
        final dynamic data = json.decode(res.body);
        if (data is Map) {
          data.forEach((k, v) {
            if (v is Map && v['username']?.toString().toLowerCase() == user) {
              userKey = k;
              if (v['password']?.toString() == cleanOld) {
                oldPasswordValid = true;
              }
            }
          });
        }
      }
    } catch (_) {}

    // Fallback student credential validation
    if (!oldPasswordValid) {
      if ((user == 'admin' && cleanOld == 'admin123') ||
          (user == 'lenie' && cleanOld == 'lenie123')) {
        oldPasswordValid = true;
      }
    }

    if (!oldPasswordValid) {
      return {'success': false, 'error': 'Current password is incorrect.'};
    }

    // Persist new password to Firebase
    try {
      final targetKey = userKey ?? (user == 'admin' ? 'user1' : 'user2');
      await http.patch(
        Uri.parse('$databaseUrl/users/$targetKey.json'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'password': cleanNew}),
      ).timeout(const Duration(seconds: 4));
    } catch (_) {}

    return {'success': true};
  }
}
