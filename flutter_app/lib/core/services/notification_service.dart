import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _localNotif = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
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
          iOS:     DarwinInitializationSettings(),
        ),
      );
    } catch (_) {
      // Notifications not supported on this platform — safe to ignore
    }
  }

  Future<void> cancelAll() async {
    try { await _localNotif.cancelAll(); } catch (_) {}
  }
}
