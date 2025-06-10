import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/nisa_investment.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  // シングルトンパターン
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  // データベースの初期化
  Future<Database> _initDatabase() async {
    // プラットフォームごとの初期化
    if (!Platform.isAndroid && !Platform.isIOS) {
      // デスクトップ向け設定
      sqfliteFfiInit();
    }
    
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'finance_app.db');
      // モバイル/デスクトッププラットフォームで適切なデータベースファクトリを使用
    final db = await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    
    // データベース初期化後に追加のチェックを実行
    await _verifyTableStructure(db);
    
    debugPrint('データベース初期化成功: $path');
    
    return db;
  }

  // データベースのバージョンアップグレード
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 新しいカラムの追加とリネーム
      try {
        // 一時的なバックアップテーブルを作成
        await db.execute('''
          CREATE TABLE nisa_investments_backup(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            stockName TEXT NOT NULL,
            ticker TEXT NOT NULL,
            investedAmount REAL NOT NULL,
            currentValue REAL NOT NULL,
            purchaseDate TEXT NOT NULL,
            monthlyContribution REAL NOT NULL,
            contributionDay INTEGER NOT NULL,
            lastUpdated TEXT NOT NULL
          )
        ''');

        // 既存データを変換して新テーブルにコピー
        await db.execute('''
          INSERT INTO nisa_investments_backup(
            id, stockName, ticker, investedAmount, currentValue, 
            purchaseDate, monthlyContribution, contributionDay, lastUpdated
          )
          SELECT 
            id, name, '', initialAmount, currentValue, 
            lastUpdated, monthlyContribution, contributionDay, lastUpdated
          FROM nisa_investments
        ''');        // 古いテーブルを削除
        await db.execute('DROP TABLE nisa_investments');

        // 新テーブルをリネーム
        await db.execute(
          'ALTER TABLE nisa_investments_backup RENAME TO nisa_investments',
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('マイグレーションエラー: $e');
        }
        // エラーが発生した場合は、新しいテーブルを作成
        await db.execute('DROP TABLE IF EXISTS nisa_investments');
        await db.execute('''
          CREATE TABLE nisa_investments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            stockName TEXT NOT NULL,
            ticker TEXT NOT NULL,
            investedAmount REAL NOT NULL,
            currentValue REAL NOT NULL,
            purchaseDate TEXT NOT NULL,
            monthlyContribution REAL NOT NULL,
            contributionDay INTEGER NOT NULL,
            lastUpdated TEXT NOT NULL
          )        ''');
      }
    }

    if (oldVersion < 3) {
      // 予算管理テーブルを追加
      try {
        // 予算設定テーブル
        await db.execute('''
          CREATE TABLE budgets(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            category INTEGER NOT NULL UNIQUE,
            amount REAL NOT NULL,
            month TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        // 月次予算テーブル
        await db.execute('''
          CREATE TABLE monthly_budgets(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount REAL NOT NULL,
            month TEXT NOT NULL UNIQUE,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        debugPrint('予算管理テーブルを作成しました');
      } catch (e) {
        debugPrint('予算テーブル作成エラー: $e');
      }
    }
  }

  // テーブルの作成
  Future<void> _onCreate(Database db, int version) async {
    // 支出テーブル
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category INTEGER NOT NULL,
        note TEXT
      )
    ''');

    // 収入テーブル
    await db.execute('''
      CREATE TABLE incomes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category INTEGER NOT NULL,
        note TEXT
      )
    ''');    // NISA投資テーブル
    await db.execute('''
      CREATE TABLE nisa_investments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stockName TEXT NOT NULL,
        ticker TEXT NOT NULL,
        investedAmount REAL NOT NULL,
        currentValue REAL NOT NULL,
        purchaseDate TEXT NOT NULL,
        monthlyContribution REAL NOT NULL,
        contributionDay INTEGER NOT NULL,
        lastUpdated TEXT NOT NULL
      )
    ''');

    // 予算設定テーブル
    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category INTEGER NOT NULL UNIQUE,
        amount REAL NOT NULL,
        month TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 月次予算テーブル
    await db.execute('''
      CREATE TABLE monthly_budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        month TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }
  // 支出データの操作メソッド
  Future<int> insertExpense(Expense expense) async {
    try {
      debugPrint('DatabaseService: 支出を挿入中... 金額: ${expense.amount}, カテゴリ: ${expense.category}');
      Database db = await database;
      final result = await db.insert('expenses', expense.toMap());
      debugPrint('DatabaseService: 支出の挿入が完了しました。ID: $result');
      return result;
    } catch (e, stackTrace) {
      debugPrint('DatabaseService: 支出挿入中にエラーが発生しました: $e');
      debugPrint('スタックトレース: $stackTrace');
      rethrow;
    }
  }

  Future<List<Expense>> getExpenses() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }  Future<List<Expense>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    Database db = await database;

    // デバッグ用：日付形式を表示
    final formattedStart = start.toIso8601String();
    final formattedEnd = end.toIso8601String();
    
    debugPrint('日付範囲クエリ（元の日付）: $start から $end');
    debugPrint('ISO形式: $formattedStart から $formattedEnd');

    try {
      // データベース内のすべての支出データを取得して検証
      final allExpenses = await db.query('expenses');
      debugPrint('データベース内の支出データ全件数: ${allExpenses.length}');
      
      if (allExpenses.isNotEmpty) {
        debugPrint('最初のレコードの日付: ${allExpenses.first['date']}');
        debugPrint('最後のレコードの日付: ${allExpenses.last['date']}');
        
        // すべての日付を表示（上限10件）
        final limit = math.min(10, allExpenses.length);
        for (var i = 0; i < limit; i++) {
          debugPrint('レコード $i の日付: ${allExpenses[i]['date']}');
        }
      }
      
      // 日付形式の問題に対応するため、様々なフォーマットを試す
      final startStr = start.toIso8601String();
      final endStr = end.toIso8601String();      final startDate = startStr.split('T')[0];
      final endDate = '${endStr.split('T')[0]}T23:59:59.999Z';
      
      debugPrint('SQL検索用日付: $startDate から $endDate');
      
      // SQLiteは文字列の比較で日付を処理するため、様々な形式を試す
      final query = '''
        SELECT * FROM expenses 
        WHERE (
          date >= ? AND date <= ? OR
          date LIKE ?
        )
      ''';
      
      // 2025-05の形式でも検索できるように
      final monthPattern = "${start.year}-${start.month.toString().padLeft(2, '0')}%";
      
      List<Map<String, dynamic>> maps = await db.rawQuery(
        query,
        [startDate, endDate, monthPattern],
      );
      
      debugPrint('クエリ結果数: ${maps.length}');
      debugPrint('検索パターン: $monthPattern');

      // 結果があれば、それを返す
      if (maps.isNotEmpty) {
        return List.generate(maps.length, (i) {
          return Expense.fromMap(maps[i]);
        });
      }
      
      // 結果がない場合は、代替方法で検索
      debugPrint('通常の検索で結果が見つかりませんでした。月ベースの検索を試みます...');
      final altMaps = await db.rawQuery(
        'SELECT * FROM expenses WHERE date LIKE ?',
        [monthPattern],
      );
      
      debugPrint('月ベース検索結果数: ${altMaps.length}');
      
      return List.generate(altMaps.length, (i) {
        return Expense.fromMap(altMaps[i]);
      });
    } catch (e) {
      debugPrint('支出クエリエラー: $e');
      return [];
    }
  }

  Future<int> updateExpense(Expense expense) async {
    Database db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    Database db = await database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);  }

  // 収入データの操作メソッド
  Future<int> insertIncome(Income income) async {
    try {
      debugPrint('DatabaseService: 収入を挿入中... 金額: ${income.amount}, カテゴリ: ${income.category}');
      Database db = await database;
      final result = await db.insert('incomes', income.toMap());
      debugPrint('DatabaseService: 収入の挿入が完了しました。ID: $result');
      return result;
    } catch (e, stackTrace) {
      debugPrint('DatabaseService: 収入挿入中にエラーが発生しました: $e');
      debugPrint('スタックトレース: $stackTrace');
      rethrow;    }
  }

  Future<List<Income>> getIncomes() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('incomes');
    return List.generate(maps.length, (i) {
      return Income.fromMap(maps[i]);
    });
  }

  Future<List<Income>> getIncomesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    Database db = await database;

    // デバッグ用：日付形式を表示
    final formattedStart = start.toIso8601String();
    final formattedEnd = end.toIso8601String();
    
    debugPrint('収入日付範囲クエリ（元の日付）: $start から $end');
    debugPrint('収入ISO形式: $formattedStart から $formattedEnd');

    try {
      // データベース内のすべての収入データを取得して検証
      final allIncomes = await db.query('incomes');
      debugPrint('データベース内の収入データ全件数: ${allIncomes.length}');
      
      if (allIncomes.isNotEmpty) {
        debugPrint('最初の収入レコードの日付: ${allIncomes.first['date']}');
        debugPrint('最後の収入レコードの日付: ${allIncomes.last['date']}');
        
        // すべての日付を表示（上限10件）
        final limit = math.min(10, allIncomes.length);
        for (var i = 0; i < limit; i++) {
          debugPrint('収入レコード $i の日付: ${allIncomes[i]['date']}');
        }
      }
      
      // 日付形式の問題に対応するため、様々なフォーマットを試す
      final startStr = start.toIso8601String();
      final endStr = end.toIso8601String();      final startDate = startStr.split('T')[0];
      final endDate = '${endStr.split('T')[0]}T23:59:59.999Z';
      
      debugPrint('収入SQL検索用日付: $startDate から $endDate');
      
      // SQLiteは文字列の比較で日付を処理するため、様々な形式を試す
      final query = '''
        SELECT * FROM incomes 
        WHERE (
          date >= ? AND date <= ? OR
          date LIKE ?
        )
      ''';
      
      // 2025-05の形式でも検索できるように
      final monthPattern = "${start.year}-${start.month.toString().padLeft(2, '0')}%";
      
      List<Map<String, dynamic>> maps = await db.rawQuery(
        query,
        [startDate, endDate, monthPattern],
      );
      
      debugPrint('収入クエリ結果数: ${maps.length}');
      debugPrint('収入検索パターン: $monthPattern');

      // 結果があれば、それを返す
      if (maps.isNotEmpty) {
        return List.generate(maps.length, (i) {
          return Income.fromMap(maps[i]);
        });
      }
      
      // 結果がない場合は、代替方法で検索
      debugPrint('通常の収入検索で結果が見つかりませんでした。月ベースの検索を試みます...');
      final altMaps = await db.rawQuery(
        'SELECT * FROM incomes WHERE date LIKE ?',
        [monthPattern],
      );
      
      debugPrint('収入月ベース検索結果数: ${altMaps.length}');
      
      return List.generate(altMaps.length, (i) {
        return Income.fromMap(altMaps[i]);
      });
    } catch (e) {
      debugPrint('収入クエリエラー: $e');
      return [];
    }
  }

  Future<int> updateIncome(Income income) async {
    Database db = await database;
    return await db.update(
      'incomes',
      income.toMap(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  Future<int> deleteIncome(int id) async {
    Database db = await database;
    return await db.delete('incomes', where: 'id = ?', whereArgs: [id]);
  }
  // NISAとテストデータ関連
  
  // NISA投資データの操作メソッド
  Future<int> insertNisaInvestment(NisaInvestment investment) async {
    Database db = await database;
    return await db.insert('nisa_investments', investment.toMap());
  }

  Future<List<NisaInvestment>> getNisaInvestments() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('nisa_investments');
    return List.generate(maps.length, (i) {
      return NisaInvestment.fromMap(maps[i]);
    });
  }

  Future<int> updateNisaInvestment(NisaInvestment investment) async {
    Database db = await database;
    return await db.update(
      'nisa_investments',
      investment.toMap(),
      where: 'id = ?',
      whereArgs: [investment.id],
    );
  }

  Future<int> deleteNisaInvestment(int id) async {
    Database db = await database;
    return await db.delete(
      'nisa_investments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
      // このセクションはテストデータインポート機能の一部として削除されました
  
  // テーブル構造の検証と修復
  Future<void> _verifyTableStructure(Database db) async {
    try {
      // NISAテーブルの構造を確認
      final tableInfo = await db.rawQuery("PRAGMA table_info(nisa_investments)");
      debugPrint('NISA投資テーブル構造: $tableInfo');
      
      // カラム名のリストを取得
      final columnNames = tableInfo.map((col) => col['name'].toString()).toList();
      debugPrint('NISAテーブルのカラム: $columnNames');
      
      // stockNameカラムが存在しない場合は修正
      if (!columnNames.contains('stockName') && columnNames.contains('name')) {
        debugPrint('古いテーブル構造を検出しました。マイグレーションを実行します...');
        
        // バックアップテーブルの作成
        await db.execute('''
          CREATE TABLE nisa_investments_new(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            stockName TEXT NOT NULL,
            ticker TEXT NOT NULL,
            investedAmount REAL NOT NULL,
            currentValue REAL NOT NULL,
            purchaseDate TEXT NOT NULL,
            monthlyContribution REAL NOT NULL,
            contributionDay INTEGER NOT NULL,
            lastUpdated TEXT NOT NULL
          )
        ''');
        
        // 既存データをマイグレーション
        await db.execute('''
          INSERT INTO nisa_investments_new(
            id, stockName, ticker, investedAmount, currentValue, 
            purchaseDate, monthlyContribution, contributionDay, lastUpdated
          )
          SELECT 
            id, name, '', initialAmount, currentValue, 
            lastUpdated, monthlyContribution, contributionDay, lastUpdated
          FROM nisa_investments
        ''');
        
        // 古いテーブルを削除して新しいテーブルをリネーム
        await db.execute('DROP TABLE nisa_investments');
        await db.execute('ALTER TABLE nisa_investments_new RENAME TO nisa_investments');
        
        debugPrint('NISAテーブルのマイグレーションが完了しました');
      } else if (!columnNames.contains('stockName') && !columnNames.contains('name')) {
        // テーブルの再作成
        debugPrint('NISAテーブルの構造が不完全です。テーブルを再作成します...');
        await db.execute('DROP TABLE IF EXISTS nisa_investments');
        await db.execute('''
          CREATE TABLE nisa_investments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            stockName TEXT NOT NULL,
            ticker TEXT NOT NULL,
            investedAmount REAL NOT NULL,
            currentValue REAL NOT NULL,
            purchaseDate TEXT NOT NULL,
            monthlyContribution REAL NOT NULL,
            contributionDay INTEGER NOT NULL,
            lastUpdated TEXT NOT NULL
          )
        ''');
        debugPrint('NISAテーブルを再作成しました');
      }
      
      // 検証完了
      final verifiedColumns = await db.rawQuery("PRAGMA table_info(nisa_investments)");
      debugPrint('検証後のNISAテーブル構造: ${verifiedColumns.map((col) => col['name']).toList()}');
      
    } catch (e) {
      debugPrint('テーブル構造の検証中にエラー: $e');
    }
  }
  
  /// すべてのデータを削除する
  Future<void> deleteAllData() async {
    final db = await database;
    
    try {
      // トランザクション内ですべてのテーブルをクリア
      await db.transaction((txn) async {
        await txn.execute('DELETE FROM expenses');
        await txn.execute('DELETE FROM incomes');
        await txn.execute('DELETE FROM nisa_investments');
        
        // オートインクリメントIDをリセット
        await txn.execute('DELETE FROM sqlite_sequence WHERE name IN ("expenses", "incomes", "nisa_investments")');
      });
      
      debugPrint('すべてのデータが削除されました');
    } catch (e) {
      debugPrint('データ削除中にエラーが発生しました: $e');
      rethrow;
    }
  }
  
  /// データベースファイル自体を削除する（完全リセット）
  Future<void> resetDatabase() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'finance_app.db');
      
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        debugPrint('データベースファイルが削除されました: $path');
      }
      
      // データベースを再初期化
      _database = await _initDatabase();
      debugPrint('データベースがリセットされました');
    } catch (e) {
      debugPrint('データベースリセット中にエラーが発生しました: $e');
      rethrow;
    }
  }
  
  /// データをJSONファイルにバックアップする
  Future<String> createBackup() async {
    try {
      final db = await database;
      
      // すべてのデータを取得
      final expensesData = await db.query('expenses');
      final incomesData = await db.query('incomes');
      final nisaData = await db.query('nisa_investments');
      
      // バックアップデータを構築
      final backupData = {
        'version': '1.0',
        'created_at': DateTime.now().toIso8601String(),
        'app_name': 'Money:G Finance App',
        'data': {
          'expenses': expensesData,
          'incomes': incomesData,
          'nisa_investments': nisaData,
        },
        'statistics': {
          'total_expenses': expensesData.length,
          'total_incomes': incomesData.length,
          'total_nisa_investments': nisaData.length,
        }
      };
      
      // JSON文字列に変換
      final jsonString = jsonEncode(backupData);
      
      // バックアップファイルを保存
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
      final fileName = 'MoneyG_Backup_$timestamp.json';
      final filePath = join(directory.path, fileName);
      
      final file = File(filePath);
      await file.writeAsString(jsonString, encoding: utf8);
      
      debugPrint('バックアップが作成されました: $filePath');
      debugPrint('バックアップサイズ: ${jsonString.length} 文字');
      
      return filePath;
    } catch (e) {
      debugPrint('バックアップ作成中にエラーが発生しました: $e');
      rethrow;
    }
  }
  
  /// JSONファイルからデータを復元する
  Future<void> restoreFromBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('バックアップファイルが見つかりません: $filePath');
      }
      
      // バックアップファイルを読み込み
      final jsonString = await file.readAsString(encoding: utf8);
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // バックアップファイルの検証
      if (!backupData.containsKey('data') || !backupData.containsKey('version')) {
        throw Exception('無効なバックアップファイル形式です');
      }
      
      final data = backupData['data'] as Map<String, dynamic>;
      final db = await database;
      
      // 既存データを削除
      await deleteAllData();
      
      // データを復元
      await db.transaction((txn) async {
        // 支出データの復元
        if (data.containsKey('expenses')) {
          final expenses = data['expenses'] as List<dynamic>;
          for (final expense in expenses) {
            final expenseMap = expense as Map<String, dynamic>;
            await txn.insert('expenses', expenseMap);
          }
        }
        
        // 収入データの復元
        if (data.containsKey('incomes')) {
          final incomes = data['incomes'] as List<dynamic>;
          for (final income in incomes) {
            final incomeMap = income as Map<String, dynamic>;
            await txn.insert('incomes', incomeMap);
          }
        }
        
        // NISA投資データの復元
        if (data.containsKey('nisa_investments')) {
          final nisaInvestments = data['nisa_investments'] as List<dynamic>;
          for (final nisa in nisaInvestments) {
            final nisaMap = nisa as Map<String, dynamic>;
            await txn.insert('nisa_investments', nisaMap);
          }
        }
      });
      
      debugPrint('データの復元が完了しました');
      debugPrint('復元されたデータ:');
      if (data.containsKey('expenses')) {
        debugPrint('  支出: ${(data['expenses'] as List).length} 件');
      }
      if (data.containsKey('incomes')) {
        debugPrint('  収入: ${(data['incomes'] as List).length} 件');
      }
      if (data.containsKey('nisa_investments')) {
        debugPrint('  NISA投資: ${(data['nisa_investments'] as List).length} 件');
      }
      
    } catch (e) {
      debugPrint('データ復元中にエラーが発生しました: $e');
      rethrow;
    }
  }
  
  /// バックアップファイルの情報を取得する
  Future<Map<String, dynamic>?> getBackupInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }
      
      final jsonString = await file.readAsString(encoding: utf8);
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return {
        'version': backupData['version'] ?? 'Unknown',
        'created_at': backupData['created_at'] ?? 'Unknown',
        'app_name': backupData['app_name'] ?? 'Unknown',
        'statistics': backupData['statistics'] ?? {},
        'file_size': await file.length(),
      };
    } catch (e) {
      debugPrint('バックアップ情報の取得中にエラー: $e');
      return null;
    }
  }
  
  /// 利用可能なバックアップファイルのリストを取得する
  Future<List<String>> getAvailableBackups() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backupFiles = <String>[];
      
      await for (final entity in directory.list()) {
        if (entity is File && entity.path.contains('MoneyG_Backup_') && entity.path.endsWith('.json')) {
          backupFiles.add(entity.path);
        }
      }
      
      // 作成日時でソート（新しい順）
      backupFiles.sort((a, b) => b.compareTo(a));
      
      return backupFiles;
    } catch (e) {
      debugPrint('バックアップファイルリストの取得中にエラー: $e');
      return [];
    }  }

  // 予算管理メソッド
  // カテゴリ別予算の保存
  Future<void> saveCategoryBudget(ExpenseCategory category, double amount, String month) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    await db.execute('''
      INSERT OR REPLACE INTO budgets(category, amount, month, created_at, updated_at)
      VALUES(?, ?, ?, ?, ?)
    ''', [category.index, amount, month, now, now]);
    
    debugPrint('カテゴリ予算を保存: ${category.name} - $amount円 ($month)');
  }

  // 月次予算の保存
  Future<void> saveMonthlyBudget(double amount, String month) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    await db.execute('''
      INSERT OR REPLACE INTO monthly_budgets(amount, month, created_at, updated_at)
      VALUES(?, ?, ?, ?)
    ''', [amount, month, now, now]);
    
    debugPrint('月次予算を保存: $amount円 ($month)');
  }

  // カテゴリ別予算の取得
  Future<Map<ExpenseCategory, double>> getCategoryBudgets(String month) async {
    final db = await database;
    final result = await db.query(
      'budgets',
      where: 'month = ?',
      whereArgs: [month],
    );

    final budgets = <ExpenseCategory, double>{};
    for (final row in result) {
      final categoryIndex = row['category'] as int;
      final amount = row['amount'] as double;
      
      if (categoryIndex >= 0 && categoryIndex < ExpenseCategory.values.length) {
        budgets[ExpenseCategory.values[categoryIndex]] = amount;
      }
    }
    
    return budgets;
  }

  // 月次予算の取得
  Future<double?> getMonthlyBudget(String month) async {
    final db = await database;
    final result = await db.query(
      'monthly_budgets',
      where: 'month = ?',
      whereArgs: [month],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['amount'] as double;
    }
    return null;
  }

  // すべての予算データを削除
  Future<void> clearAllBudgets() async {
    final db = await database;
    await db.delete('budgets');
    await db.delete('monthly_budgets');
    debugPrint('すべての予算データを削除しました');
  }
  // 予算アラート用の追加メソッド
  Future<double> getTotalExpensesForMonth(String monthString) async {
    final parts = monthString.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
    
    final expenses = await getExpensesByDateRange(startDate, endDate);
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  Future<double> getCategoryExpensesForMonth(ExpenseCategory category, String monthString) async {
    final parts = monthString.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);
    
    final expenses = await getExpensesByDateRange(startDate, endDate);
    return expenses
        .where((expense) => expense.category == category)
        .fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }
}
