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
    try {
      debugPrint('ExpenseViewModel: 支出リストを読み込み中...');
      _expenses = await _databaseService.getExpensesByDateRange(
        _startDate,
        _endDate,
      );
      debugPrint('ExpenseViewModel: ${_expenses.length}件の支出を読み込みました');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('ExpenseViewModel: 支出読み込み中にエラーが発生しました: $e');
      debugPrint('スタックトレース: $stackTrace');
      // エラーが発生してもアプリが停止しないように空のリストを設定
      _expenses = [];
      notifyListeners();
    }
  }  // 日付範囲の変更
  void setDateRange(DateTime start, DateTime end) {
    // 開始日を日の始まり（00:00:00）に設定
    _startDate = DateTime(start.year, start.month, start.day, 0, 0, 0);
    
    // 終了日を日の終わり（23:59:59）に設定
    _endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    
    debugPrint('ExpenseViewModel: 日付範囲を設定しました - $_startDate から $_endDate');
    loadExpenses();
  }

  // すべての支出を表示（日付範囲制限なし）
  Future<void> loadAllExpenses() async {
    try {
      debugPrint('ExpenseViewModel: すべての支出を読み込み中...');
      _expenses = await _databaseService.getExpenses();
      debugPrint('ExpenseViewModel: ${_expenses.length}件の支出を読み込みました');
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('ExpenseViewModel: 支出読み込み中にエラーが発生しました: $e');
      debugPrint('スタックトレース: $stackTrace');
      _expenses = [];
      notifyListeners();
    }
  }
  // 支出の追加
  Future<void> addExpense(Expense expense) async {
    try {
      debugPrint('ExpenseViewModel: 支出を追加中... 金額: ${expense.amount}, カテゴリ: ${expense.category}');
      await _databaseService.insertExpense(expense);
      debugPrint('ExpenseViewModel: 支出の追加が完了しました');
      await loadExpenses();
      debugPrint('ExpenseViewModel: 支出リストの再読み込みが完了しました');
    } catch (e, stackTrace) {
      debugPrint('ExpenseViewModel: 支出追加中にエラーが発生しました: $e');
      debugPrint('スタックトレース: $stackTrace');
      // エラーを再スローして上位でハンドリングできるようにする
      rethrow;
    }
  }
  // 支出の更新
  Future<void> updateExpense(Expense expense) async {
    try {
      debugPrint('ExpenseViewModel: 支出を更新中... ID: ${expense.id}, 金額: ${expense.amount}');
      await _databaseService.updateExpense(expense);
      debugPrint('ExpenseViewModel: 支出の更新が完了しました');
      await loadExpenses();
      debugPrint('ExpenseViewModel: 支出リストの再読み込みが完了しました');
    } catch (e, stackTrace) {
      debugPrint('ExpenseViewModel: 支出更新中にエラーが発生しました: $e');
      debugPrint('スタックトレース: $stackTrace');
      rethrow;
    }
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
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }

    return totals;
  }

  // 日付別の合計金額を計算
  Map<DateTime, double> getDailyTotals() {
    Map<DateTime, double> totals = {};

    for (var expense in _expenses) {
      // 時間部分を削除して日付のみにする
      DateTime dateOnly = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      totals[dateOnly] = (totals[dateOnly] ?? 0) + expense.amount;
    }

    return totals;
  }

  // 平均月間支出を計算
  double getAverageMonthlyExpense() {
    if (_expenses.isEmpty) return 0;

    // 月ごとの支出を集計
    Map<String, double> monthlyExpenses = {};
    for (var expense in _expenses) {
      final month = '${expense.date.year}-${expense.date.month}';
      monthlyExpenses[month] = (monthlyExpenses[month] ?? 0) + expense.amount;
    }    // 平均を計算
    double total = monthlyExpenses.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    return monthlyExpenses.isEmpty ? 0 : total / monthlyExpenses.length;
  }
  /// 複数の支出を一括追加（CSVインポート用）
  Future<void> addExpensesBatch(List<Expense> expenses) async {
    try {
      debugPrint('ExpenseViewModel: ${expenses.length}件の支出を一括追加中...');
      
      for (int i = 0; i < expenses.length; i++) {
        final expense = expenses[i];
        debugPrint('ExpenseViewModel: ${i + 1}/${expenses.length} - ${expense.amount}円, ${expense.note}');
        await _databaseService.insertExpense(expense);
      }
      
      debugPrint('ExpenseViewModel: 一括追加完了');
      await loadExpenses(); // データを再読み込み
      debugPrint('ExpenseViewModel: データ再読み込み完了、現在の支出件数: ${_expenses.length}');
    } catch (e, stackTrace) {
      debugPrint('ExpenseViewModel: 一括追加中にエラーが発生しました: $e');
      debugPrint('スタックトレース: $stackTrace');
      throw Exception('支出の一括追加に失敗しました: $e');
    }
  }
}
