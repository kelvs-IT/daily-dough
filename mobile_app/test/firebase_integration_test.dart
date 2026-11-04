import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/services/firebase_service.dart';
import 'package:mobile_app/models/product.dart';

void main() {
  group('Firebase Realtime Database Full Integration Unit Tests', () {
    late FirebaseService service;

    setUp(() {
      service = FirebaseService();
    });

    test('1. FirebaseService initializes with official Daily Dough products and checks connection', () {
      expect(FirebaseService.databaseUrl, equals('https://dailydough-5480d-default-rtdb.firebaseio.com'));
      expect(service.products.length, greaterThanOrEqualTo(14));
      expect(service.products.any((p) => p.name == 'Pistachio'), isTrue);
      expect(service.products.any((p) => p.name == 'Cappuccino'), isTrue);
    });

    test('2. Customer profile and fallback name/email generation', () {
      expect(service.profileFullName, equals('Customer'));
      expect(service.profileEmail, equals('customer@example.com'));
    });

    test('3. Local and Firebase user addresses management', () async {
      expect(service.userAddresses.isEmpty, isTrue);

      await service.saveUserAddress('123 Rizal St, Morong, Rizal');
      expect(service.userAddresses.contains('123 Rizal St, Morong, Rizal'), isTrue);
      expect(service.userAddresses.length, equals(1));

      await service.saveUserAddress('456 Quezon Ave, Angono, Rizal');
      expect(service.userAddresses.length, equals(2));

      await service.deleteUserAddress(1);
      expect(service.userAddresses.length, equals(1));
      expect(service.userAddresses.first, equals('123 Rizal St, Morong, Rizal'));
    });

    test('4. Cart add, quantity check, and clear flow', () async {
      final product = Product(id: 'prod_test', name: 'Pistachio', price: 49.0);
      await service.addToCart(product);
      expect(service.getProductQuantity('Pistachio'), equals(1));
      expect(service.cartTotal, equals(49.0));

      await service.addToCart(product);
      expect(service.getProductQuantity('Pistachio'), equals(2));
      expect(service.cartTotal, equals(98.0));

      await service.removeFromCart('Pistachio');
      expect(service.getProductQuantity('Pistachio'), equals(1));
      expect(service.cartTotal, equals(49.0));

      await service.clearCart();
      expect(service.getProductQuantity('Pistachio'), equals(0));
      expect(service.cartTotal, equals(0.0));
    });

    test('5. Process checkout creates TransactionRecord, empties cart, and auto-saves address', () async {
      final product = Product(id: 'prod_capp', name: 'Cappuccino', price: 69.0);
      await service.addToCart(product);
      expect(service.cartTotal, equals(69.0));

      final res = await service.processCheckout(
        customerName: 'Juan Dela Cruz',
        address: 'Barangay San Juan, Taytay, Rizal',
        paymentMethod: 'GCash',
      );

      expect(res['success'], isTrue);
      expect(res['transaction'], isNotNull);
      expect(service.cartTotal, equals(0.0));
      expect(service.userAddresses.contains('Barangay San Juan, Taytay, Rizal'), isTrue);
    });

    test('6. Registration validation rules', () async {
      // Empty name
      var res = await service.registerCustomer(fullName: '', email: 'test@example.com', password: 'password123', confirmPassword: 'password123');
      expect(res['success'], isFalse);
      expect(res['error'], contains('Full name'));

      // Invalid email
      res = await service.registerCustomer(fullName: 'John', email: 'invalid-email', password: 'password123', confirmPassword: 'password123');
      expect(res['success'], isFalse);
      expect(res['error'], contains('valid email'));

      // Short password
      res = await service.registerCustomer(fullName: 'John', email: 'john@example.com', password: '123', confirmPassword: '123');
      expect(res['success'], isFalse);
      expect(res['error'], contains('at least 6 characters'));

      // Mismatched passwords
      res = await service.registerCustomer(fullName: 'John', email: 'john@example.com', password: 'password123', confirmPassword: 'password999');
      expect(res['success'], isFalse);
      expect(res['error'], contains('do not match'));
    });
  });
}

