import 'package:flutter/material.dart';
import '../models/expense.dart';

class BudgetService {  // カテゴリ別予算設定
  static final Map<ExpenseCategory, double> _categoryBudgets = {
    ExpenseCategory.food: 50000,
    ExpenseCategory.transportation: 20000,
    ExpenseCategory.entertainment: 30000,
    ExpenseCategory.shopping: 40000,
    ExpenseCategory.utilities: 25000,
    ExpenseCategory.health: 15000,
    ExpenseCategory.education: 10000,
    ExpenseCategory.rent: 80000,
    ExpenseCategory.other: 20000,
  };

  // 月次総予算
  static double _monthlyBudget = 300000;

  // 予算設定の取得
  static Map<ExpenseCategory, double> getCategoryBudgets() {
    return Map.from(_categoryBudgets);
  }

  static double getMonthlyBudget() {
    return _monthlyBudget;
  }

  static double getCategoryBudget(ExpenseCategory category) {
    return _categoryBudgets[category] ?? 0;
  }

  // 予算設定の更新
  static void setCategoryBudget(ExpenseCategory category, double amount) {
    _categoryBudgets[category] = amount;
    _updateMonthlyBudget();
  }

  static void setMonthlyBudget(double amount) {
    _monthlyBudget = amount;
  }

  // 月次予算の自動計算
  static void _updateMonthlyBudget() {
    _monthlyBudget = _categoryBudgets.values.fold(0, (sum, budget) => sum + budget);
  }

  // 予算使用率の計算
  static double calculateCategoryUsage(ExpenseCategory category, double spent) {
    final budget = getCategoryBudget(category);
    if (budget == 0) return 0;
    return (spent / budget * 100).clamp(0, 200);
  }

  static double calculateMonthlyUsage(double totalSpent) {
    if (_monthlyBudget == 0) return 0;
    return (totalSpent / _monthlyBudget * 100).clamp(0, 200);
  }

  // 予算警告レベル
  static BudgetWarningLevel getWarningLevel(double usagePercentage) {
    if (usagePercentage >= 100) return BudgetWarningLevel.exceeded;
    if (usagePercentage >= 80) return BudgetWarningLevel.warning;
    if (usagePercentage >= 60) return BudgetWarningLevel.caution;
    return BudgetWarningLevel.safe;
  }

  // 予算残額の計算
  static double getRemainingBudget(ExpenseCategory category, double spent) {
    return (getCategoryBudget(category) - spent).clamp(0, double.infinity);
  }

  static double getRemainingMonthlyBudget(double totalSpent) {
    return (_monthlyBudget - totalSpent).clamp(0, double.infinity);
  }
}

enum BudgetWarningLevel {
  safe,     // 60%未満
  caution,  // 60-79%
  warning,  // 80-99%
  exceeded, // 100%以上
}

extension BudgetWarningLevelExtension on BudgetWarningLevel {
  Color get color {
    switch (this) {
      case BudgetWarningLevel.safe:
        return Colors.green;
      case BudgetWarningLevel.caution:
        return Colors.orange;
      case BudgetWarningLevel.warning:
        return Colors.red.shade300;
      case BudgetWarningLevel.exceeded:
        return Colors.red;
    }
  }

  String get message {
    switch (this) {
      case BudgetWarningLevel.safe:
        return '予算内';
      case BudgetWarningLevel.caution:
        return '注意';
      case BudgetWarningLevel.warning:
        return '警告';
      case BudgetWarningLevel.exceeded:
        return '超過';
    }
  }

  IconData get icon {
    switch (this) {
      case BudgetWarningLevel.safe:
        return Icons.check_circle;
      case BudgetWarningLevel.caution:
        return Icons.warning_amber;
      case BudgetWarningLevel.warning:
        return Icons.warning;
      case BudgetWarningLevel.exceeded:
        return Icons.error;
    }
  }
}
