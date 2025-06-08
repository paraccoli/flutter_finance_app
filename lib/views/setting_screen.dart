import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../services/notification_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _notificationEnabled = true;
  String _notificationTime = '21:00';
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await _notificationService.isNotificationEnabled();
    final time = await _notificationService.getNotificationTime();
    setState(() {
      _notificationEnabled = enabled;
      _notificationTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final isDark = themeViewModel.isDarkMode;

    return Scaffold(
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
                  SwitchListTile(
                    title: const Text('ダークモード'),
                    subtitle: const Text('暗いテーマを使用する'),
                    value: themeViewModel.isDarkMode,
                    onChanged: (value) {
                      themeViewModel.setDarkMode(value);
                    },
                    activeColor: Colors.blue,
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

            // データ管理セクション
            _buildSectionTitle('データ管理', isDark),
            const SizedBox(height: 16),
            _buildCard(
              isDark,
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.backup),
                    title: const Text('データのバックアップ'),
                    subtitle: const Text('すべてのデータをバックアップ'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('この機能は開発中です')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.restore),
                    title: const Text('データの復元'),
                    subtitle: const Text('バックアップからデータを復元'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('この機能は開発中です')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text('すべてのデータを削除', style: TextStyle(color: Colors.red)),
                    subtitle: const Text('すべての記録を完全に削除します'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showDeleteAllDataDialog(),
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
                  const ListTile(
                    leading: Icon(Icons.info),
                    title: Text('アプリ名'),
                    subtitle: Text('Money:G'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.update),
                    title: Text('バージョン'),
                    subtitle: Text('1.0.0'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.star),
                    title: const Text('アプリを評価'),
                    subtitle: const Text('Google Playでアプリを評価してください'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ありがとうございます！')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildCard(bool isDark, Widget child) {
    return Card(
      elevation: 2,
      color: isDark ? Colors.grey[800] : Colors.white,
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
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('テスト通知を送信しました')),
      );
    }
  }

  void _showDeleteAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('データ削除の確認'),
        content: const Text('すべてのデータを削除してもよろしいですか？\nこの操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('この機能は開発中です')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }
}
