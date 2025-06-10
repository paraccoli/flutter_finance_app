import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'database_service.dart';

class BudgetService {
  static final DatabaseService _databaseService = DatabaseService();
  
  // デフォルト予算設定
  static final Map<ExpenseCategory, double> _defaultCategoryBudgets = {
    ExpenseCategory.food: 50000,
    ExpenseCategory.transportation: 20000,
    ExpenseCategory.entertainment: 30000,
    ExpenseCategory.shopping: 40000,
    ExpenseCategory.utilities: 25000,    ExpenseCategory.health: 15000,
    ExpenseCategory.education: 10000,
    ExpenseCategory.rent: 80000,
    ExpenseCategory.other: 20000,
  };

  // 現在の月を取得（YYYY-MM形式）
  static String _getCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  // 予算設定の取得（データベースから）
  static Future<Map<ExpenseCategory, double>> getCategoryBudgets([String? month]) async {
    final targetMonth = month ?? _getCurrentMonth();
    final budgets = await _databaseService.getCategoryBudgets(targetMonth);
      // データベースにデータがない場合はデフォルト値を使用
    if (budgets.isEmpty) {
      return Map<ExpenseCategory, double>.from(_defaultCategoryBudgets);
    }
    
    // 足りないカテゴリはデフォルト値で補完
    final completeBudgets = Map<ExpenseCategory, double>.from(_defaultCategoryBudgets);
    completeBudgets.addAll(budgets);
    
    return completeBudgets;
  }  static Future<double> getMonthlyBudget([String? month]) async {
    final targetMonth = month ?? _getCurrentMonth();
    final budget = await _databaseService.getMonthlyBudget(targetMonth);
    
    // データベースに保存された値があればそれを使用、なければカテゴリ別予算の合計を計算
    if (budget != null) {
      return budget;
    }
      // カテゴリ別予算の合計を計算
    final categoryBudgets = await getCategoryBudgets(targetMonth);
    return categoryBudgets.values.fold<double>(0.0, (sum, categoryBudget) => sum + categoryBudget);
  }

  static Future<double> getCategoryBudget(ExpenseCategory category, [String? month]) async {
    final budgets = await getCategoryBudgets(month);
    return budgets[category] ?? 0;
  }

  // 予算設定の更新（データベースに保存）
  static Future<void> setCategoryBudget(ExpenseCategory category, double amount, [String? month]) async {
    final targetMonth = month ?? _getCurrentMonth();
    await _databaseService.saveCategoryBudget(category, amount, targetMonth);
  }

  static Future<void> setMonthlyBudget(double amount, [String? month]) async {
    final targetMonth = month ?? _getCurrentMonth();
    await _databaseService.saveMonthlyBudget(amount, targetMonth);
  }

  // 複数カテゴリの予算を一括保存
  static Future<void> saveCategoryBudgets(Map<ExpenseCategory, double> budgets, [String? month]) async {
    final targetMonth = month ?? _getCurrentMonth();
    for (final entry in budgets.entries) {
      await _databaseService.saveCategoryBudget(entry.key, entry.value, targetMonth);
    }
  }  // 予算使用率の計算
  static Future<double> calculateCategoryUsage(ExpenseCategory category, double spent, [String? month]) async {
    final budget = await getCategoryBudget(category, month);
    if (budget == 0) {
      // 予算が0で支出がある場合は超過として扱う
      return spent > 0 ? 200 : 0;
    }
    return (spent / budget * 100).clamp(0, 200);
  }

  static Future<double> calculateMonthlyUsage(double totalSpent, [String? month]) async {
    final monthlyBudget = await getMonthlyBudget(month);
    if (monthlyBudget == 0) {
      // 予算が0で支出がある場合は超過として扱う
      return totalSpent > 0 ? 200 : 0;
    }
    return (totalSpent / monthlyBudget * 100).clamp(0, 200);
  }

  // 予算警告レベル
  static BudgetWarningLevel getWarningLevel(double usagePercentage) {
    if (usagePercentage >= 100) return BudgetWarningLevel.exceeded;
    if (usagePercentage >= 80) return BudgetWarningLevel.warning;
    if (usagePercentage >= 60) return BudgetWarningLevel.caution;
    return BudgetWarningLevel.safe;
  }
  // 予算残額の計算
  static Future<double> getRemainingBudget(ExpenseCategory category, double spent, [String? month]) async {
    final budget = await getCategoryBudget(category, month);
    return (budget - spent).clamp(0, double.infinity);
  }

  static Future<double> getRemainingMonthlyBudget(double totalSpent, [String? month]) async {
    final monthlyBudget = await getMonthlyBudget(month);
    return (monthlyBudget - totalSpent).clamp(0, double.infinity);
  }

  // 予算アラート関連機能
  static Future<List<BudgetAlert>> getBudgetAlerts([String? month]) async {
    final targetMonth = month ?? _getCurrentMonth();
    final alerts = <BudgetAlert>[];
    
    // 月次予算チェック
    final monthlyBudget = await getMonthlyBudget(targetMonth);
    final monthlyExpenses = await _databaseService.getTotalExpensesForMonth(targetMonth);
    final monthlyUsage = await calculateMonthlyUsage(monthlyExpenses, targetMonth);
    
    if (monthlyUsage >= 100) {
      alerts.add(BudgetAlert(
        type: BudgetAlertType.monthly,
        category: null,
        message: '月次予算を¥${(monthlyExpenses - monthlyBudget).toStringAsFixed(0)}超過しています',
        usagePercentage: monthlyUsage,
        warningLevel: BudgetWarningLevel.exceeded,
      ));
    } else if (monthlyUsage >= 80) {
      alerts.add(BudgetAlert(
        type: BudgetAlertType.monthly,
        category: null,
        message: '月次予算の${monthlyUsage.toStringAsFixed(1)}%を使用しています',
        usagePercentage: monthlyUsage,
        warningLevel: BudgetWarningLevel.warning,
      ));
    }
      // カテゴリ別予算チェック
    final categoryBudgets = await getCategoryBudgets(targetMonth);
    for (final category in ExpenseCategory.values) {
      final budget = categoryBudgets[category] ?? 0;
      final spent = await _databaseService.getCategoryExpensesForMonth(category, targetMonth);
      final usage = await calculateCategoryUsage(category, spent, targetMonth);
      
      if (usage >= 100) {
        final overAmount = budget > 0 ? spent - budget : spent;
        alerts.add(BudgetAlert(
          type: BudgetAlertType.category,
          category: category,
          message: budget > 0 
              ? '${category.displayName}の予算を¥${overAmount.toStringAsFixed(0)}超過しています'
              : '${category.displayName}の予算が未設定ですが¥${spent.toStringAsFixed(0)}の支出があります',
          usagePercentage: usage,
          warningLevel: BudgetWarningLevel.exceeded,
        ));
      } else if (usage >= 80) {
        alerts.add(BudgetAlert(
          type: BudgetAlertType.category,
          category: category,
          message: '${category.displayName}の予算の${usage.toStringAsFixed(1)}%を使用しています',
          usagePercentage: usage,
          warningLevel: BudgetWarningLevel.warning,
        ));
      }
    }
    
    return alerts;
  }

  // 緊急度の高いアラートを取得
  static Future<List<BudgetAlert>> getHighPriorityAlerts([String? month]) async {
    final allAlerts = await getBudgetAlerts(month);
    return allAlerts.where((alert) => 
      alert.warningLevel == BudgetWarningLevel.exceeded ||
      alert.warningLevel == BudgetWarningLevel.warning
    ).toList();
  }

  // アラート数を取得
  static Future<int> getAlertCount([String? month]) async {
    final alerts = await getHighPriorityAlerts(month);
    return alerts.length;
  }
}

enum BudgetAlertType {
  monthly,   // 月次予算アラート
  category,  // カテゴリ別予算アラート
}

class BudgetAlert {
  final BudgetAlertType type;
  final ExpenseCategory? category;
  final String message;
  final double usagePercentage;
  final BudgetWarningLevel warningLevel;

  BudgetAlert({
    required this.type,
    this.category,
    required this.message,
    required this.usagePercentage,
    required this.warningLevel,
  });
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
