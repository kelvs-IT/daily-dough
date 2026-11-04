import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/screens/products_screen.dart';
import 'package:mobile_app/services/firebase_service.dart';

void main() {
  testWidgets('Home Tab Promotional Feed Layout and Scrolling Test', (WidgetTester tester) async {
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
        home: ProductsScreen(firebaseService: firebaseService, initialIndex: 0),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Home Tab is active
    expect(find.text('Home'), findsWidgets);

    // 2. Verify all promotional titles are rendered
    expect(find.text('Bavarian Cheese Donut Box'), findsOneWidget);
    expect(find.text('Signature Glazed Donut Trio'), findsOneWidget);
    expect(find.text('Pistachio Dream Glazed Donuts'), findsOneWidget);

    // 3. Verify descriptions are rendered
    expect(
      find.text(
        'Soft, powdered donuts filled with rich and creamy cheese Bavarian custard. Freshly prepared and perfect for sharing with family and friends.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Enjoy a colorful trio featuring our Strawberry Sprinkle, Glazed Cheese, and classic Chocolate Glazed donuts in one delightful treat.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Indulge in smooth, creamy pistachio glaze topped with crunchy crushed pistachios on our signature soft and fluffy donuts.',
      ),
      findsOneWidget,
    );

    // 4. Verify vertical cards exist
    expect(find.byType(Card), findsNWidgets(3));

    // 5. Test vertical scrolling in Home tab
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    // Verify last card is still visible or accessible
    expect(find.text('Pistachio Dream Glazed Donuts'), findsOneWidget);

    // 6. Verify navigation tabs (Delivery tab removed, Home/Treats/Orders/Profile present)
    expect(find.text('Treats'), findsOneWidget);
    expect(find.text('Delivery'), findsNothing);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}

