import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/income_viewmodel.dart';
import '../utils/app_theme.dart';
import '../widgets/expense_form.dart';
import '../widgets/income_form.dart';
import '../services/tutorial_service.dart';
import 'expense_screen.dart';
import 'income_screen.dart';
import 'nisa_screen.dart';
import 'asset_analysis_screen.dart';
import 'monthly_report_screen.dart';
import 'setting_screen.dart';
import 'expense_search_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool showTutorial;
  const HomeScreen({super.key, required this.showTutorial});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  // チュートリアル用のキー
  final GlobalKey _addFabKey = GlobalKey();
  final GlobalKey _expenseTabKey = GlobalKey();
  final GlobalKey _reportTabKey = GlobalKey();
  final GlobalKey _nisaTabKey = GlobalKey();
  final GlobalKey _settingTabKey = GlobalKey();
  final GlobalKey _searchFabKey = GlobalKey();
  final GlobalKey _showAllFabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    
    // チュートリアルを表示する場合、初回ビルド後にチュートリアルを開始
    if (widget.showTutorial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTutorialDialog();
      });
    }
  }

  void _showTutorialDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ようこそ！'),
          content: const Text(
            'これからアプリの全ての機能を一緒に操作していきます。\n'
            '指示に従ってタップやスライドをしてみてください。',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startTutorial();
              },
              child: const Text('はじめる'),
            ),
          ],
        );
      },
    );
  }

  void _startTutorial() {
    ShowCaseWidget.of(context).startShowCase([
      _addFabKey,
      _expenseTabKey,
      _reportTabKey,
      _nisaTabKey,
      _searchFabKey,
      _showAllFabKey,
      _settingTabKey,
    ]);
  }

  void _onTutorialFinish() async {
    await TutorialService.markTutorialCompleted();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('お疲れ様でした！これで全ての基本操作は完了です。'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  final List<Widget> _screens = [
    const ExpenseScreen(),
    const IncomeScreen(),
    const NisaScreen(),
    const AssetAnalysisScreen(),
    const MonthlyReportScreen(),
    const SettingScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final isDark = themeViewModel.isDarkMode || 
        themeViewModel.currentTheme == AppThemeType.cyber ||
        themeViewModel.currentTheme == AppThemeType.cosmic ||
        themeViewModel.currentTheme == AppThemeType.cosmos;

    // チュートリアル用にShowCaseWidgetでラップする場合
    if (widget.showTutorial) {
      return ShowCaseWidget(
        onFinish: _onTutorialFinish,
        enableAutoScroll: true,
        blurValue: 1,
        autoPlay: false,
        builder: (context) => _buildHomeScreen(isDark),
      );
    } else {
      return _buildHomeScreen(isDark);
    }
  }

  Widget _buildHomeScreen(bool isDark) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: _buildFloatingActionButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        selectedItemColor: isDark ? Colors.blue : const Color(0xFF007AFF),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Showcase(
              key: _expenseTabKey,
              title: '① 支出の管理',
              description: 'ここで支出の記録や確認ができます。日々の出費を簡単に管理できます。',
              child: const Icon(Icons.shopping_cart),
            ),
            label: '支出',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: '収入',
          ),
          BottomNavigationBarItem(
            icon: Showcase(
              key: _nisaTabKey,
              title: '⑧ 資産の管理',
              description: '日々の収支だけでなく、NISAなどの資産もここで管理できます。投資状況の記録にご活用ください。',
              child: const Icon(Icons.trending_up),
            ),
            label: 'NISA',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '資産分析',
          ),
          BottomNavigationBarItem(
            icon: Showcase(
              key: _reportTabKey,
              title: '⑥ レポートの確認',
              description: '次に、記録したデータがどう見えるか確認しましょう。この「レポート」アイコンをタップしてください。',
              child: const Icon(Icons.assessment),
            ),
            label: '月次レポート',
          ),
          BottomNavigationBarItem(
            icon: Showcase(
              key: _settingTabKey,
              title: '⑨ カテゴリーを自由に設定',
              description: '最後に、自分だけのカテゴリーを作ってみましょう。「設定」からカテゴリー編集画面に進むと、趣味の費用や特定の出費などを自由に追加できます。',
              child: const Icon(Icons.settings),
            ),
            label: '設定',
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButtons() {
    if (_currentIndex != 0 && _currentIndex != 1) {
      return null; // 支出・収入画面以外では表示しない
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // すべて表示ボタン（支出画面のみ）
        if (_currentIndex == 0)
          Showcase(
            key: _showAllFabKey,
            title: '④ すべて表示',
            description: 'タップするとすべての支出データを表示します。フィルターがかかっている時に便利です。',
            child: FloatingActionButton(
              heroTag: "show_all_fab",
              onPressed: () {
                final expenseViewModel = Provider.of<ExpenseViewModel>(context, listen: false);
                expenseViewModel.loadAllExpenses();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('すべての支出を表示しています'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'すべて表示',
              backgroundColor: Colors.orange,
              child: const Icon(Icons.view_list),
            ),
          ),
        if (_currentIndex == 0) const SizedBox(height: 16),
        // 検索ボタン
        Showcase(
          key: _searchFabKey,
          title: '⑤ 検索機能',
          description: '記録した支出や収入をキーワードで検索できます。特定の項目を素早く見つけられます。',
          child: FloatingActionButton(
            heroTag: "search_fab",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ExpenseSearchScreen()),
              );
            },
            tooltip: '検索',
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        // 追加ボタン
        Showcase(
          key: _addFabKey,
          title: '① 支出の記録',
          description: 'まずは、支出を記録してみましょう。家計管理の第一歩です。この「+」ボタンをタップしてください。',
          onTargetClick: () {
            _showAddExpenseDialog(isTutorial: true);
          },
          disposeOnTap: true,
          child: FloatingActionButton(
            heroTag: "add_fab",
            onPressed: () {
              if (_currentIndex == 0) {
                // 支出追加
                _showAddExpenseDialog();
              } else if (_currentIndex == 1) {
                // 収入追加
                _showAddIncomeDialog();
              }
            },
            tooltip: _currentIndex == 0 ? '支出を追加' : '収入を追加',
            backgroundColor: _currentIndex == 0 ? null : Colors.green,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }  void _showAddExpenseDialog({bool isTutorial = false}) {
    final expenseViewModel =
        Provider.of<ExpenseViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isTutorial ? '② 内容の入力' : '支出を追加'),
          content: SingleChildScrollView(
            child: ExpenseForm(
              isTutorial: isTutorial,
              onSave: (expense) async {
                await expenseViewModel.addExpense(expense);
                if (context.mounted) {
                  Navigator.pop(context); // ダイアログを閉じる
                  if (isTutorial) {
                    // チュートリアル中の場合、追加した項目の説明を表示
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('③ 記録の確認：記録した支出がリストに追加されました。'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }  void _showAddIncomeDialog() {
    final incomeViewModel =
        Provider.of<IncomeViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('収入を追加'),
          content: SingleChildScrollView(
            child: IncomeForm(
              onSave: (income) async {
                await incomeViewModel.addIncome(income);
                if (context.mounted) {
                  Navigator.pop(context); // ダイアログを閉じる
                }
              },
            ),
          ),
        );
      },
    );
  }
}
