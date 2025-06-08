import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/nisa_investment.dart';

class NisaAssetAllocationChart extends StatelessWidget {
  final List<NisaInvestment> investments;
  final List<Color> colorList = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.lime,
    Colors.amber,
  ];

  NisaAssetAllocationChart({super.key, required this.investments});

  @override
  Widget build(BuildContext context) {
    if (investments.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('投資データがありません')),
      );
    }

    final totalValue = investments.fold<double>(
      0,
      (sum, item) => sum + item.currentValue,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '資産配分',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // 円グラフ
            SizedBox(
              height: 200,
              width: 200,
              child: PieChart(
                PieChartData(
                  sections: _createPieSections(totalValue),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 凡例
            Expanded(
              child: SizedBox(
                height: 200,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _createLegendItems(totalValue),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> _createPieSections(double totalValue) {
    final List<PieChartSectionData> sections = [];

    for (int i = 0; i < investments.length; i++) {
      final investment = investments[i];
      final percentage = (investment.currentValue / totalValue) * 100;
      final color = colorList[i % colorList.length];

      sections.add(
        PieChartSectionData(
          value: investment.currentValue,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 60,
          color: color,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }

    return sections;
  }

  List<Widget> _createLegendItems(double totalValue) {
    final List<Widget> legendItems = [];

    for (int i = 0; i < investments.length; i++) {
      final investment = investments[i];
      final percentage = (investment.currentValue / totalValue) * 100;
      final color = colorList[i % colorList.length];

      legendItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(width: 16, height: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  investment.stockName,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return legendItems;
  }
}
