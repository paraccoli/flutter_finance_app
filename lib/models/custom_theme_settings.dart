import 'package:flutter/material.dart';

/// カスタムテーマの設定を保持するクラス
class CustomThemeSettings {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final double fontSize;
  final bool showBalanceOnHome;
  final bool showCategoryIcons;
  final bool useGradientCards;
  final bool enableAnimations;
  final DateTime createdAt;

  const CustomThemeSettings({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    this.fontSize = 14.0,
    this.showBalanceOnHome = true,
    this.showCategoryIcons = true,
    this.useGradientCards = false,
    this.enableAnimations = true,
    required this.createdAt,
  });

  /// JSONからCustomThemeSettingsを作成
  factory CustomThemeSettings.fromJson(Map<String, dynamic> json) {
    return CustomThemeSettings(
      name: json['name'] ?? 'カスタムテーマ',
      primaryColor: Color(json['primaryColor'] ?? 0xFF007AFF),
      secondaryColor: Color(json['secondaryColor'] ?? 0xFF34C759),
      accentColor: Color(json['accentColor'] ?? 0xFFFF9500),
      fontSize: json['fontSize']?.toDouble() ?? 14.0,
      showBalanceOnHome: json['showBalanceOnHome'] ?? true,
      showCategoryIcons: json['showCategoryIcons'] ?? true,
      useGradientCards: json['useGradientCards'] ?? false,
      enableAnimations: json['enableAnimations'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
  /// CustomThemeSettingsをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'primaryColor': primaryColor.toARGB32(),
      'secondaryColor': secondaryColor.toARGB32(),
      'accentColor': accentColor.toARGB32(),
      'fontSize': fontSize,
      'showBalanceOnHome': showBalanceOnHome,
      'showCategoryIcons': showCategoryIcons,
      'useGradientCards': useGradientCards,
      'enableAnimations': enableAnimations,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// カスタムテーマの設定をコピーして一部を変更
  CustomThemeSettings copyWith({
    String? name,
    Color? primaryColor,
    Color? secondaryColor,
    Color? accentColor,
    double? fontSize,
    bool? showBalanceOnHome,
    bool? showCategoryIcons,
    bool? useGradientCards,
    bool? enableAnimations,
    DateTime? createdAt,
  }) {
    return CustomThemeSettings(
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
      fontSize: fontSize ?? this.fontSize,
      showBalanceOnHome: showBalanceOnHome ?? this.showBalanceOnHome,
      showCategoryIcons: showCategoryIcons ?? this.showCategoryIcons,
      useGradientCards: useGradientCards ?? this.useGradientCards,
      enableAnimations: enableAnimations ?? this.enableAnimations,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// このカスタムテーマ設定からThemeDataを生成
  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: fontSize + 2),
        bodyMedium: TextStyle(fontSize: fontSize),
        bodySmall: TextStyle(fontSize: fontSize - 2),
        titleLarge: TextStyle(fontSize: fontSize + 8),
        titleMedium: TextStyle(fontSize: fontSize + 4),
        titleSmall: TextStyle(fontSize: fontSize + 2),
      ),
      cardTheme: CardThemeData(
        elevation: useGradientCards ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  /// ダークテーマ版のThemeDataを生成
  ThemeData toDarkThemeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontSize: fontSize + 2),
        bodyMedium: TextStyle(fontSize: fontSize),
        bodySmall: TextStyle(fontSize: fontSize - 2),
        titleLarge: TextStyle(fontSize: fontSize + 8),
        titleMedium: TextStyle(fontSize: fontSize + 4),
        titleSmall: TextStyle(fontSize: fontSize + 2),
      ),
      cardTheme: CardThemeData(
        elevation: useGradientCards ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor.withValues(alpha: 0.9),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
