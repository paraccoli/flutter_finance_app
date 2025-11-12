import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'admob_service.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = <ProductDetails>[];
  bool _isAvailable = false;
  bool _purchasePending = false;

  // プレミアム版のプロダクトID
  static const String premiumSubscriptionId = 'money_g_premium_monthly';
  static const Set<String> _kIds = <String>{premiumSubscriptionId};

  /// サービスの初期化
  Future<void> initialize() async {
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (!_isAvailable) {
        if (kDebugMode) {
          debugPrint('アプリ内購入が利用できません');
        }
        return;
      }

      // iOS向けの設定（基本設定のみ）
      // プラットフォーム固有の詳細設定は必要に応じて追加

      // 購入イベントのリスナーを設定
      _subscription = _inAppPurchase.purchaseStream.listen(
        (List<PurchaseDetails> purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        },
        onDone: () {
          _subscription.cancel();
        },
        onError: (Object error) {
          if (kDebugMode) {
            debugPrint('購入ストリームエラー: $error');
          }
        },
      );

      // 商品情報をロード
      await _loadProducts();

      // 過去の購入を復元
      await _restorePurchases();

      if (kDebugMode) {
        debugPrint('アプリ内購入サービス初期化完了');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('アプリ内購入サービス初期化エラー: $e');
      }
    }
  }

  /// 商品情報をロード
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_kIds);
      
      if (response.error != null) {
        if (kDebugMode) {
          debugPrint('商品情報ロードエラー: ${response.error}');
        }
        return;
      }

      if (response.productDetails.isEmpty) {
        if (kDebugMode) {
          debugPrint('商品が見つかりません');
        }
        return;
      }

      _products = response.productDetails;
      if (kDebugMode) {
        debugPrint('商品情報ロード完了: ${_products.length}個');
        for (final product in _products) {
          debugPrint('商品: ${product.id} - ${product.title} - ${product.price}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('商品情報ロードエラー: $e');
      }
    }
  }

  /// 過去の購入を復元
  Future<void> _restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      if (kDebugMode) {
        debugPrint('購入履歴復元完了');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('購入履歴復元エラー: $e');
      }
    }
  }

  /// プレミアム版を購入
  Future<bool> purchasePremium() async {
    if (!_isAvailable || _products.isEmpty) {
      if (kDebugMode) {
        debugPrint('購入できません: サービスが利用できないか、商品が見つかりません');
      }
      return false;
    }

    final ProductDetails productDetails = _products.firstWhere(
      (ProductDetails product) => product.id == premiumSubscriptionId,
      orElse: () => throw StateError('プレミアム商品が見つかりません'),
    );

    try {
      _purchasePending = true;
      
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (kDebugMode) {
        debugPrint('購入開始: $success');
      }

      return success;
    } catch (e) {
      _purchasePending = false;
      if (kDebugMode) {
        debugPrint('購入エラー: $e');
      }
      return false;
    }
  }

  /// 購入イベントのリスナー
  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // 購入処理中
        if (kDebugMode) {
          debugPrint('購入処理中: ${purchaseDetails.productID}');
        }
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // 購入エラー
          if (kDebugMode) {
            debugPrint('購入エラー: ${purchaseDetails.error}');
          }
          _purchasePending = false;
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          // 購入成功または復元成功
          _handleSuccessfulPurchase(purchaseDetails);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  /// 購入成功時の処理
  void _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.productID == premiumSubscriptionId) {
      // プレミアム版を有効化
      await AdMobService().setPremiumStatus(true);
      _purchasePending = false;
      
      if (kDebugMode) {
        debugPrint('プレミアム版が有効化されました');
      }
    }
  }

  /// 購入状態を取得
  bool get isPurchasePending => _purchasePending;

  /// 利用可能な商品リストを取得
  List<ProductDetails> get products => _products;

  /// サービスが利用可能かどうか
  bool get isAvailable => _isAvailable;

  /// 広告削除商品を取得（プレミアム版と同じ）
  ProductDetails? getRemoveAdsProduct() {
    if (_products.isEmpty) return null;
    return _products.firstWhere(
      (ProductDetails product) => product.id == premiumSubscriptionId,
      orElse: () => _products.first,
    );
  }

  /// 広告削除を購入（プレミアム版購入と同じ）
  Future<bool> purchaseRemoveAds() async {
    return await purchasePremium();
  }

  /// リソースの解放
  void dispose() {
    _subscription.cancel();
  }
}


