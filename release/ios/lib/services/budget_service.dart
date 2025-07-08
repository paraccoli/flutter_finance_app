import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class BudgetService {
  // デフォルトのカテゴリ別予算設定
  static final Map<ExpenseCategory, double> _defaultCategoryBudgets = {
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

  // カテゴリ別予算設定（メモリキャッシュ）
  static Map<ExpenseCategory, double> _categoryBudgets = {};

  // 月次総予算（メモリキャッシュ）
  static double _monthlyBudget = 300000;

  // 予算アラート設定
  static bool _budgetAlertEnabled = true;

  // 初期化フラグ
  static bool _isInitialized = false;

  // 初期化
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();

    // カテゴリ別予算を読み込み
    _categoryBudgets = {};
    for (final category in ExpenseCategory.values) {
      final key = 'budget_${category.name}';
      final budget =
          prefs.getDouble(key) ?? _defaultCategoryBudgets[category] ?? 0.0;
      _categoryBudgets[category] = budget;
    }

    // 月次総予算を読み込み
    _monthlyBudget =
        prefs.getDouble('monthly_budget') ??
        _categoryBudgets.values.fold(0.0, (sum, budget) => sum + budget);

    // 予算アラート設定を読み込み
    _budgetAlertEnabled = prefs.getBool('budget_alert_enabled') ?? true;

    _isInitialized = true;
  }

  // 予算設定の取得
  static Future<Map<ExpenseCategory, double>> getCategoryBudgets() async {
    await initialize();
    return Map.from(_categoryBudgets);
  }

  static Future<double> getMonthlyBudget() async {
    await initialize();
    return _monthlyBudget;
  }

  static Future<double> getCategoryBudget(ExpenseCategory category) async {
    await initialize();
    return _categoryBudgets[category] ?? 0;
  }

  static Future<bool> isBudgetAlertEnabled() async {
    await initialize();
    return _budgetAlertEnabled;
  }

  // 予算設定の更新
  static Future<void> setCategoryBudget(
    ExpenseCategory category,
    double amount,
  ) async {
    await initialize();
    _categoryBudgets[category] = amount;

    // SharedPreferencesに保存
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('budget_${category.name}', amount);
  }

  static Future<void> setMonthlyBudget(double amount) async {
    await initialize();
    _monthlyBudget = amount;

    // SharedPreferencesに保存
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_budget', amount);
  }

  static Future<void> setBudgetAlertEnabled(bool enabled) async {
    await initialize();
    _budgetAlertEnabled = enabled;

    // SharedPreferencesに保存
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('budget_alert_enabled', enabled);
  }

  // 同期メソッド（後方互換性のため）
  static Map<ExpenseCategory, double> getCategoryBudgetsSync() {
    if (!_isInitialized) {
      return Map.from(_defaultCategoryBudgets);
    }
    return Map.from(_categoryBudgets);
  }

  static double getMonthlyBudgetSync() {
    if (!_isInitialized) {
      return 300000;
    }
    return _monthlyBudget;
  }

  // 予算使用率の計算
  static double calculateCategoryUsage(ExpenseCategory category, double spent) {
    final budget = getCategoryBudgetSync(category);
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
    return (getCategoryBudgetSync(category) - spent).clamp(0, double.infinity);
  }

  static double getRemainingMonthlyBudget(double totalSpent) {
    return (_monthlyBudget - totalSpent).clamp(0, double.infinity);
  }

  static double getCategoryBudgetSync(ExpenseCategory category) {
    if (!_isInitialized) {
      return _defaultCategoryBudgets[category] ?? 0.0;
    }
    return _categoryBudgets[category] ?? 0;
  }

  static bool isBudgetAlertEnabledSync() {
    if (!_isInitialized) {
      return true;
    }
    return _budgetAlertEnabled;
  }
}

enum BudgetWarningLevel {
  safe, // 60%未満
  caution, // 60-79%
  warning, // 80-99%
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
