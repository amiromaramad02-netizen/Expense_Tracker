import 'package:flutter/material.dart';

const List<String> expenseCategories = [
  'Food',
  'Transport',
  'Entertainment',
  'Shopping',
  'Bills',
  'Health',
  'Education',
  'Other'
];

const List<String> incomeCategories = [
  'Salary',
  'Business',
  'Gift',
  'Interest',
  'Other'
];

const Map<String, IconData> categoryIcons = {
  'Food': Icons.restaurant,
  'Transport': Icons.directions_car,
  'Entertainment': Icons.movie,
  'Shopping': Icons.shopping_bag,
  'Bills': Icons.receipt,
  'Health': Icons.local_hospital,
  'Education': Icons.school,
  'Other': Icons.category,
};

const Map<String, IconData> incomeIcons = {
  'Salary': Icons.attach_money,
  'Business': Icons.business_center,
  'Gift': Icons.card_giftcard,
  'Interest': Icons.trending_up,
  'Other': Icons.account_balance_wallet,
};
