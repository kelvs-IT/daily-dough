import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/screens/products_screen.dart';
import 'package:mobile_app/services/firebase_service.dart';

void main() {
  testWidgets('DailyDoughApp smoke test with official logo verification', (WidgetTester tester) async {
    await tester.pumpWidget(const DailyDoughApp());
    expect(find.text('Daily Dough'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);

    // Verify official Daily Dough logo is rendered on LoginScreen
    final logoFinder = find.byWidgetPredicate(
      (w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == 'assets/images/daily_dough.png',
    );
    expect(logoFinder, findsOneWidget);
  });

  testWidgets('ProductsScreen AppBar displays official Daily Dough logo on Home tab', (WidgetTester tester) async {
    final firebaseService = FirebaseService();
    await tester.pumpWidget(
      MaterialApp(
        home: ProductsScreen(firebaseService: firebaseService),
      ),
    );
    await tester.pumpAndSettle();

    // Verify official Daily Dough logo is rendered in the AppBar
    final appBarLogoFinder = find.descendant(
      of: find.byType(AppBar),
      matching: find.byWidgetPredicate(
        (w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == 'assets/images/daily_dough.png',
      ),
    );
    expect(appBarLogoFinder, findsOneWidget);
  });
}
