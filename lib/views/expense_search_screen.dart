import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_service.dart';

class ExpenseSearchScreen extends StatefulWidget {
  const ExpenseSearchScreen({super.key});

  @override
  State<ExpenseSearchScreen> createState() => _ExpenseSearchScreenState();
}

class _ExpenseSearchScreenState extends State<ExpenseSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Expense> _allExpenses = [];
  List<Expense> _filteredExpenses = [];
  ExpenseCategory? _selectedCategory;
  DateTimeRange? _selectedDateRange;
  double? _minAmount;
  double? _maxAmount;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }
  Future<void> _loadExpenses() async {
    final expenses = await DatabaseService().getExpenses();
    setState(() {
      _allExpenses = expenses;
      _filteredExpenses = expenses;
    });
  }

  void _filterExpenses() {
    List<Expense> filtered = _allExpenses;    // テキスト検索
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((expense) =>
          (expense.note ?? '').toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    }

    // カテゴリフィルタ
    if (_selectedCategory != null) {
      filtered = filtered.where((expense) => expense.category == _selectedCategory).toList();
    }

    // 日付範囲フィルタ
    if (_selectedDateRange != null) {
      filtered = filtered.where((expense) =>
          expense.date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)))).toList();
    }

    // 金額範囲フィルタ
    if (_minAmount != null) {
      filtered = filtered.where((expense) => expense.amount >= _minAmount!).toList();
    }
    if (_maxAmount != null) {
      filtered = filtered.where((expense) => expense.amount <= _maxAmount!).toList();
    }

    setState(() {
      _filteredExpenses = filtered;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedDateRange = null;
      _minAmount = null;
      _maxAmount = null;
      _filteredExpenses = _allExpenses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('支出検索'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 検索フィルタ部分
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // テキスト検索
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: '説明で検索',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _filterExpenses(),
                  ),
                  const SizedBox(height: 16),

                  // フィルタ行
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // カテゴリフィルタ
                      FilterChip(
                        label: Text(_selectedCategory?.displayName ?? 'カテゴリ'),
                        selected: _selectedCategory != null,
                        onSelected: (selected) async {
                          if (selected) {
                            final category = await _showCategoryDialog();
                            if (category != null) {
                              setState(() {
                                _selectedCategory = category;
                              });
                              _filterExpenses();
                            }
                          } else {
                            setState(() {
                              _selectedCategory = null;
                            });
                            _filterExpenses();
                          }
                        },
                      ),

                      // 日付範囲フィルタ
                      FilterChip(
                        label: Text(_selectedDateRange != null
                            ? '${DateFormat('M/d').format(_selectedDateRange!.start)} - ${DateFormat('M/d').format(_selectedDateRange!.end)}'
                            : '期間'),
                        selected: _selectedDateRange != null,
                        onSelected: (selected) async {
                          if (selected) {
                            final range = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (range != null) {
                              setState(() {
                                _selectedDateRange = range;
                              });
                              _filterExpenses();
                            }
                          } else {
                            setState(() {
                              _selectedDateRange = null;
                            });
                            _filterExpenses();
                          }
                        },
                      ),

                      // 金額範囲フィルタ
                      FilterChip(
                        label: Text(_minAmount != null || _maxAmount != null
                            ? '${_minAmount?.toStringAsFixed(0) ?? ""}円 - ${_maxAmount?.toStringAsFixed(0) ?? ""}円'
                            : '金額'),
                        selected: _minAmount != null || _maxAmount != null,
                        onSelected: (selected) async {
                          if (selected) {
                            await _showAmountRangeDialog();
                          } else {
                            setState(() {
                              _minAmount = null;
                              _maxAmount = null;
                            });
                            _filterExpenses();
                          }
                        },
                      ),

                      // クリアボタン
                      if (_searchController.text.isNotEmpty ||
                          _selectedCategory != null ||
                          _selectedDateRange != null ||
                          _minAmount != null ||
                          _maxAmount != null)
                        ActionChip(
                          label: const Text('クリア'),
                          onPressed: _clearFilters,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(),

            // 検索結果
            Expanded(
              child: _filteredExpenses.isEmpty
                  ? const Center(
                      child: Text(
                        '該当する支出が見つかりません',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = _filteredExpenses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: expense.category.color,
                              child: Icon(
                                expense.category.icon,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            title: Text(expense.note ?? '支出'),
                            subtitle: Text(
                              '${expense.category.displayName} • ${DateFormat('yyyy/MM/dd').format(expense.date)}',
                            ),
                            trailing: Text(
                              '¥${NumberFormat('#,###').format(expense.amount)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // 合計金額表示
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '検索結果: ${_filteredExpenses.length}件',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '合計: ¥${NumberFormat('#,###').format(_filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount))}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<ExpenseCategory?> _showCategoryDialog() async {
    return showDialog<ExpenseCategory>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('カテゴリを選択'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: ExpenseCategory.values.map((category) {
              return ListTile(
                leading: Icon(category.icon, color: category.color),
                title: Text(category.displayName),
                onTap: () => Navigator.pop(context, category),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _showAmountRangeDialog() async {
    final TextEditingController minController = TextEditingController();
    final TextEditingController maxController = TextEditingController();

    if (_minAmount != null) {
      minController.text = _minAmount!.toStringAsFixed(0);
    }
    if (_maxAmount != null) {
      maxController.text = _maxAmount!.toStringAsFixed(0);
    }

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('金額範囲'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minController,
              decoration: const InputDecoration(
                labelText: '最小金額',
                suffixText: '円',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxController,
              decoration: const InputDecoration(
                labelText: '最大金額',
                suffixText: '円',
              ),
              keyboardType: TextInputType.number,
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
              setState(() {
                _minAmount = double.tryParse(minController.text);
                _maxAmount = double.tryParse(maxController.text);
              });
              _filterExpenses();
              Navigator.pop(context);
            },
            child: const Text('適用'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
