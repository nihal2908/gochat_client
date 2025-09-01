import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:whatsapp_clone/features/auth/current_user/user_manager.dart';
import 'package:whatsapp_clone/providers/websocket_provider.dart';
import 'package:whatsapp_clone/secrets/secrets.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['signal'] == 'wake') {
    await ensureSocketConnected();
  }
}

Future<void> ensureSocketConnected() async {
  final _localNotifications = FlutterLocalNotificationsPlugin();

  await _localNotifications.show(
    0,
    "title",
    "body",
    NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'Used for important notifications',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );
  WebSocketProvider().initialize(CurrentUser.userId!);
  // webSocketService.connect();
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission
    await _requestPermission();

    // Setup foreground/background handlers
    await _setupMessageHandlers();

    // Get FCM token
    final token = await _messaging.getToken();
    if (token != null && CurrentUser.userId != null) {
      await storeFCMToken(token);
    }
  }

  Future<AuthorizationStatus> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: false,
      badge: false,
      sound: false,
      provisional: false,
    );
    return settings.authorizationStatus;
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((message) {
      if (message.data['signal'] == 'wake') {
        ensureSocketConnected();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data['signal'] == 'wake') {
        ensureSocketConnected();
      }
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage?.data['signal'] == 'wake') {
      ensureSocketConnected();
    }
  }

  Future<bool> storeFCMToken(String token) async {
    final response = await http.post(
      Uri.parse('${Secrets.serverUrl}/fcm/store-fcm-token'),
      body: jsonEncode({
        '_id': CurrentUser.userId,
        'fcm_token': token,
      }),
    );
    return response.statusCode == 200;
  }
}
