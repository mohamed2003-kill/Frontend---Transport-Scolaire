// Models for Notifications feature
/// Main notification item as specified in requirements
class NotificationItem {
  final int id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
    };
  }

  /// Computed property for formatted timestamp
  String get formattedTimestamp {
    // Format as HH:mm for today, otherwise dd/MM/yyyy HH:mm
    final now = DateTime.now();
    final isToday = timestamp.day == now.day &&
        timestamp.month == now.month &&
        timestamp.year == now.year;

    return isToday
        ? '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}'
        : '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
  }

  /// Method to categorize notification types
  NotificationCategory getCategory() {
    // Categorize based on title keywords
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('delay') || lowerTitle.contains('retard')) {
      return NotificationCategory.delay;
    } else if (lowerTitle.contains('arrival') || lowerTitle.contains('arrivée')) {
      return NotificationCategory.arrival;
    } else if (lowerTitle.contains('emergency') || lowerTitle.contains('urgence')) {
      return NotificationCategory.emergency;
    } else {
      return NotificationCategory.general;
    }
  }

  /// Method to determine notification priority
  NotificationPriority getPriority() {
    if (getCategory() == NotificationCategory.emergency) {
      return NotificationPriority.high;
    }
    return NotificationPriority.normal;
  }
}

/// Enum for notification categories
enum NotificationCategory {
  general,
  arrival,
  delay,
  emergency,
}

/// Enum for notification priorities
enum NotificationPriority {
  low,
  normal,
  high,
}

/// Model for sending notifications
class SendNotificationRequest {
  final String title;
  final String body;
  final List<String> userIds; // Recipients
  final NotificationCategory? category;
  final NotificationPriority priority;

  SendNotificationRequest({
    required this.title,
    required this.body,
    required this.userIds,
    this.category,
    this.priority = NotificationPriority.normal,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'user_ids': userIds,
      'category': category?.toString(),
      'priority': priority.toString(),
    };
  }
}

/// Model for filtering notifications
class NotificationFilter {
  final NotificationCategory? category;
  final bool? isRead;
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int limit;

  NotificationFilter({
    this.category,
    this.isRead,
    this.startDate,
    this.endDate,
    this.page = 1,
    this.limit = 20,
  });

  /// Convert filter to query parameters
  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    if (category != null) params['category'] = category.toString();
    if (isRead != null) params['is_read'] = isRead.toString();
    if (startDate != null) params['start_date'] = startDate!.toIso8601String();
    if (endDate != null) params['end_date'] = endDate!.toIso8601String();
    params['page'] = page.toString();
    params['limit'] = limit.toString();

    return params;
  }
}
