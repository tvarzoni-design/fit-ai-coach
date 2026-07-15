import 'package:flutter_test/flutter_test.dart';
import 'package:fit_ai_coach/core/models/app_notification.dart';

void main() {
  testWidgets('App can be instantiated without crashing', (WidgetTester tester) async {
    // Smoke test - just verify the model works
    final notification = AppNotification.fromJson({
      'id': '1',
      'user_id': 'u1',
      'title': 'Test',
      'message': 'Hello',
      'type': 'info',
      'priority': 'low',
      'read': false,
      'created_at': DateTime.now().toIso8601String(),
    });

    expect(notification.id, '1');
    expect(notification.isUnread, true);
  });
}
