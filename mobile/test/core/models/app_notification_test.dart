import 'package:flutter_test/flutter_test.dart';
import 'package:fit_ai_coach/core/models/app_notification.dart';

void main() {
  group('AppNotification', () {
    test('fromJson creates correct object', () {
      final json = {
        'id': 'n1',
        'user_id': 'u1',
        'title': 'Test Title',
        'message': 'Test Message',
        'type': 'workout',
        'priority': 'high',
        'read': false,
        'sent_at': '2025-01-15T10:30:00.000Z',
        'created_at': '2025-01-15T10:00:00.000Z',
      };

      final notification = AppNotification.fromJson(json);

      expect(notification.id, 'n1');
      expect(notification.userId, 'u1');
      expect(notification.title, 'Test Title');
      expect(notification.message, 'Test Message');
      expect(notification.type, 'workout');
      expect(notification.priority, 'high');
      expect(notification.read, false);
      expect(notification.sentAt, isNotNull);
      expect(notification.createdAt, isNotNull);
    });

    test('isUnread returns true when read is false', () {
      final notification = AppNotification(
        id: 'n1',
        userId: 'u1',
        title: 'Title',
        message: 'Message',
        read: false,
        createdAt: DateTime.now(),
      );

      expect(notification.isUnread, true);
    });

    test('isUnread returns false when read is true', () {
      final notification = AppNotification(
        id: 'n1',
        userId: 'u1',
        title: 'Title',
        message: 'Message',
        read: true,
        createdAt: DateTime.now(),
      );

      expect(notification.isUnread, false);
    });

    test('handles null fields properly', () {
      final json = <String, dynamic>{};

      final notification = AppNotification.fromJson(json);

      expect(notification.id, '');
      expect(notification.userId, '');
      expect(notification.title, '');
      expect(notification.message, '');
      expect(notification.type, 'info');
      expect(notification.priority, 'low');
      expect(notification.read, false);
      expect(notification.sentAt, null);
      expect(notification.createdAt, isNotNull);
    });

    test('handles missing sent_at field', () {
      final json = {
        'id': 'n1',
        'created_at': '2025-01-15T10:00:00.000Z',
      };

      final notification = AppNotification.fromJson(json);

      expect(notification.sentAt, null);
    });
  });
}
