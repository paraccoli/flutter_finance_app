# 📚 MoneyG Finance App - API リファレンス

> **内部API仕様書** 

---

## 🎯 API リファレンス概要

このドキュメントは、MoneyG Finance Appの内部API構造、メソッドシグネチャ、および使用方法を詳細に説明します。開発者がアプリの機能を理解し、効率的に開発・デバッグを行うための技術リファレンスです。

### 📋 API分類

- 🗃️ **データベースAPI**: SQLiteデータアクセス層
- 📊 **ViewModel API**: 状態管理・ビジネスロジック層
- 🎨 **モデルAPI**: データ構造定義層
- 🔧 **サービスAPI**: 横断的機能・ユーティリティ層

---

## 🗃️ Database Service API

### 📘 DatabaseService クラス

データベース操作の中核を担うシングルトンサービス。SQLiteデータベースへの統一的なアクセスインターフェースを提供。

#### 🔧 基本メソッド

```dart
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  
  Future<Database> get database async;
  Future<void> closeDatabase() async;
  Future<void> deleteDatabase() async;
}
```

#### 💾 データベース管理

| メソッド | 戻り値 | 説明 |
|---------|--------|------|
| `get database` | `Future<Database>` | データベースインスタンス取得 |
| `closeDatabase()` | `Future<void>` | データベース接続を閉じる |
| `deleteDatabase()` | `Future<void>` | データベースファイルを削除 |
| `_initDatabase()` | `Future<Database>` | データベース初期化（内部メソッド） |
| `_onCreate()` | `Future<void>` | テーブル作成（内部メソッド） |
| `_onUpgrade()` | `Future<void>` | スキーマ更新（内部メソッド） |

---

## 💰 Expense API

### 📊 支出データ操作

#### 🔍 データ取得メソッド

```dart
// 全支出データ取得
Future<List<Expense>> getExpenses() async

// 日付範囲指定で支出データ取得
Future<List<Expense>> getExpensesByDateRange(
  DateTime startDate, 
  DateTime endDate
) async

// カテゴリ別支出データ取得
Future<List<Expense>> getExpensesByCategory(
  ExpenseCategory category
) async

// 特定支出データ取得
Future<Expense?> getExpenseById(int id) async

// 月次支出データ取得
Future<List<Expense>> getExpensesByMonth(
  int year, 
  int month
) async
```

#### ✏️ データ操作メソッド

```dart
// 支出データ作成
Future<int> insertExpense(Expense expense) async

// 支出データ更新
Future<int> updateExpense(Expense expense) async

// 支出データ削除
Future<int> deleteExpense(int id) async

// 複数支出データ削除
Future<int> deleteExpensesByIds(List<int> ids) async
```

#### 📈 集計・分析メソッド

```dart
// 合計支出額計算
Future<double> getTotalExpenseAmount(
  DateTime startDate, 
  DateTime endDate
) async

// カテゴリ別支出額計算
Future<Map<ExpenseCategory, double>> getExpensesByCategory(
  DateTime startDate, 
  DateTime endDate
) async

// 月次支出統計
Future<Map<String, double>> getMonthlyExpenseStats(
  int year
) async

// 日次支出統計
Future<Map<DateTime, double>> getDailyExpenseStats(
  DateTime startDate, 
  DateTime endDate
) async
```

### 🧮 ExpenseViewModel API

支出画面の状態管理を担当するViewModelクラス。

#### 📋 プロパティ

```dart
class ExpenseViewModel extends ChangeNotifier {
  List<Expense> get expenses;           // 支出リスト
  DateTime get startDate;               // 表示開始日
  DateTime get endDate;                 // 表示終了日
  double get totalAmount;               // 合計支出額
  bool get isLoading;                   // ローディング状態
  String? get errorMessage;             // エラーメッセージ
}
```

#### 🎬 アクションメソッド

```dart
// データ読み込み
Future<void> loadExpenses() async
Future<void> loadAllExpenses() async
Future<void> refreshExpenses() async

// 日付範囲設定
void setDateRange(DateTime start, DateTime end)
void setCurrentMonth()
void setCurrentYear()

// データ操作
Future<bool> addExpense(Expense expense) async
Future<bool> updateExpense(Expense expense) async
Future<bool> deleteExpense(int id) async

// フィルタリング
void filterByCategory(ExpenseCategory? category)
void filterByDateRange(DateTime start, DateTime end)
void clearFilters()
```

---

## 💵 Income API

### 📊 収入データ操作

#### 🔍 データ取得メソッド

```dart
// 全収入データ取得
Future<List<Income>> getIncomes() async

// 日付範囲指定で収入データ取得
Future<List<Income>> getIncomesByDateRange(
  DateTime startDate, 
  DateTime endDate
) async

// カテゴリ別収入データ取得
Future<List<Income>> getIncomesByCategory(
  IncomeCategory category
) async

// 特定収入データ取得
Future<Income?> getIncomeById(int id) async

// 月次収入データ取得
Future<List<Income>> getIncomesByMonth(
  int year, 
  int month
) async
```

#### ✏️ データ操作メソッド

```dart
// 収入データ作成
Future<int> insertIncome(Income income) async

// 収入データ更新
Future<int> updateIncome(Income income) async

// 収入データ削除
Future<int> deleteIncome(int id) async
```

#### 📈 集計・分析メソッド

```dart
// 合計収入額計算
Future<double> getTotalIncomeAmount(
  DateTime startDate, 
  DateTime endDate
) async

// カテゴリ別収入額計算
Future<Map<IncomeCategory, double>> getIncomesByCategory(
  DateTime startDate, 
  DateTime endDate
) async

// 月次収入統計
Future<Map<String, double>> getMonthlyIncomeStats(
  int year
) async
```

### 🧮 IncomeViewModel API

収入画面の状態管理を担当するViewModelクラス。

#### 📋 プロパティ

```dart
class IncomeViewModel extends ChangeNotifier {
  List<Income> get incomes;             // 収入リスト
  DateTime get startDate;               // 表示開始日
  DateTime get endDate;                 // 表示終了日
  double get totalAmount;               // 合計収入額
  bool get isLoading;                   // ローディング状態
  String? get errorMessage;             // エラーメッセージ
}
```

#### 🎬 アクションメソッド

```dart
// データ読み込み
Future<void> loadIncomes() async
Future<void> refreshIncomes() async

// 日付範囲設定
void setDateRange(DateTime start, DateTime end)
void setCurrentMonth()

// データ操作
Future<bool> addIncome(Income income) async
Future<bool> updateIncome(Income income) async
Future<bool> deleteIncome(int id) async
```

---

## 📈 NISA Investment API

### 📊 NISA投資データ操作

#### 🔍 データ取得メソッド

```dart
// 全NISA投資データ取得
Future<List<NisaInvestment>> getNisaInvestments() async

// 投資タイプ別データ取得
Future<List<NisaInvestment>> getNisaInvestmentsByType(
  String investmentType
) async

// 特定NISA投資データ取得
Future<NisaInvestment?> getNisaInvestmentById(int id) async

// 日付範囲指定でNISA投資データ取得
Future<List<NisaInvestment>> getNisaInvestmentsByDateRange(
  DateTime startDate, 
  DateTime endDate
) async
```

#### ✏️ データ操作メソッド

```dart
// NISA投資データ作成
Future<int> insertNisaInvestment(NisaInvestment investment) async

// NISA投資データ更新
Future<int> updateNisaInvestment(NisaInvestment investment) async

// NISA投資データ削除
Future<int> deleteNisaInvestment(int id) async
```

#### 📈 投資分析メソッド

```dart
// 総投資額計算
Future<double> getTotalInvestmentAmount() async

// 投資商品別投資額
Future<Map<String, double>> getInvestmentsByProduct() async

// 月次投資統計
Future<Map<String, double>> getMonthlyInvestmentStats(
  int year
) async

// 投資パフォーマンス計算
Future<Map<String, dynamic>> getInvestmentPerformance() async
```

### 🧮 NisaViewModel API

NISA投資画面の状態管理を担当するViewModelクラス。

#### 📋 プロパティ

```dart
class NisaViewModel extends ChangeNotifier {
  List<NisaInvestment> get investments;     // 投資リスト
  double get totalInvestment;               // 総投資額
  double get totalCurrentValue;             // 現在価値総額
  double get totalGainLoss;                 // 損益総額
  double get totalGainLossPercentage;       // 損益率
  bool get isLoading;                       // ローディング状態
  String? get errorMessage;                 // エラーメッセージ
}
```

#### 🎬 アクションメソッド

```dart
// データ読み込み
Future<void> loadInvestments() async
Future<void> refreshInvestments() async

// データ操作
Future<bool> addInvestment(NisaInvestment investment) async
Future<bool> updateInvestment(NisaInvestment investment) async
Future<bool> deleteInvestment(int id) async

// 分析
Map<String, double> getInvestmentBreakdown()
double calculateTotalGainLoss()
```

---

## 💳 Budget Service API

### 📊 予算管理サービス

予算設定と追跡機能を提供する静的サービスクラス。

#### 🔧 基本メソッド

```dart
class BudgetService {
  // 初期化
  static Future<void> initialize() async
  
  // 月次予算管理
  static Future<double> getMonthlyBudget() async
  static Future<void> setMonthlyBudget(double budget) async
  
  // カテゴリ別予算管理
  static Future<Map<ExpenseCategory, double>> getCategoryBudgets() async
  static Future<void> setCategoryBudget(
    ExpenseCategory category, 
    double budget
  ) async
  
  // 予算アラート設定
  static Future<bool> isBudgetAlertEnabled() async
  static Future<void> setBudgetAlertEnabled(bool enabled) async
}
```

#### 📈 予算分析メソッド

```dart
// 予算使用率計算
static Future<double> getBudgetUsagePercentage(
  DateTime month
) async

// カテゴリ別予算使用率
static Future<Map<ExpenseCategory, double>> getCategoryBudgetUsage(
  DateTime month
) async

// 予算超過チェック
static Future<bool> isBudgetExceeded(
  DateTime month
) async

// 予算残高計算
static Future<double> getRemainingBudget(
  DateTime month
) async

// 予算達成予測
static Future<Map<String, dynamic>> getBudgetProjection(
  DateTime month
) async
```

---

## 📤 Export Service API

### 📄 データエクスポートサービス

データのCSV・PDFエクスポート機能を提供。

#### 📊 CSVエクスポート

```dart
class ExportService {
  // 支出データCSVエクスポート
  static Future<String> exportExpensesToCsv(
    List<Expense> expenses
  ) async
  
  // 収入データCSVエクスポート
  static Future<String> exportIncomesToCsv(
    List<Income> incomes
  ) async
  
  // NISA投資データCSVエクスポート
  static Future<String> exportNisaInvestmentsToCsv(
    List<NisaInvestment> investments
  ) async
  
  // 全データCSVエクスポート
  static Future<String> exportAllDataToCsv() async
}
```

#### 📋 レポートエクスポート

```dart
// 月次レポートエクスポート
static Future<String> exportMonthlyReport(
  int year, 
  int month
) async

// 年次レポートエクスポート
static Future<String> exportYearlyReport(
  int year
) async

// カスタムレポートエクスポート
static Future<String> exportCustomReport(
  DateTime startDate,
  DateTime endDate,
  List<String> includeCategories
) async
```

---

## 📥 CSV Import Service API

### 📤 データインポートサービス

CSVファイルからのデータ一括インポート機能。

#### 🔧 インポートメソッド

```dart
class CsvImportService {
  // 支出データインポート
  static Future<ImportResult> importExpensesFromCsv(
    String csvContent
  ) async
  
  // 収入データインポート
  static Future<ImportResult> importIncomesFromCsv(
    String csvContent
  ) async
  
  // CSVフォーマット検証
  static bool validateCsvFormat(
    String csvContent,
    ImportType type
  )
  
  // サンプルCSVテンプレート生成
  static String generateCsvTemplate(
    ImportType type
  )
}
```

#### 📋 インポート結果

```dart
class ImportResult {
  final int successCount;          // 成功件数
  final int errorCount;            // エラー件数
  final List<String> errorMessages; // エラーメッセージリスト
  final bool isSuccess;            // 成功フラグ
  
  ImportResult({
    required this.successCount,
    required this.errorCount,
    required this.errorMessages,
    required this.isSuccess,
  });
}
```

---

## 🔔 Notification Service API

### 📢 通知サービス

予算アラートやリマインダー機能を提供。

#### 🔧 基本メソッド

```dart
class NotificationService {
  // 初期化
  Future<void> initialize() async
  
  // 権限要求
  Future<bool> requestPermission() async
  
  // 通知表示
  Future<void> showNotification(
    int id,
    String title,
    String body,
    {String? payload}
  ) async
  
  // スケジュール通知
  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
    {String? payload}
  ) async
}
```

#### 🎯 特定通知メソッド

```dart
// 予算超過アラート
Future<void> showBudgetExceededAlert(
  ExpenseCategory category,
  double usagePercentage
) async

// 月末リマインダー
Future<void> showMonthEndReminder() async

// 投資レビューリマインダー
Future<void> showInvestmentReviewReminder() async

// カスタムリマインダー
Future<void> scheduleCustomReminder(
  String title,
  String message,
  DateTime date
) async
```

---

## 🎨 Theme Service API

### 🎭 テーマ管理サービス

アプリのテーマとカラースキーム管理。

#### 🔧 ThemeViewModel

```dart
class ThemeViewModel extends ChangeNotifier {
  // プロパティ
  ThemeMode get themeMode;              // テーマモード
  ColorScheme get colorScheme;          // カラースキーム
  bool get isDarkMode;                  // ダークモードフラグ
  
  // メソッド
  void setThemeMode(ThemeMode mode);    // テーマモード設定
  void toggleTheme();                   // テーマ切り替え
  void setColorScheme(ColorScheme scheme); // カラースキーム設定
  Future<void> saveThemePreference() async; // 設定保存
  Future<void> loadThemePreference() async; // 設定読み込み
}
```

---

## 📋 Model API

### 💰 Expense Model

```dart
class Expense {
  final int? id;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final String? note;
  
  Expense({
    this.id,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
  });
  
  // ファクトリメソッド
  factory Expense.fromMap(Map<String, dynamic> map);
  
  // 変換メソッド
  Map<String, dynamic> toMap();
  Expense copyWith({...});
  
  @override
  String toString();
  
  @override
  bool operator ==(Object other);
  
  @override
  int get hashCode;
}
```

#### 🏷️ ExpenseCategory Enum

```dart
enum ExpenseCategory {
  food('食費', Colors.orange, Icons.fastfood),
  transportation('交通費', Colors.blue, Icons.directions_bus),
  entertainment('娯楽', Colors.purple, Icons.movie),
  utilities('光熱費', Colors.yellow, Icons.flash_on),
  shopping('買い物', Colors.pink, Icons.shopping_bag),
  health('健康・医療', Colors.red, Icons.favorite),
  education('教育', Colors.green, Icons.school),
  rent('家賃', Colors.brown, Icons.home),
  other('その他', Colors.grey, Icons.category);
  
  final String displayName;
  final Color color;
  final IconData icon;
  
  const ExpenseCategory(this.displayName, this.color, this.icon);
}
```

### 💵 Income Model

```dart
class Income {
  final int? id;
  final double amount;
  final DateTime date;
  final IncomeCategory category;
  final String? note;
  
  Income({
    this.id,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
  });
  
  // ファクトリメソッド
  factory Income.fromMap(Map<String, dynamic> map);
  
  // 変換メソッド
  Map<String, dynamic> toMap();
  Income copyWith({...});
}
```

### 📈 NisaInvestment Model

```dart
class NisaInvestment {
  final int? id;
  final String stockName;
  final String ticker;
  final double investedAmount;
  final double currentValue;
  final DateTime purchaseDate;
  final double monthlyContribution;
  final int contributionDay;
  final DateTime lastUpdated;
  
  NisaInvestment({
    this.id,
    required this.stockName,
    required this.ticker,
    required this.investedAmount,
    required this.currentValue,
    required this.purchaseDate,
    required this.monthlyContribution,
    required this.contributionDay,
    required this.lastUpdated,
  });
  
  // ファクトリメソッド
  factory NisaInvestment.fromMap(Map<String, dynamic> map);
  
  // 変換メソッド
  Map<String, dynamic> toMap();
  NisaInvestment copyWith({...});
  
  // 計算メソッド
  double get gainLoss => currentValue - investedAmount;
  double get gainLossPercentage => (gainLoss / investedAmount) * 100;
}
```

---

## ⚡ 使用例・サンプルコード

### 📊 基本的なデータ操作

```dart
// 支出データの追加
final expense = Expense(
  amount: 1500,
  date: DateTime.now(),
  category: ExpenseCategory.food,
  note: 'ランチ代',
);

final expenseViewModel = ExpenseViewModel();
await expenseViewModel.addExpense(expense);

// データの取得と表示
await expenseViewModel.loadExpenses();
final expenses = expenseViewModel.expenses;
```

### 📈 予算管理の使用例

```dart
// 月次予算設定
await BudgetService.initialize();
await BudgetService.setMonthlyBudget(300000);

// カテゴリ別予算設定
await BudgetService.setCategoryBudget(
  ExpenseCategory.food, 
  50000
);

// 予算使用率チェック
final usagePercentage = await BudgetService.getBudgetUsagePercentage(
  DateTime.now()
);

if (usagePercentage > 80) {
  // 予算アラート表示
  await NotificationService().showBudgetExceededAlert(
    ExpenseCategory.food,
    usagePercentage
  );
}
```

### 📤 データエクスポート例

```dart
// 月次レポートエクスポート
final csvContent = await ExportService.exportMonthlyReport(
  2025, 
  6
);

// ファイルとして保存
final file = File('monthly_report_2025_06.csv');
await file.writeAsString(csvContent);
```

---

## ❌ エラーハンドリング

### 🚨 共通エラータイプ

```dart
// データベースエラー
class DatabaseException implements Exception {
  final String message;
  final String? sqlState;
  
  DatabaseException(this.message, [this.sqlState]);
}

// バリデーションエラー
class ValidationException implements Exception {
  final String field;
  final String message;
  
  ValidationException(this.field, this.message);
}

// インポート/エクスポートエラー
class ImportExportException implements Exception {
  final String operation;
  final String message;
  
  ImportExportException(this.operation, this.message);
}
```

### 🛠️ エラーハンドリングパターン

```dart
try {
  await expenseViewModel.addExpense(expense);
} on ValidationException catch (e) {
  // バリデーションエラーの処理
  showErrorDialog('入力エラー: ${e.message}');
} on DatabaseException catch (e) {
  // データベースエラーの処理
  showErrorDialog('データベースエラー: ${e.message}');
} catch (e) {
  // その他のエラー
  showErrorDialog('予期しないエラーが発生しました: $e');
}
```

---

## 📊 パフォーマンス考慮事項

### ⚡ ベストプラクティス

1. **データベースクエリ最適化**
   - インデックスの適切な使用
   - バッチ処理での大量データ操作
   - 接続プールの活用

2. **メモリ管理**
   - ViewModelの適切なdispose
   - 大量データの遅延ロード
   - WeakReferenceの活用

3. **UI応答性**
   - 非同期処理の適切な使用
   - プログレスインジケーターの表示
   - エラー状態の適切な表示

---

## 🔗 関連ドキュメント

- **[アーキテクチャ](Architecture.md)**: システム全体設計
- **[テストガイド](Testing-Guide.md)**: テスト実装方法
- **[コーディング規約](Coding-Standards.md)**: 開発ルール
- **[開発環境セットアップ](Development-Setup.md)**: 環境構築

---

**📝 最終更新**: 2025年6月20日  
**📄 ドキュメントバージョン**: v1.0  
**👥 作成者**: [@paraccoli](https://github.com/paraccoli)

> **MoneyG Finance App**のAPI仕様を詳細に解説しました。  
> 開発者の皆様の効率的な開発にお役立てください。 🚀
