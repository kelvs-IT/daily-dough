import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:mobile_app/screens/products_screen.dart';
import 'package:mobile_app/services/firebase_service.dart';

void main() {
  testWidgets('Daily Dough Profile Tab UI and Features Comprehensive Test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final firebaseService = FirebaseService();
    await firebaseService.login('lenie', 'lenie123');

    // Launch ProductsScreen directly on the Profile tab (index 3 for customer)
    await tester.pumpWidget(
      MaterialApp(
        home: ProductsScreen(
          firebaseService: firebaseService,
          initialIndex: 3,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Profile Header and Branding
    expect(find.text('Daily Dough'), findsWidgets);
    expect(find.textContaining('COFFEE • DONUTS'), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);

    // 2. Verify Profile Card
    // Default name is derived from logged in user (Lenie)
    expect(find.text('Lenie'), findsOneWidget);
    expect(find.text('lenie@example.com'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);

    // 3. Verify Quick Stats Summary Bar
    expect(find.text('Total Orders'), findsOneWidget);
    expect(find.text('Rewards'), findsOneWidget);
    expect(find.text('Wallet Balance'), findsOneWidget);
    expect(find.text('0'), findsWidgets); // orders count or rewards
    expect(find.text('₱0.00'), findsOneWidget);

    // 4. Verify Grouped Menu Items
    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('Track your orders and delivery status'), findsOneWidget);
    expect(find.text('My Rewards'), findsOneWidget);
    expect(find.text('Check your rewards and points'), findsOneWidget);
    expect(find.text('Payment Methods'), findsOneWidget);
    expect(find.text('Manage your payment options'), findsOneWidget);
    expect(find.text('Addresses'), findsOneWidget);
    expect(find.text('Manage your delivery addresses'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Get help or contact us'), findsOneWidget);
    expect(find.text('About Daily Dough'), findsOneWidget);
    expect(find.text('Learn more about us'), findsOneWidget);

    // 5. Verify Prominent Logout Button
    expect(find.text('Log Out'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);

    // 6. Test Edit Profile Modal
    await tester.tap(find.text('Lenie'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Profile'), findsOneWidget);
    final nameField = find.widgetWithText(TextField, 'Full Name *');
    expect(nameField, findsOneWidget);

    await tester.enterText(nameField, 'Kelvin Santos');
    final saveBtn = find.widgetWithText(ElevatedButton, 'Save Changes');
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Verify updated full name displayed in profile card
    expect(find.text('Kelvin Santos'), findsOneWidget);

    // 7. Test Addresses Modal (View & Add Address)
    await tester.tap(find.text('Addresses'));
    await tester.pumpAndSettle();

    expect(find.text('Delivery Addresses'), findsOneWidget);
    expect(find.text('No saved delivery addresses yet.'), findsOneWidget);

    final addressField = find.widgetWithText(TextField, 'Add new address...');
    expect(addressField, findsOneWidget);
    await tester.enterText(addressField, '123 Bakery Lane, Sweet City, Metro Manila');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add'));
    await tester.pumpAndSettle();

    // Verify address is in the list
    expect(find.text('123 Bakery Lane, Sweet City, Metro Manila'), findsOneWidget);

    // Close Addresses sheet
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // 8. Test Payment Methods Modal
    await tester.tap(find.text('Payment Methods'));
    await tester.pumpAndSettle();

    expect(find.text('Payment Methods'), findsWidgets);
    expect(find.text('Cash on Delivery (COD)'), findsOneWidget);
    expect(find.text('GCash'), findsOneWidget);
    expect(find.text('Credit / Debit Card'), findsOneWidget);

    // Close Payment Methods sheet
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // 9. Test Change Password Modal (via Settings Gear Icon)
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Current Password *'), findsOneWidget);
    expect(find.text('New Password *'), findsOneWidget);
    expect(find.text('Confirm New Password *'), findsOneWidget);

    // Close Change Password sheet
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    // 10. Test My Orders Navigation
    await tester.tap(find.text('My Orders'));
    await tester.pumpAndSettle();

    // Should switch to Orders tab
    expect(find.text('No Orders Yet'), findsOneWidget);

    // Switch back to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Log Out'), findsOneWidget);

    // 11. Test Log Out Functionality
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();

    // Should redirect to LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(firebaseService.isLoggedIn, isFalse);
  });
}
