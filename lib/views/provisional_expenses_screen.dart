import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../widgets/expense_form.dart';

class ProvisionalExpensesScreen extends StatefulWidget {
  const ProvisionalExpensesScreen({super.key});

  @override
  State<ProvisionalExpensesScreen> createState() => _ProvisionalExpensesScreenState();
}

class _ProvisionalExpensesScreenState extends State<ProvisionalExpensesScreen> {
  final DatabaseService _db = DatabaseService();
  List<Expense> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final all = await _db.getExpenses();
    _items = all.where((e) => e.isProvisional).toList();
    setState(() => _loading = false);
  }

  Future<void> _approve(Expense e) async {
    final updated = e.copyWith(isProvisional: false);
    await _db.updateExpense(updated);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('承認しました')));
    await _load();
  }

  Future<void> _delete(Expense e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('削除確認'),
        content: Text('この暫定支出を削除しますか？\n¥${e.amount} - ${DateFormat('yyyy/MM/dd').format(e.date)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('削除')),
        ],
      ),
    );
    if (ok == true && e.id != null) {
      await _db.deleteExpense(e.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('削除しました')));
      await _load();
    }
  }

  Future<void> _edit(Expense e) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('暫定支出を編集'),
          content: SingleChildScrollView(
            child: ExpenseForm(
              expense: e,
              onSave: (updated) async {
                await _db.updateExpense(updated);
                if (context.mounted) Navigator.pop(context);
                await _load();
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('暫定支出一覧')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('暫定支出はありません'))
                : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final e = _items[idx];
                    return ListTile(
                      title: Text('¥${e.amount.toStringAsFixed(0)}'),
                      subtitle: Text('${DateFormat('yyyy/MM/dd').format(e.date)} • ${e.note ?? ''}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) async {
                          if (v == 'approve') await _approve(e);
                          if (v == 'edit') await _edit(e);
                          if (v == 'delete') await _delete(e);
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'approve', child: Text('承認')),
                          const PopupMenuItem(value: 'edit', child: Text('編集')),
                          const PopupMenuItem(value: 'delete', child: Text('破棄')),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
