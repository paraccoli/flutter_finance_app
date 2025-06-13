import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/income.dart';
import 'database_service.dart';

class ExportService {
  static Future<void> exportExpensesToCsv({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final databaseService = DatabaseService();

      // 期間指定がある場合は期間内の支出を取得、ない場合は全ての支出を取得
      List<Expense> expenses;
      if (startDate != null && endDate != null) {
        expenses = await databaseService.getExpensesByDateRange(
          startDate,
          endDate,
        );
      } else {
        expenses = await databaseService.getExpenses();
      }

      // CSVデータを作成
      List<List<dynamic>> csvData = [
        ['日付', 'カテゴリ', '金額', 'メモ'], // ヘッダー
      ];

      for (final expense in expenses) {
        csvData.add([
          DateFormat('yyyy/MM/dd').format(expense.date),
          expense.category.displayName,
          expense.amount,
          expense.note ?? '',
        ]);
      }

      // CSVファイルを作成
      final csvString = const ListToCsvConverter().convert(csvData);

      // ファイルを保存
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'expenses_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvString, encoding: utf8);

      // ファイルを共有
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } catch (e) {
      throw Exception('CSVエクスポートに失敗しました: $e');
    }
  }

  static Future<void> exportIncomesToCsv({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final databaseService = DatabaseService();

      // 期間指定がある場合は期間内の収入を取得、ない場合は全ての収入を取得
      List<Income> incomes;
      if (startDate != null && endDate != null) {
        incomes = await databaseService.getIncomesByDateRange(
          startDate,
          endDate,
        );
      } else {
        incomes = await databaseService.getIncomes();
      }

      // CSVデータを作成
      List<List<dynamic>> csvData = [
        ['日付', 'カテゴリ', '金額', 'メモ'], // ヘッダー
      ];

      for (final income in incomes) {
        csvData.add([
          DateFormat('yyyy/MM/dd').format(income.date),
          income.category.displayName,
          income.amount,
          income.note ?? '',
        ]);
      }

      // CSVファイルを作成
      final csvString = const ListToCsvConverter().convert(csvData);

      // ファイルを保存
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'incomes_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvString, encoding: utf8);

      // ファイルを共有
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } catch (e) {
      throw Exception('CSVエクスポートに失敗しました: $e');
    }
  }

  static Future<void> exportAllDataToCsv({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final databaseService = DatabaseService();

      // 支出と収入データを取得
      List<Expense> expenses;
      List<Income> incomes;

      if (startDate != null && endDate != null) {
        expenses = await databaseService.getExpensesByDateRange(
          startDate,
          endDate,
        );
        incomes = await databaseService.getIncomesByDateRange(
          startDate,
          endDate,
        );
      } else {
        expenses = await databaseService.getExpenses();
        incomes = await databaseService.getIncomes();
      }

      // CSVデータを作成
      List<List<dynamic>> csvData = [
        ['日付', 'タイプ', 'カテゴリ', '金額', 'メモ'], // ヘッダー
      ];

      // 支出データを追加
      for (final expense in expenses) {
        csvData.add([
          DateFormat('yyyy/MM/dd').format(expense.date),
          '支出',
          expense.category.displayName,
          -expense.amount, // 支出は負の値として表示
          expense.note ?? '',
        ]);
      }

      // 収入データを追加
      for (final income in incomes) {
        csvData.add([
          DateFormat('yyyy/MM/dd').format(income.date),
          '収入',
          income.category.displayName,
          income.amount,
          income.note ?? '',
        ]);
      }

      // 日付順でソート
      csvData.sort((a, b) {
        if (a == csvData.first) return -1; // ヘッダーを最初に
        if (b == csvData.first) return 1;
        return DateTime.parse(
          a[0].replaceAll('/', '-'),
        ).compareTo(DateTime.parse(b[0].replaceAll('/', '-')));
      });

      // CSVファイルを作成
      final csvString = const ListToCsvConverter().convert(csvData);

      // ファイルを保存
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'all_data_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvString, encoding: utf8);

      // ファイルを共有
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } catch (e) {
      throw Exception('CSVエクスポートに失敗しました: $e');
    }
  }
}
