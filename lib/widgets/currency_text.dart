import 'package:flutter/material.dart';
import 'package:expense_tracker/stores/settings_store.dart';
import 'package:expense_tracker/utils/currency_utils.dart';

class CurrencyText extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final TextAlign? textAlign;

  const CurrencyText(this.amount, {super.key, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsStore,
      builder: (context, child) {
        return Text(
          formatCurrency(amount),
          style: style,
          textAlign: textAlign,
        );
      },
    );
  }
}
