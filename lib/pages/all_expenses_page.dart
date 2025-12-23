import 'package:flutter/material.dart';
import 'package:expense_tracker/stores/expense_store.dart';
import 'package:expense_tracker/widgets/expense_card.dart';

class AllExpensesPage extends StatelessWidget {
  const AllExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Expenses')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: AnimatedBuilder(
          animation: expenseStore,
          builder: (context, _) {
            final items = expenseStore.items.reversed.toList();
            if (items.isEmpty) return Center(child: Text('No expenses added.', style: TextStyle(color: Colors.grey.shade600)));
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (ctx, i) {
                final e = items[i];
                return ExpenseCard(e, onDelete: () {
                  expenseStore.deleteExpense(e.id);
                });
              },
            );
          },
        ),
      ),
    );
  }
}
