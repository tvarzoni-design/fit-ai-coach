import 'package:flutter_test/flutter_test.dart';
import 'package:fit_ai_coach/core/services/api_service.dart';
import 'package:fit_ai_coach/core/constants/app_constants.dart';

void main() {
  group('ApiService', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    tearDown(() {
      apiService.dispose();
    });

    test('should initialize with correct base URL', () {
      expect(apiService.dio.options.baseUrl, AppConstants.apiBaseUrl);
    });

    test('should have correct headers', () {
      expect(
        apiService.dio.options.headers['Content-Type'],
        'application/json',
      );
      expect(
        apiService.dio.options.headers['Accept'],
        'application/json',
      );
    });

    test('should have correct timeout settings', () {
      expect(
        apiService.dio.options.connectTimeout,
        const Duration(seconds: 30),
      );
      expect(
        apiService.dio.options.receiveTimeout,
        const Duration(seconds: 30),
      );
    });
  });
}
