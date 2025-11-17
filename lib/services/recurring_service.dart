import 'package:flutter/foundation.dart';
import '../models/recurring_expense.dart';
import 'database_service.dart';
import '../models/expense.dart';

class RecurringService {
  final DatabaseService _db = DatabaseService();

  Future<int> createRecurring(RecurringExpense r) async {
    return await _db.insertRecurringExpense(r);
  }

  Future<List<RecurringExpense>> getAll() async {
    return await _db.getRecurringExpenses();
  }

  Future<int> updateRecurring(RecurringExpense r) async {
    return await _db.updateRecurringExpense(r);
  }

  Future<int> deleteRecurring(int id) async {
    return await _db.deleteRecurringExpense(id);
  }

  /// Calculate next due date based on cycle/interval and a base date
  DateTime calculateNextDue(RecurringExpense r, {DateTime? from}) {
    final base = from ?? (r.nextDueDate ?? r.startDate ?? DateTime.now());
    if (r.cycle == RecurrenceCycle.daily) {
      return DateTime(base.year, base.month, base.day).add(const Duration(days: 1));
    } else if (r.cycle == RecurrenceCycle.weekly) {
      return DateTime(base.year, base.month, base.day).add(const Duration(days: 7));
    } else if (r.cycle == RecurrenceCycle.monthly) {
      final y = base.year + (base.month == 12 ? 1 : 0);
      final m = base.month == 12 ? 1 : base.month + 1;
      final d = base.day;
      return DateTime(y, m, d);
    } else if (r.cycle == RecurrenceCycle.yearly) {
      return DateTime(base.year + 1, base.month, base.day);
    } else {
      // custom — intervalMonths must be provided
      final months = r.intervalMonths ?? 1;
      final totalMonths = base.month - 1 + months;
      final y = base.year + totalMonths ~/ 12;
      final m = totalMonths % 12 + 1;
      final d = base.day;
      return DateTime(y, m, d);
    }
  }

  /// For a given date, return recurring items due on or before that date
  Future<List<RecurringExpense>> dueOnOrBefore(DateTime date) async {
    return await _db.getRecurringDueByDate(date);
  }

  /// Run auto-registration for recurring items due on or before [date].
  /// For items with `autoRegister == true`, create Expense records and
  /// advance their `nextDueDate` to the next cycle.
  Future<void> runAutoRegisterFor(DateTime date) async {
    final due = await dueOnOrBefore(date);
    if (due.isEmpty) return;

    for (final r in due) {
      try {
        // Only auto-register if autoRegister is enabled
        if (!r.autoRegister) continue;

        // Build expense and attach recurring link; mark as confirmed (no provisional)
        final baseExpense = buildExpenseFromRecurring(r, date: r.nextDueDate ?? date);
        final expense = baseExpense.copyWith(
          recurringId: r.id,
          isProvisional: false,
        );

        await _db.insertExpense(expense);

        // advance nextDueDate
        final next = calculateNextDue(r, from: r.nextDueDate ?? date);
        final updated = r.copyWith(nextDueDate: next);
        await updateRecurring(updated);
      } catch (e) {
        // Log and continue with next item
        debugPrint('RecurringService: auto-register error for id=${r.id}: $e');
      }
    }
  }

  /// Create an Expense from a RecurringExpense (provisional or real)
  Expense buildExpenseFromRecurring(RecurringExpense r, {DateTime? date}) {
    final d = date ?? r.nextDueDate ?? DateTime.now();
    return Expense(
      amount: r.amount,
      date: d,
      category: r.category != null ? ExpenseCategory.values[r.category!] : ExpenseCategory.other,
      customCategoryId: r.customCategoryId,
      note: '自動登録: ${r.name}',
    );
  }

  /// Scan past expenses and suggest recurring candidates (simple heuristic)
  Future<List<RecurringExpense>> detectFromHistory(List<Expense> history, {int minRepeats = 3}) async {
    // Group by (amount, category) and count occurrences per month
    final Map<String, List<Expense>> groups = {};
    for (final e in history) {
      final key = '${e.amount}-${e.customCategoryId ?? e.category.index}';
      groups.putIfAbsent(key, () => []).add(e);
    }

    final List<RecurringExpense> candidates = [];
    groups.forEach((key, list) {
      if (list.length >= minRepeats) {
        // Check roughly monthly spacing (within 30±5 days)
        list.sort((a, b) => a.date.compareTo(b.date));
        bool monthlyLike = true;
        for (int i = 1; i < list.length; i++) {
          final diff = list[i].date.difference(list[i - 1].date).inDays.abs();
          if ((diff < 25 || diff > 35) && diff > 60) {
            monthlyLike = false;
            break;
          }
        }
        if (monthlyLike) {
          final sample = list.last;
          candidates.add(RecurringExpense(
            name: sample.note ?? '定期支出',
            amount: sample.amount,
            category: sample.customCategoryId == null ? sample.category.index : null,
            customCategoryId: sample.customCategoryId,
            cycle: RecurrenceCycle.monthly,
            startDate: list.first.date,
            nextDueDate: list.last.date.add(const Duration(days: 30)),
            autoRegister: false,
          ));
        }
      }
    });

    return candidates;
  }
}
