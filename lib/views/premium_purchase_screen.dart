import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/purchase_service.dart';
import '../services/ad_service.dart';

class PremiumPurchaseScreen extends StatefulWidget {
  const PremiumPurchaseScreen({super.key});

  @override
  State<PremiumPurchaseScreen> createState() => _PremiumPurchaseScreenState();
}

class _PremiumPurchaseScreenState extends State<PremiumPurchaseScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  bool _isLoading = false;
  ProductDetails? _product;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
    });

    await _purchaseService.initialize();
    _product = _purchaseService.getRemoveAdsProduct();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _purchasePremium() async {
    if (_product == null) {
      _showMessage('商品情報を読み込み中です。しばらくお待ちください。');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _purchaseService.purchaseRemoveAds();
      if (success) {
        _showMessage('購入手続きを開始しました。');
      } else {
        _showMessage('購入に失敗しました。もう一度お試しください。');
      }
    } catch (e) {
      _showMessage('エラーが発生しました: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレミアム版'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // プレミアムアイコン
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars,
                      size: 60,
                      color: Colors.purple,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // タイトル
                  const Text(
                    'Money:G プレミアム',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 説明
                  const Text(
                    '広告なしでより快適に',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 特典リスト
                  _buildFeatureCard(
                    icon: Icons.block,
                    title: '広告の完全削除',
                    description: 'すべての広告が表示されなくなります',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildFeatureCard(
                    icon: Icons.flash_on,
                    title: '快適な操作',
                    description: '広告による中断なく、スムーズに家計管理',
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildFeatureCard(
                    icon: Icons.favorite,
                    title: '開発者支援',
                    description: 'アプリの継続的な改善と新機能開発をサポート',
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 価格と購入ボタン
                  if (_product != null) ...[
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '価格: ${_product!.price}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '一度のお支払いで永続的に利用可能',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _purchasePremium,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'プレミアム版を購入',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          '商品情報を読み込み中...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 20),
                  
                  // 既にプレミアムの場合
                  if (AdService().isPremium)
                    const Card(
                      color: Colors.green,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'プレミアム版をご利用中です',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // 注意事項
                  const Text(
                    '※ 購入は Google Play Store または App Store を通じて行われます。\n'
                    '※ 購入後、広告の非表示は即座に反映されます。',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.purple,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
