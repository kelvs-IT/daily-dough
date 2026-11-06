import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/screens/products_screen.dart';
import 'package:mobile_app/screens/product_detail_screen.dart';
import 'package:mobile_app/screens/cart_screen.dart';
import 'package:mobile_app/services/firebase_service.dart';

void main() {
  testWidgets('Treats Tab Clean Browsing and Product Detail Cart Flow Test', (WidgetTester tester) async {
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
        home: ProductsScreen(firebaseService: firebaseService),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Switch to Treats tab (index 1)
    await tester.tap(find.text('Treats'));
    await tester.pumpAndSettle();

    // Verify all 14 product names in exact order
    expect(kTreatProducts.length, equals(14));
    expect(kTreatProducts[0].name, equals('Pistachio'));
    expect(kTreatProducts[1].name, equals('Matcha Donut'));
    expect(kTreatProducts[2].name, equals('Blueberry Donut'));
    expect(kTreatProducts[3].name, equals('Choco Butternut'));
    expect(kTreatProducts[4].name, equals('Strawberry Sprinkle Glazed'));
    expect(kTreatProducts[5].name, equals('Chocolate Glazed'));
    expect(kTreatProducts[6].name, equals('Glazed Cheese'));
    expect(kTreatProducts[7].name, equals('Cappuccino'));
    expect(kTreatProducts[8].name, equals('Caramel Macchiato'));
    expect(kTreatProducts[9].name, equals('Hot Americano'));
    expect(kTreatProducts[10].name, equals('Hot Cafe Latte'));
    expect(kTreatProducts[11].name, equals('Iced Americano'));
    expect(kTreatProducts[12].name, equals('Iced Cafe Latte'));
    expect(kTreatProducts[13].name, equals('Spanish Latte'));

    // 2. Verify NO Add to Cart buttons, CONFIRM buttons, or prices on cards
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.text('CONFIRM'), findsNothing);
    expect(find.text('Add to Cart'), findsNothing);

    // 3. Tap on the first donut ('Pistachio') to open ProductDetailScreen
    await tester.tap(find.text('Pistachio').first);
    await tester.pumpAndSettle();

    expect(find.byType(ProductDetailScreen), findsOneWidget);
    expect(find.text('Pistachio'), findsWidgets);
    expect(find.text('₱49'), findsOneWidget);
    expect(find.text('Add to Cart'), findsOneWidget);
    expect(find.text('1'), findsOneWidget); // Default quantity is 1

    // 4. Increase quantity to 2
    final plusBtn = find.byIcon(Icons.add_rounded);
    expect(plusBtn, findsOneWidget);
    await tester.tap(plusBtn);
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);

    // 5. Tap Add to Cart button
    await tester.tap(find.text('Add to Cart'));
    await tester.pumpAndSettle();

    // Check that quantity was added to cart
    expect(firebaseService.getProductQuantity('Pistachio'), equals(2));
    expect(firebaseService.cartTotal, equals(98.0));

    // Confirmation message shown
    expect(find.text('Added to cart'), findsOneWidget);

    // 6. Pop back to Treats tab
    final backBtn = find.byIcon(Icons.arrow_back_rounded);
    await tester.tap(backBtn);
    await tester.pumpAndSettle();

    // ProductDetailScreen popped, back on Treats tab
    expect(find.byType(ProductDetailScreen), findsNothing);

    // 7. Verify Top-Right Cart button shows badge with 2 items
    expect(find.byTooltip('Cart'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    // Tap Cart button to open CartScreen
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();
    expect(find.byType(CartScreen), findsOneWidget);
    expect(find.text('Pistachio'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
