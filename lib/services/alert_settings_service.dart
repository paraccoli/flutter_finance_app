import 'package:shared_preferences/shared_preferences.dart';

class AlertSettingsService {
  static const String _budgetAlertEnabledKey = 'budget_alert_enabled';
  static const String _monthlyAlertEnabledKey = 'monthly_alert_enabled';
  static const String _categoryAlertEnabledKey = 'category_alert_enabled';

  // 予算アラート全体のON/OFF
  static Future<bool> isBudgetAlertEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_budgetAlertEnabledKey) ?? true; // デフォルトはON
  }

  static Future<void> setBudgetAlertEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_budgetAlertEnabledKey, enabled);
  }

  // 月次予算アラートのON/OFF
  static Future<bool> isMonthlyAlertEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_monthlyAlertEnabledKey) ?? true; // デフォルトはON
  }

  static Future<void> setMonthlyAlertEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_monthlyAlertEnabledKey, enabled);
  }

  // カテゴリ別予算アラートのON/OFF
  static Future<bool> isCategoryAlertEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_categoryAlertEnabledKey) ?? true; // デフォルトはON
  }

  static Future<void> setCategoryAlertEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_categoryAlertEnabledKey, enabled);
  }

  // すべての設定をリセット
  static Future<void> resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_budgetAlertEnabledKey);
    await prefs.remove(_monthlyAlertEnabledKey);
    await prefs.remove(_categoryAlertEnabledKey);
  }
}
