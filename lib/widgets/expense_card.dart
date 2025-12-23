import 'dart:math';

import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/data/categories.dart';
import 'package:expense_tracker/widgets/currency_text.dart';
import 'package:expense_tracker/pages/add_expense_page.dart';
import 'package:expense_tracker/pages/expense_detail_page.dart';

class ExpenseCard extends StatefulWidget {
  const ExpenseCard(this.e, {this.onDelete, this.onTap, super.key});
  final Expense e;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _slideAnimation = Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final e = widget.e;
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap ?? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseDetailPage(expense: e))),
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // left avatar box: show category icon
                  Builder(builder: (ctx) {
                    final cat = e.category.isNotEmpty ? e.category : 'Other';
                    // choose the appropriate category set for color/icon
                    final base = e.isIncome ? incomeCategories : expenseCategories;
                    final idx = base.indexOf(cat);
                    Color badgeColor;
                    if (idx >= 0) {
                      final hue = (idx * 360 / max(1, base.length));
                      badgeColor = HSLColor.fromAHSL(1.0, hue % 360, 0.65, 0.45).toColor();
                    } else {
                      badgeColor = primary.withOpacity(0.12);
                    }
                    final icon = e.isIncome ? (incomeIcons[cat] ?? Icons.attach_money) : (categoryIcons[cat] ?? Icons.category);
                    return Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)),
                      child: Center(child: Icon(icon, color: Colors.white)),
                    );
                  }),
                  const SizedBox(width: 12),
                  // mid content
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(e.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)), child: Text(e.category, style: const TextStyle(fontSize: 12))),
                        const SizedBox(width: 8),
                        Text(e.date.toLocal().toString().split(' ')[0], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ])
                    ]),
                  ),
                  // right amount & delete
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Row(children: [
                      Icon(e.isIncome ? Icons.arrow_upward : Icons.arrow_downward, color: e.isIncome ? Colors.green : Colors.red, size: 16),
                      const SizedBox(width: 6),
                      CurrencyText(e.amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: e.isIncome ? Colors.green : Colors.black)),
                    ]),
                    const SizedBox(height: 8),
                    PopupMenuButton(itemBuilder: (_) => [
                      PopupMenuItem(child: const Text('Edit'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddExpensePage(expense: e)))),
                      PopupMenuItem(child: const Text('Delete', style: TextStyle(color: Colors.red)), onTap: () => widget.onDelete?.call()),
                    ]),
                  ])
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
