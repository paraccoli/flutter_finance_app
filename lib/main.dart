import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'viewmodels/expense_viewmodel.dart';
import 'viewmodels/nisa_viewmodel.dart';
import 'viewmodels/income_viewmodel.dart';
import 'viewmodels/asset_analysis_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  // SQLite FFIの初期化（Windows/Linux/macOS対応）
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExpenseViewModel()),
        ChangeNotifierProvider(create: (_) => NisaViewModel()),
        ChangeNotifierProvider(create: (_) => IncomeViewModel()),
        ChangeNotifierProvider(create: (_) => AssetAnalysisViewModel()),
      ],
      child: MaterialApp(
        title: '個人財務管理',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5), // ブルー系のテーマカラー
            primary: const Color(0xFF1E88E5),
            secondary: const Color(0xFF26A69A), // 収入用のグリーン系のカラー
            tertiary: const Color(0xFFEF6C00), // NISA用のオレンジ系のカラー
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
            ),
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.notoSansJpTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
