import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/models/product.dart';
import 'package:mobile_app/screens/checkout_screen.dart';
import 'package:mobile_app/screens/order_tracking_screen.dart';
import 'package:mobile_app/screens/products_screen.dart';
import 'package:mobile_app/services/firebase_service.dart';

void main() {
  testWidgets('Checkout multi-step flow, GCash tracking, 5 stages, and Orders tab test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final firebaseService = FirebaseService();
    await firebaseService.login('lenie', 'lenie123');

    // Add 2 Pistachio items (49 each) and 1 Blueberry Donut (60)
    final pistachio = Product(id: 'treat_pistachio', name: 'Pistachio', price: 49.0);
    final blueberry = Product(id: 'treat_blueberry', name: 'Blueberry Donut', price: 60.0);
    await firebaseService.addToCart(pistachio);
    await firebaseService.addToCart(pistachio);
    await firebaseService.addToCart(blueberry);

    await tester.pumpWidget(
      MaterialApp(
        home: CheckoutScreen(firebaseService: firebaseService),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Step 1: Order Summary & Payment Method Selection
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Delivery Information'), findsOneWidget);
    expect(find.text('Order Summary'), findsOneWidget);
    expect(find.text('Payment'), findsOneWidget);

    // Verify grouped items in summary
    expect(find.text('Pistachio'), findsOneWidget);
    expect(find.text('Blueberry Donut'), findsOneWidget);
    expect(find.text('₱158'), findsOneWidget); // 49*2 + 60 = 158

    // Verify 3 payment methods are displayed
    expect(find.text('Credit card'), findsOneWidget);
    expect(find.text('Cash on Delivery'), findsOneWidget);
    expect(find.text('GCash'), findsOneWidget);

    // Select 'GCash'
    await tester.tap(find.text('GCash'));
    await tester.pumpAndSettle();

    // 2. Test 'Next' button
    final nextBtn = find.widgetWithText(ElevatedButton, 'Next');
    expect(nextBtn, findsOneWidget);
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    // 3. Verify Step 2: Order Confirmation & Details Screen
    expect(find.text('Confirm Order'), findsWidgets);
    expect(find.text('Review Order Details'), findsOneWidget);
    expect(find.text('Payment Method: GCash'), findsOneWidget);
    expect(find.text('Pistachio x2'), findsOneWidget);
    expect(find.text('Blueberry Donut x1'), findsOneWidget);
    expect(find.text('₱158'), findsWidgets);

    // 4. Confirm Order -> Process Checkout
    final confirmOrderBtn = find.widgetWithText(ElevatedButton, 'Confirm Order');
    expect(confirmOrderBtn, findsOneWidget);
    await tester.tap(confirmOrderBtn);
    await tester.pumpAndSettle();

    // 5. Verify Step 3: Success Screen (Order Placed stage, GCash payment)
    expect(find.text('Success!'), findsOneWidget);
    expect(find.byIcon(Icons.thumb_up_alt_rounded), findsOneWidget);
    expect(find.text('Order Placed'), findsOneWidget);
    expect(find.text('Payment: GCash'), findsOneWidget);
    expect(find.text('Track Order Progress'), findsOneWidget);
    expect(find.text('View All Orders'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);

    // Cart must now be cleared
    expect(firebaseService.cartItems.isEmpty, isTrue);

    // 6. Tap 'View All Orders' -> Navigates to ProductsScreen with Orders tab selected
    await tester.tap(find.text('View All Orders'));
    await tester.pumpAndSettle();

    expect(find.byType(ProductsScreen), findsOneWidget);
    expect(find.text('My Orders'), findsOneWidget);

    // Verify that the order appears in the Orders tab with 'Order Placed' status and GCash payment
    expect(find.text('Order Placed'), findsOneWidget);
    expect(find.text('Payment: GCash'), findsOneWidget);
    expect(find.text('GCash'), findsWidgets);
    expect(find.text('₱158'), findsOneWidget);
    expect(find.text('Pistachio x2'), findsOneWidget);
    expect(find.text('Blueberry Donut x1'), findsOneWidget);

    // 7. Test Navigation to OrderTrackingScreen
    final trackBtn = find.widgetWithText(ElevatedButton, 'Track Order Progress');
    expect(trackBtn, findsOneWidget);
    await tester.tap(trackBtn);
    await tester.pumpAndSettle();

    // 8. Verify OrderTrackingScreen Elements
    expect(find.byType(OrderTrackingScreen), findsOneWidget);
    expect(find.text('Current Status'), findsOneWidget);
    expect(find.text('Step 1 of 5'), findsOneWidget);
    expect(find.text('Order Progress Stages'), findsOneWidget);

    // All 5 stages must exist
    expect(find.text('Order Placed'), findsWidgets);
    expect(find.text('Preparing Food'), findsWidgets);
    expect(find.text('Ready for Delivery'), findsWidgets);
    expect(find.text('Out for Delivery'), findsWidgets);
    expect(find.text('Order Delivered'), findsWidgets);

    // Active indicator
    expect(find.text('ACTIVE'), findsOneWidget);

    // GCash Verification badge
    expect(find.text('GCash Verified'), findsOneWidget);

    // Transparent Technical Note
    expect(
      find.text(
        'Note: Live GPS map tracking and rider photo verification are in development and require external Google Maps API and cloud storage services.',
      ),
      findsOneWidget,
    );

    // Need Help Section
    expect(find.text('Need Help with this Order?'), findsOneWidget);
    expect(find.text('Where is my food?'), findsOneWidget);

    // 9. Non-Admin / Customer Account: Section is completely removed for customers
    expect(find.text('ADMIN ONLY'), findsNothing);
    expect(find.text('Order Stage Progression'), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);

    // 10. Admin Permission Check: Login as Admin and Update Stage
    await firebaseService.login('admin', 'admin123');
    expect(firebaseService.isAdmin, isTrue);

    // Retrieve the customer's order for the admin to manage
    final currentOrder = firebaseService.transactions.first;

    await tester.pumpWidget(
      MaterialApp(
        home: OrderTrackingScreen(
          firebaseService: firebaseService,
          order: currentOrder,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Admin view shows ADMIN ACCESS
    expect(find.text('ADMIN ACCESS'), findsOneWidget);
    expect(
      find.text('Select a stage below to update this order\'s live progress in Firebase:'),
      findsOneWidget,
    );

    // Admin taps 'Order Delivered' chip
    final adminDeliveredChip = find.widgetWithText(ChoiceChip, 'Order Delivered');
    await tester.ensureVisible(adminDeliveredChip);
    await tester.tap(adminDeliveredChip);
    await tester.pumpAndSettle();

    // Scroll up to Delivery Confirmation
    await tester.ensureVisible(find.text('Delivery Confirmation'));
    await tester.pumpAndSettle();

    // Verify Order status is successfully updated and Delivery Confirmation is displayed
    expect(find.text('Delivery Confirmation'), findsOneWidget);
    expect(
      find.text(
        'Your order was successfully delivered and received. Thank you for ordering from Daily Dough!',
      ),
      findsOneWidget,
    );
    expect(find.text('Delivered'), findsOneWidget);
    expect(find.text('Order status updated to "Order Delivered"'), findsOneWidget);
  });
}

