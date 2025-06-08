import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/income_viewmodel.dart';
import '../widgets/expense_form.dart';
import '../widgets/income_form.dart';
import 'expense_screen.dart';
import 'income_screen.dart';
import 'nisa_screen.dart';
import 'asset_analysis_screen.dart';
import 'monthly_report_screen.dart';
import 'setting_screen.dart';
import 'expense_search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

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
    final isDark = themeViewModel.isDarkMode;
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '支出',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: '収入',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'NISA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '資産分析',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: '月次レポート',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
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
        // 検索ボタン
        FloatingActionButton(
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
        const SizedBox(height: 16),
        // 追加ボタン
        FloatingActionButton(
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
      ],
    );
  }
  void _showAddExpenseDialog() {
    final expenseViewModel =
        Provider.of<ExpenseViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('支出を追加'),
          content: SingleChildScrollView(
            child: ExpenseForm(
              onSave: (expense) {
                expenseViewModel.addExpense(expense);
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddIncomeDialog() {
    final incomeViewModel =
        Provider.of<IncomeViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('収入を追加'),
          content: SingleChildScrollView(
            child: IncomeForm(
              onSave: (income) {
                incomeViewModel.addIncome(income);
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }
}
