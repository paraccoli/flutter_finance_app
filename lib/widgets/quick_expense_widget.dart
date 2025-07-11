import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../services/category_service.dart';

class QuickExpenseWidget extends StatefulWidget {
  final VoidCallback? onExpenseAdded;

  const QuickExpenseWidget({super.key, this.onExpenseAdded});

  @override
  State<QuickExpenseWidget> createState() => _QuickExpenseWidgetState();
}

class _QuickExpenseWidgetState extends State<QuickExpenseWidget> {
  List<Map<String, dynamic>> _quickExpenses = [];
  final CategoryService _categoryService = CategoryService();

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
        if (parts.length >= 3) {
          // 新しい形式: amount|categoryType|categoryValue|note
          if (parts.length == 4) {
            return {
              'amount': double.parse(parts[0]),
              'categoryType': parts[1], // 'enum' or 'custom'
              'categoryValue': parts[2], // enum index or custom category id
              'note': parts[3],
            };
          }
          // 古い形式: amount|categoryIndex|note (legacy)
          return {
            'amount': double.parse(parts[0]),
            'categoryType': 'enum',
            'categoryValue': parts[1],
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
      return '${expense['amount']}|${expense['categoryType']}|${expense['categoryValue']}|${expense['note']}';
    }).toList();
    await prefs.setStringList('quick_expenses', quickExpenseStrings);
  }

  Future<void> _addQuickExpense() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _QuickExpenseDialog(categoryService: _categoryService),
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
      final categoryType = quickExpense['categoryType'] as String;
      final categoryValue = quickExpense['categoryValue'] as String;
      
      final expense = Expense(
        amount: quickExpense['amount'],
        date: DateTime.now(),
        category: categoryType == 'enum' 
          ? ExpenseCategory.values[int.parse(categoryValue)]
          : ExpenseCategory.other, // カスタムカテゴリの場合はデフォルト
        customCategoryId: categoryType == 'custom' 
          ? int.parse(categoryValue)
          : null,
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

  Future<void> _showDeleteConfirmDialog(Map<String, dynamic> expense) async {
    final categoryInfo = await _getCategoryDisplayInfo(expense);
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('クイック登録を削除'),
          content: Text(
            '以下のクイック登録を削除しますか？\n\n'
            '金額: ${NumberFormat('#,###').format(expense['amount'])}円\n'
            'カテゴリ: ${categoryInfo['name']}\n'
            'メモ: ${expense['note']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _quickExpenses.remove(expense);
                });
                _saveQuickExpenses();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getCategoryDisplayInfo(Map<String, dynamic> expense) async {
    final categoryType = expense['categoryType'] as String;
    final categoryValue = expense['categoryValue'] as String;
    
    if (categoryType == 'enum') {
      final category = ExpenseCategory.values[int.parse(categoryValue)];
      return {
        'name': category.displayName,
        'icon': category.icon,
        'color': category.color,
      };
    } else if (categoryType == 'custom') {
      try {
        final databaseService = DatabaseService();
        final customCategory = await databaseService.getCustomCategoryById(int.parse(categoryValue));
        if (customCategory != null) {
          return {
            'name': customCategory.name,
            'icon': customCategory.icon,
            'color': customCategory.color,
          };
        }
      } catch (e) {
        // エラー時はデフォルト値を返す
      }
    }
    
    return {
      'name': 'その他',
      'icon': Icons.category,
      'color': Colors.grey,
    };
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
                  onDelete: () => _showDeleteConfirmDialog(expense),
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
    return FutureBuilder<Map<String, dynamic>>(
      future: _getCategoryDisplayInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 100,
            height: 32,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final categoryInfo = snapshot.data ?? {
          'name': 'その他',
          'icon': Icons.category,
          'color': Colors.grey,
        };

        return GestureDetector(
          onLongPress: onDelete,
          child: ActionChip(
            avatar: Icon(
              categoryInfo['icon'],
              size: 18,
              color: categoryInfo['color'],
            ),
            label: Text('${NumberFormat('#,###').format(expense['amount'])}円'),
            onPressed: onTap,
            tooltip: '${expense['note']} (${categoryInfo['name']})\n長押しで削除',
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getCategoryDisplayInfo() async {
    final categoryType = expense['categoryType'] as String;
    final categoryValue = expense['categoryValue'] as String;
    
    if (categoryType == 'enum') {
      final category = ExpenseCategory.values[int.parse(categoryValue)];
      return {
        'name': category.displayName,
        'icon': category.icon,
        'color': category.color,
      };
    } else if (categoryType == 'custom') {
      try {
        final databaseService = DatabaseService();
        final customCategory = await databaseService.getCustomCategoryById(int.parse(categoryValue));
        if (customCategory != null) {
          return {
            'name': customCategory.name,
            'icon': customCategory.icon,
            'color': customCategory.color,
          };
        }
      } catch (e) {
        // エラー時はデフォルト値を返す
      }
    }
    
    return {
      'name': 'その他',
      'icon': Icons.category,
      'color': Colors.grey,
    };
  }
}

class _QuickExpenseDialog extends StatefulWidget {
  final CategoryService categoryService;
  
  const _QuickExpenseDialog({required this.categoryService});

  @override
  State<_QuickExpenseDialog> createState() => _QuickExpenseDialogState();
}

class _QuickExpenseDialogState extends State<_QuickExpenseDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  CategoryItem? _selectedCategory;
  List<CategoryItem> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await widget.categoryService.getExpenseCategories();
      setState(() {
        _categories = categories;
        if (_categories.isNotEmpty) {
          _selectedCategory = _categories.first;
        }
      });
    } catch (e) {
      // エラー時はデフォルトカテゴリを使用
      setState(() {
        _categories = [
          CategoryItem(
            id: 0,
            name: '食費',
            icon: Icons.fastfood,
            color: Colors.orange,
            isCustom: false,
          ),
        ];
        _selectedCategory = _categories.first;
      });
    }
  }

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
          if (_categories.isNotEmpty)
            DropdownButtonFormField<CategoryItem>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'カテゴリ',
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(category.icon, size: 20, color: category.color),
                      const SizedBox(width: 8),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
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
            if (amount != null && amount > 0 && _selectedCategory != null) {
              Navigator.pop(context, {
                'amount': amount,
                'categoryType': _selectedCategory!.isCustom ? 'custom' : 'enum',
                'categoryValue': _selectedCategory!.isCustom
                  ? _selectedCategory!.id.toString()
                  : _selectedCategory!.id.toString(),
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
