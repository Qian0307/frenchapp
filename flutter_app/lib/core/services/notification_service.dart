import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles local scheduled notifications (Firebase removed — add back when needed).
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _localNotif = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidChannel = AndroidNotificationChannel(
      'review_channel',
      'Review Reminders',
      description: 'Daily spaced-repetition review reminders',
      importance:  Importance.high,
    );

    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    await _localNotif.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
        macOS: DarwinInitializationSettings(),
        windows: WindowsInitializationSettings(
          appName: 'FrenchMind',
          appUserModelId: 'com.frenchmind.app',
          guid: 'd5a0b0f0-1234-5678-abcd-frenchmind001',
        ),
      ),
    );
  }

  Future<void> scheduleReviewReminder({
    required String title,
    required String body,
  }) async {
    await _localNotif.periodicallyShow(
      0,
      title,
      body,
      RepeatInterval.daily,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'review_channel',
          'Review Reminders',
          channelDescription: 'Daily spaced-repetition review reminders',
          importance: Importance.high,
          priority:   Priority.high,
        ),
        iOS:   DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'review_due',
    );
  }

  Future<void> cancelAll() => _localNotif.cancelAll();
}
