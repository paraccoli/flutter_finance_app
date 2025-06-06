import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<ExpenseCategory, double> categoryTotals;
  
  const ExpensePieChart({super.key, required this.categoryTotals});

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
    
    // カテゴリごとの色を定義
    final Map<ExpenseCategory, Color> categoryColors = {
      ExpenseCategory.food: Colors.red,
      ExpenseCategory.transportation: Colors.blue,
      ExpenseCategory.entertainment: Colors.green,
      ExpenseCategory.utilities: Colors.purple,
      ExpenseCategory.shopping: Colors.orange,
      ExpenseCategory.health: Colors.teal,
      ExpenseCategory.education: Colors.indigo,
      ExpenseCategory.other: Colors.grey,
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
  
  Widget _buildLegend() {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: categoryTotals.keys.map((category) {
        final Map<ExpenseCategory, Color> categoryColors = {
          ExpenseCategory.food: Colors.red,
          ExpenseCategory.transportation: Colors.blue,
          ExpenseCategory.entertainment: Colors.green,
          ExpenseCategory.utilities: Colors.purple,
          ExpenseCategory.shopping: Colors.orange,
          ExpenseCategory.health: Colors.teal,
          ExpenseCategory.education: Colors.indigo,
          ExpenseCategory.other: Colors.grey,
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
}
