import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/product.dart';
import 'package:mobile_app/screens/cart_screen.dart';
import 'package:mobile_app/screens/checkout_screen.dart';
import 'package:mobile_app/services/firebase_service.dart';

void main() {
  testWidgets('Cart Screen Professional Layout & Interactions Test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final firebaseService = FirebaseService();
    // Simulate login for Access Control Guard
    await firebaseService.login('lenie', 'lenie123');

    // Add 2 Pistachio items (49 each) and 1 Blueberry Donut (60)
    final pistachio = Product(id: 'treat_pistachio', name: 'Pistachio', price: 49.0);
    final blueberry = Product(id: 'treat_blueberry', name: 'Blueberry Donut', price: 60.0);
    await firebaseService.addToCart(pistachio);
    await firebaseService.addToCart(pistachio);
    await firebaseService.addToCart(blueberry);

    await tester.pumpWidget(
      MaterialApp(
        home: CartScreen(firebaseService: firebaseService),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Grouping: Pistachio appears once with quantity 2
    expect(find.text('Pistachio'), findsOneWidget);
    expect(find.text('Blueberry Donut'), findsOneWidget);
    expect(find.text('2'), findsOneWidget); // Pistachio quantity
    expect(find.text('1'), findsOneWidget); // Blueberry quantity

    // 2. Verify Red Prices
    expect(find.text('₱49'), findsOneWidget);
    expect(find.text('₱60'), findsOneWidget);

    // 3. Verify Order Summary (Subtotal: 49*2 + 60 = 158)
    expect(find.text('Subtotal'), findsOneWidget);
    expect(find.text('Total to pay'), findsOneWidget);
    expect(find.text('₱158'), findsNWidgets(2)); // Subtotal & Total to pay

    // 4. Test Increment [+] on Pistachio
    final plusButtons = find.byIcon(Icons.add);
    await tester.tap(plusButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('3'), findsOneWidget);
    expect(find.text('₱207'), findsNWidgets(2)); // 49*3 + 60 = 207

    // 5. Test Decrement [-] on Pistachio
    final minusButtons = find.byIcon(Icons.remove);
    await tester.tap(minusButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
    expect(find.text('₱158'), findsNWidgets(2));

    // 6. Test Decrement to 0 on Blueberry (quantity 1 -> 0 removes item)
    // Blueberry is the second item
    await tester.tap(minusButtons.last);
    await tester.pumpAndSettle();

    expect(find.text('Blueberry Donut'), findsNothing);
    expect(find.text('₱98'), findsNWidgets(2)); // 49*2 = 98

    // 7. Verify Checkout button
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.byIcon(Icons.lock_rounded), findsOneWidget);

    // Tap Checkout button to open CheckoutScreen
    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    expect(find.byType(CheckoutScreen), findsOneWidget);
  });
}

