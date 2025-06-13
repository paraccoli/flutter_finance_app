import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../services/database_service.dart';
import '../models/expense.dart';
import '../models/income.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime _selectedMonth = DateTime.now();
  final DatabaseService _databaseService = DatabaseService();
  List<Expense> _monthlyExpenses = [];
  List<Income> _monthlyIncomes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeWithDataMonth();
  }
  /// データが存在する月を検出して初期表示
  Future<void> _initializeWithDataMonth() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 全支出データの最初の日付を取得
      final allExpenses = await _databaseService.getExpenses();
      if (allExpenses.isNotEmpty) {
        // 最初のデータがある月に設定
        final firstDate = allExpenses.first.date;
        _selectedMonth = DateTime(firstDate.year, firstDate.month);
        debugPrint('月別レポート: データが見つかった月に移動 - ${DateFormat('yyyy年MM月').format(_selectedMonth)}');
      }
    } catch (e) {
      debugPrint('月別レポート: 初期化エラー: $e');
    }
    
    await _loadMonthlyData();
  }

  /// 指定月のデータを読み込み
  Future<void> _loadMonthlyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 月の開始日と終了日を計算
      final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

      debugPrint('月別レポート: データ読み込み中 - $startDate から $endDate');

      // データベースから直接データを取得
      _monthlyExpenses = await _databaseService.getExpensesByDateRange(startDate, endDate);
      _monthlyIncomes = await _databaseService.getIncomesByDateRange(startDate, endDate);

      debugPrint('月別レポート: 支出${_monthlyExpenses.length}件、収入${_monthlyIncomes.length}件を読み込み');
    } catch (e) {
      debugPrint('月別レポート: データ読み込みエラー: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final isDark = themeViewModel.isDarkMode;

    // 月別データを集計
    final monthlyIncomes = _getMonthlyIncomes();
    final monthlyExpenses = _getMonthlyExpenses();
    final totalIncome = monthlyIncomes.values.fold<double>(0, (sum, amount) => sum + amount);
    final totalExpense = monthlyExpenses.values.fold<double>(0, (sum, amount) => sum + amount);
    final balance = totalIncome - totalExpense;    return Scaffold(
      appBar: AppBar(
        title: const Text('月次収支レポート'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 月選択
                    _buildMonthSelector(isDark),
                    const SizedBox(height: 20),

                    // 収支サマリー
                    _buildSummaryCard(totalIncome, totalExpense, balance, isDark),
            const SizedBox(height: 20),

            // 収支グラフ
            _buildBalanceChart(monthlyIncomes, monthlyExpenses, isDark),
            const SizedBox(height: 20),            // カテゴリ別収支比較グラフ
            if (monthlyIncomes.isNotEmpty || monthlyExpenses.isNotEmpty) ...[
              _buildSectionTitle('カテゴリ別収支比較', isDark),
              const SizedBox(height: 10),
              _buildCategoryBarChart(monthlyIncomes, monthlyExpenses, isDark),
              const SizedBox(height: 20),
            ],
          ],
        ),
        ),
      ),
    );
  }
  Widget _buildMonthSelector(bool isDark) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
              });
              _loadMonthlyData(); // 新しい月のデータを読み込み
            },
            icon: Icon(
              Icons.chevron_left,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            DateFormat('yyyy年 MM月').format(_selectedMonth),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
              });
              _loadMonthlyData(); // 新しい月のデータを読み込み
            },
            icon: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    ),
    );
  }
  Widget _buildSummaryCard(double totalIncome, double totalExpense, double balance, bool isDark) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('収入', totalIncome, Colors.green, isDark),
              _buildSummaryItem('支出', totalExpense, Colors.red, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
          const SizedBox(height: 16),          _buildSummaryItem(
            '収支',
            balance,
            balance >= 0 ? Colors.green : Colors.red,
            isDark,
            isLarge: true,
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, Color color, bool isDark, {bool isLarge = false}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 18 : 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '¥${NumberFormat('#,###').format(amount.abs())}',
          style: TextStyle(
            fontSize: isLarge ? 24 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  Widget _buildBalanceChart(Map<String, double> incomes, Map<String, double> expenses, bool isDark) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('日別収支推移', isDark),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildLineChart(incomes, expenses, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(Map<String, double> incomes, Map<String, double> expenses, bool isDark) {
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];
    final balanceSpots = <FlSpot>[];

    double cumulativeIncome = 0;
    double cumulativeExpense = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      final dayKey = '$day';
      final dayIncome = incomes[dayKey] ?? 0;
      final dayExpense = expenses[dayKey] ?? 0;
      
      cumulativeIncome += dayIncome;
      cumulativeExpense += dayExpense;
      
      incomeSpots.add(FlSpot(day.toDouble(), cumulativeIncome));
      expenseSpots.add(FlSpot(day.toDouble(), cumulativeExpense));
      balanceSpots.add(FlSpot(day.toDouble(), cumulativeIncome - cumulativeExpense));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 5 == 0 || value.toInt() == 1) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey[600],
                      fontSize: 12,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact().format(value),
                  style: TextStyle(
                    color: isDark ? Colors.grey : Colors.grey[600],
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: incomeSpots,
            isCurved: true,
            color: Colors.green,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: expenseSpots,
            isCurved: true,
            color: Colors.red,
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: balanceSpots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }  Widget _buildCategoryBarChart(Map<String, double> incomeData, Map<String, double> expenseData, bool isDark) {
    // すべてのカテゴリを取得
    final allCategories = <String>{...incomeData.keys, ...expenseData.keys}.toList();
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxValue(incomeData, expenseData),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final category = allCategories[group.x.toInt()];
                    final isIncome = rodIndex == 0;
                    final value = rod.toY;
                    return BarTooltipItem(
                      '${isIncome ? "収入" : "支出"}\n$category\n¥${NumberFormat('#,###').format(value)}',
                      TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < allCategories.length) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            allCategories[index],
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          '¥${NumberFormat.compact().format(value)}',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: _createBarGroups(allCategories, incomeData, expenseData),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(List<String> categories, Map<String, double> incomeData, Map<String, double> expenseData) {
    return List.generate(categories.length, (index) {
      final category = categories[index];
      final incomeAmount = incomeData[category] ?? 0;
      final expenseAmount = expenseData[category] ?? 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: incomeAmount,
            color: Colors.green,
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: expenseAmount,
            color: Colors.red,
            width: 15,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  double _getMaxValue(Map<String, double> incomeData, Map<String, double> expenseData) {
    final maxIncome = incomeData.values.isEmpty ? 0.0 : incomeData.values.reduce((a, b) => a > b ? a : b);
    final maxExpense = expenseData.values.isEmpty ? 0.0 : expenseData.values.reduce((a, b) => a > b ? a : b);
    final maxValue = maxIncome > maxExpense ? maxIncome : maxExpense;
    return maxValue * 1.2; // 余白を追加
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );  }

  Map<String, double> _getMonthlyIncomes() {
    final monthlyData = <String, double>{};

    for (final income in _monthlyIncomes) {
      final category = income.category.toString().split('.').last;
      monthlyData[category] = (monthlyData[category] ?? 0) + income.amount;
    }

    return monthlyData;
  }

  Map<String, double> _getMonthlyExpenses() {
    final monthlyData = <String, double>{};

    for (final expense in _monthlyExpenses) {
      final category = expense.category.toString().split('.').last;
      monthlyData[category] = (monthlyData[category] ?? 0) + expense.amount;
    }

    return monthlyData;
  }
}
