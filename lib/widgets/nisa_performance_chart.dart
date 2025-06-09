import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/nisa_investment.dart';

class NisaPerformanceChart extends StatelessWidget {
  final List<NisaInvestment> investments;

  const NisaPerformanceChart({super.key, required this.investments});

  @override
  Widget build(BuildContext context) {
    if (investments.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('投資データがありません')),
      );
    }

    // 投資データをリターン率でソート
    final sortedInvestments = List<NisaInvestment>.from(investments)
      ..sort(
        (a, b) => b.calculateReturnRate().compareTo(a.calculateReturnRate()),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'パフォーマンス比較',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxY(sortedInvestments),
              minY: _getMinY(sortedInvestments),
              barGroups: _createBarGroups(sortedInvestments),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {                      return SideTitleWidget(
                        meta: meta,
                        child: Text('${value.toStringAsFixed(1)}%'),
                      );
                    },
                    reservedSize: 40,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value >= 0 && value < sortedInvestments.length) {                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            sortedInvestments[value.toInt()].ticker,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
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
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                horizontalInterval: 5,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            '※ 棒グラフはリターン率を表示',
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

  double _getMaxY(List<NisaInvestment> investments) {
    final maxRate = investments
        .map((e) => e.calculateReturnRate())
        .reduce((a, b) => a > b ? a : b);
    return maxRate > 0 ? (maxRate * 1.2) : 5.0;
  }

  double _getMinY(List<NisaInvestment> investments) {
    final minRate = investments
        .map((e) => e.calculateReturnRate())
        .reduce((a, b) => a < b ? a : b);
    return minRate < 0 ? (minRate * 1.2) : -5.0;
  }

  List<BarChartGroupData> _createBarGroups(List<NisaInvestment> investments) {
    return List.generate(investments.length, (index) {
      final investment = investments[index];
      final returnRate = investment.calculateReturnRate();
      final color = returnRate >= 0 ? Colors.green : Colors.red;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: returnRate,
            color: color,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }
}
