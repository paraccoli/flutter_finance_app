import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../viewmodels/nisa_viewmodel.dart';
import '../viewmodels/income_viewmodel.dart';
import '../viewmodels/asset_analysis_viewmodel.dart';
import 'expense_screen.dart';
import 'nisa_screen.dart';
import 'income_screen.dart';
import 'asset_analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const ExpenseScreen(),
    const IncomeScreen(),
    const NisaScreen(),
    const AssetAnalysisScreen(),
  ];
  @override
  void initState() {
    super.initState();
    // 画面が表示されたらデータをロード
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseViewModel>().loadExpenses();
      context.read<IncomeViewModel>().loadIncomes();
      context.read<NisaViewModel>().loadInvestments();
      context.read<AssetAnalysisViewModel>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('個人財務管理'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _screens[_selectedIndex],      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // 4つ以上のアイテムがある場合に必要
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '支出',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: '収入',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: 'NISA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '資産分析',
          ),
        ],
      ),
    );
  }
}
