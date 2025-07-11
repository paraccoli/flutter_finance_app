import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/income_viewmodel.dart';
import '../models/income.dart';
import '../widgets/income_form.dart';
import '../widgets/quick_income_widget.dart';
import '../services/category_service.dart';
import '../services/database_service.dart';
import 'package:fl_chart/fl_chart.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<IncomeViewModel>(context);
    final monthlyTotals = viewModel.getMonthlyTotals();

    // 合計金額を計算
    final totalIncome = viewModel.getTotalIncome();    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
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
                  ),                ),
                const SizedBox(height: 16),

                // クイック登録
                QuickIncomeWidget(
                  onIncomeAdded: () => viewModel.loadIncomes(),
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

                // カテゴリ円グラフ（カスタムカテゴリ対応）
                FutureBuilder<Map<String, Map<String, dynamic>>>(
                  future: viewModel.getCustomCategoryTotals(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('グラフの読み込みに失敗しました'),
                        ),
                      );
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return _buildCustomCategoryPieChart(snapshot.data!);
                    } else {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('カテゴリデータがありません'),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                // 収入リスト
                const Text(
                  '収入リスト',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildIncomeList(context, viewModel),
              ],            ),
          ),
        ),        ),
      ),
    );
  }

  Widget _buildDateRangeSelector(
    BuildContext context,
    IncomeViewModel viewModel,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${DateFormat('yyyy/MM/dd').format(viewModel.startDate)} - '
          '${DateFormat('yyyy/MM/dd').format(viewModel.endDate)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () => _selectDateRange(context, viewModel),
          child: const Text('期間を選択'),
        ),
      ],
    );
  }

  Future<void> _selectDateRange(
    BuildContext context,
    IncomeViewModel viewModel,
  ) async {
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
      viewModel.setDateRangeExplicit(
        pickedDateRange.start,
        pickedDateRange.end,
      );
    }
  }

  Widget _buildMonthlyBarChart(Map<String, double> monthlyTotals) {
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxMonthlyValue(monthlyTotals) * 1.2,
                    barTouchData: BarTouchData(                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Colors.blueGrey,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final date = sortedMonths[groupIndex];
                          final value = monthlyTotals[date];
                          return BarTooltipItem(
                            '$date\n¥${value?.toStringAsFixed(0)}',
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
                            if (value.toInt() >= 0 &&
                                value.toInt() < sortedMonths.length) {
                              final dateStr = sortedMonths[value.toInt()];
                              // 形式が "yyyy-MM" と仮定して、月の部分だけを抽出
                              final month = dateStr.split('-')[1];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  month,
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
                    barGroups: _getMonthlyBarGroups(
                      sortedMonths,
                      monthlyTotals,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getMaxMonthlyValue(Map<String, double> monthlyTotals) {
    if (monthlyTotals.isEmpty) return 1000;
    return monthlyTotals.values.reduce(
      (max, value) => max > value ? max : value,
    );
  }

  List<BarChartGroupData> _getMonthlyBarGroups(
    List<String> sortedMonths,
    Map<String, double> monthlyTotals,
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

  Widget _buildCustomCategoryPieChart(Map<String, Map<String, dynamic>> categoryTotals) {
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _getCustomCategorySections(categoryTotals),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildCustomCategoryLegend(categoryTotals),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _getCustomCategorySections(
    Map<String, Map<String, dynamic>> categoryTotals,
  ) {
    final List<PieChartSectionData> sections = [];

    categoryTotals.forEach((categoryKey, categoryData) {
      final amount = categoryData['amount'] as double;
      final color = categoryData['color'] as Color;
      
      sections.add(
        PieChartSectionData(
          color: color,
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

  Widget _buildCustomCategoryLegend(Map<String, Map<String, dynamic>> categoryTotals) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: categoryTotals.values.map((categoryData) {
        final name = categoryData['name'] as String;
        final color = categoryData['color'] as Color;
        final icon = categoryData['icon'] as IconData;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12, 
              height: 12, 
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(name),
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
          child: Center(child: Text('データがありません')),
        ),
      );
    }    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: incomes.length,
      itemBuilder: (context, index) {
        final income = incomes[index];
        return Card(
          child: Dismissible(
            key: Key('income_${income.id}'),
            background: Container(
              color: Colors.blue,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 30,
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 30,
              ),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // 左から右にスワイプ = 編集
                _showEditIncomeDialog(context, viewModel, income);
                return false; // アイテムを削除しない
              } else if (direction == DismissDirection.endToStart) {
                // 右から左にスワイプ = 削除確認
                return await _showDeleteConfirmationDialog(context, viewModel, income);
              }
              return false;
            },
            child: FutureBuilder<Map<String, dynamic>>(
              future: _getIncomeDisplayInfo(income),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    title: Text('読み込み中...'),
                  );
                }
                
                final displayInfo = snapshot.data ?? {
                  'name': 'その他',
                  'color': Colors.grey,
                  'icon': Icons.category,
                };
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: displayInfo['color'] as Color,
                    child: Icon(
                      displayInfo['icon'] as IconData,
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
                    '${displayInfo['name']} - ${DateFormat('yyyy/MM/dd').format(income.date)}',
                  ),
                );
              },
            ),
          ),
        );
      },
    );  }
  void _showEditIncomeDialog(
    BuildContext context,
    IncomeViewModel viewModel,
    Income income,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('収入を編集'),
          content: SingleChildScrollView(            child: IncomeForm(
              income: income,
              onSave: (updatedIncome) async {
                await viewModel.updateIncome(updatedIncome);
                if (context.mounted) {
                  Navigator.pop(context); // ダイアログを閉じる
                }
              },
            ),
          ),
        );
      },
    );
  }
  Future<bool?> _showDeleteConfirmationDialog(
    BuildContext context,
    IncomeViewModel viewModel,
    Income income,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認'),
          content: const Text('この収入を削除してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
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

  /// 収入の表示情報を取得（カスタムカテゴリ対応）
  Future<Map<String, dynamic>> _getIncomeDisplayInfo(Income income) async {
    try {
      if (income.customCategoryId != null) {
        // カスタムカテゴリの場合
        final categoryService = CategoryService();
        final databaseService = DatabaseService();
        final categoryName = await categoryService.getIncomeCategoryNameFromIncome(income);
        final customCategory = await databaseService.getCustomCategoryById(income.customCategoryId!);
        
        return {
          'name': categoryName,
          'color': customCategory?.color ?? Colors.grey,
          'icon': customCategory?.icon ?? Icons.category,
        };
      } else {
        // レガシーカテゴリの場合
        return {
          'name': income.category.displayName,
          'color': _getCategoryColor(income.category),
          'icon': _getCategoryIcon(income.category),
        };
      }
    } catch (e) {
      debugPrint('カテゴリ表示情報取得エラー: $e');
      return {
        'name': 'その他',
        'color': Colors.grey,
        'icon': Icons.category,
      };
    }
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
