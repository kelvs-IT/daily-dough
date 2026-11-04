import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:mobile_app/screens/register_screen.dart';
import 'package:mobile_app/services/firebase_service.dart';

void main() {
  testWidgets('Sign Up Flow: Open registration, validation checks, and password toggle', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final firebaseService = FirebaseService();

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(firebaseService: firebaseService),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify "Sign up" button exists on Login screen
    final signUpButton = find.text('Sign up');
    expect(signUpButton, findsOneWidget);

    // 2. Tap "Sign up" to navigate to RegisterScreen
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Sign Up'), findsNWidgets(2)); // Heading & Button
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Already have an account? '), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Sign up with Google'), findsOneWidget);

    // 3. Test empty submission triggers validation error
    final registerSubmitButton = find.widgetWithText(ElevatedButton, 'Sign Up');
    await tester.tap(registerSubmitButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter your name'), findsOneWidget);

    // 4. Test invalid email format validation
    final textFields = find.byType(TextFormField);
    // Index 0: Name, 1: Email, 2: Password
    await tester.enterText(textFields.at(0), 'Kelvin Santos');
    await tester.tap(registerSubmitButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email address'), findsOneWidget);

    await tester.enterText(textFields.at(1), 'notanemail');
    await tester.tap(registerSubmitButton);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email address'), findsOneWidget);

    // 5. Test short password validation
    await tester.enterText(textFields.at(1), 'kelvin@example.com');
    await tester.enterText(textFields.at(2), '123');
    await tester.tap(registerSubmitButton);
    await tester.pumpAndSettle();
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);

    // 6. Test password toggle icon
    final visibilityOffIcons = find.byIcon(Icons.visibility_off_outlined);
    expect(visibilityOffIcons, findsOneWidget);
    await tester.tap(visibilityOffIcons.first);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    // 7. Test back navigation returns to Login
    final backButton = find.byTooltip('Back to Login');
    await tester.tap(backButton);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
