import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import '../services/reward_service.dart';

class RewardPremiumScreen extends StatefulWidget {
  const RewardPremiumScreen({super.key});

  @override
  State<RewardPremiumScreen> createState() => _RewardPremiumScreenState();
}

class _RewardPremiumScreenState extends State<RewardPremiumScreen> {
  bool _isLoading = false;
  bool _isTemporaryPremium = false;
  String _remainingTime = '';

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
  }

  Future<void> _checkPremiumStatus() async {
    final isTemp = await RewardService().isTemporaryPremiumActive();
    final timeString = await RewardService().getRemainingTimeString();
    
    setState(() {
      _isTemporaryPremium = isTemp;
      _remainingTime = timeString;
    });
  }

  Future<void> _watchAdForPremium() async {
    debugPrint('RewardPremiumScreen: _watchAdForPremium called');
    if (!AdService().isRewardedAdReady) {
      debugPrint('RewardPremiumScreen: AdService.isRewardedAdReady is false');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('広告が準備できていません。しばらくお待ちください。')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await RewardService().watchAdForPremium();
      debugPrint('RewardPremiumScreen: RewardService.watchAdForPremium returned: $success');
      
      if (success) {
        await _checkPremiumStatus();
        // 残り時間を取得（await はここで済ませる）
        final remaining = _remainingTime.isNotEmpty ? _remainingTime : await RewardService().getRemainingTimeString();
        debugPrint('RewardPremiumScreen: showing dialog with remaining=$remaining');
        if (!mounted) return;
        // 成功時にスナックバーとダイアログで通知
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 24時間のプレミアム機能が解放されました！'),
            backgroundColor: Colors.green,
          ),
        );

        showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Text('プレミアム解放'),
            content: Text('広告の視聴により、24時間のプレミアムが有効化されました。\n残り時間: $remaining'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('広告の視聴が完了しませんでした。')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('プレミアム機能'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 現在のステータス
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          AdService().isPremium 
                              ? Icons.star 
                              : _isTemporaryPremium 
                                  ? Icons.access_time
                                  : Icons.lock,
                          color: AdService().isPremium 
                              ? Colors.amber 
                              : _isTemporaryPremium 
                                  ? Colors.green
                                  : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AdService().isPremium 
                              ? '永続的プレミアム'
                              : _isTemporaryPremium 
                                  ? '一時的プレミアム有効'
                                  : 'プレミアム未有効',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    if (!AdService().isPremium) ...[
                      const SizedBox(height: 8),
                      Text(
                        _isTemporaryPremium 
                            ? '残り時間: $_remainingTime'
                            : '広告を視聴して24時間のプレミアム機能を解放',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // プレミアム機能一覧
            Text(
              'プレミアム機能',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView(
                children: const [
                  _PremiumFeatureItem(
                    icon: Icons.block,
                    title: '広告非表示',
                    description: 'すべての広告が非表示になります',
                  ),
                  _PremiumFeatureItem(
                    icon: Icons.backup,
                    title: 'データバックアップ',
                    description: 'データの自動バックアップ機能',
                  ),
                  _PremiumFeatureItem(
                    icon: Icons.analytics,
                    title: '詳細レポート',
                    description: '高度な分析とレポート機能',
                  ),
                  _PremiumFeatureItem(
                    icon: Icons.palette,
                    title: 'カスタムテーマ',
                    description: '追加のテーマとカスタマイズ',
                  ),
                ],
              ),
            ),
            
            // 広告視聴ボタン
            if (!AdService().isPremium && !_isLoading) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isTemporaryPremium ? null : _watchAdForPremium,
                  icon: const Icon(Icons.play_circle_fill),
                  label: Text(
                    _isTemporaryPremium 
                        ? '一時的プレミアム有効中'
                        : '広告を視聴して24時間解放',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTemporaryPremium ? Colors.grey : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            
            if (_isLoading) ...[
              const SizedBox(
                width: double.infinity,
                height: 56,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PremiumFeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PremiumFeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}
