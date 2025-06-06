import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';

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
  late double _amount;
  late DateTime _date;
  late IncomeCategory _category;
  String? _note;
  
  final TextEditingController _dateController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // 編集モードの場合は既存の値をセット
    if (widget.income != null) {
      _amount = widget.income!.amount;
      _date = widget.income!.date;
      _category = widget.income!.category;
      _note = widget.income!.note;
    } else {
      // 新規作成モードの場合はデフォルト値をセット
      _amount = 0;
      _date = DateTime.now();
      _category = IncomeCategory.salary;
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
          DropdownButtonFormField<IncomeCategory>(
            decoration: const InputDecoration(
              labelText: 'カテゴリ',
              prefixIcon: Icon(Icons.category),
            ),
            value: _category,
            items: IncomeCategory.values.map((category) {
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
          const SizedBox(height: 24),
          
          // 保存ボタン
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                
                final income = Income(
                  id: widget.income?.id,
                  amount: _amount,
                  date: _date,
                  category: _category,
                  note: _note,
                );
                
                widget.onSave(income);
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
