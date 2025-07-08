import 'package:flutter/material.dart';

/// テーマの種類を表すEnum
enum AppThemeType {
  light,
  dark,
  cosmic,
  cosmos,
  nature,
  sunset,
  ocean,
  cyber,
  pinkheart,
  custom,
}

/// テーマ情報を保持するクラス
class ThemeInfo {
  final String name;
  final String description;
  final IconData icon;
  final Color previewColor;

  const ThemeInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.previewColor,
  });
}

/// アプリのテーマとスタイルを管理するクラス
class AppTheme {
  /// 利用可能なテーマの情報
  static const Map<AppThemeType, ThemeInfo> themeInfos = {
    AppThemeType.light: ThemeInfo(
      name: 'ライト',
      description: 'クリーンで明るいテーマ',
      icon: Icons.light_mode,
      previewColor: Color(0xFF007AFF),
    ),
    AppThemeType.dark: ThemeInfo(
      name: 'ダーク',
      description: '目に優しいダークテーマ',
      icon: Icons.dark_mode,
      previewColor: Color(0xFF0A84FF),
    ),    AppThemeType.cosmic: ThemeInfo(
      name: 'コズミック',
      description: '宇宙をイメージした神秘的なテーマ',
      icon: Icons.auto_awesome,
      previewColor: Color(0xFF6C5CE7),
    ),
    AppThemeType.cosmos: ThemeInfo(
      name: 'コスモス',
      description: '宇宙の花園をイメージした美しいテーマ',
      icon: Icons.stars,
      previewColor: Color(0xFFE91E63),
    ),
    AppThemeType.nature: ThemeInfo(
      name: 'ネイチャー',
      description: '自然をイメージした緑豊かなテーマ',
      icon: Icons.eco,
      previewColor: Color(0xFF00B894),
    ),
    AppThemeType.sunset: ThemeInfo(
      name: 'サンセット',
      description: '夕焼けをイメージした暖かなテーマ',
      icon: Icons.wb_sunny,
      previewColor: Color(0xFFE17055),
    ),
    AppThemeType.ocean: ThemeInfo(
      name: 'オーシャン',
      description: '海をイメージした涼しげなテーマ',
      icon: Icons.waves,
      previewColor: Color(0xFF74B9FF),
    ),
    AppThemeType.cyber: ThemeInfo(
      name: 'サイバー',
      description: '未来感あふれるサイバーパンクテーマ',
      icon: Icons.memory,
      previewColor: Color(0xFF00FFFF),
    ),    AppThemeType.pinkheart: ThemeInfo(
      name: 'ピンクハート',
      description: 'キュートで愛らしいピンクテーマ',
      icon: Icons.favorite,
      previewColor: Color(0xFFFF69B4),
    ),
    AppThemeType.custom: ThemeInfo(
      name: 'カスタム',
      description: '自分好みにカスタマイズしたテーマ',
      icon: Icons.palette,
      previewColor: Color(0xFF6C63FF),
    ),
  };/// 指定されたテーマタイプのテーマデータを取得
  static ThemeData getTheme(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.light:
        return lightTheme();
      case AppThemeType.dark:
        return darkTheme();
      case AppThemeType.cosmic:
        return cosmicTheme();
      case AppThemeType.cosmos:
        return cosmosTheme();
      case AppThemeType.nature:
        return natureTheme();
      case AppThemeType.sunset:
        return sunsetTheme();
      case AppThemeType.ocean:
        return oceanTheme();
      case AppThemeType.cyber:
        return cyberTheme();      case AppThemeType.pinkheart:
        return pinkHeartTheme();
      case AppThemeType.custom:
        return lightTheme(); // カスタムテーマの場合はデフォルトライトテーマを返す
    }
  }
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
  /// コズミックテーマ - 宇宙をイメージした神秘的なテーマ
  static ThemeData cosmicTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C5CE7),
        primary: const Color(0xFF6C5CE7),
        secondary: const Color(0xFFA29BFE),
        tertiary: const Color(0xFFE84393),
        surface: const Color(0xFF1A1A2E),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF16213E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A2E),
        foregroundColor: Color(0xFF6C5CE7),
        elevation: 0,
        centerTitle: true,
      ),      cardTheme: CardThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: const Color(0xFF0F3460),
        shadowColor: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF6C5CE7),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF6C5CE7), width: 2.0),
          ),
        ),
        dividerColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0F3460),
        selectedItemColor: Color(0xFF6C5CE7),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C5CE7),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF6C5CE7).withValues(alpha: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF6C5CE7)),
      ),
    );
  }

  /// ネイチャーテーマ - 自然をイメージした緑豊かなテーマ
  static ThemeData natureTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00B894),
        primary: const Color(0xFF00B894),
        secondary: const Color(0xFF55A3FF),
        tertiary: const Color(0xFFFFBE76),
        surface: const Color(0xFFF1F8F5),
      ),
      scaffoldBackgroundColor: const Color(0xFFF1F8F5),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF1F8F5),
        foregroundColor: Color(0xFF00B894),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        color: Colors.white,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF00B894),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF00B894), width: 2.0),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF00B894),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00B894),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF00B894)),
      ),
    );
  }

  /// サンセットテーマ - 夕焼けをイメージした暖かなテーマ
  static ThemeData sunsetTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE17055),
        primary: const Color(0xFFE17055),
        secondary: const Color(0xFFFFBE76),
        tertiary: const Color(0xFFD63031),
        surface: const Color(0xFFFEF7F0),
      ),
      scaffoldBackgroundColor: const Color(0xFFFEF7F0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFEF7F0),
        foregroundColor: Color(0xFFE17055),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: Colors.white,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFFE17055),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE17055), width: 2.0),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFFE17055),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE17055),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFFE17055)),
      ),
    );
  }

  /// オーシャンテーマ - 海をイメージした涼しげなテーマ
  static ThemeData oceanTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF74B9FF),
        primary: const Color(0xFF74B9FF),
        secondary: const Color(0xFF81ECEC),
        tertiary: const Color(0xFF00CEC9),
        surface: const Color(0xFFF0F8FF),
      ),
      scaffoldBackgroundColor: const Color(0xFFF0F8FF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF0F8FF),
        foregroundColor: Color(0xFF74B9FF),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: Colors.white,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF74B9FF),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF74B9FF), width: 2.0),
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF74B9FF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF74B9FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF74B9FF)),
      ),
    );
  }
  /// サイバーテーマ - 未来感あふれるサイバーパンクテーマ
  static ThemeData cyberTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00FFFF),
        primary: const Color(0xFF00FFFF),
        secondary: const Color(0xFFFF00FF),
        tertiary: const Color(0xFF00FF00),
        surface: const Color(0xFF0D1421),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D1421),
        foregroundColor: Color(0xFF00FFFF),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(color: Color(0xFF00FFFF), width: 1),
        ),
        color: const Color(0xFF0A0A0A),
        shadowColor: const Color(0xFF00FFFF).withValues(alpha: 0.5),
      ),      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF00FFFF),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF00FFFF), width: 3.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF00FFFF),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        dividerColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0A0A0A),
        selectedItemColor: Color(0xFF00FFFF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00FFFF),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: const BorderSide(color: Color(0xFF00FFFF), width: 1),
          ),
          elevation: 12,
          shadowColor: const Color(0xFF00FFFF).withValues(alpha: 0.8),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF00FFFF),
          textStyle: const TextStyle(
            shadows: [
              Shadow(
                color: Color(0xFF00FFFF),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
      // サイバーパンク風のアクセント
      iconTheme: const IconThemeData(
        color: Color(0xFF00FFFF),
        shadows: [
          Shadow(
            color: Color(0xFF00FFFF),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  /// ピンクハートテーマ - キュートで愛らしいピンクテーマ
  static ThemeData pinkHeartTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF69B4),
        primary: const Color(0xFFFF69B4),
        secondary: const Color(0xFFFFB6C1),
        tertiary: const Color(0xFFFF1493),
        surface: const Color(0xFFFFF0F5),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFF8FC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFF0F5),
        foregroundColor: Color(0xFFFF69B4),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        color: Colors.white,
        shadowColor: const Color(0xFFFF69B4).withValues(alpha: 0.3),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFFFF69B4),
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Color(0xFFFFB6C1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFFFF69B4),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF69B4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          elevation: 4,
          shadowColor: const Color(0xFFFF69B4).withValues(alpha: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF69B4)),
      ),      // フローティングアクションボタンのテーマも追加
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFF1493),
        foregroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }

  /// コスモステーマ - 宇宙の花園をイメージした美しいテーマ
  static ThemeData cosmosTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE91E63),
        brightness: Brightness.dark,
        primary: const Color(0xFFE91E63), // コスモスピンク
        secondary: const Color(0xFF9C27B0), // パープル
        tertiary: const Color(0xFF673AB7), // ディープパープル        surface: const Color(0xFF1A0E1A), // ダークピンクベース
        onSurface: const Color(0xFFFFE0F0),
      ),      scaffoldBackgroundColor: const Color(0xFF0D0510),      cardTheme: CardThemeData(
        color: const Color(0xFF1A0E1A).withValues(alpha: 0.8),
        elevation: 8,
        shadowColor: const Color(0xFFE91E63).withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(
            color: const Color(0xFFE91E63).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A0E1A),
        foregroundColor: Color(0xFFFFE0F0),
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A0E1A),
        selectedItemColor: Color(0xFFE91E63),
        unselectedItemColor: Color(0xFF9E9E9E),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE91E63),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),          elevation: 6,
          shadowColor: const Color(0xFFE91E63).withValues(alpha: 0.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFFE91E63)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFE91E63),
        foregroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }
}
