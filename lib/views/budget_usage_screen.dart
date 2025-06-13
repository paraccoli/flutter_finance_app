import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/budget_service.dart';
import '../services/database_service.dart';
import 'budget_setting_screen.dart';

class BudgetUsageScreen extends StatefulWidget {
  const BudgetUsageScreen({super.key});

  @override
  State<BudgetUsageScreen> createState() => _BudgetUsageScreenState();
}

class _BudgetUsageScreenState extends State<BudgetUsageScreen> {
  Map<ExpenseCategory, double> _currentSpending = {};
  Map<ExpenseCategory, double> _categoryBudgets = {};
  double _monthlyBudget = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgetUsageData();
  }

  Future<void> _loadBudgetUsageData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await BudgetService.initialize();
      _categoryBudgets = BudgetService.getCategoryBudgetsSync();
      _monthlyBudget = BudgetService.getMonthlyBudgetSync();

      await _loadCurrentSpending();
    } catch (e) {
      debugPrint('予算使用状況データの取得に失敗しました: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentSpending() async {
    try {
      final db = DatabaseService();
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final database = await db.database;
      final result = await database.rawQuery(
        '''
        SELECT category, SUM(amount) as total
        FROM expenses
        WHERE date BETWEEN ? AND ?
        GROUP BY category
      ''',
        [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
      );

      Map<ExpenseCategory, double> spending = {};
      for (var row in result) {
        final categoryIndex = row['category'] as int;
        final amount = row['total'] as double;
        if (categoryIndex < ExpenseCategory.values.length) {
          spending[ExpenseCategory.values[categoryIndex]] = amount;
        }
      }

      setState(() {
        _currentSpending = spending;
      });
    } catch (e) {
      debugPrint('現在の支出データの取得に失敗しました: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSpent = _currentSpending.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    final overallUsage = _monthlyBudget > 0
        ? (totalSpent / _monthlyBudget)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('予算使用状況'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BudgetSettingScreen(),
                ),
              );
              if (result == true) {
                // 予算設定が更新された場合、データを再読み込み
                _loadBudgetUsageData();
              }
            },
            child: const Text('予算設定', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBudgetUsageData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 全体の使用状況
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📊 今月の全体予算使用状況',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: overallUsage > 1.0
                                  ? Colors.red.shade50
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '使用率',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: overallUsage > 1.0
                                            ? Colors.red
                                            : Colors.blue,
                                      ),
                                    ),
                                    Text(
                                      '${(overallUsage * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: overallUsage > 1.0
                                            ? Colors.red
                                            : Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: overallUsage.clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    overallUsage > 1.0
                                        ? Colors.red
                                        : overallUsage > 0.8
                                        ? Colors.orange
                                        : Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '使用済み',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          '¥${totalSpent.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          '予算',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(
                                          '¥${_monthlyBudget.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (overallUsage > 1.0) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.warning,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '予算を¥${(totalSpent - _monthlyBudget).toStringAsFixed(0)}超過しています',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // カテゴリ別使用状況
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📋 カテゴリ別使用状況',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...ExpenseCategory.values.map((category) {
                            final spent = _currentSpending[category] ?? 0.0;
                            final budget = _categoryBudgets[category] ?? 0.0;
                            final usage = budget > 0 ? (spent / budget) : 0.0;
                            final warningLevel = BudgetService.getWarningLevel(
                              usage * 100,
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: warningLevel.color.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: warningLevel.color.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        category.icon,
                                        color: category.color,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          category.displayName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: warningLevel.color,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              warningLevel.icon,
                                              color: Colors.white,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              warningLevel.message,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: usage.clamp(0.0, 1.0),
                                    backgroundColor: Colors.grey.shade300,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      warningLevel.color,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '¥${spent.toStringAsFixed(0)} / ¥${budget.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        '${(usage * 100).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: warningLevel.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
