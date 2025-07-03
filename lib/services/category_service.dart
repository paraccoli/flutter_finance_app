import 'package:flutter/material.dart';
import '../models/custom_category.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../services/database_service.dart';

/// カスタムカテゴリとレガシーカテゴリを統合管理するサービス
class CategoryService {
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  final DatabaseService _databaseService = DatabaseService();

  /// 支出のカテゴリを統合して取得
  Future<List<CategoryItem>> getExpenseCategories() async {
    try {
      final customCategories = await _databaseService.getCustomCategoriesByType(CategoryType.expense);
      
      // カスタムカテゴリが存在する場合はそれを使用
      if (customCategories.isNotEmpty) {
        return customCategories.map((cat) => CategoryItem.fromCustomCategory(cat)).toList();
      }
      
      // レガシーカテゴリをフォールバックとして使用
      return ExpenseCategory.values
          .map((cat) => CategoryItem.fromExpenseCategory(cat))
          .toList();
    } catch (e) {
      debugPrint('支出カテゴリ取得エラー: $e');
      // エラーの場合はレガシーカテゴリを返す
      return ExpenseCategory.values
          .map((cat) => CategoryItem.fromExpenseCategory(cat))
          .toList();
    }
  }

  /// 収入のカテゴリを統合して取得
  Future<List<CategoryItem>> getIncomeCategories() async {
    try {
      final customCategories = await _databaseService.getCustomCategoriesByType(CategoryType.income);
      
      // カスタムカテゴリが存在する場合はそれを使用
      if (customCategories.isNotEmpty) {
        return customCategories.map((cat) => CategoryItem.fromCustomCategory(cat)).toList();
      }
      
      // レガシーカテゴリをフォールバックとして使用
      return IncomeCategory.values
          .map((cat) => CategoryItem.fromIncomeCategory(cat))
          .toList();
    } catch (e) {
      debugPrint('収入カテゴリ取得エラー: $e');
      // エラーの場合はレガシーカテゴリを返す
      return IncomeCategory.values
          .map((cat) => CategoryItem.fromIncomeCategory(cat))
          .toList();
    }
  }

  /// 支出カテゴリIDから表示名を取得
  Future<String> getExpenseCategoryName(int categoryId) async {
    try {
      final customCategories = await _databaseService.getCustomCategoriesByType(CategoryType.expense);
      
      if (customCategories.isNotEmpty) {
        // カスタムカテゴリIDとして扱う
        final category = await _databaseService.getCustomCategoryById(categoryId);
        return category?.name ?? 'その他';
      } else {
        // レガシーカテゴリインデックスとして扱う
        if (categoryId >= 0 && categoryId < ExpenseCategory.values.length) {
          return ExpenseCategory.values[categoryId].displayName;
        }
        return 'その他';
      }
    } catch (e) {
      debugPrint('支出カテゴリ名取得エラー: $e');
      return 'その他';
    }
  }

  /// 収入カテゴリIDから表示名を取得
  Future<String> getIncomeCategoryName(int categoryId) async {
    try {
      final customCategories = await _databaseService.getCustomCategoriesByType(CategoryType.income);
      
      if (customCategories.isNotEmpty) {
        // カスタムカテゴリIDとして扱う
        final category = await _databaseService.getCustomCategoryById(categoryId);
        return category?.name ?? 'その他';
      } else {
        // レガシーカテゴリインデックスとして扱う
        if (categoryId >= 0 && categoryId < IncomeCategory.values.length) {
          return IncomeCategory.values[categoryId].displayName;
        }
        return 'その他';
      }
    } catch (e) {
      debugPrint('収入カテゴリ名取得エラー: $e');
      return 'その他';
    }
  }

  /// カスタムカテゴリが有効かどうかを確認
  Future<bool> isCustomCategoryEnabled() async {
    try {
      final expenseCategories = await _databaseService.getCustomCategoriesByType(CategoryType.expense);
      final incomeCategories = await _databaseService.getCustomCategoriesByType(CategoryType.income);
      return expenseCategories.isNotEmpty || incomeCategories.isNotEmpty;
    } catch (e) {
      debugPrint('カスタムカテゴリ状態確認エラー: $e');
      return false;
    }
  }
}

/// カテゴリアイテムを表すクラス（カスタムカテゴリとレガシーカテゴリを統合）
class CategoryItem {
  final int id;
  final String name;
  final Color color;
  final IconData icon;
  final bool isCustom;

  CategoryItem({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.isCustom,
  });

  /// カスタムカテゴリからCategoryItemを作成
  factory CategoryItem.fromCustomCategory(CustomCategory category) {
    return CategoryItem(
      id: category.id!,
      name: category.name,
      color: category.color,
      icon: category.icon,
      isCustom: true,
    );
  }

  /// 支出カテゴリからCategoryItemを作成
  factory CategoryItem.fromExpenseCategory(ExpenseCategory category) {
    return CategoryItem(
      id: category.index,
      name: category.displayName,
      color: category.color,
      icon: category.icon,
      isCustom: false,
    );
  }

  /// 収入カテゴリからCategoryItemを作成
  factory CategoryItem.fromIncomeCategory(IncomeCategory category) {
    return CategoryItem(
      id: category.index,
      name: category.displayName,
      color: category.color,
      icon: category.icon,
      isCustom: false,
    );
  }

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryItem &&
        other.id == id &&
        other.isCustom == isCustom;
  }

  @override
  int get hashCode => id.hashCode ^ isCustom.hashCode;
}
