import 'package:flutter_test/flutter_test.dart';
import 'package:fit_ai_coach/core/models/app_notification.dart';

void main() {
  group('HomePage smoke test', () {
    test('AppNotification model works correctly', () {
      final notification = AppNotification(
        id: '1',
        userId: 'u1',
        title: 'Teste',
        message: 'Mensagem de teste',
        type: 'info',
        priority: 'low',
        read: false,
        createdAt: DateTime.now(),
      );

      expect(notification.id, '1');
      expect(notification.isUnread, true);
      expect(notification.title, 'Teste');
    });

    test('AppNotification fromJson handles all fields', () {
      final json = {
        'id': '2',
        'user_id': 'u2',
        'title': 'Notificação',
        'message': 'Você ganhou uma conquista!',
        'type': 'achievement',
        'priority': 'high',
        'read': true,
        'sent_at': '2024-01-15T10:00:00Z',
        'created_at': '2024-01-15T09:00:00Z',
      };

      final notification = AppNotification.fromJson(json);
      expect(notification.read, true);
      expect(notification.isUnread, false);
      expect(notification.type, 'achievement');
      expect(notification.sentAt, isNotNull);
    });
  });
}
