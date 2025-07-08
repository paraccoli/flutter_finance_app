import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../services/budget_service.dart';

class BudgetSettingScreen extends StatefulWidget {
  const BudgetSettingScreen({super.key});

  @override
  State<BudgetSettingScreen> createState() => _BudgetSettingScreenState();
}

class _BudgetSettingScreenState extends State<BudgetSettingScreen> {
  late Map<ExpenseCategory, double> _categoryBudgets;
  late double _monthlyBudget;

  @override
  void initState() {
    super.initState();
    _loadBudgetSettings();
  }

  Future<void> _loadBudgetSettings() async {
    await BudgetService.initialize();
    _categoryBudgets = BudgetService.getCategoryBudgetsSync();
    _monthlyBudget = BudgetService.getMonthlyBudgetSync();
    setState(() {});
  }

  // カテゴリ別予算の合計を計算
  double _calculateTotalCategoryBudgets() {
    return _categoryBudgets.values.fold(0.0, (sum, budget) => sum + budget);
  }

  // カテゴリ予算変更時の処理（常に自動計算）
  void _onCategoryBudgetChanged(ExpenseCategory category, double amount) {
    setState(() {
      _categoryBudgets[category] = amount;
      _monthlyBudget = _calculateTotalCategoryBudgets();
    });
    // リアルタイム保存
    BudgetService.setCategoryBudget(category, amount);
    BudgetService.setMonthlyBudget(_monthlyBudget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('予算設定'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        children: [
          // 月次総予算
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💰 月次総予算',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'カテゴリ別予算の合計が自動で計算されます',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calculate, color: Colors.green),
                        const SizedBox(width: 12),
                        const Text(
                          '月次総予算:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '¥${_monthlyBudget.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // カテゴリ別予算設定
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 カテゴリ別予算',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ...ExpenseCategory.values.map(
                    (category) => _buildCategoryBudgetItem(category),
                  ),
                ],
              ),
            ),
          ),

          // 予算テンプレート
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📋 予算テンプレート',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.blue),
                    title: const Text('一人暮らし（節約型）'),
                    subtitle: const Text('月15万円'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _applyTemplate(_getTemplateAlone()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.people, color: Colors.green),
                    title: const Text('二人暮らし（標準）'),
                    subtitle: const Text('月25万円'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _applyTemplate(_getTemplateCouple()),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.family_restroom,
                      color: Colors.orange,
                    ),
                    title: const Text('家族（4人）'),
                    subtitle: const Text('月35万円'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _applyTemplate(_getTemplateFamily()),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetItem(ExpenseCategory category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(category.icon, color: category.color, size: 24),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: Text(category.displayName)),
          Expanded(
            flex: 3,
            child: TextFormField(
              key: ValueKey(
                '${category.name}_${_categoryBudgets[category]}',
              ), // キーを追加
              initialValue:
                  _categoryBudgets[category]?.toStringAsFixed(0) ?? '0',
              decoration: const InputDecoration(
                suffixText: '円',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0;
                _onCategoryBudgetChanged(category, amount);
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<ExpenseCategory, double> _getTemplateAlone() {
    return {
      ExpenseCategory.food: 30000,
      ExpenseCategory.transportation: 10000,
      ExpenseCategory.entertainment: 15000,
      ExpenseCategory.shopping: 20000,
      ExpenseCategory.utilities: 15000,
      ExpenseCategory.health: 8000,
      ExpenseCategory.education: 5000,
      ExpenseCategory.rent: 40000,
      ExpenseCategory.other: 7000,
    };
  }

  Map<ExpenseCategory, double> _getTemplateCouple() {
    return {
      ExpenseCategory.food: 50000,
      ExpenseCategory.transportation: 20000,
      ExpenseCategory.entertainment: 30000,
      ExpenseCategory.shopping: 40000,
      ExpenseCategory.utilities: 25000,
      ExpenseCategory.health: 15000,
      ExpenseCategory.education: 10000,
      ExpenseCategory.rent: 80000,
      ExpenseCategory.other: 20000,
    };
  }

  Map<ExpenseCategory, double> _getTemplateFamily() {
    return {
      ExpenseCategory.food: 80000,
      ExpenseCategory.transportation: 30000,
      ExpenseCategory.entertainment: 40000,
      ExpenseCategory.shopping: 60000,
      ExpenseCategory.utilities: 35000,
      ExpenseCategory.health: 25000,
      ExpenseCategory.education: 30000,
      ExpenseCategory.rent: 120000,
      ExpenseCategory.other: 30000,
    };
  }

  void _applyTemplate(Map<ExpenseCategory, double> template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('テンプレートを適用'),
        content: const Text('選択したテンプレートを適用しますか？\n現在の設定は上書きされます。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _categoryBudgets = Map.from(template);
                _monthlyBudget = _calculateTotalCategoryBudgets();
              });

              // リアルタイム保存
              for (final category in ExpenseCategory.values) {
                BudgetService.setCategoryBudget(
                  category,
                  _categoryBudgets[category] ?? 0,
                );
              }
              BudgetService.setMonthlyBudget(_monthlyBudget);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('テンプレートを適用しました')));
            },
            child: const Text('適用'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // 最終保存（リアルタイム保存をしているので基本的には同期済み）
    for (final category in ExpenseCategory.values) {
      BudgetService.setCategoryBudget(
        category,
        _categoryBudgets[category] ?? 0,
      );
    }
    BudgetService.setMonthlyBudget(_monthlyBudget);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('予算設定を保存しました'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, true); // 更新フラグを返す
  }
}
