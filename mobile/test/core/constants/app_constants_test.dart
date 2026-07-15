import 'package:flutter_test/flutter_test.dart';
import 'package:fit_ai_coach/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('should have API base URL', () {
      expect(AppConstants.apiBaseUrl, isNotEmpty);
    });

    test('should have storage keys', () {
      expect(AppConstants.tokenKey, isNotEmpty);
      expect(AppConstants.refreshTokenKey, isNotEmpty);
      expect(AppConstants.userIdKey, isNotEmpty);
      expect(AppConstants.onboardingKey, isNotEmpty);
    });

    test('should have goals map', () {
      expect(AppConstants.goals, isNotEmpty);
      expect(AppConstants.goals.containsKey('hypertrophy'), true);
      expect(AppConstants.goals.containsKey('fat_loss'), true);
    });

    test('should have experience levels map', () {
      expect(AppConstants.experienceLevels, isNotEmpty);
      expect(AppConstants.experienceLevels.containsKey('beginner'), true);
      expect(AppConstants.experienceLevels.containsKey('intermediate'), true);
      expect(AppConstants.experienceLevels.containsKey('advanced'), true);
    });

    test('should have muscle groups list', () {
      expect(AppConstants.muscleGroups, isNotEmpty);
      expect(AppConstants.muscleGroups.contains('Peitoral'), true);
      expect(AppConstants.muscleGroups.contains('Costas'), true);
    });

    test('should have cardio types map', () {
      expect(AppConstants.cardioTypes, isNotEmpty);
      expect(AppConstants.cardioTypes.containsKey('treadmill'), true);
      expect(AppConstants.cardioTypes.containsKey('bike'), true);
    });

    test('should have meal types map', () {
      expect(AppConstants.mealTypes, isNotEmpty);
      expect(AppConstants.mealTypes.containsKey('breakfast'), true);
      expect(AppConstants.mealTypes.containsKey('lunch'), true);
    });
  });
}
