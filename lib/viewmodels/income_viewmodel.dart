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
    _incomes = await _databaseService.getIncomesByDateRange(
      _startDate,
      _endDate,
    );
    notifyListeners();
  }
  // 日付範囲の変更
  void setDateRangeExplicit(DateTime start, DateTime end) {
    // 開始日を日の始まり（00:00:00）に設定
    _startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    
    // 終了日を日の終わり（23:59:59）に設定
    _endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    
    debugPrint('IncomeViewModel: 日付範囲を設定しました - $_startDate から $_endDate');
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
      DateTime dateOnly = DateTime(
        income.date.year,
        income.date.month,
        income.date.day,
      );
      totals[dateOnly] = (totals[dateOnly] ?? 0) + income.amount;
    }

    return totals;
  }

  // 月別の合計金額を計算
  Map<String, double> getMonthlyTotals() {
    Map<String, double> totals = {};

    for (var income in _incomes) {
      // 月を文字列として取得（例：'2023-01'）
      String monthKey =
          '${income.date.year}-${income.date.month.toString().padLeft(2, '0')}';
      totals[monthKey] = (totals[monthKey] ?? 0) + income.amount;
    }

    // キーでソートして返す
    Map<String, double> sortedTotals = {};
    final sortedKeys = totals.keys.toList()..sort();
    for (var key in sortedKeys) {
      sortedTotals[key] = totals[key]!;
    }

    return sortedTotals;
  }

  // 合計収入額を取得
  double getTotalIncome() {
    return _incomes.fold(0, (sum, income) => sum + income.amount);
  }

  // 平均月間収入を計算
  double getAverageMonthlyIncome() {
    if (_incomes.isEmpty) return 0;

    // 月ごとの収入を集計
    Map<String, double> monthlyIncomes = {};
    for (var income in _incomes) {
      final month = '${income.date.year}-${income.date.month}';
      monthlyIncomes[month] = (monthlyIncomes[month] ?? 0) + income.amount;
    }

    // 平均を計算
    double total = monthlyIncomes.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    return monthlyIncomes.isEmpty ? 0 : total / monthlyIncomes.length;
  }

  // 表示期間の設定（整数値で期間を指定）
  int _selectedDateRange = 1; // デフォルトは「今月」

  // 表示期間の取得
  int get selectedDateRange => _selectedDateRange;

  // 表示期間の設定
  void setDateRange(int rangeType) {
    _selectedDateRange = rangeType;

    final now = DateTime.now();

    switch (rangeType) {
      case 0: // 今週
        final today = DateTime(now.year, now.month, now.day);
        _startDate = today.subtract(Duration(days: today.weekday - 1));
        _endDate = now;
        break;
      case 1: // 今月
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case 2: // 3ヶ月
        _startDate = DateTime(now.year, now.month - 2, 1);
        _endDate = now;
        break;
      case 3: // 今年
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
        break;
      case 4: // 全期間
        _startDate = DateTime(2000, 1, 1);
        _endDate = now;
        break;
    }

    loadIncomes();
  }
}
