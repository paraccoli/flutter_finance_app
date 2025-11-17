enum RecurrenceCycle { daily, weekly, monthly, yearly, custom }

enum RecurringState { active, paused, deleted }

class RecurringExpense {
  final int? id;
  final String name;
  final double amount;
  final int? category; // maps to ExpenseCategory enum.index or null
  final int? customCategoryId; // optional
  final RecurrenceCycle cycle;
  final int? intervalMonths; // used when cycle==custom (n months)
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? nextDueDate;
  final bool autoRegister; // true: auto create Expense, false: create provisional for confirmation
  final String? notes;
  final RecurringState state;

  RecurringExpense({
    this.id,
    required this.name,
    required this.amount,
    this.category,
    this.customCategoryId,
    required this.cycle,
    this.intervalMonths,
    this.startDate,
    this.endDate,
    this.nextDueDate,
    this.autoRegister = false,
    this.notes,
    this.state = RecurringState.active,
  });

  RecurringExpense copyWith({
    int? id,
    String? name,
    double? amount,
    int? category,
    int? customCategoryId,
    RecurrenceCycle? cycle,
    int? intervalMonths,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDueDate,
    bool? autoRegister,
    String? notes,
    RecurringState? state,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      customCategoryId: customCategoryId ?? this.customCategoryId,
      cycle: cycle ?? this.cycle,
      intervalMonths: intervalMonths ?? this.intervalMonths,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      autoRegister: autoRegister ?? this.autoRegister,
      notes: notes ?? this.notes,
      state: state ?? this.state,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'customCategoryId': customCategoryId,
      'cycle': cycle.index,
      'intervalMonths': intervalMonths,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextDueDate': nextDueDate?.toIso8601String(),
      'autoRegister': autoRegister ? 1 : 0,
      'notes': notes,
      'state': state.index,
    };
  }

  factory RecurringExpense.fromMap(Map<String, dynamic> m) {
    RecurrenceCycle cycle = RecurrenceCycle.values[(m['cycle'] ?? 2) as int];
    RecurringState state = RecurringState.values[(m['state'] ?? 0) as int];
    return RecurringExpense(
      id: m['id'] as int?,
      name: m['name'] as String? ?? '',
      amount: (m['amount'] as num?)?.toDouble() ?? 0.0,
      category: m['category'] as int?,
      customCategoryId: m['customCategoryId'] as int?,
      cycle: cycle,
      intervalMonths: m['intervalMonths'] as int?,
      startDate: m['startDate'] != null ? DateTime.tryParse(m['startDate'] as String) : null,
      endDate: m['endDate'] != null ? DateTime.tryParse(m['endDate'] as String) : null,
      nextDueDate: m['nextDueDate'] != null ? DateTime.tryParse(m['nextDueDate'] as String) : null,
      autoRegister: (m['autoRegister'] as int? ?? 0) == 1,
      notes: m['notes'] as String?,
      state: state,
    );
  }
}
