import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/expense.dart';
import '../services/budget_service.dart';
import '../services/alert_settings_service.dart';

class BudgetSettingScreen extends StatefulWidget {
  const BudgetSettingScreen({super.key});

  @override
  State<BudgetSettingScreen> createState() => _BudgetSettingScreenState();
}

class _BudgetSettingScreenState extends State<BudgetSettingScreen> {
  Map<ExpenseCategory, double> _categoryBudgets = {};
  double _monthlyBudget = 0;
  bool _isLoading = true;
  
  // アラート設定
  bool _budgetAlertEnabled = true;
  bool _monthlyAlertEnabled = true;
  bool _categoryAlertEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }  Future<void> _loadBudgetData() async {
    try {
      final categoryBudgets = await BudgetService.getCategoryBudgets();
      final budgetAlertEnabled = await AlertSettingsService.isBudgetAlertEnabled();
      final monthlyAlertEnabled = await AlertSettingsService.isMonthlyAlertEnabled();
      final categoryAlertEnabled = await AlertSettingsService.isCategoryAlertEnabled();
      
      setState(() {
        _categoryBudgets = categoryBudgets;
        _monthlyBudget = _calculateTotalBudget();
        _budgetAlertEnabled = budgetAlertEnabled;
        _monthlyAlertEnabled = monthlyAlertEnabled;
        _categoryAlertEnabled = categoryAlertEnabled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('予算データの読み込みに失敗しました: $e')),
        );
      }
    }
  }

  double _calculateTotalBudget() {
    return _categoryBudgets.values.fold(0.0, (sum, budget) => sum + budget);
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('予算設定'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
        children: [          // 月次総予算（自動計算）
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💰 月次総予算（自動計算）',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '合計: ¥${_monthlyBudget.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'カテゴリ別予算の合計額',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
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
                  ...ExpenseCategory.values.map((category) => 
                    _buildCategoryBudgetItem(category),
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
                    leading: const Icon(Icons.family_restroom, color: Colors.orange),
                    title: const Text('家族（4人）'),
                    subtitle: const Text('月35万円'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _applyTemplate(_getTemplateFamily()),
                  ),
                ],
              ),
            ),          ),

          // アラート設定
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔔 予算アラート設定',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),                  SwitchListTile(
                    title: const Text('予算アラート'),
                    subtitle: const Text('予算超過時の通知を有効にする'),
                    value: _budgetAlertEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _budgetAlertEnabled = value;
                      });
                      // 即座に設定を保存
                      try {
                        await AlertSettingsService.setBudgetAlertEnabled(value);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(value ? '予算アラートを有効にしました' : '予算アラートを無効にしました'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('設定の保存に失敗しました: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    secondary: const Icon(Icons.notifications, color: Colors.orange),
                  ),
                  if (_budgetAlertEnabled) ...[
                    const Divider(),                    SwitchListTile(
                      title: const Text('月次予算アラート'),
                      subtitle: const Text('月次予算の80%以上使用時に通知'),
                      value: _monthlyAlertEnabled,
                      onChanged: (value) async {
                        setState(() {
                          _monthlyAlertEnabled = value;
                        });
                        // 即座に設定を保存
                        try {
                          await AlertSettingsService.setMonthlyAlertEnabled(value);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(value ? '月次予算アラートを有効にしました' : '月次予算アラートを無効にしました'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('設定の保存に失敗しました: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      secondary: const Icon(Icons.calendar_month, color: Colors.blue),
                    ),                    SwitchListTile(
                      title: const Text('カテゴリ別予算アラート'),
                      subtitle: const Text('カテゴリ別予算の80%以上使用時に通知'),
                      value: _categoryAlertEnabled,
                      onChanged: (value) async {
                        setState(() {
                          _categoryAlertEnabled = value;
                        });
                        // 即座に設定を保存
                        try {
                          await AlertSettingsService.setCategoryAlertEnabled(value);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(value ? 'カテゴリ別予算アラートを有効にしました' : 'カテゴリ別予算アラートを無効にしました'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('設定の保存に失敗しました: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      secondary: const Icon(Icons.category, color: Colors.green),
                    ),
                  ],
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
          Expanded(
            flex: 2,
            child: Text(category.displayName),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: _categoryBudgets[category]?.toStringAsFixed(0) ?? '0',
              decoration: const InputDecoration(
                suffixText: '円',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],              onChanged: (value) {
                final amount = double.tryParse(value) ?? 0;
                setState(() {
                  _categoryBudgets[category] = amount;
                  _monthlyBudget = _calculateTotalBudget();
                });
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
          TextButton(            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _categoryBudgets = Map.from(template);
                _monthlyBudget = _calculateTotalBudget();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('テンプレートを適用しました')),
              );
            },
            child: const Text('適用'),
          ),
        ],
      ),
    );
  }  Future<void> _saveSettings() async {
    try {
      // カテゴリ別予算を一括保存
      await BudgetService.saveCategoryBudgets(_categoryBudgets);
      // 月次予算を自動計算された値で保存
      final totalBudget = _calculateTotalBudget();
      await BudgetService.setMonthlyBudget(totalBudget);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('予算設定を保存しました'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('予算設定の保存に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
