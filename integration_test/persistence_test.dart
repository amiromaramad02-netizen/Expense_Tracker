import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker/main.dart' as app;
import 'package:expense_tracker/pages/add_expense_page.dart';
import 'package:expense_tracker/pages/home_page.dart';
import 'package:expense_tracker/pages/settings_page.dart';
import 'package:expense_tracker/stores/expense_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('signup -> profile -> add expense -> change currency -> logout -> login restores data', (WidgetTester tester) async {
    // Ensure clean prefs for deterministic test
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Start the app
    app.main();
    await tester.pumpAndSettle();

    // Move to Sign Up
    final signUpLink = find.text('Sign Up');
    expect(signUpLink, findsOneWidget);
    await tester.tap(signUpLink);
    await tester.pumpAndSettle();

    // Fill signup form
    const email = 'test_user@example.com';
    const password = 'password123';
    await tester.enterText(find.widgetWithText(TextField, 'Enter your email'), email);
    await tester.enterText(find.widgetWithText(TextField, 'Create a password'), password);
    await tester.enterText(find.widgetWithText(TextField, 'Confirm your password'), password);
    // The title also contains 'Create Account', target the button specifically
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pumpAndSettle();

    // Profile setup
    await tester.enterText(find.widgetWithText(TextField, 'Enter your name'), 'Tester');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Add an expense by pushing AddExpensePage (the FAB isn't present when navigating directly to Home)
    await tester.runAsync(() async {
      final context = tester.element(find.byType(HomePage));
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddExpensePage()));
    });
    await tester.pumpAndSettle();

    // Fill expense form
    await tester.enterText(find.widgetWithText(TextField, 'e.g., Coffee'), 'Test Coffee');
    await tester.enterText(find.widgetWithText(TextField, 'Enter amount'), '12.5');
    await tester.enterText(find.widgetWithText(TextField, 'Add notes...'), 'Integration test');
    // Ensure Save button is visible (form is scrollable)
    await tester.ensureVisible(find.widgetWithText(ElevatedButton, 'Save Expense'));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save Expense'));
    await tester.pumpAndSettle();

    // Verify expense was added to the store
    expect(expenseStore.items.any((e) => e.title == 'Test Coffee'), isTrue);
    // Wait a bit and allow UI to rebuild
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    // And also verify it appears on the home UI
    expect(find.text('Test Coffee'), findsOneWidget);

    // Open Settings by pushing SettingsPage so we can access its controls
    await tester.runAsync(() async {
      final context = tester.element(find.byType(HomePage));
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
    });
    await tester.pumpAndSettle();

    // Change currency to USD
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(r'$ USD').last);
    await tester.pumpAndSettle();

    // Pop back to Home
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // Verify currency change reflected in an amount string (contains $)
    expect(find.textContaining(r'$'), findsWidgets);

    // Now open Settings again to logout
    await tester.tap(find.byTooltip('Back')); // ensure any overlays are dismissed
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final context = tester.element(find.byType(HomePage));
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
    });
    await tester.pumpAndSettle();
    // Tap the logout action in profile card (tap the icon which is inside the tappable area)
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Logout'));
    await tester.pumpAndSettle();

    // Back on Login screen. Sign in with saved credentials
    await tester.enterText(find.widgetWithText(TextField, 'Enter your email'), email);
    await tester.enterText(find.widgetWithText(TextField, 'Enter your password'), password);
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Verify name and expense persisted
    expect(find.textContaining('Tester'), findsWidgets);
    expect(find.text('Test Coffee'), findsOneWidget);
    // Amount should still show the currency symbol we chose ($)
    expect(find.textContaining(r'$'), findsWidgets);
  }, timeout: const Timeout(Duration(minutes: 2)));
}
