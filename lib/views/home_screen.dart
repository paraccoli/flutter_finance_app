import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_viewmodel.dart';
import 'expense_screen.dart';
import 'income_screen.dart';
import 'nisa_screen.dart';
import 'asset_analysis_screen.dart';
import 'monthly_report_screen.dart';
import 'setting_screen.dart';

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
}
