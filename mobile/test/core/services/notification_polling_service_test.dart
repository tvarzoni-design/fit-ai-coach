import 'package:flutter_test/flutter_test.dart';
import 'package:fit_ai_coach/core/services/auth_service.dart';
import 'package:fit_ai_coach/core/services/notification_polling_service.dart';

class MockAuthService extends AuthService {
  @override
  bool get isAuthenticated => false;
}

void main() {
  late MockAuthService mockAuthService;
  late NotificationPollingService pollingService;

  setUp(() {
    mockAuthService = MockAuthService();
    pollingService = NotificationPollingService(mockAuthService);
  });

  tearDown(() {
    pollingService.dispose();
  });

  group('NotificationPollingService', () {
    test('initial state has 0 unread count', () {
      expect(pollingService.unreadCount, 0);
    });

    test('initial state has empty notifications list', () {
      expect(pollingService.notifications, isEmpty);
    });

    test('hasNewNotifications is false initially', () {
      expect(pollingService.hasNewNotifications, false);
    });

    test('startPolling changes polling state', () {
      pollingService.startPolling();
      expect(pollingService.unreadCount, 0);
    });

    test('stopPolling resets polling state', () {
      pollingService.startPolling();
      pollingService.stopPolling();
      expect(pollingService.unreadCount, 0);
      expect(pollingService.notifications, isEmpty);
    });

    test('startPolling is idempotent', () {
      pollingService.startPolling();
      pollingService.startPolling();
      expect(pollingService.unreadCount, 0);
    });

    test('notifies listeners on startPolling', () {
      int notifyCount = 0;
      pollingService.addListener(() => notifyCount++);
      pollingService.startPolling();
      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('notifies listeners on stopPolling', () {
      pollingService.startPolling();
      int notifyCount = 0;
      pollingService.addListener(() => notifyCount++);
      pollingService.stopPolling();
      expect(notifyCount, 1);
    });
  });
}
