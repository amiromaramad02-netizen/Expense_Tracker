import 'package:expense_tracker/stores/settings_store.dart';

String formatCurrency(double amount) {
  final symbol = settingsStore.currencySymbol;
  // Simple formatting with comma separators
  final formatted = amount.toStringAsFixed(2);
  // Place symbol before amount for most currencies; if symbol is 'MZN' place after
  if (symbol == 'MZN') return '$formatted $symbol';
  if (symbol == 'R') return '$symbol $formatted';
  return '$symbol$formatted';
}
