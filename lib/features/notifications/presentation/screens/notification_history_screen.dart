import 'package:flutter/material.dart';

import 'package:transport_scolaire/features/notifications/data/notification_repository.dart';
import 'package:transport_scolaire/features/notifications/data/notification_api.dart';
import 'package:transport_scolaire/features/notifications/models/notification_model.dart';
import 'package:transport_scolaire/features/notifications/presentation/widgets/notification_bell.dart';

class NotificationHistoryScreen extends StatefulWidget {
  final String userId;

  const NotificationHistoryScreen({Key? key, required this.userId})
    : super(key: key);

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  late NotificationRepository _repository;
  late ScrollController _scrollController;

  List<NotificationItem> _notifications = [];
  List<NotificationItem> _filteredNotifications = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  int _unreadCount = 0;

  // Filtering variables
  NotificationCategory? _selectedCategory;
  bool _showUnreadOnly = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);

    // Utilise ton API FastAPI via NotificationApi
    _repository = NotificationRepositoryImpl(const NotificationApi());

    _loadInitialData();
  }

  void _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      _unreadCount = await _repository.getUnreadCount(widget.userId);
      await _loadNotifications();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading notifications: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Future<void> pour pouvoir faire "await _loadNotifications();"
  Future<void> _loadNotifications() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final filter = NotificationFilter(
        category: _selectedCategory,
        isRead: _showUnreadOnly ? false : null,
        page: _currentPage,
        limit: 20,
      );

      final newNotifications = await _repository.getNotificationHistory(
        userId: widget.userId,
        filter: filter,
      );

      setState(() {
        if (_currentPage == 1) {
          _notifications = newNotifications;
        } else {
          _notifications.addAll(newNotifications);
        }
        _filteredNotifications = _filterNotifications();
        _hasMore =
            newNotifications.length == 20; // If we got 20, there might be more
        _currentPage++;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more notifications: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<NotificationItem> _filterNotifications() {
    var result = List<NotificationItem>.from(_notifications);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      result = result.where((notification) {
        return notification.title.toLowerCase().contains(lower) ||
            notification.body.toLowerCase().contains(lower);
      }).toList();
    }

    // Optionnel : filtrer en local les non lues
    if (_showUnreadOnly) {
      result = result.where((n) => !n.isRead).toList();
    }

    return result;
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (_hasMore && !_isLoading) {
        _loadNotifications();
      }
    }
  }

  void _refreshNotifications() async {
    setState(() {
      _currentPage = 1;
      _hasMore = true;
    });
    await _loadNotifications();
  }

  void _applyFilters() {
    setState(() {
      _filteredNotifications = _filterNotifications();
    });
  }

  void _markAsRead(List<NotificationItem> notifications) async {
    final ids = notifications.map((n) => n.id).toList();
    try {
      await _repository.markMultipleAsRead(ids);
      setState(() {
        for (var notification in notifications) {
          final index = _notifications.indexWhere(
            (n) => n.id == notification.id,
          );
          if (index != -1) {
            _notifications[index] = NotificationItem(
              id: notification.id,
              title: notification.title,
              body: notification.body,
              timestamp: notification.timestamp,
              isRead: true,
            );
          }
        }
        _filteredNotifications = _filterNotifications();
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking notifications as read: $e')),
      );
    }
  }

  void _deleteNotification(NotificationItem notification) async {
    try {
      await _repository.deleteNotification(notification.id);
      setState(() {
        _notifications.removeWhere((n) => n.id == notification.id);
        _filteredNotifications = _filterNotifications();
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting notification: $e')),
      );
    }
  }

  Color _getCategoryColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.emergency:
        return Colors.red.shade100;
      case NotificationCategory.delay:
        return Colors.orange.shade100;
      case NotificationCategory.arrival:
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          NotificationBell(
            unreadCount: _unreadCount,
            onTap: () {
              // Navigate to notifications screen if not already here
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search notifications...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _applyFilters();
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<NotificationCategory?>(
                        value: _selectedCategory,
                        hint: const Text('All Categories'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...NotificationCategory.values.map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(
                                category.toString().split('.').last,
                                style: TextStyle(
                                  color:
                                      _getCategoryColor(
                                            category,
                                          ).computeLuminance() <
                                          0.5
                                      ? Colors.white
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                          _applyFilters();
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Unread only'),
                      selected: _showUnreadOnly,
                      onSelected: (selected) {
                        setState(() {
                          _showUnreadOnly = selected;
                        });
                        _applyFilters();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: _isLoading && _currentPage == 1
                ? const Center(child: CircularProgressIndicator())
                : _filteredNotifications.isEmpty
                ? const Center(child: Text('No notifications found'))
                : RefreshIndicator(
                    onRefresh: () async => _refreshNotifications(),
                    child: ListView.separated(
                      controller: _scrollController,
                      itemCount: _filteredNotifications.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 0),
                      itemBuilder: (context, index) {
                        final notification = _filteredNotifications[index];
                        return Dismissible(
                          key: ValueKey(notification.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _deleteNotification(notification),
                          confirmDismiss: (_) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Delete Notification'),
                                  content: const Text(
                                    'Are you sure you want to delete this notification?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            tileColor: _getCategoryColor(
                              notification.getCategory(),
                            ),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    notification.getCategory() ==
                                        NotificationCategory.emergency
                                    ? Colors.red
                                    : notification.getCategory() ==
                                          NotificationCategory.delay
                                    ? Colors.orange
                                    : notification.getCategory() ==
                                          NotificationCategory.arrival
                                    ? Colors.green
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                _getNotificationIcon(
                                  notification.getCategory(),
                                ),
                                color: Colors.white,
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight: notification.isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  notification.formattedTimestamp,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: notification.isRead
                                        ? Colors.grey[700]
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        notification.getPriority() ==
                                            NotificationPriority.high
                                        ? Colors.red.shade100
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    notification
                                        .getCategory()
                                        .toString()
                                        .split('.')
                                        .last,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          notification.getPriority() ==
                                              NotificationPriority.high
                                          ? Colors.red
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: notification.isRead
                                ? null
                                : Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                            onTap: () async {
                              // Mark as read when tapped
                              if (!notification.isRead) {
                                await _repository.markAsRead(notification.id);
                                setState(() {
                                  final index = _notifications.indexWhere(
                                    (n) => n.id == notification.id,
                                  );
                                  if (index != -1) {
                                    _notifications[index] = NotificationItem(
                                      id: notification.id,
                                      title: notification.title,
                                      body: notification.body,
                                      timestamp: notification.timestamp,
                                      isRead: true,
                                    );
                                  }
                                  _filteredNotifications =
                                      _filterNotifications();
                                  _unreadCount = _notifications
                                      .where((n) => !n.isRead)
                                      .length;
                                });
                              }

                              // Navigate to notification details if needed
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),

          // Load more indicator
          if (_isLoading && _currentPage > 1)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: _showUnreadOnly
          ? FloatingActionButton.extended(
              onPressed: () async {
                final unreadNotifications = _notifications
                    .where((n) => !n.isRead)
                    .toList();
                if (unreadNotifications.isNotEmpty) {
                  _markAsRead(unreadNotifications);
                }
              },
              label: const Text('Mark All Read'),
              icon: const Icon(Icons.check),
            )
          : null,
    );
  }

  IconData _getNotificationIcon(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.emergency:
        return Icons.warning_amber;
      case NotificationCategory.delay:
        return Icons.access_time;
      case NotificationCategory.arrival:
        return Icons.location_on;
      default:
        return Icons.notifications;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
