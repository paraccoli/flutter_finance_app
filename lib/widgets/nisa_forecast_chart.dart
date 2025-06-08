import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/nisa_investment.dart';

class NisaForecastChart extends StatelessWidget {
  final List<NisaInvestment> investments;
  final int forecastMonths;

  const NisaForecastChart({
    super.key,
    required this.investments,
    this.forecastMonths = 60, // デフォルトで5年（60ヶ月）
  });

  @override
  Widget build(BuildContext context) {
    if (investments.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('投資データがありません')),
      );
    }

    // 全投資の月次予測データを集計
    final combinedForecast = _generateCombinedForecast();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '資産成長予測',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '現在の投資パフォーマンスが継続した場合の予測（${forecastMonths ~/ 12}年間）',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: combinedForecast.asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value);
                  }).toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          _formatCurrency(value),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                    reservedSize: 60,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      // 6ヶ月ごとに表示
                      if (value % 6 == 0 && value < forecastMonths) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            '${(value / 12).toStringAsFixed(1)}年',
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                drawVerticalLine: true,
                horizontalInterval: _calculateInterval(combinedForecast),
                verticalInterval: 12, // 1年ごとに縦線
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  );
                },
              ),
              borderData: FlBorderData(show: true),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '※ 月次積立を含めた資産成長予測（税金・手数料考慮なし）',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  List<double> _generateCombinedForecast() {
    // 各投資の予測データを生成
    final List<List<double>> allForecasts = [];

    for (final investment in investments) {
      final forecast = investment.generateMonthlyForecastData(forecastMonths);
      allForecasts.add(forecast);
    }

    // 各月の予測値を合計
    final List<double> combinedForecast = List.filled(forecastMonths + 1, 0);

    for (int month = 0; month <= forecastMonths; month++) {
      double totalForMonth = 0;
      for (final forecast in allForecasts) {
        if (month < forecast.length) {
          totalForMonth += forecast[month];
        }
      }
      combinedForecast[month] = totalForMonth;
    }

    return combinedForecast;
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  double _calculateInterval(List<double> data) {
    final maxValue = data.reduce((a, b) => a > b ? a : b);

    if (maxValue < 100000) return 10000;
    if (maxValue < 500000) return 50000;
    if (maxValue < 1000000) return 100000;
    if (maxValue < 5000000) return 500000;
    if (maxValue < 10000000) return 1000000;

    return 1000000;
  }
}
