import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';

class ExpenseForm extends StatefulWidget {
  final Function(Expense) onSave;
  final VoidCallback? onCancel; // キャンセル時の処理
  final Expense? expense; // 編集時に使用

  const ExpenseForm({
    super.key,
    required this.onSave,
    this.onCancel,
    this.expense,
  });

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late double _amount;
  late DateTime _date;
  late ExpenseCategory _category;
  String? _note;

  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 編集モードの場合は既存の値をセット
    if (widget.expense != null) {
      _amount = widget.expense!.amount;
      _date = widget.expense!.date;
      _category = widget.expense!.category;
      _note = widget.expense!.note;
    } else {
      // 新規作成モードの場合はデフォルト値をセット
      _amount = 0;
      _date = DateTime.now();
      _category = ExpenseCategory.food;
      _note = null;
    }

    _dateController.text = DateFormat('yyyy/MM/dd').format(_date);
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
            initialValue: widget.expense != null ? _amount.toString() : '',
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
          DropdownButtonFormField<ExpenseCategory>(
            decoration: const InputDecoration(
              labelText: 'カテゴリ',
              prefixIcon: Icon(Icons.category),
            ),
            value: _category,
            items: ExpenseCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.toString()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _category = value;
                });
              }
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
          const SizedBox(height: 24),          // 保存ボタン
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  _formKey.currentState!.save();

                  final expense = Expense(
                    id: widget.expense?.id,
                    amount: _amount,
                    date: _date,
                    category: _category,
                    note: _note,
                  );

                  // ローディング表示
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );                  await widget.onSave(expense);
                  
                  // 親画面がダイアログを閉じるため、ここではローディングのみ終了
                  if (context.mounted) {
                    Navigator.pop(context); // ローディング終了のみ
                  }
                } catch (e) {
                  debugPrint('ExpenseForm: 保存中にエラーが発生しました: $e');
                  
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
