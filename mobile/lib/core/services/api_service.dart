import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiService extends ChangeNotifier {
  late Dio _dio;
  String? _token;
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        } else {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(AppConstants.tokenKey);
          if (token != null) {
            _token = token;
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final retryResponse = await _dio.fetch(error.requestOptions);
            return handler.resolve(retryResponse);
          }
        }
        handler.next(error);
      },
    ));
  }
  
  void setToken(String? token) {
    _token = token;
  }
  
  Dio get dio => _dio;
  
  Future<bool> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(AppConstants.refreshTokenKey);
      if (refreshToken == null) return false;
      
      final response = await _dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });
      
      final newToken = response.data['accessToken'];
      final newRefresh = response.data['refreshToken'];
      
      if (newToken != null) {
        _token = newToken;
        await prefs.setString(AppConstants.tokenKey, newToken);
        if (newRefresh != null) {
          await prefs.setString(AppConstants.refreshTokenKey, newRefresh);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // ========================================
  // AUTH
  // ========================================
  Future<Response> login(String email, String password) {
    return _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }
  
  Future<Response> register(Map<String, dynamic> data) {
    return _dio.post('/auth/register', data: data);
  }
  
  Future<Response> refreshToken(String token) {
    return _dio.post('/auth/refresh', data: {'refreshToken': token});
  }

  Future<Response> forgotPassword(String email) {
    return _dio.post('/auth/forgot-password', data: {'email': email});
  }

  Future<Response> resetPassword(String token, String password) {
    return _dio.post('/auth/reset-password', data: {
      'token': token,
      'password': password,
    });
  }

  Future<Response> googleSignIn(String idToken) {
    return _dio.post('/auth/google', data: {
      'idToken': idToken,
    });
  }

  Future<Response> appleSignIn(String identityToken, {String? fullName}) {
    return _dio.post('/auth/apple', data: {
      'identityToken': identityToken,
      if (fullName != null) 'fullName': fullName,
    });
  }
  
  // ========================================
  // USER
  // ========================================
  Future<Response> getProfile() {
    return _dio.get('/users/profile');
  }
  
  Future<Response> updateProfile(Map<String, dynamic> data) {
    return _dio.put('/users/profile', data: data);
  }
  
  // ========================================
  // WORKOUTS
  // ========================================
  Future<Response> getWorkouts() {
    return _dio.get('/workouts');
  }
  
  Future<Response> getWorkout(String id) {
    return _dio.get('/workouts/$id');
  }
  
  Future<Response> createWorkout(Map<String, dynamic> data) {
    return _dio.post('/workouts', data: data);
  }
  
  Future<Response> updateWorkout(String id, Map<String, dynamic> data) {
    return _dio.put('/workouts/$id', data: data);
  }
  
  Future<Response> deleteWorkout(String id) {
    return _dio.delete('/workouts/$id');
  }
  
  Future<Response> recordSet(Map<String, dynamic> data) {
    return _dio.post('/workouts/history', data: data);
  }
  
  // ========================================
  // EXERCISES
  // ========================================
  Future<Response> getExercises({String? muscle, String? equipment, String? difficulty, String? search}) {
    return _dio.get('/exercises', queryParameters: {
      if (muscle != null) 'muscle': muscle,
      if (equipment != null) 'equipment': equipment,
      if (difficulty != null) 'difficulty': difficulty,
      if (search != null) 'search': search,
    });
  }
  
  Future<Response> getExercise(String id) {
    return _dio.get('/exercises/$id');
  }
  
  Future<Response> getMuscleGroups() {
    return _dio.get('/exercises/muscle-groups');
  }
  
  // ========================================
  // AI COACH
  // ========================================
  Future<Response> chatWithAi(String message) {
    return _dio.post('/ai/chat', data: {'message': message});
  }
  
  Future<Response> generateWorkout() {
    return _dio.post('/ai/generate-workout');
  }
  
  Future<Response> analyzeProgress() {
    return _dio.post('/ai/analyze-progress');
  }
  
  Future<Response> getDailyCoach() {
    return _dio.get('/ai/daily-coach');
  }
  
  Future<Response> getRecommendations() {
    return _dio.get('/ai/recommendations');
  }
  
  Future<Response> getAlerts() {
    return _dio.get('/ai/alerts');
  }
  
  Future<Response> getPredictions() {
    return _dio.get('/ai/predictions');
  }
  
  // ========================================
  // CARDIO
  // ========================================
  Future<Response> getCardioSessions() {
    return _dio.get('/cardio');
  }
  
  Future<Response> getCardioSession(String id) {
    return _dio.get('/cardio/$id');
  }
  
  Future<Response> createCardioSession(Map<String, dynamic> data) {
    return _dio.post('/cardio', data: data);
  }
  
  // ========================================
  // NUTRITION
  // ========================================
  Future<Response> getNutritionGoals() {
    return _dio.get('/nutrition/goals');
  }
  
  Future<Response> updateNutritionGoals(Map<String, dynamic> data) {
    return _dio.put('/nutrition/goals', data: data);
  }
  
  Future<Response> logMeal(Map<String, dynamic> data) {
    return _dio.post('/nutrition/meal', data: data);
  }
  
  Future<Response> getDailySummary(String date) {
    return _dio.get('/nutrition/daily/$date');
  }
  
  Future<Response> getMealHistory() {
    return _dio.get('/nutrition/history');
  }
  
  Future<Response> deleteMeal(String id) {
    return _dio.delete('/nutrition/meal/$id');
  }
  
  Future<Response> searchFoods(String query) {
    return _dio.get('/nutrition/foods', queryParameters: {'search': query});
  }
  
  // ========================================
  // PROGRESS
  // ========================================
  Future<Response> getMeasurements() {
    return _dio.get('/progress/measurements');
  }
  
  Future<Response> addMeasurement(Map<String, dynamic> data) {
    return _dio.post('/progress/measurements', data: data);
  }
  
  Future<Response> getPhotos() {
    return _dio.get('/progress/photos');
  }
  
  Future<Response> addPhoto(Map<String, dynamic> data) {
    return _dio.post('/progress/photos', data: data);
  }
  
  // ========================================
  // GAMIFICATION
  // ========================================
  Future<Response> getGamificationProfile() {
    return _dio.get('/gamification/profile');
  }
  
  Future<Response> getAchievements() {
    return _dio.get('/gamification/achievements');
  }
  
  Future<Response> getMyAchievements() {
    return _dio.get('/gamification/achievements/mine');
  }
  
  Future<Response> getDailyChallenges() {
    return _dio.get('/gamification/daily-challenges');
  }
  
  Future<Response> completeDailyChallenge(String challengeId) {
    return _dio.post('/gamification/daily-challenges/$challengeId/complete');
  }
  
  Future<Response> getLeaderboard() {
    return _dio.get('/gamification/leaderboard');
  }
  
  Future<Response> getLeagues() {
    return _dio.get('/gamification/leagues');
  }
  
  Future<Response> getWeeklyStats() {
    return _dio.get('/gamification/weekly-stats');
  }
  
  // ========================================
  // NOTIFICATIONS
  // ========================================
  Future<Response> getNotifications() {
    return _dio.get('/notifications');
  }
  
  Future<Response> getUnreadCount() {
    return _dio.get('/notifications/unread-count');
  }
  
  Future<Response> markNotificationAsRead(String id) {
    return _dio.put('/notifications/$id/read');
  }
  
  Future<Response> markAllNotificationsAsRead() {
    return _dio.put('/notifications/read-all');
  }
  
  Future<Response> getSmartNotifications() {
    return _dio.get('/notifications/smart');
  }
  
  Future<Response> toggleSmartNotification(String id) {
    return _dio.put('/notifications/smart/$id/toggle');
  }

  Future<Response> registerDeviceToken(String fcmToken) {
    return _dio.post('/notifications/register-device', data: {
      'fcmToken': fcmToken,
      'platform': 'mobile',
    });
  }

  Future<Response> deleteNotification(String id) {
    return _dio.delete('/notifications/$id');
  }
  
  // ========================================
  // COMMUNITY
  // ========================================
  Future<Response> getCommunityFeed({int page = 1}) {
    return _dio.get('/community/posts', queryParameters: {'page': page});
  }

  Future<Response> createPost(Map<String, dynamic> data) {
    return _dio.post('/community/posts', data: data);
  }

  Future<Response> likePost(String postId) {
    return _dio.post('/community/posts/$postId/like');
  }

  Future<Response> commentPost(String postId, String content) {
    return _dio.post('/community/posts/$postId/comments', data: {'content': content});
  }

  Future<Response> getComments(String postId) {
    return _dio.get('/community/posts/$postId/comments');
  }

  Future<Response> followUser(String userId) {
    return _dio.post('/community/follow/$userId');
  }

  Future<Response> unfollowUser(String userId) {
    return _dio.delete('/community/follow/$userId');
  }

  Future<Response> getFollowers() {
    return _dio.get('/community/followers');
  }

  Future<Response> getFollowing() {
    return _dio.get('/community/following');
  }

  // ========================================
  // SUBSCRIPTIONS
  // ========================================
  Future<Response> getPlans() {
    return _dio.get('/subscriptions/plans');
  }
  
  Future<Response> getCurrentSubscription() {
    return _dio.get('/subscriptions/current');
  }
  
  Future<Response> createCheckoutSession(Map<String, dynamic> data) {
    return _dio.post('/subscriptions/checkout', data: data);
  }
  
  Future<Response> cancelSubscription() {
    return _dio.post('/subscriptions/cancel');
  }
  
  // ========================================
  // LGPD
  // ========================================
  Future<Response> getConsentStatus() {
    return _dio.get('/lgpd/consent');
  }
  
  Future<Response> recordConsent(String consentType, bool granted) {
    return _dio.post('/lgpd/consent', data: {
      'consentType': consentType,
      'granted': granted,
    });
  }
  
  Future<Response> exportMyData() {
    return _dio.get('/lgpd/export');
  }
  
  Future<Response> deleteMyAccount() {
    return _dio.delete('/lgpd/account');
  }
  
  Future<Response> getProcessingLogs() {
    return _dio.get('/lgpd/processing-logs');
  }
}
