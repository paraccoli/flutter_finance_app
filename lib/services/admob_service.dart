import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  static AdMobService get instance => _instance;
  AdMobService._internal();

  // プレミアム版の状態を管理
  bool _isPremiumUser = false;
  bool get isPremiumUser => _isPremiumUser;

  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;
  bool _isInterstitialAdReady = false;
  bool _isBannerAdReady = false;
  
  // 定期的な全画面広告表示用
  Timer? _interstitialTimer;
  DateTime? _lastInterstitialAdTime;
  static const Duration _interstitialInterval = Duration(minutes: 30); // 本番用
  static const Duration _debugInterstitialInterval = Duration(minutes: 3); // デバッグ用
  
  Duration get interstitialInterval => kDebugMode ? _debugInterstitialInterval : _interstitialInterval;

  // テスト用広告ID
  static const String _testInterstitialAdId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testBannerAdId = 'ca-app-pub-3940256099942544/6300978111';

  // 本番用広告ID（実際のAdMob IDに変更してください）
  static const String _prodInterstitialAdId = 'ca-app-pub-YOUR_APP_ID/INTERSTITIAL_ID';
  static const String _prodBannerAdId = 'ca-app-pub-YOUR_APP_ID/BANNER_ID';

  // 現在使用する広告ID
  String get interstitialAdId => kDebugMode ? _testInterstitialAdId : _prodInterstitialAdId;
  String get bannerAdId => kDebugMode ? _testBannerAdId : _prodBannerAdId;

  /// AdMobサービスの初期化
  Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      await _loadPremiumStatus();
      await _loadLastInterstitialAdTime();
      _startInterstitialTimer();
      if (kDebugMode) {
        debugPrint('AdMob初期化成功');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AdMob初期化エラー: $e');
      }
    }
  }

  /// プレミアム版の状態をロード
  Future<void> _loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremiumUser = prefs.getBool('is_premium_user') ?? false;
      if (kDebugMode) {
        debugPrint('プレミアム版状態: $_isPremiumUser');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('プレミアム版状態ロードエラー: $e');
      }
    }
  }

  /// プレミアム版の状態を保存
  Future<void> setPremiumStatus(bool isPremium) async {
    try {
      _isPremiumUser = isPremium;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium_user', isPremium);
      await _onPremiumStatusChanged(); // タイマー制御を追加
      if (kDebugMode) {
        debugPrint('プレミアム版状態保存: $isPremium');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('プレミアム版状態保存エラー: $e');
      }
    }
  }

  /// 全画面広告（インタースティシャル）をロード
  Future<void> loadInterstitialAd() async {
    if (_isPremiumUser) return; // プレミアム版は広告表示しない

    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _isInterstitialAdReady = true;
            if (kDebugMode) {
              debugPrint('インタースティシャル広告ロード完了');
            }
          },
          onAdFailedToLoad: (LoadAdError error) {
            _isInterstitialAdReady = false;
            if (kDebugMode) {
              debugPrint('インタースティシャル広告ロード失敗: $error');
            }
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('インタースティシャル広告ロードエラー: $e');
      }
    }
  }

  /// 全画面広告を表示
  Future<void> showInterstitialAd() async {
    if (_isPremiumUser || !_isInterstitialAdReady || _interstitialAd == null) {
      return;
    }

    try {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          _isInterstitialAdReady = false;
          if (kDebugMode) {
            debugPrint('インタースティシャル広告終了');
          }
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          ad.dispose();
          _isInterstitialAdReady = false;
          if (kDebugMode) {
            debugPrint('インタースティシャル広告表示失敗: $error');
          }
        },
      );

      await _interstitialAd!.show();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('インタースティシャル広告表示エラー: $e');
      }
    }
  }

  /// バナー広告を作成
  BannerAd? createBannerAd() {
    if (_isPremiumUser) return null; // プレミアム版は広告表示しない

    try {
      _bannerAd = BannerAd(
        adUnitId: bannerAdId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            _isBannerAdReady = true;
            if (kDebugMode) {
              debugPrint('バナー広告ロード完了');
            }
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            _isBannerAdReady = false;
            if (kDebugMode) {
              debugPrint('バナー広告ロード失敗: $error');
            }
          },
        ),
      );

      _bannerAd!.load();
      return _bannerAd;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('バナー広告作成エラー: $e');
      }
      return null;
    }
  }

  /// バナー広告の状態を取得
  bool get isBannerAdReady => _isBannerAdReady && !_isPremiumUser;

  /// 最後のインタースティシャル広告表示時刻を読み込み
  Future<void> _loadLastInterstitialAdTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastAdTimeString = prefs.getString('last_interstitial_ad_time');
      if (lastAdTimeString != null) {
        _lastInterstitialAdTime = DateTime.parse(lastAdTimeString);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('最後の広告表示時刻読み込みエラー: $e');
      }
    }
  }

  /// 最後のインタースティシャル広告表示時刻を保存
  Future<void> _saveLastInterstitialAdTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_interstitial_ad_time', DateTime.now().toIso8601String());
      _lastInterstitialAdTime = DateTime.now();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('最後の広告表示時刻保存エラー: $e');
      }
    }
  }

  /// 定期的なインタースティシャル広告表示タイマーを開始
  void _startInterstitialTimer() {
    if (_isPremiumUser) return;

    _interstitialTimer?.cancel();
    
    // 次の広告表示までの時間を計算
    Duration nextShowDelay = interstitialInterval;
    if (_lastInterstitialAdTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastInterstitialAdTime!);
      if (timeSinceLastAd < interstitialInterval) {
        nextShowDelay = interstitialInterval - timeSinceLastAd;
      } else {
        nextShowDelay = Duration.zero; // すぐに表示
      }
    }

    if (kDebugMode) {
      debugPrint('次のインタースティシャル広告表示まで: ${nextShowDelay.inMinutes}分${nextShowDelay.inSeconds % 60}秒');
    }

    _interstitialTimer = Timer(nextShowDelay, () {
      _showPeriodicInterstitialAd();
      // 設定間隔で繰り返し
      _interstitialTimer = Timer.periodic(interstitialInterval, (_) {
        _showPeriodicInterstitialAd();
      });
    });
  }

  /// 定期的なインタースティシャル広告を表示
  Future<void> _showPeriodicInterstitialAd() async {
    if (_isPremiumUser) return;

    try {
      await loadInterstitialAd();
      await showInterstitialAd();
      await _saveLastInterstitialAdTime();
      
      if (kDebugMode) {
        debugPrint('定期インタースティシャル広告を表示しました');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('定期インタースティシャル広告表示エラー: $e');
      }
    }
  }

  /// インタースティシャル広告タイマーを停止
  void _stopInterstitialTimer() {
    _interstitialTimer?.cancel();
    _interstitialTimer = null;
  }

  /// プレミアム版に変更時の処理
  Future<void> _onPremiumStatusChanged() async {
    if (_isPremiumUser) {
      _stopInterstitialTimer();
    } else {
      _startInterstitialTimer();
    }
  }

  /// リソースの解放
  void dispose() {
    _interstitialTimer?.cancel();
    _interstitialAd?.dispose();
    _bannerAd?.dispose();
  }
}
