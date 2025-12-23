import 'package:flutter/material.dart';
import 'package:expense_tracker/stores/expense_store.dart'; // contains expenseStore
import 'package:expense_tracker/stores/auth_store.dart';
import 'package:expense_tracker/utils/responsive_utils.dart';
import 'package:expense_tracker/widgets/currency_text.dart';
// settings_store not used here
import 'expense_detail_page.dart';
import 'package:expense_tracker/widgets/expense_card.dart';
import 'package:expense_tracker/pages/all_expenses_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    // FAB entrance animation
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final items = expenseStore.items.reversed.toList();
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final userName = authStore.currentName ?? 'User';

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Top area: greeting + action icons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: isMobile ? 26 : 32,
                    backgroundColor: primary.withOpacity(0.12),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome, $userName",
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Let's track your expenses",
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Big total card (modern look)
            Container(
              margin: EdgeInsets.symmetric(horizontal: padding),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: primary.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, 8))],
              ),
              child: Row(
                children: [
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Balance', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        // Large currency number
                        CurrencyText(
                          expenseStore.total,
                          style: TextStyle(
                            fontSize: isMobile ? 34 : 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(children: [
                          Text('Income: ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(width: 6),
                          CurrencyText(expenseStore.incomeTotal, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(width: 14),
                          Text('Expenses: ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(width: 6),
                          CurrencyText(expenseStore.expenseTotal, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ]),
                      ],
                    ),
                  ),

                  // Decorative icon / badge on the right
                  Container(
                    width: isMobile ? 64 : 84,
                    height: isMobile ? 64 : 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(child: Icon(Icons.trending_up, color: Colors.white, size: 34)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Row label & view all
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Row(children: [
                Text("Your Expenses", style: TextStyle(fontSize: isMobile ? 16 : 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AllExpensesPage())),
                  child: Text("View All", style: TextStyle(color: Colors.black54, fontSize: isMobile ? 12 : 14)),
                ),
              ]),
            ),

            const SizedBox(height: 10),

            // Large cards - expenses list
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                children: items.isEmpty
                    ? [
                        SizedBox(
                          height: 220,
                          child: Center(child: Text("No expenses added.", style: TextStyle(color: Colors.grey.shade600))),
                        )
                      ]
                    : items.map((e) => ExpenseCard(e, onDelete: () {
                          setState(() {
                            expenseStore.deleteExpense(e.id);
                          });
                        }, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseDetailPage(expense: e))))).toList(),
              ),
            ),

            SizedBox(height: isMobile ? 80 : 100), // spacing for FAB
          ],
        ),
      ),
    );
  }
  // Category totals helper removed (no longer used on home page)
}


// Local expense card removed — replaced by `ExpenseCard` widget in widgets/expense_card.dart
