import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class ExpenseViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Expense> _expenses = [];
  
  // 表示用の日付範囲
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  // ゲッター
  List<Expense> get expenses => _expenses;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  // 初期化
  Future<void> loadExpenses() async {
    _expenses = await _databaseService.getExpensesByDateRange(_startDate, _endDate);
    notifyListeners();
  }

  // 日付範囲の変更
  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    loadExpenses();
  }

  // 支出の追加
  Future<void> addExpense(Expense expense) async {
    await _databaseService.insertExpense(expense);
    await loadExpenses();
  }

  // 支出の更新
  Future<void> updateExpense(Expense expense) async {
    await _databaseService.updateExpense(expense);
    await loadExpenses();
  }

  // 支出の削除
  Future<void> deleteExpense(int id) async {
    await _databaseService.deleteExpense(id);
    await loadExpenses();
  }

  // カテゴリ別の合計金額を計算
  Map<ExpenseCategory, double> getCategoryTotals() {
    Map<ExpenseCategory, double> totals = {};
    
    for (var expense in _expenses) {
      totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
    }
    
    return totals;
  }

  // 日付別の合計金額を計算
  Map<DateTime, double> getDailyTotals() {
    Map<DateTime, double> totals = {};
    
    for (var expense in _expenses) {
      // 時間部分を削除して日付のみにする
      DateTime dateOnly = DateTime(expense.date.year, expense.date.month, expense.date.day);
      totals[dateOnly] = (totals[dateOnly] ?? 0) + expense.amount;
    }
    
    return totals;
  }
}
