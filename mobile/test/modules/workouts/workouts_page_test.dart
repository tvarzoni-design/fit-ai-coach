import 'package:flutter_test/flutter_test.dart';
import 'package:fit_ai_coach/core/services/api_service.dart';
import 'package:fit_ai_coach/core/services/auth_service.dart';
import 'package:fit_ai_coach/core/services/notification_polling_service.dart';

void main() {
  group('WorkoutsPage smoke tests', () {
    test('ApiService initializes correctly', () {
      final api = ApiService();
      expect(api, isNotNull);
    });

    test('AuthService initializes with correct default state', () {
      final auth = AuthService();
      expect(auth.isAuthenticated, false);
      expect(auth.token, isNull);
      expect(auth.userId, isNull);
      auth.dispose();
    });

    test('NotificationPollingService initializes correctly', () {
      final auth = AuthService();
      final polling = NotificationPollingService(auth);
      expect(polling.unreadCount, 0);
      expect(polling.notifications, isEmpty);
      polling.dispose();
      auth.dispose();
    });
  });
}
