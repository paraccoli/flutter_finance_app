import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';

/// バナー広告を表示するウィジェット
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  /// バナー広告を読み込む
  void _loadBannerAd() {
    final admobService = AdMobService.instance;
    
    // プレミアム版の場合は広告を表示しない
    if (admobService.isPremiumUser) {
      return;
    }

    _bannerAd = admobService.createBannerAd();
    _bannerAd?.load().then((_) {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    }).catchError((error) {
      if (kDebugMode) {
        debugPrint('バナー広告読み込みエラー: $error');
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final admobService = AdMobService.instance;
    
    // プレミアム版またはバナー広告が読み込まれていない場合は空のコンテナを返す
    if (admobService.isPremiumUser || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

/// 広告を考慮したScaffold
/// プレミアム版でない場合は底部にバナー広告を表示
class AdAwareScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final List<Widget>? actions;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  const AdAwareScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.actions,
    this.appBar,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final admobService = AdMobService.instance;
    
    return Scaffold(
      appBar: appBar ?? (title.isNotEmpty ? AppBar(
        title: Text(title),
        actions: actions,
      ) : null),
      drawer: drawer,
      body: Column(
        children: [
          Expanded(child: body),
          // プレミアム版でない場合のみバナー広告を表示
          if (!admobService.isPremiumUser) const BannerAdWidget(),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
