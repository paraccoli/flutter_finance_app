import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/income_viewmodel.dart';
import '../models/income.dart';
import '../widgets/income_form.dart';
import 'package:fl_chart/fl_chart.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<IncomeViewModel>(context);
    final categoryTotals = viewModel.getCategoryTotals();
    final monthlyTotals = viewModel.getMonthlyTotals();
    
    // 合計金額を計算
    final totalIncome = viewModel.getTotalIncome();
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => viewModel.loadIncomes(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 日付範囲選択
                _buildDateRangeSelector(context, viewModel),
                const SizedBox(height: 16),
                
                // 合計金額表示
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          '合計収入',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¥${NumberFormat('#,###').format(totalIncome)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 月次収入グラフ
                if (monthlyTotals.isNotEmpty)
                  _buildMonthlyBarChart(monthlyTotals)
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('月次データがありません'),
                    ),
                  ),
                const SizedBox(height: 16),
                
                // カテゴリ円グラフ
                if (categoryTotals.isNotEmpty)
                  _buildCategoryPieChart(categoryTotals)
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('カテゴリデータがありません'),
                    ),
                  ),
                const SizedBox(height: 16),
                
                // 収入リスト
                const Text(
                  '収入リスト',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildIncomeList(context, viewModel),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIncomeDialog(context, viewModel),
        tooltip: '収入を追加',
        child: const Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Widget _buildDateRangeSelector(BuildContext context, IncomeViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${DateFormat('yyyy/MM/dd').format(viewModel.startDate)} - '
          '${DateFormat('yyyy/MM/dd').format(viewModel.endDate)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () => _selectDateRange(context, viewModel),
          child: const Text('期間を選択'),
        ),
      ],
    );
  }
  
  Future<void> _selectDateRange(BuildContext context, IncomeViewModel viewModel) async {
    final initialDateRange = DateTimeRange(
      start: viewModel.startDate,
      end: viewModel.endDate,
    );
    
    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (pickedDateRange != null) {
      viewModel.setDateRange(pickedDateRange.start, pickedDateRange.end);
    }
  }
  
  Widget _buildMonthlyBarChart(Map<DateTime, double> monthlyTotals) {
    final sortedMonths = monthlyTotals.keys.toList()..sort();
    
    return AspectRatio(
      aspectRatio: 1.6,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                '月別収入',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxMonthlyValue(monthlyTotals) * 1.2,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.blueGrey,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final date = sortedMonths[groupIndex];
                          final value = monthlyTotals[date];
                          return BarTooltipItem(
                            '${DateFormat('yyyy/MM').format(date)}\n¥${value?.toStringAsFixed(0)}',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
                              final date = sortedMonths[value.toInt()];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('MM').format(date),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '¥${value.toInt()}',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    barGroups: _getMonthlyBarGroups(sortedMonths, monthlyTotals),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  double _getMaxMonthlyValue(Map<DateTime, double> monthlyTotals) {
    if (monthlyTotals.isEmpty) return 1000;
    return monthlyTotals.values.reduce((max, value) => max > value ? max : value);
  }
  
  List<BarChartGroupData> _getMonthlyBarGroups(
    List<DateTime> sortedMonths, 
    Map<DateTime, double> monthlyTotals
  ) {
    return List.generate(sortedMonths.length, (index) {
      final month = sortedMonths[index];
      final value = monthlyTotals[month] ?? 0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: Colors.green,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }
  
  Widget _buildCategoryPieChart(Map<IncomeCategory, double> categoryTotals) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'カテゴリ別収入',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _getCategorySections(categoryTotals),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildCategoryLegend(categoryTotals),
            ],
          ),
        ),
      ),
    );
  }
  
  List<PieChartSectionData> _getCategorySections(Map<IncomeCategory, double> categoryTotals) {
    final List<PieChartSectionData> sections = [];
    
    // カテゴリごとの色を定義
    final Map<IncomeCategory, Color> categoryColors = {
      IncomeCategory.salary: Colors.green,
      IncomeCategory.bonus: Colors.blue,
      IncomeCategory.investment: Colors.purple,
      IncomeCategory.sideJob: Colors.orange,
      IncomeCategory.gift: Colors.pink,
      IncomeCategory.other: Colors.grey,
    };
    
    categoryTotals.forEach((category, amount) {
      sections.add(
        PieChartSectionData(
          color: categoryColors[category] ?? Colors.grey,
          value: amount,
          title: '¥${amount.toStringAsFixed(0)}',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });
    
    return sections;
  }
  
  Widget _buildCategoryLegend(Map<IncomeCategory, double> categoryTotals) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: categoryTotals.keys.map((category) {
        final Map<IncomeCategory, Color> categoryColors = {
          IncomeCategory.salary: Colors.green,
          IncomeCategory.bonus: Colors.blue,
          IncomeCategory.investment: Colors.purple,
          IncomeCategory.sideJob: Colors.orange,
          IncomeCategory.gift: Colors.pink,
          IncomeCategory.other: Colors.grey,
        };
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              color: categoryColors[category],
            ),
            const SizedBox(width: 4),
            Text(category.toString()),
          ],
        );
      }).toList(),
    );
  }
  
  Widget _buildIncomeList(BuildContext context, IncomeViewModel viewModel) {
    final incomes = viewModel.incomes;
    
    if (incomes.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('データがありません'),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: incomes.length,
      itemBuilder: (context, index) {
        final income = incomes[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(income.category),
              child: Icon(
                _getCategoryIcon(income.category),
                color: Colors.white,
              ),
            ),
            title: Text(
              '¥${NumberFormat('#,###').format(income.amount)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            subtitle: Text(
              '${income.category} - ${DateFormat('yyyy/MM/dd').format(income.date)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditIncomeDialog(context, viewModel, income),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmationDialog(context, viewModel, income),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _showAddIncomeDialog(BuildContext context, IncomeViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('収入を追加'),
          content: SingleChildScrollView(
            child: IncomeForm(
              onSave: (income) {
                viewModel.addIncome(income);
              },
            ),
          ),
        );
      },
    );
  }
  
  void _showEditIncomeDialog(BuildContext context, IncomeViewModel viewModel, Income income) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('収入を編集'),
          content: SingleChildScrollView(
            child: IncomeForm(
              income: income,
              onSave: (updatedIncome) {
                viewModel.updateIncome(updatedIncome);
              },
            ),
          ),
        );
      },
    );
  }
  
  void _showDeleteConfirmationDialog(BuildContext context, IncomeViewModel viewModel, Income income) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認'),
          content: const Text('この収入を削除してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (income.id != null) {
                  viewModel.deleteIncome(income.id!);
                }
              },
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }
  
  Color _getCategoryColor(IncomeCategory category) {
    switch (category) {
      case IncomeCategory.salary:
        return Colors.green;
      case IncomeCategory.bonus:
        return Colors.blue;
      case IncomeCategory.investment:
        return Colors.purple;
      case IncomeCategory.sideJob:
        return Colors.orange;
      case IncomeCategory.gift:
        return Colors.pink;
      case IncomeCategory.other:
        return Colors.grey;
    }
  }
  
  IconData _getCategoryIcon(IncomeCategory category) {
    switch (category) {
      case IncomeCategory.salary:
        return Icons.work;
      case IncomeCategory.bonus:
        return Icons.monetization_on;
      case IncomeCategory.investment:
        return Icons.trending_up;
      case IncomeCategory.sideJob:
        return Icons.business_center;
      case IncomeCategory.gift:
        return Icons.card_giftcard;
      case IncomeCategory.other:
        return Icons.more_horiz;
    }
  }
}
