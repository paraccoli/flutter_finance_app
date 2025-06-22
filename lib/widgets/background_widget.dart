import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// テーマに応じて背景を表示するウィジェット
class BackgroundWidget extends StatelessWidget {
  final Widget child;
  final AppThemeType themeType;

  const BackgroundWidget({
    super.key,
    required this.child,
    required this.themeType,
  });
  @override
  Widget build(BuildContext context) {
    // コスモステーマの場合は背景画像を表示
    if (themeType == AppThemeType.cosmos) {
      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/cosmos_background.png'),
            fit: BoxFit.cover,
          ),
        ),        child: Container(
          // 背景画像の上に透明なオーバーレイを追加して可読性を向上
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0D0510).withValues(alpha: 0.6),
                const Color(0xFF1A0E1A).withValues(alpha: 0.8),
              ],
            ),
          ),
          child: child,
        ),
      );
    }

    // その他のテーマでは通常の背景
    return child;
  }
}
