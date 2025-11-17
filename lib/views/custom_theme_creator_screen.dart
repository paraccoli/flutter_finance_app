import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/custom_theme_settings.dart';
import '../services/ad_service.dart';
import 'reward_premium_screen.dart';
import 'premium_upgrade_screen.dart';
import '../viewmodels/theme_viewmodel.dart';

/// カスタムテーマ作成画面
class CustomThemeCreatorScreen extends StatefulWidget {
  final CustomThemeSettings? existingTheme;

  const CustomThemeCreatorScreen({
    super.key,
    this.existingTheme,
  });

  @override
  State<CustomThemeCreatorScreen> createState() => _CustomThemeCreatorScreenState();
}

class _CustomThemeCreatorScreenState extends State<CustomThemeCreatorScreen> {
  late TextEditingController _nameController;
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _accentColor;
  late double _fontSize;
  late bool _showBalanceOnHome;
  late bool _showCategoryIcons;
  late bool _useGradientCards;
  late bool _enableAnimations;

  @override
  void initState() {
    super.initState();
    
    // 既存テーマがある場合はその値を使用、なければデフォルト値
    final existing = widget.existingTheme;
    _nameController = TextEditingController(text: existing?.name ?? 'マイテーマ');
    _primaryColor = existing?.primaryColor ?? const Color(0xFF007AFF);
    _secondaryColor = existing?.secondaryColor ?? const Color(0xFF34C759);
    _accentColor = existing?.accentColor ?? const Color(0xFFFF9500);
    _fontSize = existing?.fontSize ?? 14.0;
    _showBalanceOnHome = existing?.showBalanceOnHome ?? true;
    _showCategoryIcons = existing?.showCategoryIcons ?? true;
    _useGradientCards = existing?.useGradientCards ?? false;
    _enableAnimations = existing?.enableAnimations ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTheme == null ? 'カスタムテーマを作成' : 'テーマを編集'),
        actions: [
          TextButton(
            onPressed: _saveTheme,
            child: const Text('保存', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // プレビューカード
          _buildPreviewCard(),
          const SizedBox(height: 24),
          
          // テーマ名
          _buildSectionTitle('基本設定'),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'テーマ名',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit),
            ),
          ),
          const SizedBox(height: 24),
          
          // カラー設定
          _buildSectionTitle('カラー設定'),
          const SizedBox(height: 16),
          _buildColorPicker('プライマリカラー', _primaryColor, (color) {
            setState(() => _primaryColor = color);
          }),
          const SizedBox(height: 16),
          _buildColorPicker('セカンダリカラー', _secondaryColor, (color) {
            setState(() => _secondaryColor = color);
          }),
          const SizedBox(height: 16),
          _buildColorPicker('アクセントカラー', _accentColor, (color) {
            setState(() => _accentColor = color);
          }),
          const SizedBox(height: 24),
          
          // フォント設定
          _buildSectionTitle('フォント設定'),
          const SizedBox(height: 16),
          _buildFontSizeSlider(),
          const SizedBox(height: 24),
          
          // UI設定
          _buildSectionTitle('UI設定'),
          const SizedBox(height: 16),
          _buildUISettings(),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    final previewTheme = CustomThemeSettings(
      name: _nameController.text,
      primaryColor: _primaryColor,
      secondaryColor: _secondaryColor,
      accentColor: _accentColor,
      fontSize: _fontSize,
      showBalanceOnHome: _showBalanceOnHome,
      showCategoryIcons: _showCategoryIcons,
      useGradientCards: _useGradientCards,
      enableAnimations: _enableAnimations,
      createdAt: DateTime.now(),
    );

    return Card(
      elevation: 8,
      child: Theme(
        data: previewTheme.toThemeData(),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: _useGradientCards
                ? LinearGradient(
                    colors: [_primaryColor.withValues(alpha: 0.1), _accentColor.withValues(alpha: 0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.preview, color: _primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'プレビュー',
                    style: TextStyle(
                      fontSize: _fontSize + 4,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_showBalanceOnHome) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      if (_showCategoryIcons)
                        Icon(Icons.account_balance_wallet, color: _secondaryColor),
                      if (_showCategoryIcons) const SizedBox(width: 8),
                      Text(
                        '残高: ¥123,456',
                        style: TextStyle(
                          fontSize: _fontSize,
                          color: _secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('サンプルボタン', style: TextStyle(fontSize: _fontSize)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildColorPicker(String label, Color currentColor, Function(Color) onChanged) {
    return InkWell(
      onTap: () => _showColorPicker(label, currentColor, onChanged),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            Text(label),
            const Spacer(),            Text(
              '#${currentColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: const TextStyle(
                fontFamily: 'monospace',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('フォントサイズ'),
            Text('${_fontSize.toInt()}px'),
          ],
        ),
        Slider(
          value: _fontSize,
          min: 10.0,
          max: 20.0,
          divisions: 10,
          onChanged: (value) {
            setState(() => _fontSize = value);
          },
        ),
        Text(
          'サンプルテキスト',
          style: TextStyle(fontSize: _fontSize),
        ),
      ],
    );
  }

  Widget _buildUISettings() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('ホーム画面に残高表示'),
          subtitle: const Text('メイン画面に残高を表示する'),
          value: _showBalanceOnHome,
          onChanged: (value) {
            setState(() => _showBalanceOnHome = value);
          },
        ),
        SwitchListTile(
          title: const Text('カテゴリアイコン表示'),
          subtitle: const Text('各項目にアイコンを表示する'),
          value: _showCategoryIcons,
          onChanged: (value) {
            setState(() => _showCategoryIcons = value);
          },
        ),
        SwitchListTile(
          title: const Text('グラデーションカード'),
          subtitle: const Text('カードに美しいグラデーションを適用'),
          value: _useGradientCards,
          onChanged: (value) {
            setState(() => _useGradientCards = value);
          },
        ),
        SwitchListTile(
          title: const Text('アニメーション'),
          subtitle: const Text('画面遷移やUI要素にアニメーションを適用'),
          value: _enableAnimations,
          onChanged: (value) {
            setState(() => _enableAnimations = value);
          },
        ),
      ],
    );
  }

  void _showColorPicker(String title, Color currentColor, Function(Color) onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$titleを選択'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: _buildColorPalette(onChanged),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPalette(Function(Color) onChanged) {
    final colors = [
      // ブルー系
      const Color(0xFF007AFF), const Color(0xFF0A84FF), const Color(0xFF64D2FF),
      // グリーン系
      const Color(0xFF34C759), const Color(0xFF30D158), const Color(0xFF00C896),
      // オレンジ系
      const Color(0xFFFF9500), const Color(0xFFFF9F0A), const Color(0xFFFF6B35),
      // レッド系
      const Color(0xFFFF3B30), const Color(0xFFFF453A), const Color(0xFFE74C3C),
      // パープル系
      const Color(0xFFAF52DE), const Color(0xFFBF5AF2), const Color(0xFF9B59B6),
      // ピンク系
      const Color(0xFFFF2D92), const Color(0xFFFF375F), const Color(0xFFE91E63),
      // グレー系
      const Color(0xFF8E8E93), const Color(0xFF48484A), const Color(0xFF2C2C2E),
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final color = colors[index];
        return InkWell(
          onTap: () {
            onChanged(color);
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }
  void _saveTheme() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('テーマ名を入力してください')),
      );
      return;
    }

    // プレミアム権限の防御的チェック
    if (!(AdService().isPremium || AdService().isTemporaryPremiumActive)) {
      // 非プレミアム利用者は保存前にプレミアムへ誘導
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('プレミアム限定機能'),
          content: const Text('カスタムテーマの保存はプレミアム限定です。アップグレードしますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RewardPremiumScreen()),
                );
              },
              child: const Text('広告視聴で体験'),
            ),
                ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PremiumUpgradeScreen()),
                );
              },
              child: const Text('プレミアムを見る'),
            ),
          ],
        ),
      );

      return;
    }

    final customTheme = CustomThemeSettings(
      name: _nameController.text.trim(),
      primaryColor: _primaryColor,
      secondaryColor: _secondaryColor,
      accentColor: _accentColor,
      fontSize: _fontSize,
      showBalanceOnHome: _showBalanceOnHome,
      showCategoryIcons: _showCategoryIcons,
      useGradientCards: _useGradientCards,
      enableAnimations: _enableAnimations,
      createdAt: widget.existingTheme?.createdAt ?? DateTime.now(),
    );

    final themeViewModel = Provider.of<ThemeViewModel>(context, listen: false);
    
    try {
      // カスタムテーマを保存
      await themeViewModel.saveCustomTheme(customTheme);
      
      // テーマを適用
      themeViewModel.applyCustomTheme(customTheme);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${customTheme.name}を保存して適用しました')),
      );

      Navigator.pop(context, customTheme);
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('テーマの保存に失敗しました: $e')),
      );
    }
  }
}
