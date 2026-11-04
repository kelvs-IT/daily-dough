import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/screens/product_detail_screen.dart';
import 'package:mobile_app/screens/products_screen.dart';
import 'package:mobile_app/services/firebase_service.dart';

void main() {
  testWidgets('Product Detail View, Navigation, Quantity, and Add to Cart Test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final firebaseService = FirebaseService();
    await firebaseService.login('lenie', 'lenie123');

    await tester.pumpWidget(
      MaterialApp(
        home: ProductsScreen(firebaseService: firebaseService, initialIndex: 1), // Treats tab
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Treat tab is active with products
    expect(find.text('Strawberry Sprinkle Glazed'), findsOneWidget);
    expect(find.text('Pistachio'), findsOneWidget);

    // 2. Tap on "Strawberry Sprinkle Glazed" card to open ProductDetailScreen
    await tester.tap(find.text('Strawberry Sprinkle Glazed'));
    await tester.pumpAndSettle();

    // Verify ProductDetailScreen is now open
    expect(find.byType(ProductDetailScreen), findsOneWidget);

    // 3. Verify Elements on Detail Screen
    // Upper-left Back Arrow Icon
    final backIconFinder = find.byIcon(Icons.arrow_back_rounded);
    expect(backIconFinder, findsOneWidget);

    // Product Name and Price
    expect(find.text('Strawberry Sprinkle Glazed'), findsOneWidget);
    expect(find.text('₱39'), findsOneWidget);

    // Product Description
    expect(
      find.text('A classic donut with sweet strawberry glaze and colorful sprinkles.'),
      findsOneWidget,
    );

    // Quantity selector
    expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    // Add to Cart button
    final addToCartBtn = find.widgetWithText(ElevatedButton, 'Add to Cart');
    expect(addToCartBtn, findsOneWidget);

    // 4. Test Back Navigation
    await tester.tap(backIconFinder);
    await tester.pumpAndSettle();

    // Verify returned to Treats tab (not Home tab)
    expect(find.byType(ProductDetailScreen), findsNothing);
    expect(find.byType(ProductsScreen), findsOneWidget);
    expect(find.text('Strawberry Sprinkle Glazed'), findsOneWidget);

    // 5. Open Detail Screen again to test Add to Cart with Quantity
    await tester.tap(find.text('Strawberry Sprinkle Glazed'));
    await tester.pumpAndSettle();

    // Increase quantity from 1 to 3
    final plusBtn = find.byIcon(Icons.add_rounded);
    await tester.tap(plusBtn);
    await tester.pumpAndSettle();
    await tester.tap(plusBtn);
    await tester.pumpAndSettle();
    expect(find.text('3'), findsOneWidget);

    // Tap Add to Cart
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add to Cart'));
    await tester.pumpAndSettle();

    // Verify green confirmation is displayed
    expect(find.text('Added to cart'), findsOneWidget);

    // Verify cart in firebaseService has 3 items of Strawberry Sprinkle Glazed (39 * 3 = 117)
    expect(firebaseService.getProductQuantity('Strawberry Sprinkle Glazed'), equals(3));
    expect(firebaseService.cartTotal, equals(117.0));

    // 6. Test Back button preserves cart state
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // On Treats tab, cart has 3 items
    expect(firebaseService.cartItems.length, equals(3));
    expect(firebaseService.cartTotal, equals(117.0));
  });
}
