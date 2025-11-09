import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
    // 一時プレミアム状態の変化を監視して UI を更新する
    AdService().temporaryPremiumNotifier.addListener(_onPremiumChanged);
  }

  void _onPremiumChanged() {
    // 一時プレミアムになったら現在のバナーを破棄して再描画
    if (AdService().temporaryPremiumNotifier.value) {
      _bannerAd?.dispose();
      _bannerAd = null;
      if (mounted) {
        setState(() {
          _isAdLoaded = false;
        });
      }
    } else {
      // プレミアム解除時は再読み込みを試みる
      if (mounted) {
        setState(() {
          _isAdLoaded = false;
        });
        _loadAd();
      }
    }
  }

  void _loadAd() {
    // プレミアムユーザーは広告を表示しない
    if (AdService().isPremium || AdService().isTemporaryPremiumActive) {
      return;
    }

    _bannerAd = AdService().createBannerAd();
    if (_bannerAd != null) {
      _bannerAd!.load().then((_) {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    AdService().temporaryPremiumNotifier.removeListener(_onPremiumChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // プレミアムユーザーまたは広告が読み込まれていない場合は何も表示しない
    if (AdService().isPremium || AdService().isTemporaryPremiumActive || !_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: RepaintBoundary(
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
