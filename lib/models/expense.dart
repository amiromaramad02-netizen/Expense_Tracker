// lib/models/expense.dart
class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String? notes;
  final bool isIncome;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.notes,
    this.isIncome = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
      'notes': notes,
      'isIncome': isIncome,
      };

    factory Expense.fromJson(Map<String, dynamic> map) => Expense(
        id: map['id'] as String,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.parse(map['date'] as String),
        category: map['category'] as String,
      notes: map['notes'] as String?,
      isIncome: map['isIncome'] == true || (map['isIncome'] as Object?) == 1,
      );
}
