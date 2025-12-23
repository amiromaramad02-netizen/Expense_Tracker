import 'package:flutter/material.dart';
import 'package:expense_tracker/stores/expense_store.dart';
import 'package:expense_tracker/widgets/pie_chart.dart';
import 'package:expense_tracker/data/categories.dart';
import 'package:expense_tracker/stores/settings_store.dart';
import 'add_expense_page.dart';
import 'package:expense_tracker/utils/currency_utils.dart';
import 'package:expense_tracker/widgets/currency_text.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  Map<String, double> _categoryTotals(List items) {
    final map = <String, double>{};
    for (final e in items) {
      final category = e.category ?? 'Other';
      map[category] = (map[category] ?? 0) + (e.amount ?? 0);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final items = expenseStore.items;
    final totals = _categoryTotals(items);
    final total = items.fold<double>(0.0, (a, b) => a + b.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')), 
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Spending by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                ),
                child: AnimatedBuilder(
                  animation: settingsStore,
                  builder: (context, _) => PieChart(data: totals, strokeWidth: 18, showLegend: true, valueFormatter: (v) => formatCurrency(v), categoryOrder: expenseCategories),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    const Icon(Icons.pie_chart, size: 28),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Total Expenses', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      CurrencyText(total, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ])
                  ]),
                  const SizedBox(height: 12),
                  // Add Expense button for Progress page placed beneath the totals.
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpensePage())),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Expense'),
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
