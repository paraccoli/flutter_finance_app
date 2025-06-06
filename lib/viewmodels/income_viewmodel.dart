import 'package:flutter/foundation.dart';
import '../models/income.dart';
import '../services/database_service.dart';

class IncomeViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Income> _incomes = [];
  
  // 表示用の日付範囲
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  // ゲッター
  List<Income> get incomes => _incomes;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  // 初期化
  Future<void> loadIncomes() async {
    _incomes = await _databaseService.getIncomesByDateRange(_startDate, _endDate);
    notifyListeners();
  }

  // 日付範囲の変更
  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    loadIncomes();
  }

  // 収入の追加
  Future<void> addIncome(Income income) async {
    await _databaseService.insertIncome(income);
    await loadIncomes();
  }

  // 収入の更新
  Future<void> updateIncome(Income income) async {
    await _databaseService.updateIncome(income);
    await loadIncomes();
  }

  // 収入の削除
  Future<void> deleteIncome(int id) async {
    await _databaseService.deleteIncome(id);
    await loadIncomes();
  }

  // カテゴリ別の合計金額を計算
  Map<IncomeCategory, double> getCategoryTotals() {
    Map<IncomeCategory, double> totals = {};
    
    for (var income in _incomes) {
      totals[income.category] = (totals[income.category] ?? 0) + income.amount;
    }
    
    return totals;
  }

  // 日付別の合計金額を計算
  Map<DateTime, double> getDailyTotals() {
    Map<DateTime, double> totals = {};
    
    for (var income in _incomes) {
      // 時間部分を削除して日付のみにする
      DateTime dateOnly = DateTime(income.date.year, income.date.month, income.date.day);
      totals[dateOnly] = (totals[dateOnly] ?? 0) + income.amount;
    }
    
    return totals;
  }
  
  // 月別の合計金額を計算
  Map<DateTime, double> getMonthlyTotals() {
    Map<DateTime, double> totals = {};
    
    for (var income in _incomes) {
      // 日付部分を削除して月のみにする
      DateTime monthOnly = DateTime(income.date.year, income.date.month, 1);
      totals[monthOnly] = (totals[monthOnly] ?? 0) + income.amount;
    }
    
    return totals;
  }
  
  // 合計収入額を取得
  double getTotalIncome() {
    return _incomes.fold(0, (sum, income) => sum + income.amount);
  }
}
