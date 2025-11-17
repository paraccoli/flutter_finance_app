import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';
import '../services/category_service.dart';

class IncomeForm extends StatefulWidget {
  final Function(Income) onSave;
  final Income? income; // 編集時に使用
  
  const IncomeForm({
    super.key,
    required this.onSave,
    this.income,
  });

  @override
  State<IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<IncomeForm> {
  final _formKey = GlobalKey<FormState>();
  final CategoryService _categoryService = CategoryService();
  
  late double _amount;
  late DateTime _date;
  CategoryItem? _selectedCategoryItem;
  String? _note;
  
  List<CategoryItem> _availableCategories = [];
  bool _isLoadingCategories = true;
  
  final TextEditingController _dateController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
    
    // 編集モードの場合は既存の値をセット
    if (widget.income != null) {
      _amount = widget.income!.amount;
      _date = widget.income!.date;
      _note = widget.income!.note;
    } else {
      // 新規作成モードの場合はデフォルト値をセット
      _amount = 0;
      _date = DateTime.now();
      _note = null;
    }
    
    _dateController.text = DateFormat('yyyy/MM/dd').format(_date);
  }
  
  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getIncomeCategories();
      setState(() {
        _availableCategories = categories;
        _isLoadingCategories = false;
        
        // 編集モードの場合、対応するカテゴリアイテムを選択
        if (widget.income != null) {
          if (widget.income!.customCategoryId != null) {
            // カスタムカテゴリの場合
            _selectedCategoryItem = categories.firstWhere(
              (item) => item.isCustom && item.id == widget.income!.customCategoryId,
              orElse: () => categories.first,
            );
          } else {
            // レガシーカテゴリの場合
            _selectedCategoryItem = categories.firstWhere(
              (item) => !item.isCustom && item.id == widget.income!.category.index,
              orElse: () => categories.first,
            );
          }
        } else {
          _selectedCategoryItem = categories.first;
        }
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      debugPrint('カテゴリ読み込みエラー: $e');
    }
  }
  
  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 金額入力
          TextFormField(
            decoration: const InputDecoration(
              labelText: '金額 (¥)',
              prefixIcon: Icon(Icons.monetization_on),
            ),
            keyboardType: TextInputType.number,
            initialValue: widget.income != null ? _amount.toString() : '',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '金額を入力してください';
              }
              if (double.tryParse(value) == null) {
                return '有効な数値を入力してください';
              }
              return null;
            },
            onSaved: (value) {
              _amount = double.parse(value!);
            },
          ),
          const SizedBox(height: 16),
          
          // 日付選択
          TextFormField(
            controller: _dateController,
            decoration: const InputDecoration(
              labelText: '日付',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 1)),
              );
              
              if (pickedDate != null) {
                setState(() {
                  _date = pickedDate;
                  _dateController.text = DateFormat('yyyy/MM/dd').format(_date);
                });
              }
            },
          ),
          const SizedBox(height: 16),
          
          // カテゴリ選択
          if (_isLoadingCategories)
            const Center(child: CircularProgressIndicator())
          else
            DropdownButtonFormField<CategoryItem>(
              decoration: const InputDecoration(
                labelText: 'カテゴリ',
                prefixIcon: Icon(Icons.category),
              ),
              value: _selectedCategoryItem,
              items: _availableCategories.map((item) {
                return DropdownMenuItem<CategoryItem>(
                  value: item,
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.color,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(item.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategoryItem = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'カテゴリを選択してください';
                }
                return null;
              },
            ),
          const SizedBox(height: 16),
          
          // メモ入力
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'メモ (任意)',
              prefixIcon: Icon(Icons.note),
            ),
            initialValue: _note,
            maxLines: 2,
            onSaved: (value) {
              _note = value;
            },
          ),
          const SizedBox(height: 24),
            // 保存ボタン
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() && _selectedCategoryItem != null) {
                try {
                  _formKey.currentState!.save();
                  
                  final income = Income(
                    id: widget.income?.id,
                    amount: _amount,
                    date: _date,
                    category: _selectedCategoryItem!.isCustom 
                        ? IncomeCategory.other // カスタムカテゴリの場合は一時的にother
                        : IncomeCategory.values[_selectedCategoryItem!.id],
                    customCategoryId: _selectedCategoryItem!.isCustom 
                        ? _selectedCategoryItem!.id 
                        : null,
                    note: _note,
                  );
                  
                  // ローディング表示
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  await widget.onSave(income);
                  
                  // 親画面がダイアログを閉じるため、ここではローディングのみ終了
                  if (context.mounted) {
                    Navigator.pop(context); // ローディング終了のみ
                  }
                } catch (e) {
                  debugPrint('IncomeForm: 保存中にエラーが発生しました: $e');
                  
                  if (context.mounted) {
                    Navigator.pop(context); // ローディング終了
                    
                    // エラーダイアログを表示
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('エラー'),
                        content: Text('保存中にエラーが発生しました。\n再度お試しください。\n\nエラー詳細: $e'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
