import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class QuickExpenseWidget extends StatefulWidget {
  final VoidCallback? onExpenseAdded;

  const QuickExpenseWidget({super.key, this.onExpenseAdded});

  @override
  State<QuickExpenseWidget> createState() => _QuickExpenseWidgetState();
}

class _QuickExpenseWidgetState extends State<QuickExpenseWidget> {
  List<Map<String, dynamic>> _quickExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadQuickExpenses();
  }

  Future<void> _loadQuickExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final quickExpenseStrings = prefs.getStringList('quick_expenses') ?? [];
    
    setState(() {
      _quickExpenses = quickExpenseStrings.map((str) {
        final parts = str.split('|');
        if (parts.length == 3) {
          return {
            'amount': double.parse(parts[0]),
            'category': ExpenseCategory.values[int.parse(parts[1])],
            'note': parts[2],
          };
        }
        return <String, dynamic>{};
      }).where((expense) => expense.isNotEmpty).toList();
    });
  }

  Future<void> _saveQuickExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final quickExpenseStrings = _quickExpenses.map((expense) {
      return '${expense['amount']}|${expense['category'].index}|${expense['note']}';
    }).toList();
    await prefs.setStringList('quick_expenses', quickExpenseStrings);
  }

  Future<void> _addQuickExpense() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _QuickExpenseDialog(),
    );

    if (result != null) {
      setState(() {
        _quickExpenses.add(result);
      });
      await _saveQuickExpenses();
    }
  }

  Future<void> _registerExpense(Map<String, dynamic> quickExpense) async {
    try {
      final expense = Expense(
        amount: quickExpense['amount'],
        date: DateTime.now(),
        category: quickExpense['category'],
        note: quickExpense['note'],
      );

      await DatabaseService().insertExpense(expense);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('支出を登録しました: ${NumberFormat('#,###').format(expense.amount)}円'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onExpenseAdded?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('支出の登録に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_quickExpenses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.flash_on, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              const Text(
                'クイック登録',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'よく使う支出を登録して\nワンタップで記録できます',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _addQuickExpense,
                child: const Text('クイック支出を追加'),
              ),
            ],
          ),
        ),
      );
    }

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
                  'クイック登録',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: _addQuickExpense,
                  icon: const Icon(Icons.add),
                  tooltip: 'クイック支出を追加',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickExpenses.map((expense) {
                return _QuickExpenseChip(
                  expense: expense,
                  onTap: () => _registerExpense(expense),
                  onDelete: () {
                    setState(() {
                      _quickExpenses.remove(expense);
                    });
                    _saveQuickExpenses();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickExpenseChip extends StatelessWidget {
  final Map<String, dynamic> expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _QuickExpenseChip({
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });
  @override
  Widget build(BuildContext context) {
    final category = expense['category'] as ExpenseCategory;
    
    return GestureDetector(
      onLongPress: onDelete,
      child: ActionChip(
        avatar: Icon(
          category.icon,
          size: 18,
          color: category.color,
        ),
        label: Text('${NumberFormat('#,###').format(expense['amount'])}円'),
        onPressed: onTap,
        tooltip: '${expense['note']} (${category.displayName})\n長押しで削除',
      ),
    );
  }
}

class _QuickExpenseDialog extends StatefulWidget {
  const _QuickExpenseDialog();

  @override
  State<_QuickExpenseDialog> createState() => _QuickExpenseDialogState();
}

class _QuickExpenseDialogState extends State<_QuickExpenseDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('クイック支出を追加'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: '金額',
              suffixText: '円',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ExpenseCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'カテゴリ',
            ),
            items: ExpenseCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Row(
                  children: [
                    Icon(category.icon, size: 20, color: category.color),
                    const SizedBox(width: 8),
                    Text(category.displayName),
                  ],
                ),
              );
            }).toList(),
            onChanged: (category) {
              if (category != null) {
                setState(() {
                  _selectedCategory = category;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'メモ',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text);
            if (amount != null && amount > 0) {
              Navigator.pop(context, {
                'amount': amount,
                'category': _selectedCategory,
                'note': _noteController.text.trim(),
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('有効な金額を入力してください')),
              );
            }
          },
          child: const Text('追加'),
        ),
      ],
    );
  }
}
