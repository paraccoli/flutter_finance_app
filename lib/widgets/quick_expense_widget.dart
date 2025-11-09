import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../services/category_service.dart';
import '../services/ad_service.dart';

class QuickExpenseWidget extends StatefulWidget {
  final VoidCallback? onExpenseAdded;

  const QuickExpenseWidget({super.key, this.onExpenseAdded});

  @override
  State<QuickExpenseWidget> createState() => _QuickExpenseWidgetState();
}

class _QuickExpenseWidgetState extends State<QuickExpenseWidget> {
  List<Map<String, dynamic>> _quickExpenses = [];
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _loadQuickExpenses();
  }

  Future<void> _loadQuickExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final quickExpenseStrings = prefs.getStringList('quick_expenses') ?? [];
    
    List<Map<String, dynamic>> loadedExpenses = [];
    
    for (String str in quickExpenseStrings) {
      final parts = str.split('|');
      if (parts.length == 4) {
        // 新しい形式: amount|categoryType|categoryValue|note
        try {
          final amount = double.parse(parts[0]);
          final categoryType = parts[1];
          final categoryValue = parts[2];
          final note = parts[3];
          
          CategoryItem? category;
          if (categoryType == 'custom') {
            // カスタムカテゴリの場合、データベースから取得
            try {
              final customCategory = await DatabaseService().getCustomCategoryById(int.parse(categoryValue));
              if (customCategory != null) {
                category = CategoryItem.fromCustomCategory(customCategory);
              }
            } catch (e) {
              debugPrint('カスタムカテゴリ読み込みエラー: $e');
            }
          } else {
            // 列挙型カテゴリの場合
            final enumIndex = int.parse(categoryValue);
            if (enumIndex >= 0 && enumIndex < ExpenseCategory.values.length) {
              final enumCategory = ExpenseCategory.values[enumIndex];
              category = CategoryItem(
                id: enumIndex,
                name: enumCategory.displayName,
                icon: enumCategory.icon,
                color: enumCategory.color,
                isCustom: false,
              );
            }
          }
          
          if (category != null) {
            loadedExpenses.add({
              'amount': amount,
              'category': category,
              'note': note,
            });
          }
        } catch (e) {
          debugPrint('クイック支出読み込みエラー: $e');
        }
      } else if (parts.length == 3) {
        try {
          final amount = double.parse(parts[0]);
          final categoryIndex = int.parse(parts[1]);
          final note = parts[2];
          
          if (categoryIndex >= 0 && categoryIndex < ExpenseCategory.values.length) {
            final enumCategory = ExpenseCategory.values[categoryIndex];
            final category = CategoryItem(
              id: categoryIndex,
              name: enumCategory.displayName,
              icon: enumCategory.icon,
              color: enumCategory.color,
              isCustom: false,
            );
            
            loadedExpenses.add({
              'amount': amount,
              'category': category,
              'note': note,
            });
          }
        } catch (e) {
          debugPrint('クイック支出読み込みエラー: $e');
        }
      }
    }
    
    setState(() {
      _quickExpenses = loadedExpenses;
    });
  }

  Future<void> _saveQuickExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final quickExpenseStrings = _quickExpenses.map((expense) {
      final category = expense['category'] as CategoryItem;
      final categoryType = category.isCustom ? 'custom' : 'enum';
      final categoryValue = category.isCustom ? category.id.toString() : category.id.toString();
      return '${expense['amount']}|$categoryType|$categoryValue|${expense['note']}';
    }).toList();
    await prefs.setStringList('quick_expenses', quickExpenseStrings);
  }

  Future<void> _addQuickExpense(double amount, CategoryItem category, String note) async {
    final newQuickExpense = {
      'amount': amount,
      'category': category,
      'note': note,
    };

    setState(() {
      _quickExpenses.add(newQuickExpense);
    });

    await _saveQuickExpenses();
  }

  Future<void> _removeQuickExpense(int index) async {
    setState(() {
      _quickExpenses.removeAt(index);
    });
    await _saveQuickExpenses();
  }

  Future<void> _registerExpense(Map<String, dynamic> quickExpense) async {
    try {
      final categoryItem = quickExpense['category'] as CategoryItem;
      final expense = Expense(
        amount: quickExpense['amount'],
        category: categoryItem.isCustom 
            ? ExpenseCategory.other 
            : ExpenseCategory.values[categoryItem.id],
        customCategoryId: categoryItem.isCustom ? categoryItem.id : null,
        date: DateTime.now(),
        note: quickExpense['note'],
      );

      await _databaseService.insertExpense(expense);
      
      // 新規データ登録後に全画面広告を表示（無料版のみ）
      try {
        await AdService().showInterstitialAd();
      } catch (e) {
        debugPrint('インタースティシャル表示エラー: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('支出を登録しました: ¥${NumberFormat('#,###').format(expense.amount)}'),
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

  void _showAddQuickExpenseDialog() {
    double amount = 0;
    CategoryItem? selectedCategory;
    String note = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('クイック支出の追加'),
        content: StatefulBuilder(
          builder: (context, setState) => FutureBuilder<List<CategoryItem>>(
            future: CategoryService().getExpenseCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final categories = snapshot.data ?? [];
              if (categories.isNotEmpty && selectedCategory == null) {
                selectedCategory = categories.first;
              }
              
              return Column(
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
                  DropdownButtonFormField<CategoryItem>(
                    decoration: const InputDecoration(labelText: 'カテゴリ'),
                    value: selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Row(
                          children: [
                            Icon(cat.icon, color: cat.color),
                            const SizedBox(width: 8),
                            Text(cat.name),
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
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              if (amount > 0 && selectedCategory != null) {
                await _addQuickExpense(amount, selectedCategory!, note);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
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
                  'クイック支出',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _showAddQuickExpenseDialog,
                  tooltip: 'クイック支出を追加',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_quickExpenses.isEmpty)
              const Text(
                'クイック支出が設定されていません。\n右の+ボタンから追加してください。',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _quickExpenses.asMap().entries.map((entry) {
                  final index = entry.key;
                  final quickExpense = entry.value;
                  final categoryItem = quickExpense['category'] as CategoryItem;
                  
                  return GestureDetector(
                    onLongPress: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('削除確認'),
                          content: Text(
                            'クイック支出「${categoryItem.name} ¥${NumberFormat('#,###').format(quickExpense['amount'])}」を削除しますか？',
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
                        _removeQuickExpense(index);
                      }
                    },
                    child: ActionChip(
                      avatar: Icon(
                        categoryItem.icon,
                        size: 16,
                        color: categoryItem.color,
                      ),
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            categoryItem.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            '¥${NumberFormat('#,###').format(quickExpense['amount'])}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () => _registerExpense(quickExpense),
                    ),
                  );
                }).toList(),
              ),
            if (_quickExpenses.isNotEmpty)
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
