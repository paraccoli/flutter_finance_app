import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math' as Math;
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../models/nisa_investment.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

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
      version: 2,
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
        ''');

        // 古いテーブルを削除
        await db.execute('DROP TABLE nisa_investments');

        // 新テーブルをリネーム
        await db.execute(
          'ALTER TABLE nisa_investments_backup RENAME TO nisa_investments',
        );
      } catch (e) {
        print('マイグレーションエラー: $e');
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
          )
        ''');
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
    '''); // NISA投資テーブル
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
  }

  // 支出データの操作メソッド
  Future<int> insertExpense(Expense expense) async {
    Database db = await database;
    return await db.insert('expenses', expense.toMap());
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
        final limit = Math.min(10, allExpenses.length);
        for (var i = 0; i < limit; i++) {
          debugPrint('レコード $i の日付: ${allExpenses[i]['date']}');
        }
      }
      
      // 日付形式の問題に対応するため、様々なフォーマットを試す
      final startStr = start.toIso8601String();
      final endStr = end.toIso8601String();
      final startDate = startStr.split('T')[0];
      final endDate = endStr.split('T')[0] + 'T23:59:59.999Z';
      
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
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  // 収入データの操作メソッド
  Future<int> insertIncome(Income income) async {
    Database db = await database;
    return await db.insert('incomes', income.toMap());
  }

  Future<List<Income>> getIncomes() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('incomes');
    return List.generate(maps.length, (i) {
      return Income.fromMap(maps[i]);
    });
  }  Future<List<Income>> getIncomesByDateRange(
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
        final limit = Math.min(10, allIncomes.length);
        for (var i = 0; i < limit; i++) {
          debugPrint('収入レコード $i の日付: ${allIncomes[i]['date']}');
        }
      }
      
      // 日付形式の問題に対応するため、様々なフォーマットを試す
      final startStr = start.toIso8601String();
      final endStr = end.toIso8601String();
      final startDate = startStr.split('T')[0];
      final endDate = endStr.split('T')[0] + 'T23:59:59.999Z';
      
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
}
