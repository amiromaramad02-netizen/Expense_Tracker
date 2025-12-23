import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/stores/auth_store.dart';
import 'package:expense_tracker/stores/expense_store.dart';
import 'package:expense_tracker/models/expense.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Auth & Expense persistence', () {
    setUp(() async {
      // clear mock prefs before each test
      SharedPreferences.setMockInitialValues({});
      // Force reload stores
      // Note: stores are singletons; ensure they load from the mocked prefs
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });

    test('sign up, add expense, logout, login restores expenses', () async {
      final email = 'test@example.com';
      final password = 'secret';

      // sign up
      final signed = await authStore.signUp(email, password);
      expect(signed, isTrue);
      expect(authStore.currentEmail, equals(email));

      // persist an expense directly via SharedPreferences (simulating add/persist)
      final e = Expense(id: '1', title: 'Coffee', amount: 3.5, category: 'Food', date: DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('expenses_v1_$email', jsonEncode([e.toJson()]));

      // ensure persisted
      final raw = prefs.getString('expenses_v1_$email');
      expect(raw, isNotNull);
      final list = jsonDecode(raw!) as List<dynamic>;
      expect(list.length, equals(1));

      // logout should clear in-memory items
      await authStore.logout();
      // give store a moment to react
      await Future.delayed(const Duration(milliseconds: 50));
      expect(expenseStore.items, isEmpty);

      // login again and confirm items restored
      final logged = await authStore.login(email, password);
      expect(logged, isTrue);
      // allow async load from prefs
      await Future.delayed(const Duration(milliseconds: 150));
      expect(expenseStore.items.length, equals(1));
      expect(expenseStore.items.first.title, equals('Coffee'));
    });

    test('addExpense persists to SharedPreferences', () async {
      final email = 'persist@example.com';
      final password = 'pw';

      final signed = await authStore.signUp(email, password);
      expect(signed, isTrue);
      // give auth listeners time to settle
      await Future.delayed(const Duration(milliseconds: 50));

      final e = Expense(id: 'a1', title: 'Latte', amount: 4.2, category: 'Food', date: DateTime.now());
      expenseStore.addExpense(e);
      await Future.delayed(const Duration(milliseconds: 100));

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('expenses_v1_$email');
      expect(raw, isNotNull);
      final list = jsonDecode(raw!) as List<dynamic>;
      expect(list.length, equals(1));
      expect((list.first as Map<String, dynamic>)['title'], equals('Latte'));
    });

    test('adding income adjusts totals correctly', () async {
      final email = 'money@example.com';
      final password = 'pw';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('users_map_v1', ['$email:$password']);
      // login
      await authStore.login(email, password);
      await Future.delayed(const Duration(milliseconds: 50));

      // add income and expense
      final inc = Expense(id: 'inc1', title: 'Salary', amount: 1000.0, category: 'Salary', date: DateTime.now(), isIncome: true);
      final exp = Expense(id: 'e1', title: 'Phone', amount: 200.0, category: 'Bills', date: DateTime.now());
      expenseStore.addExpense(inc);
      expenseStore.addExpense(exp);
      await Future.delayed(const Duration(milliseconds: 100));

      expect(expenseStore.incomeTotal, equals(1000.0));
      expect(expenseStore.expenseTotal, equals(200.0));
      expect(expenseStore.total, equals(800.0));
    });
  });
}
