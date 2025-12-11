import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/notification_model.dart';

/// Handles push notifications using Firebase Cloud Messaging
class PushHandler {
  static final PushHandler _instance = PushHandler._internal();
  factory PushHandler() => _instance;
  PushHandler._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Callbacks for handling notification events
  Function(NotificationItem notification)? onNotificationReceived;
  Function(NotificationItem notification)? onNotificationTapped;

  /// Initialize FCM and local notifications
  Future<void> initialize() async {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Initialize local notifications plugin
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettingsIOS = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotificationsPlugin.initialize(initializationSettings);

    // Request permission for notifications
    await _firebaseMessaging.requestPermission();

    // Get FCM token
    final fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fcmToken');

    // Handle token refresh (CORRIGÉ : utilisation de l'instance)
    _firebaseMessaging.onTokenRefresh
        .listen((newToken) {
          print('FCM Token Refreshed: $newToken');
          // In a real app, you would send this token to your server
        })
        .onError((error) {
          print('Error getting FCM token: $error');
        });

    // Handle foreground messages (when app is in foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a foreground message: ${message.messageId}');
      _handleRemoteMessage(message);
    });

    // Handle background messages (when app is in background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new notification was tapped on: ${message.messageId}');
      _handleRemoteMessage(message, tapped: true);
    });

    // Handle background messages when app is terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleRemoteMessage(initialMessage, tapped: true);
    }
  }

  /// Handle incoming remote message
  void _handleRemoteMessage(RemoteMessage message, {bool tapped = false}) {
    print('Handling remote message: ${message.data}');

    // Extract notification data
    final notification = message.notification;
    if (notification != null) {
      // Create NotificationItem from the message
      final notificationItem = NotificationItem(
        id: _generateIdFromMessage(message),
        title: notification.title ?? 'Notification',
        body: notification.body ?? 'You have a new notification',
        timestamp: DateTime.now(),
        isRead: tapped, // Mark as read if tapped
      );

      // Show local notification if in foreground
      if (!tapped) {
        _showLocalNotification(notificationItem);
      }

      // Call appropriate callback
      if (tapped) {
        onNotificationTapped?.call(notificationItem);
      } else {
        onNotificationReceived?.call(notificationItem);
      }
    }
  }

  /// Show local notification when app is in foreground
  Future<void> _showLocalNotification(NotificationItem notificationItem) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'transport_scolaire_channel',
      'Transport Scolaire Notifications',
      channelDescription: 'Notifications for school transport updates',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await _localNotificationsPlugin.show(
      notificationItem.id,
      notificationItem.title,
      notificationItem.body,
      platformChannelSpecifics,
    );
  }

  /// Generate an ID from the message for tracking purposes
  int _generateIdFromMessage(RemoteMessage message) {
    // Use the messageId as a basis for the ID, or create a hash
    final messageId =
        message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    return messageId.hashCode.abs();
  }

  /// Subscribe to a topic
  Future<bool> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
      return true;
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
      return false;
    }
  }

  /// Unsubscribe from a topic
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
      return true;
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
      return false;
    }
  }

  /// Get the current FCM token
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
