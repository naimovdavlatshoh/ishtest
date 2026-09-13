import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles a push notification that arrives while the app is fully
/// terminated or backgrounded. Must be a top-level (or static) function
/// annotated with [pragma('vm:entry-point')] -- Firebase spawns a
/// separate isolate to run it, so it can't close over anything from
/// the main isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Background message received: ${message.messageId}', name: 'PushNotification');
}

/// Wraps FCM setup: permission request, local-notification display while
/// the app is in the foreground (FCM does not show a system banner for a
/// foregrounded app on its own), and the token/tap callbacks the rest of
/// the app hooks into.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'Muhim bildirishnomalar',
    description: 'Ilova ochiq bo\'lganda ko\'rsatiladigan bildirishnomalar uchun kanal.',
    importance: Importance.high,
  );

  /// Called with the FCM registration token whenever one becomes available
  /// or is refreshed. Wire this up (e.g. in main.dart) to send the token
  /// to the backend so it can target this device.
  ValueChanged<String>? onToken;

  /// Called when the user taps a notification (from background or a cold
  /// start) so the app can navigate to the relevant screen.
  ValueChanged<RemoteMessage>? onMessageTap;

  /// The most recently issued FCM token, if any. Callers that need the
  /// token outside the [onToken] callback (e.g. right after login, to
  /// register it with the backend) can read it here instead of caching
  /// it themselves.
  String? get currentToken => _currentToken;
  String? _currentToken;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _initLocalNotifications();

    try {
      final String? token = await _messaging.getToken();
      if (token != null) {
        _currentToken = token;
        onToken?.call(token);
      }
    } catch (e) {
      // On iOS, getToken() throws until the APNS token is registered (e.g.
      // simulators, or a fresh install before APNs finishes handshaking).
      // onTokenRefresh below still fires once it becomes available, so this
      // isn't fatal -- but left uncaught it aborts main() before runApp().
      developer.log('Initial FCM token fetch failed: $e', name: 'PushNotification');
    }
    _messaging.onTokenRefresh.listen((String newToken) {
      _currentToken = newToken;
      onToken?.call(newToken);
    });

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onMessageTap?.call(message);
    });

    final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) onMessageTap?.call(initialMessage);
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  void _showForegroundNotification(RemoteMessage message) {
    final RemoteNotification? notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
