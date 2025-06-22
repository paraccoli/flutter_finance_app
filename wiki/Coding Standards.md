# 📋 MoneyG Finance App - コーディング規約

> MoneyG Finance Appの開発における統一的なコーディング標準

---

## 🎯 規約の目的

このコーディング規約は、MoneyG Finance Appの開発チーム全体で**一貫性のある高品質なコード**を書くためのガイドラインです。これらの規約に従うことで、コードの可読性、保守性、そしてチーム全体の開発効率が向上します。

### 📋 対象範囲

- **Dart/Flutter コード**: アプリケーション本体
- **設定ファイル**: `pubspec.yaml`, `analysis_options.yaml`
- **ドキュメント**: README, コメント, APIドキュメント
- **テストコード**: 単体テスト、統合テスト

### 🎨 基本理念

- **可読性優先**: 他の開発者が理解しやすいコード
- **一貫性**: プロジェクト全体で統一された書式
- **保守性**: 変更・拡張が容易な設計
- **効率性**: 開発・デバッグ効率の向上

---

## 📝 Dart言語規約

### 🔤 命名規則

#### クラス・型名（PascalCase）

```dart
// ✅ 良い例
class ExpenseViewModel extends ChangeNotifier { }
class DatabaseService { }
enum ExpenseCategory { }
typedef DataCallback = Future<List<Data>> Function();

// ❌ 悪い例
class expenseViewModel { }
class database_service { }
enum expense_category { }
```

#### 変数・メソッド・パラメータ名（camelCase）

```dart
// ✅ 良い例
String userName = 'MoneyG User';
double totalExpenseAmount = 0.0;
void calculateMonthlyTotal() { }
Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async { }

// ❌ 悪い例
String user_name = 'User';
double TotalExpenseAmount = 0.0;
void Calculate_monthly_total() { }
```

#### 定数（SCREAMING_SNAKE_CASE）

```dart
// ✅ 良い例
class AppConstants {
  static const int MAX_EXPENSE_AMOUNT = 1000000;
  static const String DEFAULT_CURRENCY = 'JPY';
  static const Duration ANIMATION_DURATION = Duration(milliseconds: 300);
}

// ❌ 悪い例
static const int maxExpenseAmount = 1000000;
static const String defaultCurrency = 'JPY';
```

#### ファイル・ディレクトリ名（snake_case）

```
// ✅ 良い例
expense_viewmodel.dart
database_service.dart
monthly_report_screen.dart
models/expense.dart
services/budget_service.dart

// ❌ 悪い例
ExpenseViewModel.dart
DatabaseService.dart
MonthlyReportScreen.dart
```

#### プライベートメンバ（アンダースコア始まり）

```dart
// ✅ 良い例
class DatabaseService {
  static DatabaseService? _instance;
  Database? _database;
  
  Future<void> _initializeDatabase() async { }
  String _generateId() => uuid.v4();
}

// ❌ 悪い例
class DatabaseService {
  static DatabaseService? instance; // publicになってしまう
  Database? database; // publicになってしまう
}
```

### 📋 変数・型宣言

#### 型アノテーション

```dart
// ✅ 良い例 - 明示的な型宣言
final List<Expense> expenses = <Expense>[];
final Map<String, double> categoryTotals = <String, double>{};
late final DatabaseService _databaseService;

// ✅ 良い例 - 型推論が明確な場合
final expense = Expense(amount: 1000, category: ExpenseCategory.food);
final total = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);

// ❌ 悪い例 - 型が不明確
final data = getData(); // 戻り値の型が不明
var items = []; // 空のリストの型が不明
```

#### null許可型の適切な使用

```dart
// ✅ 良い例
class Expense {
  final int? id; // データベースIDは新規作成時はnull
  final double amount; // 金額は必須
  final String? note; // メモは任意
  
  Expense({
    this.id,
    required this.amount,
    this.note,
  });
}

// ❌ 悪い例
class Expense {
  int? amount; // 金額は必須なのにnull許可
  String note; // メモが任意なのにnon-null
}
```

### 🔧 関数・メソッド設計

#### 関数の単一責任原則

```dart
// ✅ 良い例 - 単一の責任を持つ関数
double calculateTotalExpense(List<Expense> expenses) {
  return expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
}

bool isExpenseValid(Expense expense) {
  return expense.amount > 0 && expense.category != null;
}

Future<void> saveExpense(Expense expense) async {
  if (!isExpenseValid(expense)) {
    throw ValidationException('Invalid expense data');
  }
  await _databaseService.insertExpense(expense);
}

// ❌ 悪い例 - 複数の責任を持つ関数
Future<double> saveAndCalculateTotal(Expense expense, List<Expense> expenses) async {
  // バリデーション + 保存 + 計算 = 責任が多すぎる
  if (expense.amount <= 0) throw ValidationException('Invalid amount');
  await _databaseService.insertExpense(expense);
  return expenses.fold<double>(0, (sum, e) => sum + e.amount) + expense.amount;
}
```

#### 非同期処理の書き方

```dart
// ✅ 良い例 - 適切なasync/await使用
class ExpenseService {
  Future<List<Expense>> getExpensesByMonth(DateTime month) async {
    try {
      final database = await DatabaseService().database;
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0);
      
      final List<Map<String, dynamic>> maps = await database.query(
        'expenses',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      );
      
      return maps.map((map) => Expense.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Failed to get expenses: $e');
      rethrow;
    }
  }
  
  // 複数の非同期処理を並列実行
  Future<(List<Expense>, List<Income>)> getMonthlyData(DateTime month) async {
    final (expenses, incomes) = await (
      getExpensesByMonth(month),
      getIncomesByMonth(month),
    ).wait;
    
    return (expenses, incomes);
  }
}

// ❌ 悪い例 - 非効率な非同期処理
Future<List<Expense>> getExpensesByMonth(DateTime month) async {
  final database = await DatabaseService().database; // エラーハンドリングなし
  
  // 非効率な順次実行
  final List<Map<String, dynamic>> maps = await database.query('expenses');
  final allExpenses = maps.map((map) => Expense.fromMap(map)).toList();
  
  // フィルタリングをDartで実行（SQLで行うべき）
  return allExpenses.where((expense) => 
    expense.date.year == month.year && expense.date.month == month.month
  ).toList();
}
```

---

## 🎨 Flutter/UI 規約

### 🏗️ Widget構造とアーキテクチャ

#### StatelessWidget vs StatefulWidget

```dart
// ✅ 良い例 - 状態を持たないUIはStatelessWidget
class ExpenseCard extends StatelessWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
  });
  
  final Expense expense;
  final VoidCallback? onTap;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(expense.category.displayName),
        subtitle: Text('¥${expense.amount.toStringAsFixed(0)}'),
        trailing: Text(DateFormat('MM/dd').format(expense.date)),
        onTap: onTap,
      ),
    );
  }
}

// ✅ 良い例 - 状態を持つUIのみStatefulWidget
class ExpenseForm extends StatefulWidget {
  const ExpenseForm({super.key, this.initialExpense});
  
  final Expense? initialExpense;
  
  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late ExpenseCategory _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialExpense?.amount.toString() ?? '',
    );
    _selectedCategory = widget.initialExpense?.category ?? ExpenseCategory.food;
  }
  
  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // フォームUI実装
  }
}
```

#### ウィジェット分割の原則

```dart
// ✅ 良い例 - 適切なウィジェット分割
class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: const _ExpenseListBody(),
      floatingActionButton: _buildFAB(context),
    );
  }
  
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('支出一覧'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => _showSearchDelegate(context),
        ),
      ],
    );
  }
  
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showExpenseForm(context),
      child: const Icon(Icons.add),
    );
  }
}

class _ExpenseListBody extends StatelessWidget {
  const _ExpenseListBody();
  
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (viewModel.expenses.isEmpty) {
          return const _EmptyExpensesList();
        }
        
        return _ExpensesList(expenses: viewModel.expenses);
      },
    );
  }
}

// ❌ 悪い例 - 巨大なbuildメソッド
class ExpenseListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('支出一覧'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 長いコールバック処理...
            },
          ),
          PopupMenuButton<String>(
            // 長いポップアップメニュー定義...
          ),
        ],
      ),
      body: Consumer<ExpenseViewModel>(
        builder: (context, viewModel, child) {
          // 長い条件分岐とUI構築...
          if (viewModel.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('データを読み込み中...'),
                  // さらに長いUI定義が続く...
                ],
              ),
            );
          }
          // 100行以上のUI定義が続く...
        },
      ),
    );
  }
}
```

### 🎨 レイアウトとスタイリング

#### const constructorの使用

```dart
// ✅ 良い例 - const constructorの適切な使用
class AppTheme {
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(8.0));
  
  static const TextStyle headlineStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppTheme.defaultPadding,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.defaultBorderRadius,
      ),
      child: const Text(
        'Hello World',
        style: AppTheme.headlineStyle,
      ),
    );
  }
}

// ❌ 悪い例 - constを使わない非効率なコード
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0), // 毎回新しいインスタンス作成
      decoration: BoxDecoration( // 毎回新しいインスタンス作成
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: Text( // constが使える場面でも使わない
        'Hello World',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
```

#### レスポンシブデザインの実装

```dart
// ✅ 良い例 - レスポンシブデザインの実装
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobileBody,
    required this.tabletBody,
    this.desktopBody,
  });
  
  final Widget mobileBody;
  final Widget tabletBody;
  final Widget? desktopBody;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return mobileBody;
        } else if (constraints.maxWidth < 1200) {
          return tabletBody;
        } else {
          return desktopBody ?? tabletBody;
        }
      },
    );
  }
}

// 使用例
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: const _MobileDashboard(),
      tabletBody: const _TabletDashboard(),
      desktopBody: const _DesktopDashboard(),
    );
  }
}
```

---

## 🗃️ データ・状態管理規約

### 📊 Provider/ChangeNotifierの使用

```dart
// ✅ 良い例 - 適切なChangeNotifier実装
class ExpenseViewModel extends ChangeNotifier {
  final DatabaseService _databaseService;
  
  ExpenseViewModel(this._databaseService);
  
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalAmount => _expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
  
  // 状態変更メソッド
  Future<void> loadExpenses() async {
    if (_isLoading) return; // 重複読み込み防止
    
    _setLoading(true);
    _setError(null);
    
    try {
      _expenses = await _databaseService.getExpenses();
      notifyListeners();
    } catch (e) {
      _setError('支出データの読み込みに失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> addExpense(Expense expense) async {
    try {
      final id = await _databaseService.insertExpense(expense);
      final newExpense = expense.copyWith(id: id);
      _expenses.add(newExpense);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('支出の追加に失敗しました: $e');
      return false;
    }
  }
  
  // プライベートヘルパーメソッド
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
  
  void _setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }
}

// ❌ 悪い例 - 不適切なChangeNotifier実装
class BadExpenseViewModel extends ChangeNotifier {
  List<Expense> expenses = []; // publicフィールド
  bool isLoading = false; // publicフィールド
  
  void loadExpenses() async { // Future<void>ではない
    isLoading = true;
    notifyListeners(); // 状態変更のたびに呼ぶ必要がある
    
    // エラーハンドリングなし
    expenses = await DatabaseService().getExpenses();
    isLoading = false;
    notifyListeners();
  }
  
  void addExpense(Expense expense) { // 戻り値なし、エラーハンドリングなし
    expenses.add(expense); // データベース操作なし
    notifyListeners();
  }
}
```

### 🏗️ データモデルの設計

```dart
// ✅ 良い例 - 適切なデータモデル設計
class Expense {
  const Expense({
    this.id,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
  });
  
  final int? id;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final String? note;
  
  // ファクトリコンストラクタ
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      category: ExpenseCategory.values[map['category'] as int],
      note: map['note'] as String?,
    );
  }
  
  // JSON/Map変換
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.index,
      'note': note,
    };
  }
  
  // copyWithメソッド
  Expense copyWith({
    int? id,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }
  
  // equalsとhashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Expense &&
        other.id == id &&
        other.amount == amount &&
        other.date == date &&
        other.category == category &&
        other.note == note;
  }
  
  @override
  int get hashCode {
    return Object.hash(id, amount, date, category, note);
  }
  
  @override
  String toString() {
    return 'Expense(id: $id, amount: $amount, date: $date, category: $category, note: $note)';
  }
}
```

---

## 📝 ドキュメント・コメント規約

### 📚 Dartdocコメント

```dart
/// 支出管理を行うサービスクラス
/// 
/// データベースからの支出データの取得、作成、更新、削除を担当します。
/// シングルトンパターンを使用してアプリ全体で単一のインスタンスを共有します。
/// 
/// 使用例:
/// ```dart
/// final service = ExpenseService();
/// final expenses = await service.getExpensesByMonth(DateTime(2025, 6));
/// ```
class ExpenseService {
  /// 指定された月の支出一覧を取得します
  /// 
  /// [month] - 取得対象の月（年月のみ使用、日は無視されます）
  /// 
  /// 戻り値: 指定月の支出一覧。データが存在しない場合は空のリストを返します。
  /// 
  /// 例外:
  /// - [DatabaseException] - データベースアクセスエラー
  /// - [ArgumentError] - 不正な月の指定
  Future<List<Expense>> getExpensesByMonth(DateTime month) async {
    ArgumentError.checkNotNull(month, 'month');
    
    try {
      // 実装...
    } catch (e) {
      throw DatabaseException('Failed to get expenses for month: $month', e);
    }
  }
  
  /// 新しい支出を作成します
  /// 
  /// [expense] - 作成する支出データ（idは無視されます）
  /// 
  /// 戻り値: 作成された支出のID
  /// 
  /// 例外:
  /// - [ValidationException] - 支出データが無効
  /// - [DatabaseException] - データベース保存エラー
  Future<int> createExpense(Expense expense) async {
    // 実装...
  }
}
```

### 💬 インラインコメント

```dart
class BudgetCalculator {
  /// 月次予算使用率を計算します
  static double calculateUsagePercentage(
    double spent,
    double budget,
  ) {
    // 予算が0の場合は使用率を0%とする
    if (budget <= 0) return 0.0;
    
    // 使用率を計算（100%を超える場合もあり得る）
    final percentage = (spent / budget) * 100;
    
    // 負の値は0%として扱う（返金などの場合）
    return math.max(0.0, percentage);
  }
  
  /// カテゴリ別予算の検証を行います
  static bool validateCategoryBudgets(Map<ExpenseCategory, double> budgets) {
    for (final entry in budgets.entries) {
      // 各カテゴリの予算は0以上である必要がある
      if (entry.value < 0) {
        debugPrint('Invalid budget for ${entry.key}: ${entry.value}');
        return false;
      }
      
      // TODO: 将来的には上限チェックも追加する
      // 現在は無制限だが、現実的な上限値を設定することを検討
    }
    
    return true;
  }
}
```

### 🚫 コメントのアンチパターン

```dart
// ❌ 悪い例 - 不要・冗長なコメント
class Example {
  // 変数を宣言する（自明なコメント）
  int count = 0;
  
  // カウントを増やすメソッド（メソッド名で明らか）
  void incrementCount() {
    count++; // カウントを1増やす（コードと同じ内容）
  }
  
  // 古くなったコメント
  void processData() {
    // XMLファイルを読み込む（実際はJSONを処理している）
    final data = jsonDecode(response);
    // ...
  }
}

// ✅ 良い例 - 有用なコメント
class Example {
  int _retryCount = 0;
  
  /// APIリトライ回数を増やします
  /// 
  /// 最大リトライ回数（3回）に達した場合は例外をスローします
  void incrementRetryCount() {
    _retryCount++;
    if (_retryCount > 3) {
      throw MaxRetriesExceededException();
    }
  }
  
  /// レスポンスデータを処理します
  /// 
  /// 注意: APIバージョン2.0では、レスポンス形式が変更される予定です
  /// バージョンアップ時にはパースロジックの見直しが必要です
  void processData() {
    final data = jsonDecode(response);
    // ...
  }
}
```

---

## 🔧 ツール設定・自動化

### 📊 analysis_options.yaml 設定

```yaml
# プロジェクトルートのanalysis_options.yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"
    - "ios/**"
    - "android/**"
  
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true

linter:
  rules:
    # コードスタイル
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_const_declarations
    - unnecessary_const
    - unnecessary_new
    
    # 可読性
    - prefer_single_quotes
    - sort_child_properties_last
    - use_key_in_widget_constructors
    - avoid_unnecessary_containers
    
    # パフォーマンス
    - avoid_function_literals_in_foreach_calls
    - prefer_for_elements_to_map_fromIterable
    - prefer_if_null_operators
    
    # エラー防止
    - use_build_context_synchronously
    - avoid_print
    - prefer_typing_uninitialized_variables
    - require_trailing_commas
    
    # ドキュメント
    - public_member_api_docs
    - lines_longer_than_80_chars
```

### 🎨 VSCode設定（.vscode/settings.json）

```json
{
  "dart.lineLength": 80,
  "editor.rulers": [80],
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "dart.completeFunctionCalls": true,
  "dart.closingLabels": true,
  "dart.enableSdkFormatter": true,
  "dart.insertArgumentPlaceholders": false,
  "flutter.hot Reload": true,
  "files.associations": {
    "*.dart": "dart"
  },
  "emmet.includeLanguages": {
    "dart": "html"
  }
}
```

### 🔧 pre-commit hooks 設定

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running pre-commit checks..."

# 静的解析実行
echo "Running flutter analyze..."
flutter analyze
if [ $? -ne 0 ]; then
  echo "❌ Flutter analyze failed. Please fix the issues before committing."
  exit 1
fi

# フォーマットチェック
echo "Checking code formatting..."
dart format --set-exit-if-changed .
if [ $? -ne 0 ]; then
  echo "❌ Code formatting issues found. Run 'dart format .' to fix."
  exit 1
fi

# テスト実行
echo "Running tests..."
flutter test
if [ $? -ne 0 ]; then
  echo "❌ Tests failed. Please fix the failing tests before committing."
  exit 1
fi

echo "✅ All pre-commit checks passed!"
```

---

## 🧪 テストコード規約

### 📋 テスト構造とパターン

```dart
// ✅ 良い例 - 適切なテスト構造
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_finance_app/models/expense.dart';
import 'package:flutter_finance_app/services/expense_service.dart';
import 'package:flutter_finance_app/services/database_service.dart';

// モック生成アノテーション
@GenerateMocks([DatabaseService])
import 'expense_service_test.mocks.dart';

void main() {
  group('ExpenseService', () {
    late ExpenseService expenseService;
    late MockDatabaseService mockDatabaseService;
    
    setUp(() {
      mockDatabaseService = MockDatabaseService();
      expenseService = ExpenseService(mockDatabaseService);
    });
    
    group('getExpensesByMonth', () {
      test('正常な月の指定で支出一覧を取得できる', () async {
        // Arrange
        final month = DateTime(2025, 6);
        final expectedExpenses = [
          Expense(
            id: 1,
            amount: 1000,
            date: DateTime(2025, 6, 15),
            category: ExpenseCategory.food,
          ),
        ];
        
        when(mockDatabaseService.getExpensesByDateRange(any, any))
            .thenAnswer((_) async => expectedExpenses);
        
        // Act
        final result = await expenseService.getExpensesByMonth(month);
        
        // Assert
        expect(result, equals(expectedExpenses));
        verify(mockDatabaseService.getExpensesByDateRange(
          DateTime(2025, 6, 1),
          DateTime(2025, 6, 30, 23, 59, 59),
        )).called(1);
      });
      
      test('データベースエラー時は例外をスローする', () async {
        // Arrange
        final month = DateTime(2025, 6);
        when(mockDatabaseService.getExpensesByDateRange(any, any))
            .thenThrow(Exception('Database error'));
        
        // Act & Assert
        expect(
          () => expenseService.getExpensesByMonth(month),
          throwsA(isA<DatabaseException>()),
        );
      });
      
      test('null値の月指定時はArgumentErrorをスローする', () async {
        // Act & Assert
        expect(
          () => expenseService.getExpensesByMonth(null as DateTime),
          throwsArgumentError,
        );
      });
    });
    
    group('calculateMonthlyTotal', () {
      test('空のリストで0を返す', () {
        // Arrange
        final expenses = <Expense>[];
        
        // Act
        final result = expenseService.calculateMonthlyTotal(expenses);
        
        // Assert
        expect(result, equals(0.0));
      });
      
      test('複数の支出の合計を正しく計算する', () {
        // Arrange
        final expenses = [
          Expense(amount: 1000, date: DateTime.now(), category: ExpenseCategory.food),
          Expense(amount: 2000, date: DateTime.now(), category: ExpenseCategory.transportation),
          Expense(amount: 1500, date: DateTime.now(), category: ExpenseCategory.shopping),
        ];
        
        // Act
        final result = expenseService.calculateMonthlyTotal(expenses);
        
        // Assert
        expect(result, equals(4500.0));
      });
    });
  });
}
```

### 🎨 Widget テスト規約

```dart
// ✅ 良い例 - Widgetテストのパターン
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_finance_app/widgets/expense_card.dart';
import 'package:flutter_finance_app/models/expense.dart';

void main() {
  group('ExpenseCard Widget', () {
    late Expense testExpense;
    
    setUp(() {
      testExpense = Expense(
        id: 1,
        amount: 1500,
        date: DateTime(2025, 6, 15),
        category: ExpenseCategory.food,
        note: 'ランチ代',
      );
    });
    
    testWidgets('支出データが正しく表示される', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseCard(expense: testExpense),
          ),
        ),
      );
      
      // Assert
      expect(find.text('食費'), findsOneWidget);
      expect(find.text('¥1,500'), findsOneWidget);
      expect(find.text('06/15'), findsOneWidget);
    });
    
    testWidgets('タップイベントが正しく動作する', (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseCard(
              expense: testExpense,
              onTap: () => wasPressed = true,
            ),
          ),
        ),
      );
      
      // Act
      await tester.tap(find.byType(ExpenseCard));
      await tester.pump();
      
      // Assert
      expect(wasPressed, isTrue);
    });
    
    testWidgets('メモが空の場合は表示されない', (WidgetTester tester) async {
      // Arrange
      final expenseWithoutNote = testExpense.copyWith(note: null);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseCard(expense: expenseWithoutNote),
          ),
        ),
      );
      
      // Assert
      expect(find.text('ランチ代'), findsNothing);
    });
  });
}
```

---

## 🔄 CI/CD・品質管理

### 📊 GitHub Actions 設定例

```yaml
# .github/workflows/dart.yml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.32.2'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Verify formatting
      run: dart format --output=none --set-exit-if-changed .
    
    - name: Analyze project source
      run: flutter analyze --fatal-infos
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info
    
    - name: Build APK
      run: flutter build apk --debug
    
    - name: Build iOS (without signing)
      run: flutter build ios --debug --no-codesign
```

### 📋 コードレビューチェックリスト

#### 🔍 レビュアー向けチェックリスト

**アーキテクチャ・設計**
- [ ] 適切なデザインパターンが使用されている
- [ ] 単一責任原則が守られている
- [ ] 依存関係が適切に管理されている
- [ ] パフォーマンスへの配慮がある

**コード品質**
- [ ] 命名規則が守られている
- [ ] 適切なコメント・ドキュメントがある
- [ ] エラーハンドリングが適切に実装されている
- [ ] null安全性が考慮されている

**テスト**
- [ ] 適切なテストが書かれている
- [ ] テストカバレッジが十分である
- [ ] エッジケースが考慮されている

**UI/UX**
- [ ] レスポンシブデザインに対応している
- [ ] アクセシビリティが考慮されている
- [ ] デザインガイドラインに準拠している

---

## 📚 参考リソース

### 🔗 公式ドキュメント

- **[Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)**
- **[Flutter Widget のスタイル](https://flutter.dev/docs/development/ui/widgets/styling)**
- **[Flutter のパフォーマンス](https://flutter.dev/docs/perf)**

### 📖 推奨書籍・記事

- **[Effective Dart](https://dart.dev/guides/language/effective-dart)**
- **[Flutter Architectural Patterns](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)**
- **[Clean Code in Dart/Flutter](https://medium.com/flutter-community)**

---

**📝 最終更新**: 2025年6月20日  
**📄 ドキュメントバージョン**: v1.0  
**👥 作成者**: [@paraccoli](https://github.com/paraccoli)

---

*📌 **注意**: この規約は継続的に改善されます。チーム全体でのフィードバックを歓迎します。*
