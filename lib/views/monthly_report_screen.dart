import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/income_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final expenseViewModel = Provider.of<ExpenseViewModel>(context);
    final incomeViewModel = Provider.of<IncomeViewModel>(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final isDark = themeViewModel.isDarkMode;

    // 選択された月のデータを取得
    final monthlyIncomes = _getMonthlyIncomes(incomeViewModel);
    final monthlyExpenses = _getMonthlyExpenses(expenseViewModel);
    final totalIncome = monthlyIncomes.values.fold<double>(0, (sum, amount) => sum + amount);
    final totalExpense = monthlyExpenses.values.fold<double>(0, (sum, amount) => sum + amount);
    final balance = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(
        title: const Text('月次収支レポート'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),      body: SafeArea(
        child: SingleChildScrollView(
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
            const SizedBox(height: 20),

            // カテゴリ別収入グラフ
            if (monthlyIncomes.isNotEmpty) ...[
              _buildSectionTitle('カテゴリ別収入', isDark),
              const SizedBox(height: 10),
              _buildCategoryPieChart(monthlyIncomes, isDark, true),
              const SizedBox(height: 20),
            ],

            // カテゴリ別支出グラフ
            if (monthlyExpenses.isNotEmpty) ...[
              _buildSectionTitle('カテゴリ別支出', isDark),
              const SizedBox(height: 10),
              _buildCategoryPieChart(monthlyExpenses, isDark, false),            ],
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
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
              });
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
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
              });            },
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
  }
  Widget _buildCategoryPieChart(Map<String, double> categoryData, bool isDark, bool isIncome) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: _createPieChartSections(categoryData, isIncome),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(Map<String, double> data, bool isIncome) {
    final colors = isIncome 
        ? [Colors.green, Colors.lightGreen, Colors.teal, Colors.cyan]
        : [Colors.red, Colors.orange, Colors.pink, Colors.purple, Colors.indigo, Colors.blue];
    
    final total = data.values.fold<double>(0, (sum, value) => sum + value);
    final sections = <PieChartSectionData>[];
    
    int index = 0;
    data.forEach((category, amount) {
      final percentage = (amount / total) * 100;
      sections.add(
        PieChartSectionData(
          color: colors[index % colors.length],
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      index++;
    });
    
    return sections;
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Map<String, double> _getMonthlyIncomes(IncomeViewModel viewModel) {
    final incomes = viewModel.incomes;
    final monthlyData = <String, double>{};

    for (final income in incomes) {
      if (income.date.year == _selectedMonth.year && 
          income.date.month == _selectedMonth.month) {
        final category = income.category.toString().split('.').last;
        monthlyData[category] = (monthlyData[category] ?? 0) + income.amount;
      }
    }

    return monthlyData;
  }

  Map<String, double> _getMonthlyExpenses(ExpenseViewModel viewModel) {
    final expenses = viewModel.expenses;
    final monthlyData = <String, double>{};

    for (final expense in expenses) {
      if (expense.date.year == _selectedMonth.year && 
          expense.date.month == _selectedMonth.month) {
        final category = expense.category.toString().split('.').last;
        monthlyData[category] = (monthlyData[category] ?? 0) + expense.amount;
      }
    }

    return monthlyData;
  }
}
