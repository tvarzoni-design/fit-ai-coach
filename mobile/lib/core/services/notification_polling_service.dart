import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/auth_service.dart';

class NotificationPollingService extends ChangeNotifier {
  final AuthService _authService;
  Timer? _pollTimer;
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  int _lastUnreadCount = 0;
  bool _isPolling = false;
  bool _initialized = false;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get hasNewNotifications => _unreadCount > _lastUnreadCount;

  NotificationPollingService(this._authService);

  void startPolling() {
    if (_isPolling) return;
    _isPolling = true;

    _fetchUnreadCount();

    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_authService.isAuthenticated) {
        _fetchUnreadCount();
      }
    });

    notifyListeners();
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _isPolling = false;
    notifyListeners();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      if (!_authService.isAuthenticated) return;

      final response = await _authService.api.getUnreadCount();
      final newCount = response.data['count'] ?? 0;

      if (newCount != _unreadCount) {
        _lastUnreadCount = _unreadCount;
        _unreadCount = newCount;
        notifyListeners();

        if (newCount > 0) {
          await fetchNotifications();
        }
      }
    } catch (_) {}
  }

  Future<void> fetchNotifications() async {
    try {
      if (!_authService.isAuthenticated) return;

      final response = await _authService.api.getNotifications();
      final data = response.data;

      List<dynamic> items;
      if (data is List) {
        items = data;
      } else if (data is Map && data.containsKey('data')) {
        items = data['data'] ?? [];
      } else {
        items = [];
      }

      _notifications = items.map((json) => AppNotification.fromJson(json)).toList();
      _unreadCount = _notifications.where((n) => n.isUnread).length;
      _lastUnreadCount = _unreadCount;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markAsRead(String id) async {
    try {
      await _authService.api.markNotificationAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications.removeAt(index);
        _unreadCount = _notifications.where((n) => n.isUnread).length;
        _lastUnreadCount = _unreadCount;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _authService.api.markAllNotificationsAsRead();
      _notifications = _notifications.map((n) => AppNotification(id: n.id, userId: n.userId, title: n.title, message: n.message, type: n.type, priority: n.priority, read: true, sentAt: n.sentAt, createdAt: n.createdAt)).toList();
      _unreadCount = 0;
      _lastUnreadCount = 0;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> refresh() async {
    await fetchNotifications();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
