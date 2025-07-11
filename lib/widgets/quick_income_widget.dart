import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';
import '../services/database_service.dart';
import '../services/category_service.dart';

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
    
    List<Map<String, dynamic>> loadedIncomes = [];
    
    for (String str in quickIncomeStrings) {
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
            if (enumIndex >= 0 && enumIndex < IncomeCategory.values.length) {
              final enumCategory = IncomeCategory.values[enumIndex];
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
            loadedIncomes.add({
              'amount': amount,
              'category': category,
              'note': note,
            });
          }
        } catch (e) {
          debugPrint('クイック収入読み込みエラー: $e');
        }
      } else if (parts.length == 3) {
        // 旧形式: amount|categoryIndex|note
        try {
          final amount = double.parse(parts[0]);
          final categoryIndex = int.parse(parts[1]);
          final note = parts[2];
          
          if (categoryIndex >= 0 && categoryIndex < IncomeCategory.values.length) {
            final enumCategory = IncomeCategory.values[categoryIndex];
            final category = CategoryItem(
              id: categoryIndex,
              name: enumCategory.displayName,
              icon: enumCategory.icon,
              color: enumCategory.color,
              isCustom: false,
            );
            
            loadedIncomes.add({
              'amount': amount,
              'category': category,
              'note': note,
            });
          }
        } catch (e) {
          debugPrint('旧形式クイック収入読み込みエラー: $e');
        }
      }
    }
    
    setState(() {
      _quickIncomes = loadedIncomes;
    });
  }

  Future<void> _saveQuickIncomes() async {
    final prefs = await SharedPreferences.getInstance();
    final quickIncomeStrings = _quickIncomes.map((income) {
      final category = income['category'] as CategoryItem;
      final categoryType = category.isCustom ? 'custom' : 'enum';
      final categoryValue = category.isCustom ? category.id.toString() : category.id.toString();
      return '${income['amount']}|$categoryType|$categoryValue|${income['note']}';
    }).toList();
    await prefs.setStringList('quick_incomes', quickIncomeStrings);
  }

  Future<void> _addQuickIncome(double amount, CategoryItem category, String note) async {
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
      final categoryItem = quickIncome['category'] as CategoryItem;
      final income = Income(
        amount: quickIncome['amount'],
        category: categoryItem.isCustom 
            ? IncomeCategory.other 
            : IncomeCategory.values[categoryItem.id],
        customCategoryId: categoryItem.isCustom ? categoryItem.id : null,
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
    CategoryItem? selectedCategory;
    String note = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('クイック収入の追加'),
        content: StatefulBuilder(
          builder: (context, setState) => FutureBuilder<List<CategoryItem>>(
            future: CategoryService().getIncomeCategories(),
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
                await _addQuickIncome(amount, selectedCategory!, note);
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
                  final categoryItem = quickIncome['category'] as CategoryItem;
                  
                  return GestureDetector(
                    onLongPress: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('削除確認'),
                          content: Text(
                            'クイック収入「${categoryItem.name} ¥${NumberFormat('#,###').format(quickIncome['amount'])}」を削除しますか？',
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
