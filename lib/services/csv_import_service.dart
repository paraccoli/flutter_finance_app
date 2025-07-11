import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../models/expense.dart';
import '../models/income.dart';

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
    'moneyg_legacy_expenses': CSVFormat(
      name: 'MoneyG v1.2.2 支出形式',
      dateColumn: 0,
      amountColumn: 2,
      descriptionColumn: 3,
      dateFormat: 'yyyy/MM/dd',
      encoding: 'utf-8',
      categoryColumn: 1,
      dataType: 'expense',
    ),
    'moneyg_legacy_incomes': CSVFormat(
      name: 'MoneyG v1.2.2 収入形式',
      dateColumn: 0,
      amountColumn: 2,
      descriptionColumn: 3,
      dateFormat: 'yyyy/MM/dd',
      encoding: 'utf-8',
      categoryColumn: 1,
      dataType: 'income',
    ),
    'moneyg_legacy_all': CSVFormat(
      name: 'MoneyG v1.2.2 全データ形式',
      dateColumn: 0,
      amountColumn: 3,
      descriptionColumn: 4,
      dateFormat: 'yyyy/MM/dd',
      encoding: 'utf-8',
      categoryColumn: 2,
      typeColumn: 1,
      dataType: 'both',
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
    try {      // ファイル名からフォーマットを推定
      final fileName = path.basenameWithoutExtension(file.path).toLowerCase();
      if (kDebugMode) {
        debugPrint('CSV Import: ファイル名 = $fileName');
      }
      CSVFormat? detectedFormat = _detectFormat(fileName);
      bool isMoneyGFormat = false;
      if (kDebugMode) {
        debugPrint('CSV Import: 検出フォーマット = ${detectedFormat?.name}');
      }

      // ファイル内容を読み込み（複数のエンコーディングを試行）
      String content;
      try {
        // まずUTF-8で試行
        content = await file.readAsString(encoding: utf8);
        if (kDebugMode) {
          debugPrint('CSV Import: UTF-8で読み込み成功');
        }      } catch (e) {
        try {
          // UTF-8で失敗した場合はShift_JISを試行
          final bytes = await file.readAsBytes();
          content = String.fromCharCodes(bytes);
          if (kDebugMode) {
            debugPrint('CSV Import: バイト配列として読み込み成功');
          }
        } catch (e) {
          throw CSVImportException('ファイルのエンコーディングが認識できません');
        }      }
      
      if (kDebugMode) {
        debugPrint('CSV Import: コンテンツの最初の100文字 = ${content.length > 100 ? content.substring(0, 100) : content}');
      }
      
      // CSVをパース
      List<List<dynamic>> csvData;
      try {
        csvData = const CsvToListConverter().convert(content);
        if (kDebugMode) {
          debugPrint('CSV Import: CSVパース成功、${csvData.length}行検出');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('CSV Import: CSVパースエラー = $e');
        }
        throw CSVImportException('CSVファイルの形式が正しくありません');
      }
      
      if (csvData.isEmpty) {
        throw CSVImportException('CSVファイルが空です');
      }
      
      // MoneyG形式の検出
      if (csvData.isNotEmpty && csvData[0].isNotEmpty) {
        final headerRow = csvData[0];
        final header = headerRow.join(',').toLowerCase();
        
        if (kDebugMode) {
          debugPrint('CSV Import: ヘッダー行 = $headerRow');
          debugPrint('CSV Import: ヘッダー文字列 = $header');
        }
        
        // 全データ形式（v1.2.2以前）- 5列構成をチェック
        if (headerRow.length >= 5 && 
            headerRow[0].toString().trim() == '日付' &&
            headerRow[1].toString().trim() == 'タイプ' &&
            headerRow[2].toString().trim() == 'カテゴリ' &&
            headerRow[3].toString().trim() == '金額' &&
            headerRow[4].toString().trim() == 'メモ') {
          detectedFormat = supportedFormats['moneyg_legacy_all'];
          isMoneyGFormat = false;
          if (kDebugMode) {
            debugPrint('CSV Import: MoneyG v1.2.2 全データ形式として確定');
            debugPrint('CSV Import: 検出フォーマット = ${detectedFormat?.name}');
          }
        }
        // 支出のみ・収入のみ形式（v1.2.2以前）- 4列構成をチェック
        else if (headerRow.length >= 4 && 
            headerRow[0].toString().trim() == '日付' &&
            headerRow[1].toString().trim() == 'カテゴリ' &&
            headerRow[2].toString().trim() == '金額' &&
            headerRow[3].toString().trim() == 'メモ') {
          // ファイル名で支出か収入かを判定
          if (fileName.contains('expenses')) {
            detectedFormat = supportedFormats['moneyg_legacy_expenses'];
          } else if (fileName.contains('incomes')) {
            detectedFormat = supportedFormats['moneyg_legacy_incomes'];
          } else {
            // ファイル名で判定できない場合はデフォルトで支出とする
            detectedFormat = supportedFormats['moneyg_legacy_expenses'];
          }
          isMoneyGFormat = false;
          if (kDebugMode) {
            debugPrint('CSV Import: MoneyG v1.2.2 ${detectedFormat?.dataType == 'income' ? '収入' : '支出'}形式として確定');
            debugPrint('CSV Import: 検出フォーマット = ${detectedFormat?.name}');
          }
        }
        // 新しいMoneyG形式（v1.3.1以降）
        else if (header.contains('type') && header.contains('category') && 
            (fileName.contains('moneyg') || fileName.contains('export'))) {
          isMoneyGFormat = true;
          detectedFormat = null; // MoneyG形式の場合は独自処理
          if (kDebugMode) {
            debugPrint('CSV Import: MoneyG v1.3.1+形式として検出');
          }
        }
      }      // ヘッダー行をスキップ（通常は最初の行）
      final dataRows = csvData.skip(1).toList();
      if (kDebugMode) {
        debugPrint('CSV Import: データ行数 = ${dataRows.length}');
      }
      
      if (dataRows.isEmpty) {
        throw CSVImportException('データ行が見つかりません');
      }
      
      // データを解析してプレビューを生成
      final previewData = _generatePreview(dataRows, detectedFormat, isMoneyGFormat);
      if (kDebugMode) {
        debugPrint('CSV Import: プレビューデータ生成完了、${previewData.length}行');
      }
      
      return CSVImportResult(
        file: file,
        detectedFormat: detectedFormat,
        previewData: previewData,
        totalRows: dataRows.length,
        isMoneyGFormat: isMoneyGFormat,
      );    } catch (e) {
      if (kDebugMode) {
        debugPrint('CSV Import: エラー発生 = $e');
      }
      if (e is CSVImportException) {
        rethrow;
      }
      throw CSVImportException('CSVファイルの読み込み中にエラーが発生しました: $e');
    }
  }
  /// プレビューデータを生成
  List<CSVPreviewRow> _generatePreview(List<List<dynamic>> dataRows, CSVFormat? format, [bool isMoneyGFormat = false]) {
    final preview = <CSVPreviewRow>[];
    
    // 最初の10行をプレビューとして使用
    final previewRows = dataRows.take(10);
    
    for (final row in previewRows) {
      if (row.isEmpty) continue;
      
      try {
        // MoneyG形式の処理
        if (isMoneyGFormat) {
          if (row.length >= 6) { // type, categoryType, categoryId, categoryName, amount, note
            final type = row[0].toString().trim();
            final amount = _parseAmount(row[4].toString());
            final note = row[5].toString().trim();
            final categoryName = row[3].toString().trim();
            
            final previewRow = CSVPreviewRow(
              rawData: row,
              parsedDate: null, // MoneyG形式では日付が含まれる場合があるが、基本的にはプレビューではスキップ
              parsedAmount: amount,
              parsedDescription: '$type: $note ($categoryName)',
              suggestedCategory: type == '支出' ? _suggestCategory(note) : null,
            );
            preview.add(previewRow);
          } else {
            final previewRow = CSVPreviewRow(
              rawData: row,
              parsedDate: null,
              parsedAmount: null,
              parsedDescription: row.join(', '),
              suggestedCategory: null,
            );
            preview.add(previewRow);
          }
        }
        // フォーマットが指定されている場合の処理
        else if (format != null) {
          final dateIndex = format.dateColumn;
          final amountIndex = format.amountColumn;
          final descIndex = format.descriptionColumn;
          final categoryIndex = format.categoryColumn;
          final typeIndex = format.typeColumn;
          
          // インデックスが範囲内かチェック
          if (row.length > dateIndex && row.length > amountIndex && row.length > descIndex) {
            String description = row[descIndex].toString().trim();
            ExpenseCategory? suggestedCategory;
            String? dataTypeInfo;
            
            // 全データ形式の場合、タイプ列もチェック
            if (format.dataType == 'both' && typeIndex != null && row.length > typeIndex) {
              final typeStr = row[typeIndex].toString().trim();
              dataTypeInfo = typeStr;
              description = '$typeStr: $description';
            }
            
            // MoneyG v1.2.2形式の場合、カテゴリ列から直接カテゴリを取得
            if (format.name.contains('MoneyG v1.2.2') && categoryIndex != null && row.length > categoryIndex) {
              final categoryName = row[categoryIndex].toString().trim();
              // 支出のみまたは全データで支出の場合のみカテゴリ推定
              if (format.dataType == 'expense' || (format.dataType == 'both' && dataTypeInfo == '支出')) {
                suggestedCategory = _mapCategoryNameToExpenseCategory(categoryName);
              }
              description = description.isEmpty ? categoryName : description;
              if (kDebugMode) {
                debugPrint('CSV Import Preview: フォーマット = ${format.name}');
                debugPrint('CSV Import Preview: カテゴリインデックス = $categoryIndex');
                debugPrint('CSV Import Preview: カテゴリ名: "$categoryName" → $suggestedCategory');
              }
            } else {
              suggestedCategory = _suggestCategory(description);
            }
            
            final previewRow = CSVPreviewRow(
              rawData: row,
              parsedDate: _parseDate(row[dateIndex].toString(), format.dateFormat),
              parsedAmount: _parseAmount(row[amountIndex].toString()),
              parsedDescription: description,
              suggestedCategory: suggestedCategory,
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
    if (kDebugMode) {
      debugPrint('CSV Import: ファイル名検出開始: $fileName');
    }
    
    // MoneyG v1.2.2形式の検出
    if (fileName.contains('all_data')) {
      if (kDebugMode) {
        debugPrint('CSV Import: ファイル名検出でMoneyG v1.2.2 全データ形式として認識: $fileName');
      }
      return supportedFormats['moneyg_legacy_all'];
    } else if (fileName.contains('expenses')) {
      if (kDebugMode) {
        debugPrint('CSV Import: ファイル名検出でMoneyG v1.2.2 支出形式として認識: $fileName');
      }
      return supportedFormats['moneyg_legacy_expenses'];
    } else if (fileName.contains('incomes')) {
      if (kDebugMode) {
        debugPrint('CSV Import: ファイル名検出でMoneyG v1.2.2 収入形式として認識: $fileName');
      }
      return supportedFormats['moneyg_legacy_incomes'];
    }
    
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
  Future<List<Expense>> convertToExpenses(CSVImportResult importResult, CSVFormat? selectedFormat) async {
    if (importResult.isMoneyGFormat) {
      return await _convertMoneyGFormatToExpenses(importResult);
    }
    
    return await _convertStandardFormatToExpenses(importResult, selectedFormat!);
  }

  /// プレビューデータを実際の収入データに変換
  Future<List<Income>> convertToIncomes(CSVImportResult importResult) async {
    if (importResult.isMoneyGFormat) {
      return await _convertMoneyGFormatToIncomes(importResult);
    }
    
    // MoneyG v1.2.2形式の場合
    if (importResult.detectedFormat != null) {
      return await _convertStandardFormatToIncomes(importResult, importResult.detectedFormat!);
    }
    
    throw CSVImportException('収入データのインポートに対応していない形式です');
  }

  /// MoneyG形式から支出と収入両方をインポート
  Future<ImportResultData> convertToAll(CSVImportResult importResult) async {
    List<Expense> expenses = [];
    List<Income> incomes = [];
    
    if (importResult.isMoneyGFormat) {
      // 新しいMoneyG形式（v1.3.1以降）
      expenses = await _convertMoneyGFormatToExpenses(importResult);
      incomes = await _convertMoneyGFormatToIncomes(importResult);
    } else if (importResult.detectedFormat?.dataType == 'both') {
      // MoneyG v1.2.2全データ形式
      expenses = await _convertStandardFormatToExpenses(importResult, importResult.detectedFormat!);
      incomes = await _convertStandardFormatToIncomes(importResult, importResult.detectedFormat!);
    } else {
      throw CSVImportException('両方のデータのインポートは対応していない形式です');
    }

    return ImportResultData(
      expenses: expenses,
      incomes: incomes,
    );
  }

  /// MoneyG形式から支出データに変換
  Future<List<Expense>> _convertMoneyGFormatToExpenses(CSVImportResult importResult) async {
    final expenses = <Expense>[];
    
    try {
      if (kDebugMode) {
        debugPrint('CSV Import: MoneyG形式から支出データ変換開始');
      }
      
      // ファイルを再読み込み
      String content;
      try {
        content = await importResult.file.readAsString(encoding: utf8);
      } catch (e) {
        final bytes = await importResult.file.readAsBytes();
        content = String.fromCharCodes(bytes);
      }
      
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(content);
      final dataRows = csvData.skip(1).toList(); // ヘッダーをスキップ
      
      for (int i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];
        if (row.length < 6) continue; // 必要な列数をチェック
        
        try {
          final type = row[0].toString().trim();
          if (type != '支出') continue; // 支出のみ処理
          
          final categoryType = row[1].toString().trim();
          final categoryIdStr = row[2].toString().trim();
          final categoryName = row[3].toString().trim();
          final amountStr = row[4].toString().trim();
          final note = row[5].toString().trim();
          final dateStr = row.length > 6 ? row[6].toString().trim() : '';
          
          final amount = _parseAmount(amountStr);
          if (amount == null || amount <= 0) continue;
          
          DateTime date = DateTime.now();
          if (dateStr.isNotEmpty) {
            final parsedDate = _parseDate(dateStr, 'yyyy-MM-dd');
            if (parsedDate != null) {
              date = parsedDate;
            }
          }
          
          // カテゴリ解決
          ExpenseCategory category = ExpenseCategory.other;
          int? customCategoryId;
          
          if (categoryType == 'custom' && categoryIdStr.isNotEmpty) {
            customCategoryId = int.tryParse(categoryIdStr);
          } else if (categoryType == 'legacy') {
            // レガシーカテゴリの場合、名前からカテゴリを特定
            category = _mapCategoryNameToExpenseCategory(categoryName);
          }
          
          final expense = Expense(
            amount: amount,
            date: date,
            category: category,
            note: note,
            customCategoryId: customCategoryId,
          );
          expenses.add(expense);
          
        } catch (e) {
          if (kDebugMode) {
            debugPrint('CSV Import: MoneyG行${i + 1}で例外発生: $e');
          }
          continue;
        }
      }
      
      if (kDebugMode) {
        debugPrint('CSV Import: MoneyG形式変換完了、${expenses.length}件の支出データを生成');
      }
      return expenses;
    } catch (e) {
      throw CSVImportException('MoneyG形式データ変換中にエラーが発生しました: $e');
    }
  }

  /// MoneyG形式から収入データに変換
  Future<List<Income>> _convertMoneyGFormatToIncomes(CSVImportResult importResult) async {
    final incomes = <Income>[];
    
    try {
      if (kDebugMode) {
        debugPrint('CSV Import: MoneyG形式から収入データ変換開始');
      }
      
      // ファイルを再読み込み
      String content;
      try {
        content = await importResult.file.readAsString(encoding: utf8);
      } catch (e) {
        final bytes = await importResult.file.readAsBytes();
        content = String.fromCharCodes(bytes);
      }
      
      final List<List<dynamic>> csvData = const CsvToListConverter().convert(content);
      final dataRows = csvData.skip(1).toList(); // ヘッダーをスキップ
      
      for (int i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];
        if (row.length < 6) continue; // 必要な列数をチェック
        
        try {
          final type = row[0].toString().trim();
          if (type != '収入') continue; // 収入のみ処理
          
          final categoryType = row[1].toString().trim();
          final categoryIdStr = row[2].toString().trim();
          final categoryName = row[3].toString().trim();
          final amountStr = row[4].toString().trim();
          final note = row[5].toString().trim();
          final dateStr = row.length > 6 ? row[6].toString().trim() : '';
          
          final amount = _parseAmount(amountStr);
          if (amount == null || amount <= 0) continue;
          
          DateTime date = DateTime.now();
          if (dateStr.isNotEmpty) {
            final parsedDate = _parseDate(dateStr, 'yyyy-MM-dd');
            if (parsedDate != null) {
              date = parsedDate;
            }
          }
          
          // カテゴリ解決
          IncomeCategory category = IncomeCategory.other;
          int? customCategoryId;
          
          if (categoryType == 'custom' && categoryIdStr.isNotEmpty) {
            customCategoryId = int.tryParse(categoryIdStr);
          } else if (categoryType == 'legacy') {
            // レガシーカテゴリの場合、名前からカテゴリを特定
            category = _mapCategoryNameToIncomeCategory(categoryName);
          }
          
          final income = Income(
            amount: amount,
            date: date,
            category: category,
            note: note,
            customCategoryId: customCategoryId,
          );
          incomes.add(income);
          
        } catch (e) {
          if (kDebugMode) {
            debugPrint('CSV Import: MoneyG収入行${i + 1}で例外発生: $e');
          }
          continue;
        }
      }
      
      if (kDebugMode) {
        debugPrint('CSV Import: MoneyG形式収入変換完了、${incomes.length}件の収入データを生成');
      }
      return incomes;
    } catch (e) {
      throw CSVImportException('MoneyG形式収入データ変換中にエラーが発生しました: $e');
    }
  }

  /// 標準形式から支出データに変換
  Future<List<Expense>> _convertStandardFormatToExpenses(CSVImportResult importResult, CSVFormat selectedFormat) async {
    final expenses = <Expense>[];
    
    try {
      if (kDebugMode) {
        debugPrint('CSV Import: データ変換開始、フォーマット = ${selectedFormat.name}');
      }
      
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
      if (kDebugMode) {
        debugPrint('CSV Import: 変換対象行数 = ${dataRows.length}');
      }
        for (int i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];
        if (row.length <= selectedFormat.descriptionColumn || 
            row.length <= selectedFormat.amountColumn ||
            row.length <= selectedFormat.dateColumn) {
          if (kDebugMode) {
            debugPrint('CSV Import: 行${i + 1}をスキップ（データ不足）');
          }
          continue;
        }
        
        try {
          final dateStr = row[selectedFormat.dateColumn].toString().trim();
          final amountStr = row[selectedFormat.amountColumn].toString().trim();
          final descriptionStr = row[selectedFormat.descriptionColumn].toString().trim();
          
          if (kDebugMode) {
            debugPrint('CSV Import: 行${i + 1} - 日付: $dateStr, 金額: $amountStr, 説明: $descriptionStr');
          }
          
          if (dateStr.isEmpty || amountStr.isEmpty) {
            if (kDebugMode) {
              debugPrint('CSV Import: 行${i + 1}をスキップ（空データ）');
            }
            continue;
          }
          
          final date = _parseDate(dateStr, selectedFormat.dateFormat);
          final amount = _parseAmount(amountStr);
          
          if (kDebugMode) {
            debugPrint('CSV Import: 行${i + 1} - パース結果 - 日付: $date, 金額: $amount');
          }
          
          if (date != null && amount != null) {
            ExpenseCategory category = ExpenseCategory.other;
            
            // 全データ形式の場合、タイプをチェックして支出のみ処理
            if (selectedFormat.dataType == 'both' && selectedFormat.typeColumn != null && 
                row.length > selectedFormat.typeColumn!) {
              final typeStr = row[selectedFormat.typeColumn!].toString().trim();
              if (typeStr != '支出') {
                if (kDebugMode) {
                  debugPrint('CSV Import: 行${i + 1} - 支出ではないためスキップ（タイプ: $typeStr）');
                }
                continue; // 収入データなのでスキップ
              }
              // 全データ形式の支出データは通常負の値なので、金額チェックをスキップ
            } else if (amount <= 0) {
              // 全データ形式以外では正の値が期待される
              if (kDebugMode) {
                debugPrint('CSV Import: 行${i + 1} - 金額が0以下のためスキップ（金額: $amount）');
              }
              continue;
            }
            // 収入形式の場合はスキップ
            else if (selectedFormat.dataType == 'income') {
              if (kDebugMode) {
                debugPrint('CSV Import: 行${i + 1} - 収入形式のためスキップ');
              }
              continue;
            }
            
            // MoneyG v1.2.2形式の場合、カテゴリ列から直接カテゴリを取得
            if (selectedFormat.name.contains('MoneyG v1.2.2') && 
                selectedFormat.categoryColumn != null && 
                row.length > selectedFormat.categoryColumn!) {
              final categoryName = row[selectedFormat.categoryColumn!].toString().trim();
              category = _mapCategoryNameToExpenseCategory(categoryName);
              if (kDebugMode) {
                debugPrint('CSV Import: 行${i + 1} - フォーマット: ${selectedFormat.name}');
                debugPrint('CSV Import: 行${i + 1} - カテゴリ列インデックス: ${selectedFormat.categoryColumn}');
                debugPrint('CSV Import: 行${i + 1} - 行データ: $row');
                debugPrint('CSV Import: 行${i + 1} - カテゴリ名: "$categoryName" → $category');
              }
            } else {
              category = _suggestCategory(descriptionStr);
              if (kDebugMode) {
                debugPrint('CSV Import: 行${i + 1} - カテゴリ推定（説明ベース）: "$descriptionStr" → $category');
              }
            }
            
            // 金額が負の場合は正の値に変換（全データ形式では支出が負の値）
            final finalAmount = amount < 0 ? -amount : amount;
            
            final expense = Expense(
              amount: finalAmount,
              date: date,
              category: category,
              note: descriptionStr.isEmpty ? null : descriptionStr,
            );
            expenses.add(expense);
            if (kDebugMode) {
              debugPrint('CSV Import: 行${i + 1} - 支出追加成功、カテゴリ: $category, 金額: $finalAmount');
            }
          } else {
            if (kDebugMode) {
              debugPrint('CSV Import: 行${i + 1}をスキップ（パースエラー）');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('CSV Import: 行${i + 1}で例外発生: $e');
          }
          continue;
        }
      }
      
      if (kDebugMode) {
        debugPrint('CSV Import: 変換完了、${expenses.length}件の支出データを生成');
      }
      return expenses;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CSV Import: データ変換エラー: $e');
      }
      throw CSVImportException('データ変換中にエラーが発生しました: $e');
    }
  }

  /// 標準形式から収入データに変換（MoneyG v1.2.2形式対応）
  Future<List<Income>> _convertStandardFormatToIncomes(CSVImportResult importResult, CSVFormat selectedFormat) async {
    final incomes = <Income>[];
    
    try {
      if (kDebugMode) {
        debugPrint('CSV Import: 収入データ変換開始、フォーマット = ${selectedFormat.name}');
      }
      
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
      if (kDebugMode) {
        debugPrint('CSV Import: 収入変換対象行数 = ${dataRows.length}');
      }
      
      for (int i = 0; i < dataRows.length; i++) {
        final row = dataRows[i];
        if (row.length <= selectedFormat.descriptionColumn || 
            row.length <= selectedFormat.amountColumn ||
            row.length <= selectedFormat.dateColumn) {
          if (kDebugMode) {
            debugPrint('CSV Import: 行${i + 1}をスキップ（データ不足）');
          }
          continue;
        }
        
        try {
          final dateStr = row[selectedFormat.dateColumn].toString().trim();
          final amountStr = row[selectedFormat.amountColumn].toString().trim();
          final descriptionStr = row[selectedFormat.descriptionColumn].toString().trim();
          
          if (kDebugMode) {
            debugPrint('CSV Import: 行${i + 1} - 日付: $dateStr, 金額: $amountStr, 説明: $descriptionStr');
          }
          
          if (dateStr.isEmpty || amountStr.isEmpty) {
            if (kDebugMode) {
              debugPrint('CSV Import: 行${i + 1}をスキップ（空データ）');
            }
            continue;
          }
          
          final date = _parseDate(dateStr, selectedFormat.dateFormat);
          final amount = _parseAmount(amountStr);
          
          if (kDebugMode) {
            debugPrint('CSV Import: 行${i + 1} - パース結果 - 日付: $date, 金額: $amount');
          }
          
          if (date != null && amount != null) {
            IncomeCategory category = IncomeCategory.other;
            
            // 全データ形式の場合、タイプをチェックして収入のみ処理
            if (selectedFormat.dataType == 'both' && selectedFormat.typeColumn != null && 
                row.length > selectedFormat.typeColumn!) {
              final typeStr = row[selectedFormat.typeColumn!].toString().trim();
              if (typeStr != '収入') {
                if (kDebugMode) {
                  debugPrint('CSV Import: 行${i + 1} - 収入ではないためスキップ（タイプ: $typeStr）');
                }
                continue; // 支出データなのでスキップ
              }
              // 全データ形式の収入データは通常正の値だが、絶対値で処理
            } else if (amount <= 0) {
              // 全データ形式以外では正の値が期待される
              if (kDebugMode) {
                debugPrint('CSV Import: 行${i + 1} - 金額が0以下のためスキップ（金額: $amount）');
              }
              continue;
            }
            // 支出形式の場合はスキップ
            else if (selectedFormat.dataType == 'expense') {
              if (kDebugMode) {
                debugPrint('CSV Import: 行${i + 1} - 支出形式のためスキップ');
              }
              continue;
            }
            
            // MoneyG v1.2.2形式の場合、カテゴリ列から直接カテゴリを取得
            if (selectedFormat.name.contains('MoneyG v1.2.2') && 
                selectedFormat.categoryColumn != null && 
                row.length > selectedFormat.categoryColumn!) {
              final categoryName = row[selectedFormat.categoryColumn!].toString().trim();
              category = _mapCategoryNameToIncomeCategory(categoryName);
              if (kDebugMode) {
                debugPrint('CSV Import: 行${i + 1} - フォーマット: ${selectedFormat.name}');
                debugPrint('CSV Import: 行${i + 1} - カテゴリ列インデックス: ${selectedFormat.categoryColumn}');
                debugPrint('CSV Import: 行${i + 1} - 行データ: $row');
                debugPrint('CSV Import: 行${i + 1} - カテゴリ名: "$categoryName" → $category');
              }
            }
            
            // 金額は正の値として扱う（全データ形式で負の場合は正に変換）
            final finalAmount = amount < 0 ? -amount : amount;
            
            final income = Income(
              amount: finalAmount,
              date: date,
              category: category,
              note: descriptionStr.isEmpty ? null : descriptionStr,
            );
            incomes.add(income);
            if (kDebugMode) {
              debugPrint('CSV Import: 行${i + 1} - 収入追加成功、カテゴリ: $category, 金額: $finalAmount');
            }
          } else {
            if (kDebugMode) {
              debugPrint('CSV Import: 行${i + 1}をスキップ（パースエラー）');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('CSV Import: 行${i + 1}で例外発生: $e');
          }
          continue;
        }
      }
      
      if (kDebugMode) {
        debugPrint('CSV Import: 収入変換完了、${incomes.length}件の収入データを生成');
      }
      return incomes;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CSV Import: 収入データ変換エラー: $e');
      }
      throw CSVImportException('収入データ変換中にエラーが発生しました: $e');
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

  /// カテゴリ名から支出カテゴリにマッピング
  ExpenseCategory _mapCategoryNameToExpenseCategory(String categoryName) {
    if (kDebugMode) {
      debugPrint('CSV Import: カテゴリマッピング開始 - 入力: "$categoryName"');
    }
    
    final result = switch (categoryName) {
      '食費' => ExpenseCategory.food,
      '日用品' || '買い物' => ExpenseCategory.shopping,
      '交通費' => ExpenseCategory.transportation,
      '光熱費' => ExpenseCategory.utilities,
      '医療・健康' || '健康・医療' => ExpenseCategory.health,
      '教育' => ExpenseCategory.education,
      '娯楽' => ExpenseCategory.entertainment,
      '家賃' || 'その他' || _ => ExpenseCategory.other,
    };
    
    if (kDebugMode) {
      debugPrint('CSV Import: カテゴリマッピング結果 - "$categoryName" → $result');
    }
    
    return result;
  }

  /// カテゴリ名から収入カテゴリにマッピング
  IncomeCategory _mapCategoryNameToIncomeCategory(String categoryName) {
    if (kDebugMode) {
      debugPrint('CSV Import: 収入カテゴリマッピング開始 - 入力: "$categoryName"');
    }
    
    final result = switch (categoryName) {
      '給与' => IncomeCategory.salary,
      'ボーナス' => IncomeCategory.bonus,
      '副業' => IncomeCategory.sideJob,
      '投資収入' || '投資' => IncomeCategory.investment,
      '贈与・臨時収入' || 'ギフト' => IncomeCategory.gift,
      'その他' || _ => IncomeCategory.other,
    };
    
    if (kDebugMode) {
      debugPrint('CSV Import: 収入カテゴリマッピング結果 - "$categoryName" → $result');
    }
    
    return result;
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
  final int? categoryColumn; // カテゴリ列（オプション）
  final int? typeColumn; // タイプ列（全データ形式用）
  final String? dataType; // データタイプ ('expense', 'income', 'both')

  const CSVFormat({
    required this.name,
    required this.dateColumn,
    required this.amountColumn,
    required this.descriptionColumn,
    required this.dateFormat,
    required this.encoding,
    this.categoryColumn,
    this.typeColumn,
    this.dataType,
  });
}

/// CSVインポート結果
class CSVImportResult {
  final File file;
  final CSVFormat? detectedFormat;
  final List<CSVPreviewRow> previewData;
  final int totalRows;
  final bool isMoneyGFormat;

  CSVImportResult({
    required this.file,
    required this.detectedFormat,
    required this.previewData,
    required this.totalRows,
    this.isMoneyGFormat = false,
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

/// インポート対象の種類
enum ImportDataType {
  expense('支出'),
  income('収入'),
  both('両方');

  const ImportDataType(this.displayName);
  final String displayName;
}

/// インポート結果の統計
class ImportStats {
  final int expenseCount;
  final int incomeCount;
  final int totalCount;

  ImportStats({
    this.expenseCount = 0,
    this.incomeCount = 0,
  }) : totalCount = expenseCount + incomeCount;
}

/// 両方のデータ型を含むインポート結果
class ImportResultData {
  final List<Expense> expenses;
  final List<Income> incomes;
  final ImportStats stats;

  ImportResultData({
    this.expenses = const [],
    this.incomes = const [],
  }) : stats = ImportStats(
         expenseCount: expenses.length,
         incomeCount: incomes.length,
       );
}
