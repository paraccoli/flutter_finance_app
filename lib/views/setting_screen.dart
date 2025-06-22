import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../services/notification_service.dart';
import '../services/export_service.dart';
import '../services/database_service.dart';
import '../services/budget_service.dart';
import '../utils/app_theme.dart';
import 'help_screen.dart';
import 'budget_setting_screen.dart';
import 'budget_usage_screen.dart';
import 'expense_search_screen.dart';
import 'csv_import_screen.dart';
import 'splash_screen.dart';
import 'theme_selection_screen.dart';
import 'custom_theme_creator_screen.dart';
import 'custom_theme_manager_screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _notificationEnabled = true;
  String _notificationTime = '21:00';
  final NotificationService _notificationService = NotificationService();

  String _appVersion = '';
  String _appName = ''; // 統計情報
  int _totalExpenses = 0;
  int _totalIncomes = 0;
  int _totalNisaInvestments = 0;

  // 予算管理関連
  bool _budgetAlertEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _loadAppInfo();
    _loadStatistics();
    _loadBudgetSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await _notificationService.isNotificationEnabled();
    final time = await _notificationService.getNotificationTime();
    setState(() {
      _notificationEnabled = enabled;
      _notificationTime = time;
    });
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appName = packageInfo.appName;
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _loadBudgetSettings() async {
    await BudgetService.initialize();
    setState(() {
      _budgetAlertEnabled = BudgetService.isBudgetAlertEnabledSync();
    });
  }

  Future<void> _loadStatistics() async {
    try {
      final db = DatabaseService();

      // 支出データ数を取得
      final expenseCount = await db.database.then((database) async {
        final result = await database.rawQuery(
          'SELECT COUNT(*) as count FROM expenses',
        );
        return result.first['count'] as int;
      });

      // 収入データ数を取得
      final incomeCount = await db.database.then((database) async {
        final result = await database.rawQuery(
          'SELECT COUNT(*) as count FROM incomes',
        );
        return result.first['count'] as int;
      });

      // NISA投資データ数を取得
      final nisaCount = await db.database.then((database) async {
        final result = await database.rawQuery(
          'SELECT COUNT(*) as count FROM nisa_investments',
        );
        return result.first['count'] as int;
      });
      setState(() {
        _totalExpenses = expenseCount;
        _totalIncomes = incomeCount;
        _totalNisaInvestments = nisaCount; // NISAデータ数として表示
      });
    } catch (e) {
      debugPrint('統計情報の取得に失敗しました: $e'); // エラー時はデフォルト値を設定
      setState(() {
        _totalExpenses = 0;
        _totalIncomes = 0;
        _totalNisaInvestments = 0;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);    final isDark = themeViewModel.isDarkMode || 
        themeViewModel.currentTheme == AppThemeType.cyber ||
        themeViewModel.currentTheme == AppThemeType.cosmic ||
        themeViewModel.currentTheme == AppThemeType.cosmos;return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : null,
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 外観設定
            _buildSectionTitle('外観設定', isDark),
            const SizedBox(height: 16),            _buildCard(
              isDark,
              Column(
                children: [
                  ListTile(
                    title: const Text('テーマ'),
                    subtitle: Text(AppTheme.themeInfos[themeViewModel.currentTheme]?.name ?? 'ライト'),
                    leading: Icon(AppTheme.themeInfos[themeViewModel.currentTheme]?.icon ?? Icons.light_mode),
                    trailing: const Icon(Icons.arrow_forward_ios),                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ThemeSelectionScreen(),
                        ),
                      );
                    },                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('カスタムテーマ作成'),
                    subtitle: const Text('自分好みのテーマを作成'),
                    leading: const Icon(Icons.palette),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomThemeCreatorScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('カスタムテーマ管理'),
                    subtitle: const Text('作成したテーマの編集・削除'),
                    leading: const Icon(Icons.manage_accounts),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomThemeManagerScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 通知設定
            _buildSectionTitle('通知設定', isDark),
            const SizedBox(height: 16),
            _buildCard(
              isDark,
              Column(
                children: [
                  SwitchListTile(
                    title: const Text('家計簿リマインダー'),
                    subtitle: const Text('毎日決まった時間に記録を促す通知'),
                    value: _notificationEnabled,
                    onChanged: (value) async {
                      setState(() {
                        _notificationEnabled = value;
                      });
                      await _notificationService.setNotificationEnabled(value);
                    },
                    activeColor: Colors.blue,
                  ),
                  if (_notificationEnabled) ...[
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('通知時間'),
                      subtitle: Text('毎日 $_notificationTime に通知'),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectNotificationTime(),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('テスト通知'),
                      subtitle: const Text('今すぐ通知をテストする'),
                      trailing: const Icon(Icons.send),
                      onTap: () => _sendTestNotification(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 予算管理
            _buildSectionTitle('予算管理', isDark),
            const SizedBox(height: 16),
            _buildCard(
              isDark,
              Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.green,
                    ),
                    title: const Text('予算設定'),
                    subtitle: const Text('月次予算とカテゴリ別予算の設定'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BudgetSettingScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.trending_up, color: Colors.blue),
                    title: const Text('予算使用状況'),
                    subtitle: const Text('今月の予算消化率を確認'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BudgetUsageScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.notifications_active,
                      color: Colors.orange,
                    ),
                    title: const Text('予算アラート'),
                    subtitle: const Text('予算超過時の通知設定'),
                    trailing: Switch(
                      value: _budgetAlertEnabled,
                      onChanged: (value) {
                        setState(() {
                          _budgetAlertEnabled = value;
                        });
                        BudgetService.setBudgetAlertEnabled(value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('予算アラートを${value ? '有効' : '無効'}にしました'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 使用統計
            _buildSectionTitle('使用統計', isDark),
            const SizedBox(height: 16),
            _buildCard(
              isDark,
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.trending_down, color: Colors.red),
                    title: const Text('支出記録数'),
                    trailing: Text(
                      '$_totalExpenses件',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.trending_up, color: Colors.green),
                    title: const Text('収入記録数'),
                    trailing: Text(
                      '$_totalIncomes件',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.account_balance,
                      color: Colors.blue,
                    ),
                    title: const Text('NISA投資記録数'),
                    trailing: Text(
                      '$_totalNisaInvestments件',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // データ管理セクション
            _buildSectionTitle('データ管理', isDark),
            const SizedBox(height: 16),
            _buildCard(
              isDark,
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.search),
                    title: const Text('支出・収入の検索'),
                    subtitle: const Text('条件を指定してデータを検索'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _navigateToExpenseSearch(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.file_upload),
                    title: const Text('CSVインポート'),
                    subtitle: const Text('クレジットカード明細をインポート'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _navigateToCSVImport(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.file_download),
                    title: const Text('データエクスポート'),
                    subtitle: const Text('支出・収入データをCSV形式で出力'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showExportDialog(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('データのバックアップ'),
                    subtitle: const Text('すべてのデータをバックアップ'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showBackupDialog(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('データの復元'),
                    subtitle: const Text('バックアップからデータを復元'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showRestoreDialog(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'すべてのデータを削除',
                      style: TextStyle(color: Colors.red),
                    ),
                    subtitle: const Text('すべての記録を完全に削除します'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showDeleteAllDataDialog(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ヘルプ・サポート
            _buildSectionTitle('ヘルプ・サポート', isDark),
            const SizedBox(height: 16),
            _buildCard(
              isDark,
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help, color: Colors.blue),
                    title: const Text('使い方ガイド'),
                    subtitle: const Text('アプリの使い方とよくある質問'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.quiz, color: Colors.purple),
                    title: const Text('初回チュートリアル'),
                    subtitle: const Text('アプリの基本的な使い方を学ぶ'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showTutorialDialog(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.feedback, color: Colors.orange),
                    title: const Text('フィードバック'),
                    subtitle: const Text('改善要望やバグ報告'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launchUrl(
                      'https://github.com/paraccoli/flutter_finance_app/issues',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 開発者情報
            _buildSectionTitle('開発者情報', isDark),
            const SizedBox(height: 16),
            _buildCard(
              isDark,
              Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.person, color: Colors.blue),
                    title: Text('開発者'),
                    subtitle: Text('paraccoli'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.code, color: Colors.purple),
                    title: const Text('GitHub'),
                    subtitle: const Text('ソースコードとプロジェクト'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launchUrl('https://github.com/paraccoli'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.alternate_email, color: Colors.black87),
                    title: const Text('X (Twitter)'),
                    subtitle: const Text('最新情報とアップデート'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launchUrl('https://twitter.com/paraccoli'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.bug_report, color: Colors.orange),
                    title: const Text('バグ報告・要望'),
                    subtitle: const Text('GitHubでissueを作成'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launchUrl(
                      'https://github.com/paraccoli/flutter_finance_app/issues',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // アプリ情報
            _buildSectionTitle('アプリ情報', isDark),
            const SizedBox(height: 16),
            _buildCard(
              isDark,
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('アプリ名'),
                    subtitle: Text(_appName.isNotEmpty ? _appName : 'Money:G'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.update),
                    title: const Text('バージョン'),
                    subtitle: Text(
                      _appVersion.isNotEmpty ? _appVersion : '1.0.0',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: const Text('アプリを評価'),
                    subtitle: const Text('Google Playでアプリを評価してください'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launchUrl(
                      'https://play.google.com/store/apps/details?id=com.moneyg.finance_app',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.share, color: Colors.green),
                    title: const Text('アプリをシェア'),
                    subtitle: const Text('友達にMoney:Gを紹介'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _shareApp(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip, color: Colors.grey),
                    title: const Text('プライバシーポリシー'),
                    subtitle: const Text('データの取り扱いについて'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launchUrl(
                      'https://github.com/paraccoli/flutter_finance_app/blob/main/PRIVACY.md',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  Widget _buildSectionTitle(String title, bool isDark) {
    final themeViewModel = Provider.of<ThemeViewModel>(context, listen: false);
    final shouldBeDark = isDark || 
        themeViewModel.currentTheme == AppThemeType.cyber ||
        themeViewModel.currentTheme == AppThemeType.cosmic;
        
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: shouldBeDark ? Colors.white : Colors.black,
      ),
    );
  }
  Widget _buildCard(bool isDark, Widget child) {
    final themeViewModel = Provider.of<ThemeViewModel>(context, listen: false);
    final shouldBeDark = isDark || 
        themeViewModel.currentTheme == AppThemeType.cyber ||
        themeViewModel.currentTheme == AppThemeType.cosmic;
        
    return Card(
      elevation: 2,
      color: shouldBeDark ? Colors.grey[800] : Colors.white,
      child: child,
    );
  }

  Future<void> _selectNotificationTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_notificationTime.split(':')[0]),
        minute: int.parse(_notificationTime.split(':')[1]),
      ),
    );

    if (picked != null) {
      final timeString =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _notificationTime = timeString;
      });
      await _notificationService.setNotificationTime(timeString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('通知時間を $_notificationTime に設定しました')),
        );
      }
    }
  }

  Future<void> _sendTestNotification() async {
    await _notificationService.sendTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('テスト通知を送信しました')));
    }
  }

  // データ削除ダイアログの表示
  void _showDeleteAllDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('データ削除の確認'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠️ 重要な警告',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'この操作により、以下のすべてのデータが完全に削除されます：',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• すべての支出記録'),
              Text('• すべての収入記録'),
              Text('• NISA投資記録'),
              Text('• 予算設定'),
              SizedBox(height: 12),
              Text(
                '削除されたデータは復元できません。\n本当に続行しますか？',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showFinalConfirmationDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('削除する'),
            ),
          ],
        );
      },
    );
  }

  // 最終確認ダイアログ
  void _showFinalConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('最終確認'),
          content: const Text(
            '本当にすべてのデータを削除しますか？\n\nこの操作は取り消せません。',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAllData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('完全に削除'),
            ),
          ],
        );
      },
    );
  }

  // データ削除の実行
  Future<void> _deleteAllData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('データを削除しています...'),
            ],
          ),
        );
      },
    );

    try {
      await DatabaseService().deleteAllData();

      if (mounted) {
        Navigator.of(context).pop(); // プログレスダイアログを閉じる

        // スプラッシュスクリーンを経由してホーム画面に戻る
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // プログレスダイアログを閉じる

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('データ削除に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // URL起動メソッド
  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('URLを開けませんでした: $url')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('URLの形式が正しくありません')));
      }
    }
  }

  // アプリシェアメソッド
  void _shareApp() {
    // TODO: share_plus パッケージを使用してアプリをシェア
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('シェア機能は近日実装予定です')));
  }

  // バックアップダイアログの表示
  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.backup, color: Colors.blue),
              SizedBox(width: 8),
              Text('データバックアップ'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📋 バックアップ内容',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• すべての支出記録'),
              Text('• すべての収入記録'),
              Text('• NISA投資記録'),
              Text('• 作成日時と統計情報'),
              SizedBox(height: 12),
              Text(
                '💾 保存場所',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('アプリ内のドキュメントフォルダに\nJSON形式で保存されます'),
              SizedBox(height: 12),
              Text(
                'バックアップを作成しますか？',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createBackup();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('バックアップ作成'),
            ),
          ],
        );
      },
    );
  }

  // バックアップ作成の実行
  Future<void> _createBackup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('バックアップを作成しています...'),
            ],
          ),
        );
      },
    );

    try {
      final filePath = await DatabaseService().createBackup();

      if (mounted) {
        Navigator.of(context).pop(); // プログレスダイアログを閉じる

        _showBackupSuccessDialog(filePath);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // プログレスダイアログを閉じる

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('バックアップ作成に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // バックアップ成功ダイアログ
  void _showBackupSuccessDialog(String filePath) {
    final fileName = filePath.split(Platform.pathSeparator).last;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('バックアップ完了'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '✅ バックアップが正常に作成されました',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('📁 ファイル名:'),
              Text(
                fileName,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
              const SizedBox(height: 8),
              const Text('💾 保存場所: アプリ内ドキュメントフォルダ'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  // 復元ダイアログの表示
  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.restore, color: Colors.orange),
              SizedBox(width: 8),
              Text('データ復元'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⚠️ 重要な注意事項',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Text('• 現在のすべてのデータが削除されます'),
              Text('• バックアップファイルのデータで置き換えられます'),
              Text('• この操作は取り消せません'),
              SizedBox(height: 12),
              Text(
                '利用可能なバックアップファイルから選択してください',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showBackupFileSelectionDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('ファイル選択'),
            ),
          ],
        );
      },
    );
  }

  // バックアップファイル選択ダイアログ
  void _showBackupFileSelectionDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('バックアップファイルを検索しています...'),
            ],
          ),
        );
      },
    );

    try {
      final backupFiles = await DatabaseService().getAvailableBackups();

      if (mounted) {
        Navigator.of(context).pop(); // プログレスダイアログを閉じる

        if (backupFiles.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('利用可能なバックアップファイルが見つかりません'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        _showBackupListDialog(backupFiles);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // プログレスダイアログを閉じる

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('バックアップファイルの検索に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // バックアップファイルリストダイアログ
  void _showBackupListDialog(List<String> backupFiles) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('バックアップファイル選択'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: backupFiles.length,
              itemBuilder: (context, index) {
                final filePath = backupFiles[index];
                final fileName = filePath.split(Platform.pathSeparator).last;
                final displayName = fileName
                    .replaceAll('MoneyG_Backup_', '')
                    .replaceAll('.json', '')
                    .replaceAll('-', ':')
                    .replaceAll('T', ' ');

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.backup, color: Colors.blue),
                    title: Text(
                      displayName,
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: FutureBuilder<Map<String, dynamic>?>(
                      future: DatabaseService().getBackupInfo(filePath),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final stats =
                              snapshot.data!['statistics']
                                  as Map<String, dynamic>? ??
                              {};
                          return Text(
                            '支出: ${stats['total_expenses'] ?? 0}件, '
                            '収入: ${stats['total_incomes'] ?? 0}件, '
                            'NISA: ${stats['total_nisa_investments'] ?? 0}件',
                            style: const TextStyle(fontSize: 12),
                          );
                        }
                        return const Text('情報を取得中...');
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _confirmRestore(filePath);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
          ],
        );
      },
    );
  }

  // 復元確認ダイアログ
  void _confirmRestore(String filePath) {
    final fileName = filePath.split(Platform.pathSeparator).last;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('復元の最終確認'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⚠️ 現在のデータがすべて削除され、以下のバックアップで置き換えられます：',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text('📁 $fileName'),
              const SizedBox(height: 12),
              const Text(
                'この操作は取り消せません。続行しますか？',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restoreFromBackup(filePath);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('復元実行'),
            ),
          ],
        );
      },
    );
  }

  // データ復元の実行
  Future<void> _restoreFromBackup(String filePath) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('データを復元しています...'),
            ],
          ),
        );
      },
    );

    try {
      await DatabaseService().restoreFromBackup(filePath);

      if (mounted) {
        Navigator.of(context).pop(); // プログレスダイアログを閉じる

        // スプラッシュスクリーンを経由してホーム画面に戻る
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // プログレスダイアログを閉じる

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('データ復元に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // チュートリアルダイアログ
  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📱 Money:G 使い方ガイド'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '💰 支出・収入の記録',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('下部のタブから金額とカテゴリを選択して記録'),
              SizedBox(height: 12),
              Text('📊 月次レポート', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('月ごとの支出内訳をグラフで確認'),
              SizedBox(height: 12),
              Text('📈 資産分析', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('収支のトレンドと貯蓄の推移を分析'),
              SizedBox(height: 12),
              Text('💹 NISA管理', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('投資記録と運用成果を管理'),
              SizedBox(height: 12),
              Text('⚙️ 設定', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('通知設定やデータ管理機能'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
            child: const Text('詳細ガイド'),
          ),
        ],
      ),
    );
  }

  // データ管理  // 支出検索画面への遷移
  void _navigateToExpenseSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseSearchScreen()),
    );
  }

  // CSVインポート画面への遷移
  void _navigateToCSVImport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CSVImportScreen()),
    );
  }

  // エクスポートダイアログの表示
  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データエクスポート'),
        content: const Text('どのデータをエクスポートしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _exportExpenses();
            },
            child: const Text('支出のみ'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _exportIncomes();
            },
            child: const Text('収入のみ'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _exportAllData();
            },
            child: const Text('全データ'),
          ),
        ],
      ),
    );
  }

  // 支出データのエクスポート
  Future<void> _exportExpenses() async {
    try {
      await ExportService.exportExpensesToCsv();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('支出データをエクスポートしました')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エクスポートに失敗しました: $e')));
      }
    }
  }

  // 収入データのエクスポート
  Future<void> _exportIncomes() async {
    try {
      await ExportService.exportIncomesToCsv();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('収入データをエクスポートしました')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エクスポートに失敗しました: $e')));
      }
    }
  } // 全データのエクスポート

  Future<void> _exportAllData() async {
    try {
      await ExportService.exportAllDataToCsv();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('全データをエクスポートしました')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エクスポートに失敗しました: $e')));
      }
    }
  }
}
