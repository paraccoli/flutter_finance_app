import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// テーマ設定を管理するViewModel
class ThemeViewModel extends ChangeNotifier {
  /// ダークモードかどうか
  bool _isDarkMode = false;

  /// ダークモードかどうかを取得
  bool get isDarkMode => _isDarkMode;

  /// コンストラクタ - 設定値をロード
  ThemeViewModel() {
    _loadPreferences();
  }

  /// ダークモードと通常モードを切り替える
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  /// ダークモードを直接設定するメソッド
  void setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  /// 設定をSharedPreferencesから読み込む
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // デフォルトはダークモード（ユーザーが選択できるように）
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}
