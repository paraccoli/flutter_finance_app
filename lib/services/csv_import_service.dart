import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../models/expense.dart';

/// CSVインポートサービス
/// クレジットカード明細のCSVファイルを読み込み、支出データに変換する
class CSVImportService {
  /// サポートしているCSVフォーマット
  static const Map<String, CSVFormat> supportedFormats = {
    'smbc': CSVFormat(
      name: '三井住友カード',
      dateColumn: 0,
      amountColumn: 1,
      descriptionColumn: 2,
      dateFormat: 'yyyy/MM/dd',
      encoding: 'shift_jis',
    ),
    'rakuten': CSVFormat(
      name: '楽天カード',
      dateColumn: 0,
      amountColumn: 1,
      descriptionColumn: 2,
      dateFormat: 'yyyy-MM-dd',
      encoding: 'utf-8',
    ),
    'jcb': CSVFormat(
      name: 'JCBカード',
      dateColumn: 0,
      amountColumn: 2,
      descriptionColumn: 1,
      dateFormat: 'MM/dd/yyyy',
      encoding: 'shift_jis',
    ),
    'aeon': CSVFormat(
      name: 'イオンカード',
      dateColumn: 0,
      amountColumn: 1,
      descriptionColumn: 3,
      dateFormat: 'yyyy/MM/dd',
      encoding: 'shift_jis',
    ),
  };

  /// CSVファイルを選択して読み込み
  Future<CSVImportResult?> selectAndImportCSV() async {
    try {
      // ファイル選択
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null) {
        return null; // ユーザーがキャンセル
      }

      final file = File(result.files.single.path!);
      return await importCSVFile(file);
    } catch (e) {
      throw CSVImportException('ファイル選択中にエラーが発生しました: $e');
    }
  }  /// CSVファイルをインポート
  Future<CSVImportResult> importCSVFile(File file) async {
    try {
      // ファイル名からフォーマットを推定
      final fileName = path.basenameWithoutExtension(file.path).toLowerCase();
      print('CSV Import: ファイル名 = $fileName');
      CSVFormat? detectedFormat = _detectFormat(fileName);
      print('CSV Import: 検出フォーマット = ${detectedFormat?.name}');

      // ファイル内容を読み込み（複数のエンコーディングを試行）
      String content;
      try {
        // まずUTF-8で試行
        content = await file.readAsString(encoding: utf8);
        print('CSV Import: UTF-8で読み込み成功');
      } catch (e) {
        try {
          // UTF-8で失敗した場合はShift_JISを試行
          final bytes = await file.readAsBytes();
          content = String.fromCharCodes(bytes);
          print('CSV Import: バイト配列として読み込み成功');
        } catch (e) {
          throw CSVImportException('ファイルのエンコーディングが認識できません');
        }
      }
      
      print('CSV Import: コンテンツの最初の100文字 = ${content.length > 100 ? content.substring(0, 100) : content}');
      
      // CSVをパース
      List<List<dynamic>> csvData;
      try {
        csvData = const CsvToListConverter().convert(content);
        print('CSV Import: CSVパース成功、${csvData.length}行検出');
      } catch (e) {
        print('CSV Import: CSVパースエラー = $e');
        throw CSVImportException('CSVファイルの形式が正しくありません');
      }
      
      if (csvData.isEmpty) {
        throw CSVImportException('CSVファイルが空です');
      }

      // ヘッダー行をスキップ（通常は最初の行）
      final dataRows = csvData.skip(1).toList();
      print('CSV Import: データ行数 = ${dataRows.length}');
      
      if (dataRows.isEmpty) {
        throw CSVImportException('データ行が見つかりません');
      }
      
      // データを解析してプレビューを生成
      final previewData = _generatePreview(dataRows, detectedFormat);
      print('CSV Import: プレビューデータ生成完了、${previewData.length}行');
      
      return CSVImportResult(
        file: file,
        detectedFormat: detectedFormat,
        previewData: previewData,
        totalRows: dataRows.length,
      );
    } catch (e) {
      print('CSV Import: エラー発生 = $e');
      if (e is CSVImportException) {
        rethrow;
      }
      throw CSVImportException('CSVファイルの読み込み中にエラーが発生しました: $e');
    }
  }
  /// プレビューデータを生成
  List<CSVPreviewRow> _generatePreview(List<List<dynamic>> dataRows, CSVFormat? format) {
    final preview = <CSVPreviewRow>[];
    
    // 最初の10行をプレビューとして使用
    final previewRows = dataRows.take(10);
    
    for (final row in previewRows) {
      if (row.isEmpty) continue;
      
      try {
        // フォーマットが指定されている場合の処理
        if (format != null) {
          final dateIndex = format.dateColumn;
          final amountIndex = format.amountColumn;
          final descIndex = format.descriptionColumn;
          
          // インデックスが範囲内かチェック
          if (row.length > dateIndex && row.length > amountIndex && row.length > descIndex) {
            final previewRow = CSVPreviewRow(
              rawData: row,
              parsedDate: _parseDate(row[dateIndex].toString(), format.dateFormat),
              parsedAmount: _parseAmount(row[amountIndex].toString()),
              parsedDescription: row[descIndex].toString().trim(),
              suggestedCategory: _suggestCategory(row[descIndex].toString()),
            );
            preview.add(previewRow);
          } else {
            // データが不十分な場合でも生データとして追加
            final previewRow = CSVPreviewRow(
              rawData: row,
              parsedDate: null,
              parsedAmount: null,
              parsedDescription: row.isNotEmpty ? row.join(', ') : '',
              suggestedCategory: null,
            );
            preview.add(previewRow);
          }
        } else {
          // フォーマット未指定の場合は生データのみ
          final previewRow = CSVPreviewRow(
            rawData: row,
            parsedDate: null,
            parsedAmount: null,
            parsedDescription: row.join(', '),
            suggestedCategory: null,
          );
          preview.add(previewRow);
        }
      } catch (e) {
        // パースエラーの場合でも生データとして追加
        final previewRow = CSVPreviewRow(
          rawData: row,
          parsedDate: null,
          parsedAmount: null,
          parsedDescription: 'パースエラー: ${row.join(', ')}',
          suggestedCategory: null,
        );
        preview.add(previewRow);
      }
    }
    
    return preview;
  }
  /// ファイル名からフォーマットを推定
  CSVFormat? _detectFormat(String fileName) {
    // sample.csvの場合は三井住友カードフォーマットをデフォルトとする
    if (fileName.contains('sample')) {
      return supportedFormats['smbc'];
    }
    
    for (final entry in supportedFormats.entries) {
      if (fileName.contains(entry.key) || fileName.contains(entry.value.name)) {
        return entry.value;
      }
    }
    
    // 自動検出できない場合はデフォルトで三井住友カードフォーマットを返す
    return supportedFormats['smbc'];
  }

  /// 日付をパース
  DateTime? _parseDate(String dateStr, String format) {
    try {
      // 簡単な日付パース（実際にはintlパッケージを使用する方が良い）
      dateStr = dateStr.trim();
      
      if (format == 'yyyy/MM/dd') {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }
      } else if (format == 'yyyy-MM-dd') {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }
      } else if (format == 'MM/dd/yyyy') {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 金額をパース
  double? _parseAmount(String amountStr) {
    try {
      // カンマや円マークを除去
      final cleanAmount = amountStr.replaceAll(RegExp(r'[,¥￥円]'), '').trim();
      return double.parse(cleanAmount);
    } catch (e) {
      return null;
    }
  }
  /// 店舗名からカテゴリを推定
  ExpenseCategory _suggestCategory(String description) {
    final desc = description.toLowerCase();
    
    // カテゴリ推定ロジック
    if (desc.contains('コンビニ') || desc.contains('セブン') || desc.contains('ローソン') || desc.contains('ファミマ')) {
      return ExpenseCategory.food;
    } else if (desc.contains('スーパー') || desc.contains('イオン') || desc.contains('西友')) {
      return ExpenseCategory.shopping;
    } else if (desc.contains('ガソリン') || desc.contains('ガス') || desc.contains('esso') || desc.contains('shell')) {
      return ExpenseCategory.transportation;
    } else if (desc.contains('電気') || desc.contains('ガス') || desc.contains('水道')) {
      return ExpenseCategory.utilities;
    } else if (desc.contains('病院') || desc.contains('薬局') || desc.contains('ドラッグ')) {
      return ExpenseCategory.health;
    } else if (desc.contains('服') || desc.contains('ユニクロ') || desc.contains('しまむら')) {
      return ExpenseCategory.shopping;
    } else if (desc.contains('映画') || desc.contains('カラオケ') || desc.contains('遊園地')) {
      return ExpenseCategory.entertainment;
    } else {
      return ExpenseCategory.other;
    }
  }  /// プレビューデータを実際の支出データに変換
  Future<List<Expense>> convertToExpenses(CSVImportResult importResult, CSVFormat selectedFormat) async {
    final expenses = <Expense>[];
    
    try {
      print('CSV Import: データ変換開始、フォーマット = ${selectedFormat.name}');
      
      // ファイルを再読み込み
      String content;
      try {
        content = await importResult.file.readAsString(encoding: utf8);
      } catch (e) {
        final bytes = await importResult.file.readAsBytes();
        content = String.fromCharCodes(bytes);
      }
      
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(content);
      final dataRows = csvData.skip(1).toList();
      print('CSV Import: 変換対象行数 = ${dataRows.length}');
      
      for (int i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];
        if (row.length <= selectedFormat.descriptionColumn || 
            row.length <= selectedFormat.amountColumn ||
            row.length <= selectedFormat.dateColumn) {
          print('CSV Import: 行${i + 1}をスキップ（データ不足）');
          continue;
        }
        
        try {
          final dateStr = row[selectedFormat.dateColumn].toString().trim();
          final amountStr = row[selectedFormat.amountColumn].toString().trim();
          final descriptionStr = row[selectedFormat.descriptionColumn].toString().trim();
          
          print('CSV Import: 行${i + 1} - 日付: $dateStr, 金額: $amountStr, 説明: $descriptionStr');
          
          if (dateStr.isEmpty || amountStr.isEmpty || descriptionStr.isEmpty) {
            print('CSV Import: 行${i + 1}をスキップ（空データ）');
            continue;
          }
          
          final date = _parseDate(dateStr, selectedFormat.dateFormat);
          final amount = _parseAmount(amountStr);
          
          print('CSV Import: 行${i + 1} - パース結果 - 日付: $date, 金額: $amount');
          
          if (date != null && amount != null && amount > 0) {
            final category = _suggestCategory(descriptionStr);
            final expense = Expense(
              amount: amount,
              date: date,
              category: category,
              note: descriptionStr,
            );
            expenses.add(expense);
            print('CSV Import: 行${i + 1} - 支出追加成功、カテゴリ: $category');
          } else {
            print('CSV Import: 行${i + 1}をスキップ（パースエラー）');
          }
        } catch (e) {
          print('CSV Import: 行${i + 1}で例外発生: $e');
          continue;
        }
      }
      
      print('CSV Import: 変換完了、${expenses.length}件の支出データを生成');
      return expenses;
    } catch (e) {
      print('CSV Import: データ変換エラー: $e');
      throw CSVImportException('データ変換中にエラーが発生しました: $e');
    }
  }

  /// 重複チェック
  Future<List<Expense>> checkDuplicates(List<Expense> newExpenses, List<Expense> existingExpenses) async {
    final duplicates = <Expense>[];
    
    for (final newExpense in newExpenses) {
      for (final existing in existingExpenses) {
        // 日付、金額、説明が一致する場合は重複とみなす
        if (_isSameDate(newExpense.date, existing.date) &&
            (newExpense.amount - existing.amount).abs() < 0.01 &&
            newExpense.note?.toLowerCase() == existing.note?.toLowerCase()) {
          duplicates.add(newExpense);
          break;
        }
      }
    }
    
    return duplicates;
  }
  
  /// 日付が同じかチェック（時刻は無視）
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
}

/// CSVフォーマット定義
class CSVFormat {
  final String name;
  final int dateColumn;
  final int amountColumn;
  final int descriptionColumn;
  final String dateFormat;
  final String encoding;

  const CSVFormat({
    required this.name,
    required this.dateColumn,
    required this.amountColumn,
    required this.descriptionColumn,
    required this.dateFormat,
    required this.encoding,
  });
}

/// CSVインポート結果
class CSVImportResult {
  final File file;
  final CSVFormat? detectedFormat;
  final List<CSVPreviewRow> previewData;
  final int totalRows;

  CSVImportResult({
    required this.file,
    required this.detectedFormat,
    required this.previewData,
    required this.totalRows,
  });
}

/// CSVプレビュー行
class CSVPreviewRow {
  final List<dynamic> rawData;
  final DateTime? parsedDate;
  final double? parsedAmount;
  final String? parsedDescription;
  final ExpenseCategory? suggestedCategory;

  CSVPreviewRow({
    required this.rawData,
    this.parsedDate,
    this.parsedAmount,
    this.parsedDescription,
    this.suggestedCategory,
  });
}

/// CSVインポート例外
class CSVImportException implements Exception {
  final String message;
  CSVImportException(this.message);
  
  @override
  String toString() => 'CSVImportException: $message';
}
