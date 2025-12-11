import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/notification_model.dart';

// URL de ton backend FastAPI
const String kNotificationBaseUrl = 'http://localhost:8002';

class NotificationApi {
  const NotificationApi({this.baseUrl = kNotificationBaseUrl});

  final String baseUrl;

  /// Récupère l'historique des notifications pour un user donné avec filtres
  Future<List<NotificationItem>> fetchHistoryWithFilters({
    required String userId,
    Map<String, String>? queryParams,
  }) async {
    // Build the URI with the base path and user ID
    String url = '$baseUrl/notifications/history/$userId';

    // Add query parameters if provided
    if (queryParams != null && queryParams.isNotEmpty) {
      final queryParamString = queryParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      url += '?$queryParamString';
    }

    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erreur ${response.statusCode} : ${response.body}');
    }

    final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Send a notification (POST /notifications/send)
  Future<bool> sendNotification(SendNotificationRequest request) async {
    final uri = Uri.parse('$baseUrl/notifications/send');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur ${response.statusCode} : ${response.body}');
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return responseBody['success'] ?? false;
  }

  /// Get notification by ID
  Future<NotificationItem?> getNotificationById(int id) async {
    final uri = Uri.parse('$baseUrl/notifications/$id');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      if (response.statusCode == 404) {
        return null;
      }
      throw Exception('Erreur ${response.statusCode} : ${response.body}');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return NotificationItem.fromJson(decoded);
  }

  /// Mark notification as read
  Future<bool> markAsRead(int id) async {
    final uri = Uri.parse('$baseUrl/notifications/$id/read');
    final response = await http.put(uri);

    if (response.statusCode != 200) {
      throw Exception('Erreur ${response.statusCode} : ${response.body}');
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return responseBody['success'] ?? false;
  }

  /// Delete a notification
  Future<bool> deleteNotification(int id) async {
    final uri = Uri.parse('$baseUrl/notifications/$id');
    final response = await http.delete(uri);

    if (response.statusCode != 200) {
      throw Exception('Erreur ${response.statusCode} : ${response.body}');
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return responseBody['success'] ?? false;
  }

  /// Get unread notifications count for a user
  Future<int> getUnreadCount(String userId) async {
    final uri = Uri.parse('$baseUrl/notifications/unread_count/$userId');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erreur ${response.statusCode} : ${response.body}');
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return responseBody['count'] ?? 0;
  }
}
