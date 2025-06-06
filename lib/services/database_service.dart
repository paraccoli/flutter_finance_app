import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
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
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'finance_app.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // データベースのバージョンアップグレード
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 収入テーブルの追加
      await db.execute('''
        CREATE TABLE incomes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          category INTEGER NOT NULL,
          note TEXT
        )
      ''');
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
    ''');

    // NISA投資テーブル
    await db.execute('''
      CREATE TABLE nisa_investments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        initialAmount REAL NOT NULL,
        monthlyContribution REAL NOT NULL,
        currentValue REAL NOT NULL,
        lastUpdated TEXT NOT NULL,
        contributionDay INTEGER NOT NULL
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
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
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
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
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
  }

  Future<List<Income>> getIncomesByDateRange(DateTime start, DateTime end) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'incomes',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );
    return List.generate(maps.length, (i) {
      return Income.fromMap(maps[i]);
    });
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
    return await db.delete(
      'incomes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

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
}
