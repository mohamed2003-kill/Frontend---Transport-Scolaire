import '../models/notification_model.dart';
import 'notification_api.dart';

abstract class NotificationRepository {
  /// Fetch notification history for a user with filtering and pagination
  Future<List<NotificationItem>> getNotificationHistory({
    required String userId,
    NotificationFilter? filter,
  });

  /// Send a notification to users
  Future<bool> sendNotification(SendNotificationRequest request);

  /// Mark a notification as read
  Future<bool> markAsRead(int notificationId);

  /// Mark multiple notifications as read
  Future<bool> markMultipleAsRead(List<int> notificationIds);

  /// Delete a notification
  Future<bool> deleteNotification(int notificationId);

  /// Get count of unread notifications
  Future<int> getUnreadCount(String userId);

  /// Subscribe to topic-based notifications
  Future<bool> subscribeToTopic(String topic);

  /// Unsubscribe from topic-based notifications
  Future<bool> unsubscribeFromTopic(String topic);
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationApi _api;

  NotificationRepositoryImpl(this._api);

  @override
  Future<List<NotificationItem>> getNotificationHistory({
    required String userId,
    NotificationFilter? filter,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': (filter?.page ?? 1).toString(),
        'limit': (filter?.limit ?? 20).toString(),
      };

      // Add filter parameters if provided
      if (filter != null) {
        queryParams.addAll(filter.toQueryParams());
      }

      final response = await _api.fetchHistoryWithFilters(userId: userId, queryParams: queryParams);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch notification history: $e');
    }
  }

  @override
  Future<bool> sendNotification(SendNotificationRequest request) async {
    try {
      final response = await _api.sendNotification(request);
      return response;
    } catch (e) {
      throw Exception('Failed to send notification: $e');
    }
  }

  @override
  Future<bool> markAsRead(int notificationId) async {
    try {
      // In a real implementation, this would call an API endpoint
      // For now, returning true to indicate success
      return true;
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<bool> markMultipleAsRead(List<int> notificationIds) async {
    try {
      // In a real implementation, this would call an API endpoint
      // For now, returning true to indicate success
      return true;
    } catch (e) {
      throw Exception('Failed to mark notifications as read: $e');
    }
  }

  @override
  Future<bool> deleteNotification(int notificationId) async {
    try {
      // In a real implementation, this would call an API endpoint
      // For now, returning true to indicate success
      return true;
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    try {
      final notifications = await getNotificationHistory(
        userId: userId,
        filter: NotificationFilter(isRead: false),
      );
      return notifications.length;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  @override
  Future<bool> subscribeToTopic(String topic) async {
    try {
      // FCM subscription would happen here
      // For now, returning true to indicate success
      return true;
    } catch (e) {
      throw Exception('Failed to subscribe to topic: $e');
    }
  }

  @override
  Future<bool> unsubscribeFromTopic(String topic) async {
    try {
      // FCM unsubscription would happen here
      // For now, returning true to indicate success
      return true;
    } catch (e) {
      throw Exception('Failed to unsubscribe from topic: $e');
    }
  }
}