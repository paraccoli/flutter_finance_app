
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/app_theme.dart';
import '../models/custom_theme_settings.dart';

/// テーマ設定を管理するViewModel
class ThemeViewModel extends ChangeNotifier {
  /// 現在のテーマタイプ
  AppThemeType _currentTheme = AppThemeType.light;
  
  /// 現在のカスタムテーマ設定
  CustomThemeSettings? _currentCustomTheme;
  
  /// 保存されたカスタムテーマのリスト
  List<CustomThemeSettings> _customThemes = [];

  /// 現在のテーマタイプを取得
  AppThemeType get currentTheme => _currentTheme;
  
  /// 現在のカスタムテーマ設定を取得
  CustomThemeSettings? get currentCustomTheme => _currentCustomTheme;
  
  /// 保存されたカスタムテーマのリストを取得
  List<CustomThemeSettings> get customThemes => List.unmodifiable(_customThemes);

  /// 現在のテーマデータを取得
  ThemeData get themeData {
    if (_currentTheme == AppThemeType.custom && _currentCustomTheme != null) {
      return _currentCustomTheme!.toThemeData();
    }
    return AppTheme.getTheme(_currentTheme);
  }

  /// ダークモードかどうか（後方互換性のため）
  bool get isDarkMode => _currentTheme == AppThemeType.dark;

  /// コンストラクタ - 設定値をロード
  ThemeViewModel() {
    _loadPreferences();
  }

  /// テーマを変更する
  void changeTheme(AppThemeType themeType) async {
    if (_currentTheme == themeType) return;
    _currentTheme = themeType;
    
    // カスタムテーマ以外の場合はカスタムテーマ設定をクリア
    if (themeType != AppThemeType.custom) {
      _currentCustomTheme = null;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeType', themeType.toString());
    notifyListeners();
  }
  
  /// カスタムテーマを適用する
  void applyCustomTheme(CustomThemeSettings customTheme) async {
    _currentTheme = AppThemeType.custom;
    _currentCustomTheme = customTheme;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeType', AppThemeType.custom.toString());
    await prefs.setString('currentCustomTheme', jsonEncode(customTheme.toJson()));
    notifyListeners();
  }
  
  /// カスタムテーマを保存する
  Future<void> saveCustomTheme(CustomThemeSettings theme) async {
    // 同じ名前のテーマがある場合は更新、なければ追加
    final existingIndex = _customThemes.indexWhere((t) => t.name == theme.name);
    if (existingIndex != -1) {
      _customThemes[existingIndex] = theme;
    } else {
      _customThemes.add(theme);
    }
    
    await _saveCustomThemes();
    notifyListeners();
  }
  
  /// カスタムテーマを削除する
  Future<void> deleteCustomTheme(String themeName) async {
    _customThemes.removeWhere((theme) => theme.name == themeName);
    
    // 削除したテーマが現在適用中の場合はライトテーマに戻す
    if (_currentCustomTheme?.name == themeName) {
      changeTheme(AppThemeType.light);
    }
    
    await _saveCustomThemes();
    notifyListeners();
  }
  
  /// カスタムテーマを編集する
  Future<void> updateCustomTheme(String oldName, CustomThemeSettings newTheme) async {
    final index = _customThemes.indexWhere((theme) => theme.name == oldName);
    if (index != -1) {
      _customThemes[index] = newTheme;
      
      // 編集したテーマが現在適用中の場合は更新
      if (_currentCustomTheme?.name == oldName) {
        _currentCustomTheme = newTheme;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentCustomTheme', jsonEncode(newTheme.toJson()));
      }
      
      await _saveCustomThemes();
      notifyListeners();
    }
  }

  /// ダークモードと通常モードを切り替える（後方互換性のため）
  void toggleTheme() async {
    final newTheme = _currentTheme == AppThemeType.dark 
        ? AppThemeType.light 
        : AppThemeType.dark;
    changeTheme(newTheme);
  }

  /// ダークモードを直接設定するメソッド（後方互換性のため）
  void setDarkMode(bool value) async {
    final newTheme = value ? AppThemeType.dark : AppThemeType.light;
    changeTheme(newTheme);
  }

  /// 設定をSharedPreferencesから読み込む
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 新しい形式のテーマ設定を読み込み
    final themeTypeString = prefs.getString('themeType');
    if (themeTypeString != null) {
      try {
        _currentTheme = AppThemeType.values.firstWhere(
          (e) => e.toString() == themeTypeString,
          orElse: () => AppThemeType.light,
        );
        
        // カスタムテーマの場合は設定を読み込み
        if (_currentTheme == AppThemeType.custom) {
          final customThemeJson = prefs.getString('currentCustomTheme');
          if (customThemeJson != null) {
            final customThemeData = jsonDecode(customThemeJson) as Map<String, dynamic>;
            _currentCustomTheme = CustomThemeSettings.fromJson(customThemeData);
          }
        }
      } catch (e) {
        _currentTheme = AppThemeType.light;
      }
    } else {
      // 古い形式（isDarkMode）からの移行処理
      final isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _currentTheme = isDarkMode ? AppThemeType.dark : AppThemeType.light;
      // 新しい形式で保存
      await prefs.setString('themeType', _currentTheme.toString());
    }
    
    // カスタムテーマのリストを読み込み
    await _loadCustomThemes();
    
    notifyListeners();
  }
  
  /// カスタムテーマのリストを読み込む
  Future<void> _loadCustomThemes() async {
    final prefs = await SharedPreferences.getInstance();
    final customThemesJson = prefs.getStringList('customThemes') ?? [];
    
    _customThemes = customThemesJson.map((themeJson) {
      final themeData = jsonDecode(themeJson) as Map<String, dynamic>;
      return CustomThemeSettings.fromJson(themeData);
    }).toList();
  }
  
  /// カスタムテーマのリストを保存する
  Future<void> _saveCustomThemes() async {
    final prefs = await SharedPreferences.getInstance();
    final customThemesJson = _customThemes.map((theme) => jsonEncode(theme.toJson())).toList();
    await prefs.setStringList('customThemes', customThemesJson);
  }
}
