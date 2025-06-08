import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ヘルプ'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // チュートリアル
          _buildSection(
            '使い方',
            [
              _buildHelpItem(
                Icons.add_circle,
                '支出・収入の記録',
                '画面下部の「支出」や「収入」タブから簡単にお金の出入りを記録できます。',
                () => _showTutorialDialog(context, '支出・収入の記録', 
                  '1. 下部のタブで「支出」または「収入」を選択\n'
                  '2. 金額を入力\n'
                  '3. カテゴリを選択\n'
                  '4. 必要に応じてメモを追加\n'
                  '5. 「記録する」をタップ'),
              ),
              _buildHelpItem(
                Icons.pie_chart,
                '月次レポートの確認',
                '月次レポートタブで支出の内訳や傾向をグラフで確認できます。',
                () => _showTutorialDialog(context, '月次レポートの確認',
                  '1. 下部の「月次レポート」タブを選択\n'
                  '2. 上部で確認したい月を選択\n'
                  '3. 円グラフで支出の内訳を確認\n'
                  '4. 下部で詳細な支出リストを確認'),
              ),
              _buildHelpItem(
                Icons.trending_up,
                '資産分析の活用',
                '資産分析タブで収支のトレンドや貯蓄の推移を確認できます。',
                () => _showTutorialDialog(context, '資産分析の活用',
                  '1. 「資産分析」タブを選択\n'
                  '2. 月別の収支推移をグラフで確認\n'
                  '3. 貯蓄の増減をトラッキング\n'
                  '4. 家計の改善点を発見'),
              ),
              _buildHelpItem(
                Icons.savings,
                'NISA投資の管理',
                'NISAタブで投資の記録と運用成果を管理できます。',
                () => _showTutorialDialog(context, 'NISA投資の管理',
                  '1. 「NISA」タブを選択\n'
                  '2. 投資銘柄と金額を記録\n'
                  '3. 現在の評価額を更新\n'
                  '4. 運用成果をグラフで確認'),
              ),
            ],
          ),
          
          // よくある質問
          _buildSection(
            'よくある質問',
            [
              _buildFaqItem(
                'データはどこに保存されますか？',
                'すべてのデータはお使いのデバイス内に安全に保存されます。外部のサーバーには送信されません。',
              ),
              _buildFaqItem(
                'データのバックアップはできますか？',
                '設定画面からデータのバックアップとCSVエクスポートが可能です。定期的なバックアップをお勧めします。',
              ),
              _buildFaqItem(
                'カテゴリは変更できますか？',
                '現在のバージョンでは固定カテゴリを使用していますが、今後のアップデートでカスタマイズ機能を追加予定です。',
              ),
              _buildFaqItem(
                '通知が来ないのですが？',
                '設定画面で通知設定を確認してください。また、端末の通知設定でアプリの通知が許可されているか確認してください。',
              ),
              _buildFaqItem(
                'データを間違って削除してしまいました',
                'バックアップがある場合は設定画面から復元できます。バックアップがない場合、データの復旧はできません。',
              ),
            ],
          ),

          // トラブルシューティング
          _buildSection(
            'トラブルシューティング',
            [
              _buildHelpItem(
                Icons.bug_report,
                'アプリがクラッシュする',
                'アプリの再起動やデバイスの再起動をお試しください。',
                () => _showTroubleshootingDialog(context, 'アプリがクラッシュする場合',
                  '1. アプリを完全に終了して再起動\n'
                  '2. デバイスを再起動\n'
                  '3. アプリを最新版に更新\n'
                  '4. 問題が続く場合はGitHubでissueを報告'),
              ),
              _buildHelpItem(
                Icons.sync_problem,
                'データが表示されない',
                'アプリの再起動やキャッシュクリアをお試しください。',
                () => _showTroubleshootingDialog(context, 'データが表示されない場合',
                  '1. アプリを再起動\n'
                  '2. 月次レポートで正しい月が選択されているか確認\n'
                  '3. データが正しく記録されているか確認\n'
                  '4. 問題が続く場合は開発者にご連絡ください'),
              ),
            ],
          ),

          // 連絡先
          _buildSection(
            'サポート',
            [
              _buildHelpItem(
                Icons.email,
                'バグ報告・機能要望',
                'GitHubのissueページで報告してください。',
                () => _launchUrl('https://github.com/paraccoli/flutter_finance_app/issues'),
              ),
              _buildHelpItem(
                Icons.code,
                'ソースコード',
                'GitHubでソースコードを公開しています。',
                () => _launchUrl('https://github.com/paraccoli/flutter_finance_app'),
              ),
              _buildHelpItem(
                Icons.person,
                '開発者について',
                '開発者のSNSアカウントをフォローして最新情報を入手。',
                () => _launchUrl('https://twitter.com/paraccoli'),
              ),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...items,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline, color: Colors.orange),
        title: Text(question),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showTutorialDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content, style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showTroubleshootingDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content, style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUrl('https://github.com/paraccoli/flutter_finance_app/issues');
            },
            child: const Text('問題を報告'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        // エラーハンドリング
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}
