import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/nisa_investment.dart';

class NisaInvestmentForm extends StatefulWidget {
  final Function(NisaInvestment) onSave;
  final NisaInvestment? investment; // 編集時に使用

  const NisaInvestmentForm({super.key, required this.onSave, this.investment});

  @override
  State<NisaInvestmentForm> createState() => _NisaInvestmentFormState();
}

class _NisaInvestmentFormState extends State<NisaInvestmentForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late double _initialAmount;
  late double _monthlyContribution;
  late double _currentValue;
  late DateTime _lastUpdated;
  late int _contributionDay;

  final TextEditingController _lastUpdatedController = TextEditingController();

  @override
  void initState() {
    super.initState(); // 編集モードの場合は既存の値をセット
    if (widget.investment != null) {
      _name = widget.investment!.stockName;
      _initialAmount = widget.investment!.investedAmount;
      _monthlyContribution = widget.investment!.monthlyContribution;
      _currentValue = widget.investment!.currentValue;
      _lastUpdated = widget.investment!.lastUpdated;
      _contributionDay = widget.investment!.contributionDay;
    } else {
      // 新規作成モードの場合はデフォルト値をセット
      _name = 'つみたてNISA';
      _initialAmount = 0;
      _monthlyContribution = 0;
      _currentValue = 0;
      _lastUpdated = DateTime.now();
      _contributionDay = 10; // デフォルトは10日
    }

    _lastUpdatedController.text = DateFormat('yyyy/MM/dd').format(_lastUpdated);
  }

  @override
  void dispose() {
    _lastUpdatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 投資名入力
          TextFormField(
            decoration: const InputDecoration(
              labelText: '投資名',
              prefixIcon: Icon(Icons.account_balance),
            ),
            initialValue: _name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '投資名を入力してください';
              }
              return null;
            },
            onSaved: (value) {
              _name = value!;
            },
          ),
          const SizedBox(height: 16),

          // 初期投資額入力
          TextFormField(
            decoration: const InputDecoration(
              labelText: '初期投資額 (¥)',
              prefixIcon: Icon(Icons.money),
            ),
            keyboardType: TextInputType.number,
            initialValue: widget.investment != null
                ? _initialAmount.toString()
                : '',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '初期投資額を入力してください';
              }
              if (double.tryParse(value) == null) {
                return '有効な数値を入力してください';
              }
              return null;
            },
            onSaved: (value) {
              _initialAmount = double.parse(value!);
            },
          ),
          const SizedBox(height: 16),

          // 月々の拠出額入力
          TextFormField(
            decoration: const InputDecoration(
              labelText: '月々の拠出額 (¥)',
              prefixIcon: Icon(Icons.calendar_month),
            ),
            keyboardType: TextInputType.number,
            initialValue: widget.investment != null
                ? _monthlyContribution.toString()
                : '',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '月々の拠出額を入力してください';
              }
              if (double.tryParse(value) == null) {
                return '有効な数値を入力してください';
              }
              return null;
            },
            onSaved: (value) {
              _monthlyContribution = double.parse(value!);
            },
          ),
          const SizedBox(height: 16),

          // 現在の評価額入力
          TextFormField(
            decoration: const InputDecoration(
              labelText: '現在の評価額 (¥)',
              prefixIcon: Icon(Icons.trending_up),
            ),
            keyboardType: TextInputType.number,
            initialValue: widget.investment != null
                ? _currentValue.toString()
                : '',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '現在の評価額を入力してください';
              }
              if (double.tryParse(value) == null) {
                return '有効な数値を入力してください';
              }
              return null;
            },
            onSaved: (value) {
              _currentValue = double.parse(value!);
            },
          ),
          const SizedBox(height: 16),

          // 最終更新日選択
          TextFormField(
            controller: _lastUpdatedController,
            decoration: const InputDecoration(
              labelText: '最終更新日',
              prefixIcon: Icon(Icons.update),
            ),
            readOnly: true,
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: _lastUpdated,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );

              if (pickedDate != null) {
                setState(() {
                  _lastUpdated = pickedDate;
                  _lastUpdatedController.text = DateFormat(
                    'yyyy/MM/dd',
                  ).format(_lastUpdated);
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // 拠出日入力
          TextFormField(
            decoration: const InputDecoration(
              labelText: '毎月の拠出日 (1-28)',
              prefixIcon: Icon(Icons.date_range),
            ),
            keyboardType: TextInputType.number,
            initialValue: _contributionDay.toString(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '拠出日を入力してください';
              }
              final day = int.tryParse(value);
              if (day == null || day < 1 || day > 28) {
                return '1から28の間で入力してください';
              }
              return null;
            },
            onSaved: (value) {
              _contributionDay = int.parse(value!);
            },
          ),
          const SizedBox(height: 24),

          // 保存ボタン
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                final investment = NisaInvestment(
                  id: widget.investment?.id,
                  stockName: _name,
                  ticker: '', // ティッカーシンボルはフォームに追加していないのでダミー値
                  investedAmount: _initialAmount,
                  monthlyContribution: _monthlyContribution,
                  currentValue: _currentValue,
                  purchaseDate: _lastUpdated, // 購入日も追加
                  lastUpdated: _lastUpdated,
                  contributionDay: _contributionDay,
                );

                widget.onSave(investment);
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
