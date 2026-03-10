import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';

/// Handles both local (scheduled) and push (FCM/APNs via Expo) notifications.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _localNotif = FlutterLocalNotificationsPlugin();
  final _messaging  = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // iOS permission
    await _messaging.requestPermission(
      alert:  true,
      badge:  true,
      sound:  true,
    );

    // Local notification channels (Android)
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
        iOS:     DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // FCM foreground handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background tap opens deep link
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundTap);

    // Register FCM token with backend
    await _registerToken();

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen(_uploadToken);
  }

  Future<void> _registerToken() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    final token = Platform.isIOS
        ? await _messaging.getAPNSToken()
        : await _messaging.getToken();

    if (token != null) await _uploadToken(token);
  }

  Future<void> _uploadToken(String token) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    await Supabase.instance.client.functions.invoke(
      AppConstants.fnNotifications,
      body:       {'token': token, 'platform': Platform.isIOS ? 'ios' : 'android'},
      method:     HttpMethod.post,
      // The path suffix is set via the edge function routing
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navigate via GoRouter based on payload
    final payload = response.payload;
    if (payload == null) return;
    // Deep link handled in router redirect or global navigator key
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'review_channel',
          'Review Reminders',
          channelDescription: 'Daily spaced-repetition review reminders',
          importance: Importance.high,
          priority:   Priority.high,
          icon:       '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['type'],
    );
  }

  void _handleBackgroundTap(RemoteMessage message) {
    // Handled via router
  }

  /// Schedule a local notification (fallback when FCM is not available).
  Future<void> scheduleReviewReminder({
    required int hour,
    required int minute,
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
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'review_due',
    );
  }

  Future<void> cancelAll() => _localNotif.cancelAll();
}
