import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_service.dart';

class RewardService {
  static final RewardService _instance = RewardService._internal();
  factory RewardService() => _instance;
  RewardService._internal();

  static const String _temporaryPremiumKey = 'temporary_premium_until';
  static const int _rewardDurationHours = 24; // 24時間の一時的プレミアム

  // 一時的プレミアムの有効期限を確認
  Future<bool> isTemporaryPremiumActive() async {
    if (AdService().isPremium) return true; // 永続的プレミアムの場合

    final prefs = await SharedPreferences.getInstance();
    final expiryTime = prefs.getInt(_temporaryPremiumKey);
    
    if (expiryTime == null) return false;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now > expiryTime) {
      // 期限切れの場合、データを削除
      await prefs.remove(_temporaryPremiumKey);
      return false;
    }
    
    return true;
  }

  // リワード広告を視聴して一時的プレミアムを有効化
  Future<bool> watchAdForPremium() async {
    try {
      debugPrint('RewardService: watchAdForPremium called');
      debugPrint('RewardService: AdService.isRewardedAdReady=${AdService().isRewardedAdReady}');
      final success = await AdService().showRewardedAd();
      debugPrint('RewardService: showRewardedAd returned: $success');
      
      if (success) {
        // 24時間後の時刻を計算
        final expiryTime = DateTime.now()
            .add(Duration(hours: _rewardDurationHours))
            .millisecondsSinceEpoch;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_temporaryPremiumKey, expiryTime);
          // AdService に一時プレミアムの情報を伝える
          try {
            AdService().updateTemporaryPremium(expiryTime);
          } catch (e) {
            debugPrint('AdServiceへ一時プレミアム通知エラー: $e');
          }
        
        debugPrint('一時的プレミアムが24時間有効化されました');
        return true;
      }
    } catch (e) {
      debugPrint('リワード広告の表示エラー: $e');
    }
    
    return false;
  }

  // 残り時間を取得（分単位）
  Future<int> getRemainingTimeMinutes() async {
    if (AdService().isPremium) return -1; // 永続的プレミアム

    final prefs = await SharedPreferences.getInstance();
    final expiryTime = prefs.getInt(_temporaryPremiumKey);
    
    if (expiryTime == null) return 0;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final remainingMs = expiryTime - now;
    
    if (remainingMs <= 0) return 0;
    
    return (remainingMs / (1000 * 60)).ceil(); // 分に変換
  }

  // 残り時間を文字列で取得
  Future<String> getRemainingTimeString() async {
    final minutes = await getRemainingTimeMinutes();
    
    if (minutes == -1) return '永続的プレミアム';
    if (minutes == 0) return '期限切れ';
    
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    
    if (hours > 0) {
      return '$hours時間$remainingMinutes分';
    } else {
      return '$remainingMinutes分';
    }
  }

  // 一時的プレミアムをクリア
  Future<void> clearTemporaryPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_temporaryPremiumKey);
  }
}
