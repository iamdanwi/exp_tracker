import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryBudget {
  final String category;
  final double amount;

  CategoryBudget({required this.category, required this.amount});

  Map<String, dynamic> toJson() => {'category': category, 'amount': amount};

  factory CategoryBudget.fromJson(Map<String, dynamic> json) {
    return CategoryBudget(
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static Future<Map<String, double>> getAllBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetsString = prefs.getString('category_budgets') ?? '{}';
      final Map<String, dynamic> budgetsMap = json.decode(budgetsString);
      return Map<String, double>.from(
        budgetsMap.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      );
    } catch (e) {
      print('Error loading budgets: $e');
      return {};
    }
  }

  static Future<void> saveBudget(String category, double amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgets = await getAllBudgets();
      budgets[category] = amount;
      await prefs.setString('category_budgets', json.encode(budgets));
    } catch (e) {
      print('Error saving budget: $e');
    }
  }

  static Future<double> getTotalBudget() async {
    try {
      final budgets = await getAllBudgets();
      double total = 0.0;
      budgets.forEach((_, amount) {
        total += amount;
      });
      return total;
    } catch (e) {
      print('Error calculating total budget: $e');
      return 0.0;
    }
  }
}
