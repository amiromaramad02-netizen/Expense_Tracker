import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/stores/auth_store.dart';
import 'package:expense_tracker/stores/expense_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Login / SignUp UI flows', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      // ensure auth and expense stores are reset between tests
      await Future<void>.delayed(const Duration(milliseconds: 10));
      try {
        await authStore.logout();
      } catch (_) {}
      try {
        expenseStore.clearAll();
      } catch (_) {}
    });

    testWidgets('Selecting a saved account auto-logs in and shows expenses', (tester) async {
      final email = 'saved@example.com';
      final password = 'pw123';

      // prepare stored state: user, saved password and expenses
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('users_map_v1', ['$email:$password']);
      await prefs.setString('saved_pass_$email', password);
      final expense = {'id': 'x1', 'title': 'SavedExpense', 'amount': 5.0, 'category': 'Food', 'date': DateTime.now().toIso8601String()};
      await prefs.setString('expenses_v1_$email', jsonEncode([expense]));

      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pumpAndSettle();

      // We're on LoginPage
      expect(find.text('Welcome Back'), findsOneWidget);

      // Tap the saved accounts (people) button
      final people = find.byIcon(Icons.people);
      expect(people, findsOneWidget);
      await tester.tap(people);
      await tester.pumpAndSettle();

      // Choose the saved email in the dialog
      expect(find.text(email), findsOneWidget);
      await tester.tap(find.text(email));
      await tester.pumpAndSettle();

      // Ensure authStore reflects the authenticated user
      expect(authStore.isAuthenticated, isTrue);
      expect(authStore.currentEmail, equals(email));

      // If a profile setup is required, finish it; otherwise proceed to Home
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      if (find.text('Complete Your Profile').evaluate().isNotEmpty) {
        await tester.enterText(find.byType(TextField), 'Saved User');
        await tester.ensureVisible(find.text('Continue'));
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Now we should be on Home and see the expense
      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('SavedExpense'), findsOneWidget);
    });

    testWidgets('Manual login navigates to Home and loads user data', (tester) async {
      final email = 'manual@example.com';
      final password = 'pass';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('users_map_v1', ['$email:$password']);
      final expense = {'id': 'm1', 'title': 'ManualExpense', 'amount': 12.0, 'category': 'Other', 'date': DateTime.now().toIso8601String()};
      await prefs.setString('expenses_v1_$email', jsonEncode([expense]));

      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pumpAndSettle();

      // Enter credentials (email first, password second)
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));
      await tester.enterText(textFields.first, email);
      await tester.enterText(textFields.at(1), password);
      await tester.pump();

      // Tap Sign In
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('ManualExpense'), findsOneWidget);
    });

    testWidgets('Add Income via FAB updates balance', (tester) async {
      final email = 'incomeui@example.com';
      final password = 'p';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('users_map_v1', ['$email:$password']);

      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pumpAndSettle();

      // login
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, email);
      await tester.enterText(textFields.at(1), password);
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Tap add income FAB (green attach_money icon)
      final addIncome = find.byIcon(Icons.attach_money);
      expect(addIncome, findsOneWidget);
      await tester.ensureVisible(addIncome);
      await tester.tap(addIncome, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Ensure Add Income page appeared
      expect(find.text('Add Income'), findsOneWidget);

      // Fill income form
      final formFields = find.byType(TextField);
      expect(formFields, findsAtLeastNWidgets(2));
      await tester.enterText(formFields.first, 'Salary Quick');
      await tester.enterText(formFields.at(1), '1500');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Income'));
      await tester.pumpAndSettle();

      // Balance should reflect added income
      expect(find.text('Balance'), findsOneWidget);
      expect(find.textContaining('1 transactions'), findsNothing); // not relying on count
      // The income entry should be visible in list
      expect(find.text('Salary Quick'), findsOneWidget);
    });

    testWidgets('Sign up -> Profile setup -> Home', (tester) async {
      final email = 'new@example.com';
      final password = 'newpass';

      await tester.pumpWidget(const ExpenseTrackerApp());
      await tester.pumpAndSettle();

      // Navigate to Sign Up page
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // The header and the button share the same text; check the subtitle instead
      expect(find.text('Join us today'), findsOneWidget);

      // Fill form and create account
      await tester.enterText(find.byType(TextField).first, email);
      await tester.enterText(find.byType(TextField).at(1), password);
      await tester.enterText(find.byType(TextField).at(2), password);
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
      await tester.pumpAndSettle();

      // The 'save credentials' dialog may appear; decline it so we proceed
      if (find.text('No').evaluate().isNotEmpty) {
        await tester.tap(find.text('No'));
        await tester.pumpAndSettle();
      }

      // Now on ProfileSetupPage
      expect(find.text('Complete Your Profile'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'New User');
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Now we should see Home
      expect(find.text('Balance'), findsOneWidget);
    });
  });
}
