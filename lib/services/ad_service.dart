import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // テスト用広告ID（本番では実際の広告IDに変更）
  static const String _bannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _bannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String _interstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _interstitialAdUnitIdIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String _rewardedAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _rewardedAdUnitIdIOS = 'ca-app-pub-3940256099942544/1712485313';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;
  bool _isPremium = false;
  // 一時的プレミアム
  bool _isTemporaryPremiumActive = false;
  // 一時プレミアム状態を通知する Notifier
  final ValueNotifier<bool> temporaryPremiumNotifier = ValueNotifier(false);

  // 広告非表示フラグのキー
  static const String _premiumKey = 'is_premium';

  // 初期化
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadPremiumStatus();
    await _loadTemporaryPremium();
    
    // 広告の事前読み込み
    if (!_isPremium && !_isTemporaryPremiumActive) {
      await loadInterstitialAd();
      await loadRewardedAd();
    }
  }

  // 一時プレミアムの状態を読み込む
  Future<void> _loadTemporaryPremium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiry = prefs.getInt('temporary_premium_until');
      if (expiry != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (now < expiry) {
          _isTemporaryPremiumActive = true;
          temporaryPremiumNotifier.value = true;
          return;
        } else {
          // 期限切れ
          await prefs.remove('temporary_premium_until');
        }
      }
      _isTemporaryPremiumActive = false;
      temporaryPremiumNotifier.value = false;
    } catch (e) {
      debugPrint('一時プレミアム読み込みエラー: $e');
      _isTemporaryPremiumActive = false;
      temporaryPremiumNotifier.value = false;
    }
  }

  // プレミアム状態の読み込み
  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
  }

  // プレミアム状態の保存
  Future<void> setPremiumStatus(bool isPremium) async {
    _isPremium = isPremium;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);
  }

  // プレミアム状態の取得
  bool get isPremium => _isPremium;

  // バナー広告ID取得
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _bannerAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _bannerAdUnitIdIOS;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // インタースティシャル広告ID取得
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _interstitialAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _interstitialAdUnitIdIOS;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // リワード広告ID取得
  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return _rewardedAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return _rewardedAdUnitIdIOS;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // バナー広告作成
  BannerAd? createBannerAd() {
    if (_isPremium || _isTemporaryPremiumActive) return null;

    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('バナー広告が読み込まれました');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('バナー広告の読み込みに失敗しました: $error');
          ad.dispose();
        },
      ),
    );
    
    return _bannerAd;
  }

  // インタースティシャル広告読み込み
  Future<void> loadInterstitialAd() async {
    if (_isPremium || _isTemporaryPremiumActive) return;

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          debugPrint('インタースティシャル広告が読み込まれました');
        },
        onAdFailedToLoad: (error) {
          debugPrint('インタースティシャル広告の読み込みに失敗しました: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  // インタースティシャル広告表示
  Future<void> showInterstitialAd() async {
    if (_isPremium || _isTemporaryPremiumActive || !_isInterstitialAdReady || _interstitialAd == null) {
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isInterstitialAdReady = false;
        loadInterstitialAd(); // 次の広告を読み込み
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('インタースティシャル広告の表示に失敗しました: $error');
        ad.dispose();
        _isInterstitialAdReady = false;
        loadInterstitialAd(); // 次の広告を読み込み
      },
    );

    await _interstitialAd!.show();
  }

  // リワード広告読み込み
  Future<void> loadRewardedAd() async {
    if (_isPremium || _isTemporaryPremiumActive) return;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          debugPrint('リワード広告が読み込まれました');
        },
        onAdFailedToLoad: (error) {
          debugPrint('リワード広告の読み込みに失敗しました: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  // リワード広告表示
  Future<bool> showRewardedAd() async {
    debugPrint('AdService.showRewardedAd called: _isPremium=$_isPremium, _isTemporaryPremiumActive=$_isTemporaryPremiumActive, _isRewardedAdReady=$_isRewardedAdReady, _rewardedAd==null=${_rewardedAd==null}');
    if (_isPremium || _isTemporaryPremiumActive || !_isRewardedAdReady || _rewardedAd == null) {
      debugPrint('AdService.showRewardedAd aborted: not ready or premium');
      return false;
    }

    // Use a Completer so we wait until the reward/dismiss events happen.
    final completer = Completer<bool>();
    bool rewarded = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('AdService: rewarded ad showed');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('AdService: rewarded ad dismissed');
        try {
          ad.dispose();
        } catch (_) {}
        _isRewardedAdReady = false;
        loadRewardedAd(); // 次の広告を読み込み
        if (!completer.isCompleted) {
          completer.complete(rewarded);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('リワード広告の表示に失敗しました: $error');
        try {
          ad.dispose();
        } catch (_) {}
        _isRewardedAdReady = false;
        loadRewardedAd(); // 次の広告を読み込み
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    // show() will trigger onUserEarnedReward when appropriate
    try {
      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        rewarded = true;
        debugPrint('AdService: onUserEarnedReward called: ${reward.amount} ${reward.type}');
      });
    } catch (e) {
      debugPrint('AdService.showRewardedAd: show() threw: $e');
      if (!completer.isCompleted) completer.complete(false);
    }

    final result = await completer.future;
    debugPrint('AdService.showRewardedAd returning rewardEarned=$result');
    return result;
  }

  // リワード広告が準備できているかチェック
  bool get isRewardedAdReady => _isRewardedAdReady && !_isPremium && !_isTemporaryPremiumActive;

  // 一時プレミアムが有効か
  bool get isTemporaryPremiumActive => _isTemporaryPremiumActive;

  // RewardService から一時プレミアムが設定されたときに呼ぶ
  void updateTemporaryPremium(int expiryMilliseconds) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (expiryMilliseconds > now) {
      _isTemporaryPremiumActive = true;
      temporaryPremiumNotifier.value = true;
      // プレミアムになったら広告を破棄
      _bannerAd?.dispose();
      _bannerAd = null;
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
      _rewardedAd?.dispose();
      _rewardedAd = null;
      _isRewardedAdReady = false;
    } else {
      _isTemporaryPremiumActive = false;
      temporaryPremiumNotifier.value = false;
    }
  }

  // リソース解放
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }

  // プレミアム状態設定（テスト用）
  Future<void> setPremium(bool premium) async {
    // setPremiumStatus に集約
    await setPremiumStatus(premium);
    if (premium) {
      // プレミアム有効化時は広告を非表示
      _bannerAd?.dispose();
      _bannerAd = null;
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isInterstitialAdReady = false;
    }
  }
}
