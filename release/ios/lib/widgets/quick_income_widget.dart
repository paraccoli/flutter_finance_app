import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';
import '../services/database_service.dart';

class QuickIncomeWidget extends StatefulWidget {
  final VoidCallback? onIncomeAdded;

  const QuickIncomeWidget({super.key, this.onIncomeAdded});

  @override
  State<QuickIncomeWidget> createState() => _QuickIncomeWidgetState();
}

class _QuickIncomeWidgetState extends State<QuickIncomeWidget> {
  List<Map<String, dynamic>> _quickIncomes = [];
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadQuickIncomes();
  }

  Future<void> _loadQuickIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final quickIncomeStrings = prefs.getStringList('quick_incomes') ?? [];
    
    setState(() {
      _quickIncomes = quickIncomeStrings.map((str) {
        final parts = str.split('|');
        if (parts.length == 3) {
          return {
            'amount': double.parse(parts[0]),
            'category': IncomeCategory.values[int.parse(parts[1])],
            'note': parts[2],
          };
        }
        return <String, dynamic>{};
      }).where((income) => income.isNotEmpty).toList();
    });
  }

  Future<void> _saveQuickIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final quickIncomeStrings = _quickIncomes.map((income) {
      return '${income['amount']}|${income['category'].index}|${income['note']}';
    }).toList();
    await prefs.setStringList('quick_incomes', quickIncomeStrings);
  }

  Future<void> _addQuickIncome(double amount, IncomeCategory category, String note) async {
    final newQuickIncome = {
      'amount': amount,
      'category': category,
      'note': note,
    };

    setState(() {
      _quickIncomes.add(newQuickIncome);
    });

    await _saveQuickIncomes();
  }

  Future<void> _removeQuickIncome(int index) async {
    setState(() {
      _quickIncomes.removeAt(index);
    });
    await _saveQuickIncomes();
  }

  Future<void> _registerIncome(Map<String, dynamic> quickIncome) async {
    try {
      final income = Income(
        amount: quickIncome['amount'],
        category: quickIncome['category'],
        date: DateTime.now(),
        note: quickIncome['note'],
      );

      await _databaseService.insertIncome(income);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('収入を登録しました: ¥${NumberFormat('#,###').format(income.amount)}'),
            backgroundColor: Colors.green,
          ),
        );
        
        widget.onIncomeAdded?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('収入の登録に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddQuickIncomeDialog() {
    double amount = 0;
    IncomeCategory category = IncomeCategory.salary;
    String note = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('クイック収入の追加'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: '金額',
                  prefixText: '¥',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  amount = double.tryParse(value) ?? 0;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<IncomeCategory>(
                decoration: const InputDecoration(labelText: 'カテゴリ'),
                value: category,
                onChanged: (value) {
                  setState(() {
                    category = value!;
                  });
                },
                items: IncomeCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(_getIncomeIcon(cat), color: _getIncomeColor(cat)),
                        const SizedBox(width: 8),
                        Text(_getIncomeCategoryName(cat)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'メモ（任意）',
                ),
                onChanged: (value) {
                  note = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              if (amount > 0) {
                await _addQuickIncome(amount, category, note);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }
  String _getIncomeCategoryName(IncomeCategory category) {
    switch (category) {
      case IncomeCategory.salary:
        return '給与';
      case IncomeCategory.bonus:
        return 'ボーナス';
      case IncomeCategory.investment:
        return '投資収益';
      case IncomeCategory.sideJob:
        return '副業';
      case IncomeCategory.gift:
        return '贈与・お祝い';
      case IncomeCategory.other:
        return 'その他';
    }
  }
  IconData _getIncomeIcon(IncomeCategory category) {
    switch (category) {
      case IncomeCategory.salary:
        return Icons.work;
      case IncomeCategory.bonus:
        return Icons.card_giftcard;
      case IncomeCategory.investment:
        return Icons.trending_up;
      case IncomeCategory.sideJob:
        return Icons.computer;
      case IncomeCategory.gift:
        return Icons.redeem;
      case IncomeCategory.other:
        return Icons.more_horiz;
    }
  }
  Color _getIncomeColor(IncomeCategory category) {
    switch (category) {
      case IncomeCategory.salary:
        return Colors.blue;
      case IncomeCategory.bonus:
        return Colors.purple;
      case IncomeCategory.investment:
        return Colors.orange;
      case IncomeCategory.sideJob:
        return Colors.teal;
      case IncomeCategory.gift:
        return Colors.pink;
      case IncomeCategory.other:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'クイック収入',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _showAddQuickIncomeDialog,
                  tooltip: 'クイック収入を追加',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_quickIncomes.isEmpty)
              const Text(
                'クイック収入が設定されていません。\n右の+ボタンから追加してください。',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _quickIncomes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final quickIncome = entry.value;
                  return GestureDetector(
                    onLongPress: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('削除確認'),
                          content: Text(
                            'クイック収入「${_getIncomeCategoryName(quickIncome['category'])} ¥${NumberFormat('#,###').format(quickIncome['amount'])}」を削除しますか？',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('キャンセル'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('削除'),
                            ),
                          ],
                        ),
                      );
                      if (result == true) {
                        _removeQuickIncome(index);
                      }
                    },
                    child: ActionChip(
                      avatar: Icon(
                        _getIncomeIcon(quickIncome['category']),
                        size: 16,
                        color: _getIncomeColor(quickIncome['category']),
                      ),
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getIncomeCategoryName(quickIncome['category']),
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '¥${NumberFormat('#,###').format(quickIncome['amount'])}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () => _registerIncome(quickIncome),
                    ),
                  );
                }).toList(),
              ),
            if (_quickIncomes.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  'タップで登録、長押しで削除',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
