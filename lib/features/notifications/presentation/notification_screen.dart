import 'package:transport_scolaire/features/notifications/data/notification_api.dart';
import 'package:transport_scolaire/features/notifications/models/notification_model.dart';

/// Filtre utilisé pour récupérer l'historique des notifications
class NotificationFilter {
  final NotificationCategory? category;
  final bool? isRead;
  final int page;
  final int limit;

  const NotificationFilter({
    this.category,
    this.isRead,
    required this.page,
    required this.limit,
  });

  /// Convertit le filtre en query params pour l'API FastAPI
  Map<String, String> toQueryParams() {
    final Map<String, String> params = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (category != null) {
      // Exemple côté backend : "emergency", "delay", "arrival", etc.
      params['category'] = category.toString().split('.').last;
    }

    if (isRead != null) {
      params['is_read'] = isRead! ? 'true' : 'false';
    }

    return params;
  }
}

/// Contrat du repository de notifications
abstract class NotificationRepository {
  /// Nombre de notifications non lues pour un utilisateur
  Future<int> getUnreadCount(String userId);

  /// Historique de notifications avec pagination + filtres
  Future<List<NotificationItem>> getNotificationHistory({
    required String userId,
    required NotificationFilter filter,
  });

  /// Marquer plusieurs notifications comme lues
  Future<void> markMultipleAsRead(List<int> ids);

  /// Marquer une notification comme lue
  Future<void> markAsRead(int id);

  /// Supprimer une notification
  Future<void> deleteNotification(int id);
}

/// Implémentation du repository connectée à ton backend FastAPI via NotificationApi
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationApi api;

  const NotificationRepositoryImpl(this.api);

  @override
  Future<int> getUnreadCount(String userId) async {
    // Appelle GET /notifications/unread_count/{userId}
    return await api.getUnreadCount(userId);
  }

  @override
  Future<List<NotificationItem>> getNotificationHistory({
    required String userId,
    required NotificationFilter filter,
  }) async {
    final params = filter.toQueryParams();

    // Appelle GET /notifications/history/{userId}?page=...&limit=...&...
    return await api.fetchHistoryWithFilters(
      userId: userId,
      queryParams: params,
    );
  }

  @override
  Future<void> markMultipleAsRead(List<int> ids) async {
    // Tu n'as pas montré d'endpoint "mark multiple" dans NotificationApi,
    // donc on boucle sur markAsRead pour chaque id.
    for (final id in ids) {
      await api.markAsRead(id);
    }
  }

  @override
  Future<void> markAsRead(int id) async {
    // Appelle PUT /notifications/{id}/read
    await api.markAsRead(id);
  }

  @override
  Future<void> deleteNotification(int id) async {
    // Appelle DELETE /notifications/{id}
    await api.deleteNotification(id);
  }
}
