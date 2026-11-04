import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:mobile_app/screens/products_screen.dart';
import 'package:mobile_app/services/firebase_service.dart';

void main() {
  group('Platform & Role Separation Verification Tests', () {
    testWidgets('1. Mobile Login Screen strictly blocks admin from mobile app', (WidgetTester tester) async {
      final service = FirebaseService();

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(firebaseService: service),
        ),
      );
      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextFormField, 'Email');
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      final loginBtn = find.widgetWithText(ElevatedButton, 'Login');

      // Attempt admin login
      await tester.enterText(emailField, 'admin');
      await tester.enterText(passwordField, 'admin123');
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      // Verify Access Guard error message is displayed and login is prevented
      expect(
        find.text('Admin accounts must use the Daily Dough Web Application. The mobile app is exclusively for customers.'),
        findsOneWidget,
      );
      expect(service.isLoggedIn, isFalse);
    });

    testWidgets('2. ProductsScreen navigation bar strictly contains only Customer tabs', (WidgetTester tester) async {
      final service = FirebaseService();

      await tester.pumpWidget(
        MaterialApp(
          home: ProductsScreen(firebaseService: service),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the 4 customer tabs exist
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Treats'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify Admin 'Product Setting' tab is completely absent
      expect(find.text('Product Setting'), findsNothing);
      expect(find.byIcon(Icons.settings_outlined), findsNothing);
    });
  });
}

