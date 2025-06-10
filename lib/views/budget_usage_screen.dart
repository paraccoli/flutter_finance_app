import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/budget_service.dart';
import '../services/database_service.dart';

class BudgetUsageScreen extends StatefulWidget {
  const BudgetUsageScreen({super.key});

  @override
  State<BudgetUsageScreen> createState() => _BudgetUsageScreenState();
}

class _BudgetUsageScreenState extends State<BudgetUsageScreen> {
  final DatabaseService _databaseService = DatabaseService();
  Map<ExpenseCategory, double> _categoryBudgets = {};
  Map<ExpenseCategory, double> _categorySpending = {};
  double _monthlyBudget = 0;
  double _totalSpending = 0;
  bool _isLoading = true;
  String _selectedMonth = '';

  @override
  void initState() {
    super.initState();
    _selectedMonth = _getCurrentMonth();
    _loadBudgetUsageData();
  }

  String _getCurrentMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> _loadBudgetUsageData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 予算データを取得
      final categoryBudgets = await BudgetService.getCategoryBudgets(_selectedMonth);
      final monthlyBudget = await BudgetService.getMonthlyBudget(_selectedMonth);

      // 支出データを取得（選択された月）
      final year = int.parse(_selectedMonth.split('-')[0]);
      final month = int.parse(_selectedMonth.split('-')[1]);
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final expenses = await _databaseService.getExpensesByDateRange(
        startDate,
        endDate,
      );

      // カテゴリ別支出額を計算
      final categorySpending = <ExpenseCategory, double>{};
      double totalSpending = 0;

      for (final expense in expenses) {
        categorySpending[expense.category] = 
            (categorySpending[expense.category] ?? 0) + expense.amount;
        totalSpending += expense.amount;
      }

      setState(() {
        _categoryBudgets = categoryBudgets;
        _categorySpending = categorySpending;
        _monthlyBudget = monthlyBudget;
        _totalSpending = totalSpending;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('データの読み込みに失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('予算使用状況'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBudgetUsageData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // 月選択
                _buildMonthSelector(),
                
                // 月次予算サマリー
                _buildMonthlySummaryCard(),
                
                // カテゴリ別予算使用状況
                _buildCategoryUsageList(),
                
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.blue),
            const SizedBox(width: 8),
            const Text('対象月:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButton<String>(
                value: _selectedMonth,
                isExpanded: true,
                items: _generateMonthOptions(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMonth = value;
                    });
                    _loadBudgetUsageData();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _generateMonthOptions() {
    final now = DateTime.now();
    final options = <DropdownMenuItem<String>>[];
    
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthStr = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      final displayStr = '${date.year}年${date.month}月';
      
      options.add(DropdownMenuItem(
        value: monthStr,
        child: Text(displayStr),
      ));
    }
    
    return options;
  }  Widget _buildMonthlySummaryCard() {    final usagePercentage = _monthlyBudget > 0 
        ? (_totalSpending / _monthlyBudget * 100).clamp(0, 200).toDouble()
        : _totalSpending > 0 ? 200.0 : 0.0; // 予算0で支出がある場合は超過として扱う
    final remaining = _monthlyBudget > 0 
        ? (_monthlyBudget - _totalSpending).clamp(0, double.infinity).toDouble()
        : -_totalSpending; // 予算0の場合は負の支出額を表示
    final warningLevel = BudgetService.getWarningLevel(usagePercentage);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _getCardColor(warningLevel),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  warningLevel.icon,
                  color: warningLevel.color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '月次予算使用状況',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: warningLevel.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // 進捗バー
            LinearProgressIndicator(
              value: (usagePercentage / 100).clamp(0, 1),
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(warningLevel.color),
              minHeight: 8,
            ),
            
            const SizedBox(height: 16),
            
            // 数値情報
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('使用額', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '¥${_totalSpending.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('使用率', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      '${usagePercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: warningLevel.color,
                      ),
                    ),
                    Text(
                      warningLevel.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: warningLevel.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _monthlyBudget > 0 ? '残り予算' : '超過額',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '¥${remaining.abs().toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: remaining >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '予算: ¥${_monthlyBudget.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryUsageList() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'カテゴリ別使用状況',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),            ...ExpenseCategory.values.map((category) {
              final budget = _categoryBudgets[category] ?? 0;
              final spent = _categorySpending[category] ?? 0;              final usagePercentage = budget > 0 
                  ? (spent / budget * 100).clamp(0, 200).toDouble()
                  : spent > 0 ? 200.0 : 0.0; // 予算0で支出がある場合は超過として扱う
              final remaining = budget > 0 
                  ? (budget - spent).clamp(0, double.infinity).toDouble()
                  : -spent; // 予算0の場合は負の支出額を表示
              final warningLevel = BudgetService.getWarningLevel(usagePercentage);              return _buildCategoryUsageItem(
                category,
                budget,
                spent,
                usagePercentage,
                remaining,
                warningLevel,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryUsageItem(
    ExpenseCategory category,
    double budget,
    double spent,
    double usagePercentage,
    double remaining,
    BudgetWarningLevel warningLevel,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(        border: Border.all(color: warningLevel.color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
        color: warningLevel.color.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [          Row(
            children: [
              Icon(
                category.icon,
                color: category.color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.displayName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(
                warningLevel.icon,
                color: warningLevel.color,
                size: 16,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 進捗バー
          LinearProgressIndicator(
            value: (usagePercentage / 100).clamp(0, 1),
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(warningLevel.color),
            minHeight: 6,
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '¥${spent.toStringAsFixed(0)} / ¥${budget.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12),
              ),              Text(
                '${usagePercentage.toStringAsFixed(1)}% (${budget > 0 ? "残り" : "超過"}¥${remaining.abs().toStringAsFixed(0)})',
                style: TextStyle(
                  fontSize: 12,
                  color: warningLevel.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCardColor(BudgetWarningLevel warningLevel) {
    switch (warningLevel) {
      case BudgetWarningLevel.safe:
        return Colors.green.shade50;
      case BudgetWarningLevel.caution:
        return Colors.orange.shade50;
      case BudgetWarningLevel.warning:
        return Colors.red.shade50;
      case BudgetWarningLevel.exceeded:
        return Colors.red.shade100;
    }
  }
}
