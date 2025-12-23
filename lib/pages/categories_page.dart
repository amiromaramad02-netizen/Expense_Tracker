import 'package:flutter/material.dart';
import 'package:expense_tracker/stores/expense_store.dart';
import 'package:expense_tracker/widgets/currency_text.dart';
import 'package:expense_tracker/data/categories.dart';
import 'package:expense_tracker/stores/settings_store.dart';
import 'package:expense_tracker/utils/currency_utils.dart';

// icons and category ordering are provided by `data/categories.dart`

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categoryIcons.length,
          itemBuilder: (ctx, idx) {
            final categoryName = categoryIcons.keys.toList()[idx];
            final icon = categoryIcons[categoryName]!;
            final expenses = expenseStore.items.where((e) => e.category == categoryName).toList();
            final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

            return GestureDetector(
              onTap: () => _showCategoryDetails(context, categoryName, expenses, total),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary.withOpacity(0.8), primary.withOpacity(0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 40, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(categoryName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: settingsStore,
                      builder: (context, _) => Text(formatCurrency(total), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 4),
                    Text('${expenses.length} items', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCategoryDetails(BuildContext context, String category, List expenses, double total) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        builder: (ctx, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: settingsStore,
                  builder: (context, _) => Text('Total: ${formatCurrency(total)}', style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 20),
                if (expenses.isEmpty)
                  Center(child: Text('No expenses in $category', style: TextStyle(color: Colors.grey.shade600)))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    itemBuilder: (ctx, idx) {
                      final e = expenses[idx];
                      return ListTile(
                        title: Text(e.title),
                        subtitle: Text(e.date.toString().split(' ')[0]),
                        trailing: CurrencyText(e.amount, style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
