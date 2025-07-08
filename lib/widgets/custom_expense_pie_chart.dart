import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CustomExpensePieChart extends StatelessWidget {
  final Map<String, Map<String, dynamic>> categoryTotals;
  
  const CustomExpensePieChart({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'カテゴリ別支出',
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
                    sections: _getSections(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLegend(),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _getSections() {
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
  
  Widget _buildLegend() {
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
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 12,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              name,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}
