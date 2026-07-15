import 'package:flutter_test/flutter_test.dart';
import 'package:fit_ai_coach/core/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    tearDown(() {
      authService.dispose();
    });

    test('should initialize with loading state false', () {
      expect(authService.isLoading, false);
    });

    test('should have isAuthenticated false initially', () {
      expect(authService.isAuthenticated, false);
    });

    test('should have token null initially', () {
      expect(authService.token, null);
    });

    test('should have userId null initially', () {
      expect(authService.userId, null);
    });
  });
}
