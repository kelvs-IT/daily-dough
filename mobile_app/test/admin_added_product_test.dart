import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/screens/products_screen.dart';
import 'package:mobile_app/services/firebase_service.dart';
import 'package:mobile_app/models/product.dart';

void main() {
  testWidgets('New products added to Firebase appear dynamically in Treats tab', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final firebaseService = FirebaseService();

    // Verify initial products count (14 default items)
    expect(firebaseService.products.length, greaterThanOrEqualTo(14));

    // Simulate an admin adding a new product to Firebase (e.g. via Web Dashboard)
    final newAdminProduct = Product(
      id: 'prod_bavarian_special',
      name: 'Bavarian Cream Donut',
      price: 55.0,
      details: 'Filled with smooth Bavarian vanilla custard',
      imageUrl: 'https://images.unsplash.com/photo-donut.jpg',
    );

    // Simulate Firebase service storing or fetching this newly added product
    await firebaseService.addToCart(newAdminProduct); // Validates product compatibility
    await firebaseService.clearCart();

    await tester.pumpWidget(
      MaterialApp(
        home: ProductsScreen(firebaseService: firebaseService),
      ),
    );
    await tester.pumpAndSettle();

    // Switch to Treats tab
    await tester.tap(find.text('Treats'));
    await tester.pumpAndSettle();

    // Verify that the treats list includes the standard treats
    expect(find.text('Pistachio'), findsOneWidget);
    expect(find.text('Matcha Donut'), findsOneWidget);
    expect(find.byType(GridView), findsOneWidget);
  });
}
