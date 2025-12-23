import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/pages/add_expense_page.dart';
import 'package:expense_tracker/widgets/currency_text.dart';

class ExpenseDetailPage extends StatelessWidget {
  final Expense expense;
  const ExpenseDetailPage({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddExpensePage(expense: expense)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Amount', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    CurrencyText(expense.amount, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Details Section
              const Text('Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Title
              _DetailItem(
                label: 'Title',
                value: expense.title,
                icon: Icons.label,
              ),

              const SizedBox(height: 12),

              // Category
              _DetailItem(
                label: 'Category',
                value: expense.category,
                icon: Icons.category,
              ),

              const SizedBox(height: 12),
              // Type (Income / Expense)
              _DetailItem(
                label: 'Type',
                value: expense.isIncome ? 'Income' : 'Expense',
                icon: expense.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              ),

              const SizedBox(height: 12),

              // Date
              _DetailItem(
                label: 'Date',
                value: expense.date.toString().split(' ')[0],
                icon: Icons.calendar_today,
              ),

              const SizedBox(height: 12),

              // ID
              _DetailItem(
                label: 'ID',
                value: expense.id,
                icon: Icons.fingerprint,
              ),

              if (expense.notes != null) ...[
                const SizedBox(height: 24),
                const Text('Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: Text(
                    expense.notes!,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
