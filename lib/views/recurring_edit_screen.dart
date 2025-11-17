import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/recurring_expense.dart';
import '../services/recurring_service.dart';
import '../services/database_service.dart';
import '../services/category_service.dart';

class RecurringEditScreen extends StatefulWidget {
  final RecurringExpense? recurring;
  const RecurringEditScreen({super.key, this.recurring});

  @override
  State<RecurringEditScreen> createState() => _RecurringEditScreenState();
}

class _RecurringEditScreenState extends State<RecurringEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final RecurringService _service = RecurringService();
  final CategoryService _catService = CategoryService();

  late String _name;
  late double _amount;
  DateTime? _startDate;
  DateTime? _endDate;
  RecurrenceCycle _cycle = RecurrenceCycle.monthly;
  int? _intervalMonths;
  bool _autoRegister = false;
  CategoryItem? _selectedCategoryItem;
  List<CategoryItem> _categories = [];
  bool _catsLoaded = false;

  @override
  void initState() {
    super.initState();
    final r = widget.recurring;
    _name = r?.name ?? '';
    _amount = r?.amount ?? 0.0;
    _startDate = r?.startDate;
    _endDate = r?.endDate;
    _cycle = r?.cycle ?? RecurrenceCycle.monthly;
    _intervalMonths = r?.intervalMonths;
    _autoRegister = r?.autoRegister ?? false;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await _catService.getExpenseCategories();
    // Determine initial selection based on existing recurring (edit) or default
    CategoryItem? sel;
    final r = widget.recurring;
    if (cats.isNotEmpty) {
      if (r != null) {
        if (r.customCategoryId != null) {
          sel = cats.firstWhere((c) => c.isCustom && c.id == r.customCategoryId, orElse: () => cats.first);
        } else if (r.category != null) {
          sel = cats.firstWhere((c) => !c.isCustom && c.id == r.category, orElse: () => cats.first);
        }
      }
      // Fallback to first category if none selected
      sel ??= cats.first;
    }

    setState(() {
      _categories = cats;
      _selectedCategoryItem = sel;
      _catsLoaded = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // 開始日は必須にする
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('開始日を入力してください')));
      return;
    }

    bool isToday(DateTime d) {
      final now = DateTime.now();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }

    final willCreateExpenseNow = _startDate != null && isToday(_startDate!);

    // Build a temporary RecurringExpense to calculate nextDue properly
    final temp = RecurringExpense(
      id: widget.recurring?.id,
      name: _name,
      amount: _amount,
      category: _selectedCategoryItem != null && !_selectedCategoryItem!.isCustom ? _selectedCategoryItem!.id : null,
      customCategoryId: _selectedCategoryItem != null && _selectedCategoryItem!.isCustom ? _selectedCategoryItem!.id : null,
      cycle: _cycle,
      intervalMonths: _intervalMonths,
      startDate: _startDate,
      endDate: _endDate,
      nextDueDate: _startDate,
      autoRegister: _autoRegister,
    );

    final nextDue = willCreateExpenseNow ? _service.calculateNextDue(temp, from: _startDate) : _startDate;

    final r = RecurringExpense(
      id: widget.recurring?.id,
      name: _name,
      amount: _amount,
      category: _selectedCategoryItem != null && !_selectedCategoryItem!.isCustom ? _selectedCategoryItem!.id : null,
      customCategoryId: _selectedCategoryItem != null && _selectedCategoryItem!.isCustom ? _selectedCategoryItem!.id : null,
      cycle: _cycle,
      intervalMonths: _intervalMonths,
      startDate: _startDate,
      endDate: _endDate,
      nextDueDate: nextDue,
      autoRegister: _autoRegister,
    );

    int? createdRecurringId;
    if (widget.recurring == null) {
      createdRecurringId = await _service.createRecurring(r);
    } else {
      await _service.updateRecurring(r);
      createdRecurringId = widget.recurring?.id;
    }

    // 開始日が今日なら、Expenseを即時作成して反映させる
    if (willCreateExpenseNow) {
      try {
        final expense = _service.buildExpenseFromRecurring(r, date: _startDate).copyWith(
          recurringId: createdRecurringId,
          isProvisional: false,
        );
        await DatabaseService().insertExpense(expense);
      } catch (e) {
        debugPrint('RecurringEdit: immediate expense creation failed: $e');
      }
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.recurring == null ? '定期支出を追加' : '定期支出を編集')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: '名称'),
                  initialValue: _name,
                  validator: (v) => (v == null || v.isEmpty) ? '名称を入力してください' : null,
                  onSaved: (v) => _name = v!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: '金額 (¥)'),
                  keyboardType: TextInputType.number,
                  initialValue: _amount == 0 ? '' : _amount.toString(),
                  validator: (v) => (v == null || v.isEmpty || double.tryParse(v) == null) ? '有効な金額を入力してください' : null,
                  onSaved: (v) => _amount = double.parse(v!),
                ),
                const SizedBox(height: 12),
                if (!_catsLoaded) ...[
                  const SizedBox(),
                ] else ...[
                  DropdownButtonFormField<CategoryItem>(
                    value: _selectedCategoryItem,
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                    onChanged: (v) => setState(() => _selectedCategoryItem = v),
                    decoration: const InputDecoration(labelText: 'カテゴリ'),
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<RecurrenceCycle>(
                  value: _cycle,
                  decoration: const InputDecoration(labelText: 'サイクル'),
                  items: RecurrenceCycle.values.map((c) => DropdownMenuItem(value: c, child: Text(c.toString().split('.').last))).toList(),
                  onChanged: (v) => setState(() => _cycle = v!),
                ),
                if (_cycle == RecurrenceCycle.custom) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: '間隔（月）'),
                    keyboardType: TextInputType.number,
                    initialValue: _intervalMonths?.toString() ?? '1',
                    onSaved: (v) => _intervalMonths = int.tryParse(v ?? '1'),
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: _startDate != null ? DateFormat('yyyy/MM/dd').format(_startDate!) : ''),
                  decoration: const InputDecoration(labelText: '開始日'),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: _startDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (d != null) setState(() => _startDate = d);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: _endDate != null ? DateFormat('yyyy/MM/dd').format(_endDate!) : ''),
                  decoration: const InputDecoration(labelText: '終了日（任意）'),
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: _endDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                    if (d != null) setState(() => _endDate = d);
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('自動登録'),
                  subtitle: const Text('ONにすると自動で支出を作成します。'),
                  value: _autoRegister,
                  onChanged: (v) => setState(() => _autoRegister = v),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: _save, child: const Text('保存'))),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
