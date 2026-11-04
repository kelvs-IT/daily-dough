import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/screens/products_screen.dart';
import 'package:mobile_app/screens/cart_screen.dart';
import 'package:mobile_app/services/firebase_service.dart';

void main() {
  testWidgets('Treats Tab Confirm and Cart Flow Test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final firebaseService = FirebaseService();

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

    // 2. Test ADD button: customer picks quantity first
    expect(find.text('CONFIRM'), findsNothing);
    final initialCartTotal = firebaseService.cartTotal;

    final addButtons = find.byType(ElevatedButton);
    expect(addButtons, findsWidgets);
    await tester.tap(addButtons.first); // Tap Pistachio ADD
    await tester.pumpAndSettle();

    // Quantity controls show 1 and button shows "CONFIRM" with brown background
    expect(find.text('1'), findsOneWidget);
    expect(find.text('CONFIRM'), findsOneWidget);

    // Verify brown color #624B1D while waiting to confirm
    final brownContainerFinder = find.byWidgetPredicate(
      (w) => w is Container && (w.decoration as BoxDecoration?)?.color == const Color(0xFF624B1D),
    );
    expect(brownContainerFinder, findsOneWidget);

    // Not yet in cart before confirm
    expect(firebaseService.getProductQuantity('Pistachio'), equals(0));
    expect(firebaseService.cartTotal, equals(initialCartTotal));

    // 3. Increment quantity to 2
    final plusButton = find.byIcon(Icons.add);
    await tester.tap(plusButton.first);
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
    expect(find.text('CONFIRM'), findsOneWidget);
    expect(firebaseService.getProductQuantity('Pistachio'), equals(0));

    // 4. Click CONFIRM button -> Now it is added to the cart and changes to green #B2BE33!
    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    expect(firebaseService.getProductQuantity('Pistachio'), equals(2));
    final greenContainerFinder = find.byWidgetPredicate(
      (w) => w is Container && (w.decoration as BoxDecoration?)?.color == const Color(0xFFB2BE33),
    );
    expect(greenContainerFinder, findsOneWidget);
    expect(firebaseService.cartTotal, equals(initialCartTotal + 98.0));

    // 5. Verify Top-Right Cart button has the badge showing 2 items
    expect(find.byTooltip('Cart'), findsOneWidget);
    expect(find.text('2'), findsWidgets); // on card and in top-right badge

    // Tap top-right Cart button to open CartScreen
    await tester.tap(find.byTooltip('Cart'));
    await tester.pumpAndSettle();
    expect(find.byType(CartScreen), findsOneWidget);

    // Pop back to ProductsScreen
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // 6. Test Profile tab has the Logout button
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Log Out'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
  });
}
