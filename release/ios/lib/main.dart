import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;
import 'viewmodels/expense_viewmodel.dart';
import 'viewmodels/nisa_viewmodel.dart';
import 'viewmodels/income_viewmodel.dart';
import 'viewmodels/asset_analysis_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'views/splash_screen.dart';
import 'utils/app_theme.dart';
import 'services/database_service.dart'; // DatabaseServiceをインポート
import 'services/notification_service.dart'; // NotificationServiceをインポート

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // プラットフォームに応じてSQLiteの初期化
  if (!Platform.isAndroid && !Platform.isIOS) {
    // デスクトッププラットフォーム用の初期化（Windows/Linux/macOS）
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }  // データベースの初期化を確認
  try {
    final db = await DatabaseService().database;
    // デバッグビルドでのみログ出力
    if (kDebugMode) {
      debugPrint('データベース初期化成功: ${db.path}');
    }

    // テーブルが存在するか確認
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    if (kDebugMode) {
      debugPrint('テーブル一覧: $tables');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('データベース初期化エラー: $e');
    }
  }

  // 通知サービスの初期化
  try {
    await NotificationService().initialize();
    if (kDebugMode) {
      debugPrint('通知サービス初期化成功');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('通知サービス初期化エラー: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => ExpenseViewModel()),
        ChangeNotifierProvider(create: (_) => NisaViewModel()),
        ChangeNotifierProvider(create: (_) => IncomeViewModel()),
        ChangeNotifierProvider(create: (_) => AssetAnalysisViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {          return AnimatedTheme(
            data: themeViewModel.isDarkMode
                ? AppTheme.darkTheme()
                : AppTheme.lightTheme(),
            duration: const Duration(milliseconds: 300),
            child: MaterialApp(
              title: 'Money:G',
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: themeViewModel.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: const SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}
