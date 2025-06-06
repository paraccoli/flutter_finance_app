import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/expense.dart';
import '../widgets/expense_bar_chart.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/expense_form.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ExpenseViewModel>(context);
    final categoryTotals = viewModel.getCategoryTotals();
    final dailyTotals = viewModel.getDailyTotals();
    
    // 合計金額を計算
    final totalExpense = categoryTotals.values.fold<double>(
        0, (previousValue, amount) => previousValue + amount);
    
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => viewModel.loadExpenses(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 日付範囲選択
                _buildDateRangeSelector(context, viewModel),
                const SizedBox(height: 16),
                
                // 合計金額表示
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          '合計支出',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¥${NumberFormat('#,###').format(totalExpense)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // 棒グラフ
                if (dailyTotals.isNotEmpty)
                  ExpenseBarChart(dailyTotals: dailyTotals)
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('データがありません'),
                    ),
                  ),
                const SizedBox(height: 16),
                
                // 円グラフ
                if (categoryTotals.isNotEmpty)
                  ExpensePieChart(categoryTotals: categoryTotals)
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('データがありません'),
                    ),
                  ),
                const SizedBox(height: 16),
                
                // 支出リスト
                const Text(
                  '支出リスト',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildExpenseList(context, viewModel),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context, viewModel),
        tooltip: '支出を追加',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildDateRangeSelector(BuildContext context, ExpenseViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${DateFormat('yyyy/MM/dd').format(viewModel.startDate)} - '
          '${DateFormat('yyyy/MM/dd').format(viewModel.endDate)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () => _selectDateRange(context, viewModel),
          child: const Text('期間を選択'),
        ),
      ],
    );
  }
  
  Future<void> _selectDateRange(BuildContext context, ExpenseViewModel viewModel) async {
    final initialDateRange = DateTimeRange(
      start: viewModel.startDate,
      end: viewModel.endDate,
    );
    
    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (pickedDateRange != null) {
      viewModel.setDateRange(pickedDateRange.start, pickedDateRange.end);
    }
  }
  
  Widget _buildExpenseList(BuildContext context, ExpenseViewModel viewModel) {
    final expenses = viewModel.expenses;
    
    if (expenses.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('データがありません'),
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(expense.category),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: Colors.white,
              ),
            ),
            title: Text(
              '¥${NumberFormat('#,###').format(expense.amount)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${expense.category} - ${DateFormat('yyyy/MM/dd').format(expense.date)}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditExpenseDialog(context, viewModel, expense),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmationDialog(context, viewModel, expense),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  void _showAddExpenseDialog(BuildContext context, ExpenseViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('支出を追加'),
          content: SingleChildScrollView(
            child: ExpenseForm(
              onSave: (expense) {
                viewModel.addExpense(expense);
              },
            ),
          ),
        );
      },
    );
  }
  
  void _showEditExpenseDialog(BuildContext context, ExpenseViewModel viewModel, Expense expense) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('支出を編集'),
          content: SingleChildScrollView(
            child: ExpenseForm(
              expense: expense,
              onSave: (updatedExpense) {
                viewModel.updateExpense(updatedExpense);
              },
            ),
          ),
        );
      },
    );
  }
  
  void _showDeleteConfirmationDialog(BuildContext context, ExpenseViewModel viewModel, Expense expense) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('確認'),
          content: const Text('この支出を削除してもよろしいですか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (expense.id != null) {
                  viewModel.deleteExpense(expense.id!);
                }
              },
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }
  
  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.red;
      case ExpenseCategory.transportation:
        return Colors.blue;
      case ExpenseCategory.entertainment:
        return Colors.green;
      case ExpenseCategory.utilities:
        return Colors.purple;
      case ExpenseCategory.shopping:
        return Colors.orange;
      case ExpenseCategory.health:
        return Colors.teal;
      case ExpenseCategory.education:
        return Colors.indigo;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }
  
  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Icons.restaurant;
      case ExpenseCategory.transportation:
        return Icons.directions_car;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.utilities:
        return Icons.flash_on;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.health:
        return Icons.healing;
      case ExpenseCategory.education:
        return Icons.school;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }
}
