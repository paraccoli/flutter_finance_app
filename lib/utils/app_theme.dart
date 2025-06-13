import 'package:flutter/material.dart';

/// アプリのテーマとスタイルを管理するクラス
class AppTheme {
  /// ライトモードのテーマ
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF007AFF), // iOSブルー
        primary: const Color(0xFF007AFF),
        secondary: const Color(0xFF34C759), // 収入用のグリーン系のカラー
        tertiary: const Color(0xFFFF9500), // NISA用のオレンジ系のカラー
        surface: const Color(0xFFF2F2F7), // iOSライトモードの背景色
      ),
      scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF2F2F7),
        foregroundColor: Color(0xFF007AFF),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Colors.white,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF007AFF),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF007AFF), width: 2.0),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF007AFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007AFF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF007AFF)),
      ),
    );
  }

  /// ダークモードのテーマ
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0A84FF), // iOSブルー（ダーク）
        primary: const Color(0xFF0A84FF),
        secondary: const Color(0xFF30D158), // 収入用のグリーン系のカラー（ダーク）
        tertiary: const Color(0xFFFF9F0A), // NISA用のオレンジ系のカラー（ダーク）
        surface: const Color(0xFF1C1C1E), // iOSダークモードの背景色
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF1C1C1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1C1C1E),
        foregroundColor: Color(0xFF0A84FF),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: const Color(0xFF2C2C2E),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF0A84FF),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF0A84FF), width: 2.0),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1C1C1E),
        selectedItemColor: Color(0xFF0A84FF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A84FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF0A84FF)),
      ),
    );  }
}
