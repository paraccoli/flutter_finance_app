import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/nisa_investment.dart';
import '../services/database_service.dart';

/// 資産分析用のViewModel
class AssetAnalysisViewModel extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Expense> _expenses = [];
  List<Income> _incomes = [];
  List<NisaInvestment> _investments = [];

  // 表示用の日付範囲
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 365));
  DateTime _endDate = DateTime.now();

  // 将来予測の月数
  int _forecastMonths = 12;

  // ゲッター
  List<Expense> get expenses => _expenses;
  List<Income> get incomes => _incomes;
  List<NisaInvestment> get investments => _investments;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;
  int get forecastMonths => _forecastMonths;

  // 初期化
  Future<void> loadData() async {
    _expenses = await _databaseService.getExpensesByDateRange(
      _startDate,
      _endDate,
    );
    _incomes = await _databaseService.getIncomesByDateRange(
      _startDate,
      _endDate,
    );
    _investments = await _databaseService.getNisaInvestments();
    notifyListeners();
  }

  // 日付範囲の変更
  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    loadData();
  }

  // 予測月数の変更
  void setForecastMonths(int months) {
    _forecastMonths = months;
    notifyListeners();
  }

  // 月別の収支バランスを計算
  Map<DateTime, double> getMonthlyBalances() {
    // 月別の収入を集計
    Map<DateTime, double> incomesByMonth = {};
    for (var income in _incomes) {
      final DateTime month = DateTime(income.date.year, income.date.month, 1);
      incomesByMonth[month] = (incomesByMonth[month] ?? 0) + income.amount;
    }

    // 月別の支出を集計
    Map<DateTime, double> expensesByMonth = {};
    for (var expense in _expenses) {
      final DateTime month = DateTime(expense.date.year, expense.date.month, 1);
      expensesByMonth[month] = (expensesByMonth[month] ?? 0) + expense.amount;
    }

    // 収支バランスを計算
    Map<DateTime, double> balances = {};

    // すべての月のセットを作成
    Set<DateTime> allMonths = {};
    allMonths.addAll(incomesByMonth.keys);
    allMonths.addAll(expensesByMonth.keys);

    // 各月の収支バランスを計算
    for (var month in allMonths) {
      final income = incomesByMonth[month] ?? 0;
      final expense = expensesByMonth[month] ?? 0;
      balances[month] = income - expense;
    }

    return balances;
  }

  // 将来の月別収支予測を計算
  List<MonthlyForecast> getFutureBalancesForecast() {
    // 過去のデータから平均値を計算
    double avgMonthlyIncome = 0;
    double avgMonthlyExpense = 0;

    if (_incomes.isNotEmpty) {
      // 月ごとの収入を集計
      Map<DateTime, double> monthlyIncomes = {};
      for (var income in _incomes) {
        final month = DateTime(income.date.year, income.date.month, 1);
        monthlyIncomes[month] = (monthlyIncomes[month] ?? 0) + income.amount;
      }
      // 平均月収を計算（データがある月のみの平均）
      avgMonthlyIncome =
          monthlyIncomes.values.fold(
            0.0,
            (double sum, amount) => sum + amount,
          ) /
          monthlyIncomes.length;
    }

    if (_expenses.isNotEmpty) {
      // 月ごとの支出を集計
      Map<DateTime, double> monthlyExpenses = {};
      for (var expense in _expenses) {
        final month = DateTime(expense.date.year, expense.date.month, 1);
        monthlyExpenses[month] = (monthlyExpenses[month] ?? 0) + expense.amount;
      }
      // 平均月支出を計算（データがある月のみの平均）
      avgMonthlyExpense =
          monthlyExpenses.values.fold(
            0.0,
            (double sum, amount) => sum + amount,
          ) /
          monthlyExpenses.length;
    }
    // NISA投資の月々の拠出総額
    double monthlyNisaContribution = _investments.fold(
      0.0,
      (double sum, investment) => sum + investment.monthlyContribution,
    );

    // 現在の月から予測開始
    DateTime currentMonth = DateTime.now();
    // 日付部分を1日に設定
    currentMonth = DateTime(currentMonth.year, currentMonth.month, 1);

    List<MonthlyForecast> forecasts = [];
    double cumulativeBalance = 0; // 累積収支
    double cumulativeNisa = _investments.fold(
      0,
      (sum, investment) => sum + investment.currentValue,
    ); // 現在のNISA評価額

    // 過去の月別収支バランスを取得
    Map<DateTime, double> pastBalances = getMonthlyBalances();

    // 過去の収支を累積値に加算
    for (var entry in pastBalances.entries) {
      if (entry.key.isBefore(currentMonth)) {
        cumulativeBalance += entry.value;
      }
    }

    // NISA成長率（年率）
    const double annualNisaGrowthRate = 0.05; // 5%成長と仮定
    final double monthlyNisaGrowthRate = annualNisaGrowthRate / 12;

    // 将来予測を計算
    for (int i = 0; i < _forecastMonths; i++) {
      final forecastMonth = DateTime(
        currentMonth.year,
        currentMonth.month + i,
        1,
      );

      // 月収 - 月支出 = 月間収支
      final monthlyBalance = avgMonthlyIncome - avgMonthlyExpense;

      // 累積収支を更新
      cumulativeBalance += monthlyBalance;

      // NISA資産を更新（成長率 + 毎月の拠出額）
      cumulativeNisa =
          cumulativeNisa * (1 + monthlyNisaGrowthRate) +
          monthlyNisaContribution;

      // 合計資産
      final totalAssets = cumulativeBalance + cumulativeNisa;

      forecasts.add(
        MonthlyForecast(
          month: forecastMonth,
          income: avgMonthlyIncome,
          expense: avgMonthlyExpense,
          balance: monthlyBalance,
          cumulativeBalance: cumulativeBalance,
          nisaValue: cumulativeNisa,
          totalAssets: totalAssets,
        ),
      );
    }

    return forecasts;
  }

  // NISAの将来価値予測を計算
  List<NisaForecast> getNisaForecast() {
    // 現在のNISA投資合計
    double totalCurrentValue = _investments.fold(
      0.0,
      (double sum, investment) => sum + investment.currentValue,
    );

    // 月々の拠出総額
    double monthlyContribution = _investments.fold(
      0.0,
      (double sum, investment) => sum + investment.monthlyContribution,
    );

    // NISA成長率（年率）
    const double annualGrowthRate = 0.05; // 5%成長と仮定
    final double monthlyGrowthRate = annualGrowthRate / 12;

    // 現在の月から予測開始
    DateTime currentMonth = DateTime.now();
    // 日付部分を1日に設定
    currentMonth = DateTime(currentMonth.year, currentMonth.month, 1);

    List<NisaForecast> forecasts = [];
    double cumulativeValue = totalCurrentValue;

    // 将来予測を計算
    for (int i = 0; i < _forecastMonths; i++) {
      final forecastMonth = DateTime(
        currentMonth.year,
        currentMonth.month + i,
        1,
      );

      // 前月の値に成長率を適用し、今月の拠出額を加算
      cumulativeValue =
          cumulativeValue * (1 + monthlyGrowthRate) + monthlyContribution;

      forecasts.add(
        NisaForecast(month: forecastMonth, expectedValue: cumulativeValue),
      );
    }

    return forecasts;
  }

  /// 資産配分（資産種類別の金額）を取得
  Map<String, double> getAssetAllocation() {
    // 例として単純化した資産配分を返す
    return {
      '現金・預金': 1200000,
      '株式': 800000,
      'NISA': _investments.fold(
        0.0,
        (sum, investment) => sum + investment.currentValue,
      ),
      '債券': 500000,
      '不動産': 3000000,
    };
  }

  /// 資産の履歴データを取得
  List<AssetHistoryData> getAssetHistory() {
    // 過去12ヶ月分の資産推移データを生成（サンプル）
    final List<AssetHistoryData> history = [];
    final now = DateTime.now();

    double baseAmount = 5000000.0; // 基準額

    for (int i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      // 徐々に増加するトレンドを作成（変動あり）
      final randomFactor =
          0.95 +
          (0.1 * i / 12) +
          (0.05 * (DateTime.now().millisecondsSinceEpoch % 10) / 10);
      final amount = baseAmount * randomFactor;

      history.add(AssetHistoryData(date: month, totalAssets: amount));

      // 次の月のベース額を更新
      baseAmount = amount;
    }

    return history;
  }

  /// 収支予測データを生成
  List<ForecastData> generateCashFlowForecast(
    int months,
    double monthlyIncome,
    double monthlyExpense,
  ) {
    final List<ForecastData> forecast = [];
    final now = DateTime.now();
    double cumulativeBalance = 0;

    for (int i = 0; i < months; i++) {
      final month = DateTime(now.year, now.month + i, 1);
      final balance = monthlyIncome - monthlyExpense;
      cumulativeBalance += balance;

      forecast.add(
        ForecastData(
          date: month,
          income: monthlyIncome,
          expense: monthlyExpense,
          balance: cumulativeBalance,
        ),
      );
    }
    return forecast;
  }
}

/// 月次予測データを表すクラス
class MonthlyForecast {
  final DateTime month;
  final double income;
  final double expense;
  final double balance;
  final double cumulativeBalance;
  final double nisaValue;
  final double totalAssets;

  MonthlyForecast({
    required this.month,
    required this.income,
    required this.expense,
    required this.balance,
    required this.cumulativeBalance,
    required this.nisaValue,
    required this.totalAssets,
  });
}

/// NISA予測データを表すクラス
class NisaForecast {
  final DateTime month;
  final double expectedValue;

  NisaForecast({required this.month, required this.expectedValue});
}

/// 資産履歴データを表すクラス
class AssetHistoryData {
  final DateTime date;
  final double totalAssets;

  AssetHistoryData({required this.date, required this.totalAssets});
}

/// 収支予測データを表すクラス
class ForecastData {
  final DateTime date;
  final double income;
  final double expense;
  final double balance;

  ForecastData({
    required this.date,
    required this.income,
    required this.expense,
    required this.balance,
  });
}
