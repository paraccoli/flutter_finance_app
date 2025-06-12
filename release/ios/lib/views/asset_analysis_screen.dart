import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../viewmodels/asset_analysis_viewmodel.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/income_viewmodel.dart';

class AssetAnalysisScreen extends StatefulWidget {
  const AssetAnalysisScreen({super.key});

  @override
  State<AssetAnalysisScreen> createState() => _AssetAnalysisScreenState();
}

class _AssetAnalysisScreenState extends State<AssetAnalysisScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _forecastMonths = 12;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 画面が表示されたらデータをロード
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssetAnalysisViewModel>().loadData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysisViewModel = Provider.of<AssetAnalysisViewModel>(context);
    final expenseViewModel = Provider.of<ExpenseViewModel>(context);
    final incomeViewModel = Provider.of<IncomeViewModel>(context);
    
    // 収入と支出の合計を取得
    final totalIncome = incomeViewModel.getTotalIncome();
    final totalExpense = expenseViewModel.expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final balance = totalIncome - totalExpense;
      return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 収支サマリーカード
            Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      '収支サマリー',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow('収入', totalIncome, Colors.green),
                    const SizedBox(height: 8),
                    _buildSummaryRow('支出', totalExpense, Colors.red),
                    const Divider(),
                    _buildSummaryRow(
                      '収支', 
                      balance,
                      balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 予測月数選択
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Text('予測期間:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _forecastMonths,
                  items: [6, 12, 24, 36, 60].map((months) {
                    return DropdownMenuItem<int>(
                      value: months,
                      child: Text('$months ヶ月'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _forecastMonths = value;
                        analysisViewModel.setForecastMonths(value);
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          
          // タブバー
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: '月次収支', icon: Icon(Icons.account_balance)),
              Tab(text: '資産推移', icon: Icon(Icons.trending_up)),
              Tab(text: 'NISA予測', icon: Icon(Icons.savings)),
            ],
          ),
          
          // タブコンテンツ
          Expanded(
            child: TabBarView(
              controller: _tabController,              children: [
                _buildMonthlyBalanceTab(analysisViewModel),
                _buildAssetForecastTab(analysisViewModel),
                _buildNisaForecastTab(analysisViewModel),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, double value, Color valueColor) {
    final formatter = NumberFormat('#,###');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '¥${formatter.format(value)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMonthlyBalanceTab(AssetAnalysisViewModel viewModel) {
    final monthlyBalances = viewModel.getMonthlyBalances();
    
    if (monthlyBalances.isEmpty) {
      return const Center(
        child: Text('月次データがありません'),
      );
    }
    
    // 日付でソート
    final sortedMonths = monthlyBalances.keys.toList()..sort();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '月次収支バランス',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // 月次収支グラフ
          AspectRatio(
            aspectRatio: 1.5,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    barTouchData: BarTouchData(                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Colors.blueGrey,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final date = sortedMonths[groupIndex];
                          final value = monthlyBalances[date];
                          return BarTooltipItem(
                            '${DateFormat('yyyy/MM').format(date)}\n¥${value?.toStringAsFixed(0)}',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
                              final date = sortedMonths[value.toInt()];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('yy/MM').format(date),
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
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                    barGroups: List.generate(sortedMonths.length, (index) {
                      final month = sortedMonths[index];
                      final value = monthlyBalances[month] ?? 0;
                      
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: value,
                            color: value >= 0 ? Colors.green : Colors.red,
                            width: 16,
                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 月次収支リスト
          const Text(
            '月次収支明細',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedMonths.length,
            itemBuilder: (context, index) {
              final month = sortedMonths[sortedMonths.length - 1 - index]; // 逆順で表示
              final balance = monthlyBalances[month] ?? 0;
              
              return Card(
                elevation: 2,
                child: ListTile(
                  title: Text(
                    DateFormat('yyyy年MM月').format(month),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '¥${NumberFormat('#,###').format(balance)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildAssetForecastTab(AssetAnalysisViewModel viewModel) {
    final forecasts = viewModel.getFutureBalancesForecast();
    
    if (forecasts.isEmpty) {
      return const Center(
        child: Text('予測データを生成できません'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '資産推移予測',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
            // 資産推移グラフ
          AspectRatio(
            aspectRatio: 1.5,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => Colors.blueGrey,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final forecast = forecasts[spot.x.toInt()];
                            String label = '';
                            double value = 0;
                            
                            switch (spot.barIndex) {
                              case 0:
                                label = '累積収支';
                                value = forecast.cumulativeBalance;
                                break;
                              case 1:
                                label = 'NISA資産';
                                value = forecast.nisaValue;
                                break;
                              case 2:
                                label = '総資産';
                                value = forecast.totalAssets;
                                break;
                            }
                            
                            return LineTooltipItem(
                              '${DateFormat('yyyy/MM').format(forecast.month)}\n$label: ¥${value.toStringAsFixed(0)}',
                              TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < forecasts.length && value.toInt() % 3 == 0) {
                              final date = forecasts[value.toInt()].month;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('yy/MM').format(date),
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
                              '¥${(value / 10000).toInt()}万',
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
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      // 累積収支
                      LineChartBarData(
                        spots: List.generate(forecasts.length, (index) {
                          return FlSpot(index.toDouble(), forecasts[index].cumulativeBalance);
                        }),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      ),
                      // NISA資産
                      LineChartBarData(
                        spots: List.generate(forecasts.length, (index) {
                          return FlSpot(index.toDouble(), forecasts[index].nisaValue);
                        }),
                        isCurved: true,
                        color: Colors.purple,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      ),
                      // 総資産
                      LineChartBarData(
                        spots: List.generate(forecasts.length, (index) {
                          return FlSpot(index.toDouble(), forecasts[index].totalAssets);
                        }),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 凡例
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('累積収支', Colors.blue),
              const SizedBox(width: 16),
              _buildLegendItem('NISA資産', Colors.purple),
              const SizedBox(width: 16),
              _buildLegendItem('総資産', Colors.green),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 予測データリスト
          const Text(
            '月次予測データ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('年月')),
                DataColumn(label: Text('収支')),
                DataColumn(label: Text('累積収支')),
                DataColumn(label: Text('NISA資産')),
                DataColumn(label: Text('総資産')),
              ],
              rows: forecasts.map((forecast) {
                return DataRow(
                  cells: [
                    DataCell(Text(DateFormat('yyyy/MM').format(forecast.month))),
                    DataCell(Text(
                      '¥${NumberFormat('#,###').format(forecast.balance)}',
                      style: TextStyle(
                        color: forecast.balance >= 0 ? Colors.green : Colors.red,
                      ),
                    )),
                    DataCell(Text('¥${NumberFormat('#,###').format(forecast.cumulativeBalance)}')),
                    DataCell(Text('¥${NumberFormat('#,###').format(forecast.nisaValue)}')),
                    DataCell(Text(
                      '¥${NumberFormat('#,###').format(forecast.totalAssets)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNisaForecastTab(AssetAnalysisViewModel viewModel) {
    final forecasts = viewModel.getNisaForecast();
    
    if (forecasts.isEmpty) {
      return const Center(
        child: Text('NISA予測データを生成できません'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NISA資産予測',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
            // NISA資産推移グラフ
          AspectRatio(
            aspectRatio: 1.5,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => Colors.blueGrey,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final forecast = forecasts[spot.x.toInt()];
                            return LineTooltipItem(
                              '${DateFormat('yyyy/MM').format(forecast.month)}\n¥${forecast.expectedValue.toStringAsFixed(0)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < forecasts.length && value.toInt() % 3 == 0) {
                              final date = forecasts[value.toInt()].month;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('yy/MM').format(date),
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
                              '¥${(value / 10000).toInt()}万',
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
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(forecasts.length, (index) {
                          return FlSpot(index.toDouble(), forecasts[index].expectedValue);
                        }),
                        isCurved: true,
                        color: Colors.purple,
                        barWidth: 3,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.purple.withValues(alpha: 0.2),
                        ),
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 予測データリスト
          const Text(
            'NISA月次予測データ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: forecasts.length,
            itemBuilder: (context, index) {
              final forecast = forecasts[index];
              
              return Card(
                elevation: 2,
                child: ListTile(
                  title: Text(
                    DateFormat('yyyy年MM月').format(forecast.month),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '¥${NumberFormat('#,###').format(forecast.expectedValue)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
