// lib/stores/expense_store.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import 'auth_store.dart';

const _kExpensesKeyPrefix = 'expenses_v1_';

class ExpenseStore extends ChangeNotifier {
  final List<Expense> _items = [];

  List<Expense> get items => List.unmodifiable(_items);

  // Total is computed as income minus expense
  double get incomeTotal => _items.where((e) => e.isIncome).fold(0.0, (s, e) => s + e.amount);
  double get expenseTotal => _items.where((e) => !e.isIncome).fold(0.0, (s, e) => s + e.amount);
  double get total => incomeTotal - expenseTotal;

  ExpenseStore() {
    // Load expenses for current user if any
    if (authStore.initialized) {
      _loadForCurrentUser();
    }
    // Listen for auth changes to load/clear user-specific expenses
    authStore.addListener(() {
      _loadForCurrentUser();
    });
  }

  Future<void> _loadForCurrentUser() async {
    final email = authStore.currentEmail;
    if (email == null) {
      _items.clear();
      notifyListeners();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_kExpensesKeyPrefix$email');
    if (raw == null) {
      _items.clear();
      notifyListeners();
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _items
        ..clear()
        ..addAll(list.map((e) => Expense.fromJson(Map<String, dynamic>.from(e))));
      notifyListeners();
    } catch (_) {
      _items.clear();
      notifyListeners();
    }
  }

  Future<void> _saveForCurrentUser() async {
    final email = authStore.currentEmail;
    if (email == null) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_items.map((e) => e.toJson()).toList());
    await prefs.setString('$_kExpensesKeyPrefix$email', raw);
  }

  Expense? getById(String id) {
    for (final e in _items) {
      if (e.id == id) return e;
    }
    return null;
  }

  void addExpense(Expense expense) {
    _items.add(expense);
    _saveForCurrentUser();
    notifyListeners();
  }

  void deleteExpense(String id) {
    _items.removeWhere((e) => e.id == id);
    _saveForCurrentUser();
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    _saveForCurrentUser();
    notifyListeners();
  }
}

// global instance used by the UI (export only from here)
final expenseStore = ExpenseStore();
