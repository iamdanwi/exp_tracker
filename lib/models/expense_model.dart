import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Expense {
  final String name;
  final String category;
  final String price;
  final DateTime date;
  final String icon;

  Expense({
    required this.name,
    required this.category,
    required this.price,
    required this.date,
    required this.icon,
  }) {
    if (name.isEmpty || category.isEmpty || price.isEmpty) {
      throw ArgumentError('All fields must be non-empty');
    }
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'price': price,
    'date': date.toIso8601String(),
    'icon': icon,
  };

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: json['price'] as String? ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      icon: json['icon'] as String? ?? 'shopping_cart',
    );
  }

  static Future<List<Expense>> getAllExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expenses = prefs.getStringList('expenses') ?? [];
      return expenses.map((e) {
        try {
          return Expense.fromJson(jsonDecode(e));
        } catch (e) {
          print('Error parsing expense: $e');
          return Expense(
            name: 'Error',
            category: 'Error',
            price: '0',
            date: DateTime.now(),
            icon: 'error',
          );
        }
      }).toList();
    } catch (e) {
      print('Failed to load expenses: $e');
      return [];
    }
  }

  static Future<void> saveExpense(Expense expense) async {
    final prefs = await SharedPreferences.getInstance();
    final expenses = prefs.getStringList('expenses') ?? [];
    expenses.add(jsonEncode(expense.toJson()));
    await prefs.setStringList('expenses', expenses);
  }

  static Future<void> deleteExpense(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expenses = prefs.getStringList('expenses') ?? [];

      if (index >= 0 && index < expenses.length) {
        expenses.removeAt(index);
        await prefs.setStringList('expenses', expenses);
      } else {
        throw Exception('Invalid index');
      }
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }
}
