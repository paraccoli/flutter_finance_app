import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _dailyReminderChannelId = 'daily_reminder';
  static const String _notificationEnabledKey = 'notification_enabled';
  static const String _notificationTimeKey = 'notification_time';

  /// 通知サービスを初期化
  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // 通知チャンネルを作成（Android）
    await _createNotificationChannel();
    
    // 権限をリクエスト
    await _requestPermissions();
  }

  /// 通知チャンネルを作成（Android用）
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _dailyReminderChannelId,
      '家計簿リマインダー',
      description: '毎日の収支記録を促すリマインダー通知',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// 通知権限をリクエスト
  Future<bool> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? grantedAndroid = await androidImplementation?.requestNotificationsPermission();
    
    final IOSFlutterLocalNotificationsPlugin? iOSImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    final bool? grantedIOS = await iOSImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return grantedAndroid ?? grantedIOS ?? false;
  }
  /// 通知応答の処理
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // 通知がタップされた時の処理
    if (kDebugMode) {
      debugPrint('通知がタップされました: ${response.payload}');
    }
  }

  /// 毎日のリマインダー通知をスケジュール
  Future<void> scheduleDailyReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool(_notificationEnabledKey) ?? true;
    final timeString = prefs.getString(_notificationTimeKey) ?? '21:00';
    
    if (!isEnabled) return;

    // 既存の通知をキャンセル
    await _flutterLocalNotificationsPlugin.cancel(0);

    // 時間を解析
    final timeParts = timeString.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // 今日の指定時間を設定
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    // 既に過ぎている場合は明日に設定
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      _dailyReminderChannelId,
      '家計簿リマインダー',
      channelDescription: '毎日の収支記録を促すリマインダー通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Money:G 家計簿リマインダー',
      '今日の収支は記録しましたか？💰\n忘れずに記録して家計管理を続けましょう！',
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// 通知設定を保存
  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
    
    if (enabled) {
      await scheduleDailyReminder();
    } else {
      await _flutterLocalNotificationsPlugin.cancel(0);
    }
  }

  /// 通知時間を設定
  Future<void> setNotificationTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationTimeKey, time);
    
    // 通知が有効な場合は再スケジュール
    final isEnabled = prefs.getBool(_notificationEnabledKey) ?? true;
    if (isEnabled) {
      await scheduleDailyReminder();
    }
  }

  /// 通知有効状態を取得
  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? true;
  }

  /// 通知時間を取得
  Future<String> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_notificationTimeKey) ?? '21:00';
  }

  /// 即座にテスト通知を送信
  Future<void> sendTestNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      _dailyReminderChannelId,
      '家計簿リマインダー',
      channelDescription: 'テスト通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      1,
      'Money:G テスト通知',
      'これはテスト通知です。通知が正常に動作しています！',
      notificationDetails,
    );
  }
}
