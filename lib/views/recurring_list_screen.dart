import 'package:flutter/material.dart';
import '../services/recurring_service.dart';
import '../models/recurring_expense.dart';
import 'recurring_edit_screen.dart';

class RecurringListScreen extends StatefulWidget {
  const RecurringListScreen({super.key});

  @override
  State<RecurringListScreen> createState() => _RecurringListScreenState();
}

class _RecurringListScreenState extends State<RecurringListScreen> {
  final RecurringService _service = RecurringService();
  List<RecurringExpense> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _items = await _service.getAll();
    setState(() => _loading = false);
  }

  Future<void> _onAdd() async {
    final changed = await Navigator.push<bool?>(context, MaterialPageRoute(builder: (_) => const RecurringEditScreen()));
    if (changed == true) await _load();
  }

  Future<void> _onEdit(RecurringExpense r) async {
    final changed = await Navigator.push<bool?>(context, MaterialPageRoute(builder: (_) => RecurringEditScreen(recurring: r)));
    if (changed == true) await _load();
  }

  Future<void> _toggleAuto(RecurringExpense r) async {
    final updated = r.copyWith(autoRegister: !r.autoRegister);
    await _service.updateRecurring(updated);
    await _load();
  }

  Future<void> _delete(RecurringExpense r) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      title: const Text('削除確認'),
      content: Text('定期支出「${r.name}」を削除しますか？'),
      actions: [TextButton(onPressed: ()=>Navigator.pop(context,false), child: const Text('キャンセル')), TextButton(onPressed: ()=>Navigator.pop(context,true), child: const Text('削除'))],
    ));
    if (ok == true) {
      await _service.deleteRecurring(r.id!);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('定期支出の管理')),
      body: Builder(
        builder: (context) {
          if (_loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (_items.isEmpty) {
            return const Center(child: Text('定期支出が登録されていません'));
          } else {
            return ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final r = _items[idx];
                return ListTile(
                  title: Text(r.name),
                  subtitle: Text('¥${r.amount.toStringAsFixed(0)} • 次回: ${r.nextDueDate != null ? r.nextDueDate!.toIso8601String().split('T').first : '未設定'}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') await _onEdit(r);
                      if (v == 'toggle') await _toggleAuto(r);
                      if (v == 'delete') await _delete(r);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('編集')),
                      PopupMenuItem(value: 'toggle', child: Text(r.autoRegister ? '自動登録を無効化' : '自動登録を有効化')),
                      const PopupMenuItem(value: 'delete', child: Text('削除')),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        tooltip: '定期支出を追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}
