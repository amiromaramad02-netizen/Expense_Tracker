import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/stores/expense_store.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/stores/settings_store.dart';
import 'package:expense_tracker/data/categories.dart';

class AddExpensePage extends StatefulWidget {
  final Expense? expense;
  final bool isIncome;
  const AddExpensePage({super.key, this.expense, this.isIncome = false});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController notesController;
  late DateTime selectedDate;
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      titleController = TextEditingController(text: widget.expense!.title);
      amountController = TextEditingController(text: widget.expense!.amount.toString());
      notesController = TextEditingController(text: widget.expense!.notes);
      selectedDate = widget.expense!.date;
      selectedCategory = widget.expense!.category;
    } else {
      titleController = TextEditingController();
      amountController = TextEditingController();
      notesController = TextEditingController();
      selectedDate = DateTime.now();
      selectedCategory = widget.isIncome ? incomeCategories.first : expenseCategories.first;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  void _saveExpense() {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final expense = Expense(
      id: widget.expense?.id ?? const Uuid().v4(),
      title: titleController.text,
      amount: amount,
      date: selectedDate,
      category: selectedCategory,
      isIncome: widget.isIncome || (widget.expense?.isIncome ?? false),
      notes: notesController.text.isEmpty ? null : notesController.text,
    );

    if (widget.expense != null) {
      expenseStore.deleteExpense(widget.expense!.id);
    }
    expenseStore.addExpense(expense);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense != null ? (widget.expense!.isIncome ? 'Edit Income' : 'Edit Expense') : (widget.isIncome ? 'Add Income' : 'Add Expense')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text('Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'Add type of Transaction',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Amount
              const Text('Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              AnimatedBuilder(
                animation: settingsStore,
                builder: (context, _) => TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    prefixText: '${settingsStore.currencySymbol} ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category
              Text(widget.isIncome ? 'Income Category' : 'Category', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                items: (widget.isIncome ? incomeCategories : expenseCategories).map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => selectedCategory = val ?? selectedCategory),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Date
              const Text('Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedDate.toString().split(' ')[0]),
                      Icon(Icons.calendar_today, color: primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Notes
              const Text('Notes (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add notes...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 40),

                  // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                      child: Text(widget.isIncome ? 'Save Income' : 'Save Expense', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
