import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../utils/app_theme.dart';
import '../models/custom_theme_settings.dart';
import '../services/ad_service.dart';
import 'premium_upgrade_screen.dart';
import 'reward_premium_screen.dart';
import 'custom_theme_creator_screen.dart';

/// テーマ選択画面
class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeViewModel, child) {        final isDark = themeViewModel.isDarkMode || 
            themeViewModel.currentTheme == AppThemeType.cyber ||
            themeViewModel.currentTheme == AppThemeType.cosmic ||
            themeViewModel.currentTheme == AppThemeType.cosmos;
            
        return Scaffold(
          backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : null,
          appBar: AppBar(
            title: const Text('テーマ選択'),
            backgroundColor: isDark ? Theme.of(context).appBarTheme.backgroundColor : null,
            foregroundColor: isDark ? Theme.of(context).appBarTheme.foregroundColor : null,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'お好みのテーマを選択してください',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // プリセットテーマ
                        const Text(
                          'プリセットテーマ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: AppThemeType.values.where((type) => type != AppThemeType.custom).length,
                          itemBuilder: (context, index) {
                            final presetThemes = AppThemeType.values.where((type) => type != AppThemeType.custom).toList();
                            final themeType = presetThemes[index];
                            final themeInfo = AppTheme.themeInfos[themeType]!;
                            final isSelected = themeViewModel.currentTheme == themeType;

                            return ThemeCard(
                              themeType: themeType,
                              themeInfo: themeInfo,
                              isSelected: isSelected,
                              onTap: () {
                                themeViewModel.changeTheme(themeType);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${themeInfo.name}テーマに変更しました'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        
                        // カスタムテーマ
                        if (themeViewModel.customThemes.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'カスタムテーマ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.1,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: themeViewModel.customThemes.length,
                            itemBuilder: (context, index) {
                              final customTheme = themeViewModel.customThemes[index];
                              final isSelected = themeViewModel.currentTheme == AppThemeType.custom &&
                                  themeViewModel.currentCustomTheme?.name == customTheme.name;

                              return CustomThemeCard(
                                customTheme: customTheme,
                                isSelected: isSelected,
                                onTap: () {
                                  // カスタムテーマはプレミアム限定
                                  if (AdService().isPremium || AdService().isTemporaryPremiumActive) {
                                    themeViewModel.applyCustomTheme(customTheme);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${customTheme.name}テーマに変更しました'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('プレミアム限定機能'),
                                        content: const Text('カスタムテーマはプレミアム限定です。アップグレードしますか？'),
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
                                                MaterialPageRoute(
                                                  builder: (context) => const RewardPremiumScreen(),
                                                ),
                                              );
                                            },
                                            child: const Text('広告視聴で体験'),
                                          ),
                                            ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const PremiumUpgradeScreen(),
                                                ),
                                              );
                                            },
                                            child: const Text('プレミアムを見る'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // カスタム作成はプレミアム限定
              if (AdService().isPremium || AdService().isTemporaryPremiumActive) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomThemeCreatorScreen(),
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('プレミアム限定'),
                    content: const Text('カスタムテーマ作成はプレミアム限定です。アップグレードしますか？'),
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
                            MaterialPageRoute(
                              builder: (context) => const RewardPremiumScreen(),
                            ),
                          );
                        },
                        child: const Text('広告視聴で体験'),
                      ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(ctx).pop();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => const PremiumUpgradeScreen(),
                                                    ),
                                                  );
                                                },
                                                child: const Text('プレミアムを見る'),
                                              ),
                    ],
                  ),
                );
              }
            },
            icon: const Icon(Icons.palette),
            label: const Text('カスタム作成'),
            tooltip: 'カスタムテーマを作成',
          ),
        );
      },
    );
  }
}

/// テーマカードウィジェット
class ThemeCard extends StatelessWidget {
  final AppThemeType themeType;
  final ThemeInfo themeInfo;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeCard({
    super.key,
    required this.themeType,
    required this.themeInfo,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeData = AppTheme.getTheme(themeType);
    final isCyber = themeType == AppThemeType.cyber;
    final isPinkHeart = themeType == AppThemeType.pinkheart;
    final isCosmic = themeType == AppThemeType.cosmic;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? themeInfo.previewColor 
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected 
              ? [
                  BoxShadow(
                    color: themeInfo.previewColor.withValues(alpha: 0.3),
                    blurRadius: isCyber ? 12 : (isCosmic ? 10 : 8),
                    offset: const Offset(0, 4),
                    spreadRadius: isCyber ? 2 : (isCosmic ? 1 : 0),
                  ),
                  if (isCyber)
                    BoxShadow(
                      color: themeInfo.previewColor.withValues(alpha: 0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 0),
                    ),
                  if (isCosmic)
                    BoxShadow(
                      color: themeInfo.previewColor.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 0),
                    ),
                ]
              : null,
          gradient: isCyber && isSelected ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF001122),
              Color(0xFF000011),
            ],
          ) : null,
        ),
        child: Card(
          elevation: 0,
          color: themeData.cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: themeInfo.previewColor,
                    borderRadius: BorderRadius.circular(isCyber ? 8 : (isCosmic ? 12 : 25)),
                    boxShadow: isPinkHeart && isSelected ? [
                      BoxShadow(
                        color: themeInfo.previewColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : isCosmic && isSelected ? [
                      BoxShadow(
                        color: themeInfo.previewColor.withValues(alpha: 0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: isPinkHeart 
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 28,
                        )
                      : isCyber
                          ? const Icon(
                              Icons.memory,
                              color: Colors.black,
                              size: 28,
                            )
                          : isCosmic
                              ? const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: 28,
                                )
                              : Icon(
                                  themeInfo.icon,
                                  color: Colors.white,
                                  size: 28,
                                ),
                ),
                const SizedBox(height: 12),
                Text(
                  themeInfo.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCyber && isSelected 
                        ? const Color(0xFF00FFFF)
                        : isCosmic && isSelected
                            ? const Color(0xFF6C5CE7)
                            : isPinkHeart && isSelected
                                ? const Color(0xFFFF69B4)
                                : themeData.colorScheme.onSurface,
                    shadows: isCyber && isSelected ? [
                      const Shadow(
                        color: Color(0xFF00FFFF),
                        blurRadius: 4,
                      ),
                    ] : isCosmic && isSelected ? [
                      const Shadow(
                        color: Color(0xFF6C5CE7),
                        blurRadius: 3,
                      ),
                    ] : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  themeInfo.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isCyber && isSelected
                        ? const Color(0xFF00FFFF).withValues(alpha: 0.8)
                        : isCosmic && isSelected
                            ? const Color(0xFF6C5CE7).withValues(alpha: 0.8)
                            : isPinkHeart && isSelected
                                ? const Color(0xFFFF69B4).withValues(alpha: 0.8)
                                : themeData.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontStyle: isPinkHeart ? FontStyle.italic : FontStyle.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isSelected) ...[
                  const SizedBox(height: 8),
                  Icon(
                    isPinkHeart ? Icons.favorite : Icons.check_circle,
                    color: themeInfo.previewColor,
                    size: 20,
                    shadows: isCyber ? [
                      const Shadow(
                        color: Color(0xFF00FFFF),
                        blurRadius: 4,
                      ),
                    ] : null,
                  ),
                ],              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// カスタムテーマカードウィジェット
class CustomThemeCard extends StatelessWidget {
  final CustomThemeSettings customTheme;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomThemeCard({
    super.key,
    required this.customTheme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? customTheme.primaryColor
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: customTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [                  customTheme.primaryColor.withValues(alpha: 0.8),
                  customTheme.secondaryColor.withValues(alpha: 0.8),
                  customTheme.accentColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.palette,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          customTheme.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildColorDot(customTheme.primaryColor),
                            const SizedBox(width: 4),
                            _buildColorDot(customTheme.secondaryColor),
                            const SizedBox(width: 4),
                            _buildColorDot(customTheme.accentColor),
                          ],
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }
}
