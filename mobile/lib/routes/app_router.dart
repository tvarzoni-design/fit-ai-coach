import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth
import '../../modules/auth/pages/login_page.dart';
import '../../modules/auth/pages/register_page.dart';
import '../../modules/auth/pages/forgot_password_page.dart';
import '../../modules/auth/pages/reset_password_page.dart';
import '../../modules/auth/pages/change_password_page.dart';
import '../../modules/auth/pages/email_verification_page.dart';

// Onboarding
import '../../modules/onboarding/pages/onboarding_page.dart';

// Splash
import '../../modules/splash/pages/splash_page.dart';

// Home
import '../../modules/home/pages/home_page.dart';
import '../../modules/home/pages/daily_summary_page.dart';
import '../../modules/home/pages/activity_heatmap_page.dart';

// Workouts
import '../../modules/workouts/pages/workouts_page.dart';
import '../../modules/workouts/pages/workout_detail_page.dart';
import '../../modules/workouts/pages/workout_execution_page.dart';
import '../../modules/workouts/pages/workout_categories_page.dart';
import '../../modules/workouts/pages/workout_filter_page.dart';
import '../../modules/workouts/pages/create_workout_page.dart';
import '../../modules/workouts/pages/workout_history_page.dart';
import '../../modules/workouts/pages/workout_stats_page.dart';
import '../../modules/workouts/pages/personal_records_page.dart';
import '../../modules/workouts/pages/workout_completion_page.dart';
import '../../modules/workouts/pages/rest_timer_page.dart';
import '../../modules/workouts/pages/workout_templates_page.dart';
import '../../modules/workouts/pages/workout_calendar_page.dart';
import '../../modules/workouts/pages/exercise_selection_page.dart';
import '../../modules/workouts/pages/workout_share_page.dart';

// Exercises
import '../../modules/exercises/pages/exercise_detail_page.dart';
import '../../modules/exercises/pages/exercise_video_page.dart';
import '../../modules/exercises/pages/exercise_browser_page.dart';
import '../../modules/exercises/pages/exercise_category_page.dart';

// Coach AI
import '../../modules/coach_ai/pages/coach_ai_page.dart';
import '../../modules/coach_ai/pages/chat_history_page.dart';
import '../../modules/coach_ai/pages/ai_workout_plan_page.dart';
import '../../modules/coach_ai/pages/ai_nutrition_plan_page.dart';
import '../../modules/coach_ai/pages/ai_analysis_page.dart';
import '../../modules/coach_ai/pages/ai_settings_page.dart';
import '../../modules/coach_ai/pages/workout_suggestion_detail_page.dart';

// Progress
import '../../modules/progress/pages/progress_page.dart';
import '../../modules/progress/pages/measurement_detail_page.dart';
import '../../modules/progress/pages/body_fat_chart_page.dart';
import '../../modules/progress/pages/strength_progress_page.dart';
import '../../modules/progress/pages/weekly_summary_page.dart';
import '../../modules/progress/pages/monthly_summary_page.dart';
import '../../modules/progress/pages/add_measurement_page.dart';

// Profile
import '../../modules/profile/pages/profile_page.dart';
import '../../modules/profile/pages/profile_edit_page.dart';
import '../../modules/profile/pages/badges_page.dart';
import '../../modules/profile/pages/activity_timeline_page.dart';
import '../../modules/profile/pages/change_photo_page.dart';

// Nutrition
import '../../modules/nutrition/pages/nutrition_page.dart';
import '../../modules/nutrition/pages/meal_detail_page.dart';
import '../../modules/nutrition/pages/food_search_page.dart';
import '../../modules/nutrition/pages/food_log_page.dart';
import '../../modules/nutrition/pages/water_history_page.dart';
import '../../modules/nutrition/pages/calorie_chart_page.dart';
import '../../modules/nutrition/pages/macro_calculator_page.dart';
import '../../modules/nutrition/pages/meal_plan_page.dart';
import '../../modules/nutrition/pages/recipes_page.dart';
import '../../modules/nutrition/pages/food_detail_page.dart';

// Cardio
import '../../modules/cardio/pages/cardio_detail_page.dart';
import '../../modules/cardio/pages/cardio_history_page.dart';
import '../../modules/cardio/pages/cardio_stats_page.dart';

// Body Analysis
import '../../modules/body_analysis/pages/body_analysis_page.dart';
import '../../modules/body_analysis/pages/bmi_calculator_page.dart';
import '../../modules/body_analysis/pages/body_fat_calculator_page.dart';
import '../../modules/body_analysis/pages/ideal_weight_page.dart';
import '../../modules/body_analysis/pages/progress_photos_page.dart';
import '../../modules/body_analysis/pages/body_composition_detail_page.dart';

// Community
import '../../modules/community/pages/community_page.dart';
import '../../modules/community/pages/leaderboard_page.dart';
import '../../modules/community/pages/post_detail_page.dart';
import '../../modules/community/pages/create_post_page.dart';
import '../../modules/community/pages/user_profile_page.dart';

// Gamification
import '../../modules/gamification/pages/achievements_page.dart';
import '../../modules/gamification/pages/daily_challenges_page.dart';
import '../../modules/gamification/pages/challenge_detail_page.dart';
import '../../modules/gamification/pages/league_detail_page.dart';
import '../../modules/gamification/pages/xp_history_page.dart';
import '../../modules/gamification/pages/streak_page.dart';
import '../../modules/gamification/pages/reward_detail_page.dart';

// Premium
import '../../modules/premium/pages/premium_page.dart';
import '../../modules/premium/pages/plan_comparison_page.dart';
import '../../modules/premium/pages/payment_methods_page.dart';
import '../../modules/premium/pages/invoice_history_page.dart';
import '../../modules/premium/pages/subscription_management_page.dart';

// Notifications
import '../../modules/notifications/pages/smart_notifications_page.dart';
import '../../modules/notifications/pages/notification_detail_page.dart';

// Predictive
import '../../modules/predictive/pages/predictive_page.dart';

// Settings
import '../../modules/settings/pages/settings_page.dart';
import '../../modules/settings/pages/notification_settings_page.dart';
import '../../modules/settings/pages/privacy_settings_page.dart';
import '../../modules/settings/pages/account_settings_page.dart';
import '../../modules/settings/pages/help_page.dart';
import '../../modules/settings/pages/about_page.dart';
import '../../modules/settings/pages/language_settings_page.dart';
import '../../modules/settings/pages/theme_settings_page.dart';

// Health
import '../../modules/health/pages/sleep_tracker_page.dart';
import '../../modules/health/pages/hydration_tracker_page.dart';
import '../../modules/health/pages/weight_tracker_page.dart';
import '../../modules/health/pages/steps_counter_page.dart';

// Search
import '../../modules/search/pages/search_page.dart';

// Social
import '../../modules/social/pages/followers_page.dart';
import '../../modules/social/pages/following_page.dart';
import '../../modules/social/pages/share_progress_page.dart';

// LGPD
import '../../modules/lgpd/pages/lgpd_consent_page.dart';
import '../../modules/lgpd/pages/data_export_page.dart';
import '../../modules/lgpd/pages/account_deletion_page.dart';
import '../../modules/lgpd/pages/privacy_policy_page.dart';
import '../../modules/lgpd/pages/terms_of_service_page.dart';

// Workouts extras
import '../../modules/workouts/pages/previous_workouts_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Auth
      GoRoute(path: '/', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordPage()),
      GoRoute(path: '/reset-password', builder: (context, state) => ResetPasswordPage(token: state.uri.queryParameters['token'] ?? '')),

      // Onboarding
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingPage()),

      // Splash
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),

      // Search
      GoRoute(path: '/search', builder: (context, state) => const SearchPage()),

      // Main shell (bottom nav)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', pageBuilder: (context, state) => const NoTransitionPage(child: HomePage())),
          GoRoute(path: '/workouts', pageBuilder: (context, state) => const NoTransitionPage(child: WorkoutsPage())),
          GoRoute(path: '/coach', pageBuilder: (context, state) => const NoTransitionPage(child: CoachAiPage())),
          GoRoute(path: '/progress', pageBuilder: (context, state) => const NoTransitionPage(child: ProgressPage())),
          GoRoute(path: '/profile', pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage())),
        ],
      ),

      // Workouts
      GoRoute(path: '/workout/:id', builder: (context, state) => WorkoutDetailPage(workoutId: state.pathParameters['id']!)),
      GoRoute(path: '/workout/:id/execute', builder: (context, state) => WorkoutExecutionPage(workoutId: state.pathParameters['id']!)),
      GoRoute(path: '/workout-categories', builder: (context, state) => const WorkoutCategoriesPage()),
      GoRoute(path: '/workout-filter', builder: (context, state) => const WorkoutFilterPage()),
      GoRoute(path: '/create-workout', builder: (context, state) => const CreateWorkoutPage()),
      GoRoute(path: '/workout-history', builder: (context, state) => const WorkoutHistoryPage()),
      GoRoute(path: '/workout-stats', builder: (context, state) => const WorkoutStatsPage()),
      GoRoute(path: '/personal-records', builder: (context, state) => const PersonalRecordsPage()),
      GoRoute(path: '/workout/:id/complete', builder: (context, state) => WorkoutCompletionPage(workoutId: state.pathParameters['id']!)),
      GoRoute(path: '/workout-rest', builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return RestTimerPage(restSeconds: extra['restSeconds'] ?? 60, nextExerciseName: extra['nextExerciseName'] ?? '');
      }),
      GoRoute(path: '/workout-templates', builder: (context, state) => const WorkoutTemplatesPage()),
      GoRoute(path: '/workout-calendar', builder: (context, state) => const WorkoutCalendarPage()),
      GoRoute(path: '/exercise-selection', builder: (context, state) {
        final ids = state.extra as List<String>? ?? [];
        return ExerciseSelectionPage(selectedExerciseIds: ids);
      }),
      GoRoute(path: '/workout/:id/share', builder: (context, state) => WorkoutSharePage(workoutId: state.pathParameters['id']!)),

      // Exercises
      GoRoute(path: '/exercise/:id', builder: (context, state) => ExerciseDetailPage(exerciseId: state.pathParameters['id']!)),
      GoRoute(path: '/exercise/:id/video', builder: (context, state) => ExerciseVideoPage(exerciseId: state.pathParameters['id']!)),
      GoRoute(path: '/exercise-browser', builder: (context, state) => const ExerciseBrowserPage()),
      GoRoute(path: '/exercise-category/:name', builder: (context, state) => ExerciseCategoryPage(categoryName: state.pathParameters['name']!)),

      // Coach AI
      GoRoute(path: '/chat-history', builder: (context, state) => const ChatHistoryPage()),
      GoRoute(path: '/ai-workout-plan', builder: (context, state) => const AIWorkoutPlanPage()),
      GoRoute(path: '/ai-nutrition-plan', builder: (context, state) => const AINutritionPlanPage()),
      GoRoute(path: '/ai-analysis', builder: (context, state) => const AIAnalysisPage()),

      // Progress
      GoRoute(path: '/measurement/:type', builder: (context, state) => MeasurementDetailPage(measurementType: state.pathParameters['type']!)),
      GoRoute(path: '/body-fat-chart', builder: (context, state) => const BodyFatChartPage()),
      GoRoute(path: '/strength-progress', builder: (context, state) => const StrengthProgressPage()),

      // Profile
      GoRoute(path: '/profile/edit', builder: (context, state) => const ProfileEditPage()),
      GoRoute(path: '/badges', builder: (context, state) => const BadgesPage()),
      GoRoute(path: '/activity-timeline', builder: (context, state) => const ActivityTimelinePage()),

      // Nutrition
      GoRoute(path: '/nutrition', builder: (context, state) => const NutritionPage()),
      GoRoute(path: '/meal/:type', builder: (context, state) => MealDetailPage(mealType: state.pathParameters['type']!)),
      GoRoute(path: '/food-search', builder: (context, state) => const FoodSearchPage()),
      GoRoute(path: '/food-log', builder: (context, state) => const FoodLogPage()),
      GoRoute(path: '/water-history', builder: (context, state) => const WaterHistoryPage()),
      GoRoute(path: '/calorie-chart', builder: (context, state) => const CalorieChartPage()),
      GoRoute(path: '/macro-calculator', builder: (context, state) => const MacroCalculatorPage()),
      GoRoute(path: '/meal-plan', builder: (context, state) => const MealPlanPage()),
      GoRoute(path: '/recipes', builder: (context, state) => const RecipesPage()),

      // Cardio
      GoRoute(path: '/cardio/:id', builder: (context, state) => CardioDetailPage(sessionId: state.pathParameters['id']!)),
      GoRoute(path: '/cardio-history', builder: (context, state) => const CardioHistoryPage()),
      GoRoute(path: '/cardio-stats', builder: (context, state) => const CardioStatsPage()),

      // Body Analysis
      GoRoute(path: '/body-analysis', builder: (context, state) => const BodyAnalysisPage()),
      GoRoute(path: '/bmi-calculator', builder: (context, state) => const BMICalculatorPage()),
      GoRoute(path: '/body-fat-calculator', builder: (context, state) => const BodyFatCalculatorPage()),
      GoRoute(path: '/ideal-weight', builder: (context, state) => const IdealWeightPage()),
      GoRoute(path: '/progress-photos', builder: (context, state) => const ProgressPhotosPage()),

      // Community
      GoRoute(path: '/community', builder: (context, state) => const CommunityPage()),
      GoRoute(path: '/leaderboard', builder: (context, state) => const LeaderboardPage()),
      GoRoute(path: '/post/:id', builder: (context, state) => PostDetailPage(postId: state.pathParameters['id']!)),
      GoRoute(path: '/create-post', builder: (context, state) => const CreatePostPage()),
      GoRoute(path: '/user/:id', builder: (context, state) => CommunityUserProfilePage(userId: state.pathParameters['id']!)),

      // Gamification
      GoRoute(path: '/achievements', builder: (context, state) => const AchievementsPage()),
      GoRoute(path: '/daily-challenges', builder: (context, state) => const DailyChallengesPage()),
      GoRoute(path: '/challenge/:id', builder: (context, state) => ChallengeDetailPage(challengeId: state.pathParameters['id']!)),
      GoRoute(path: '/league/:id', builder: (context, state) => const LeagueDetailPage()),
      GoRoute(path: '/xp-history', builder: (context, state) => const XPHistoryPage()),
      GoRoute(path: '/streak', builder: (context, state) => const StreakPage()),

      // Premium
      GoRoute(path: '/premium', builder: (context, state) => const PremiumPage()),
      GoRoute(path: '/plan-comparison', builder: (context, state) => const PlanComparisonPage()),
      GoRoute(path: '/payment-methods', builder: (context, state) => const PaymentMethodsPage()),
      GoRoute(path: '/invoice-history', builder: (context, state) => const InvoiceHistoryPage()),

      // Notifications
      GoRoute(path: '/notifications', builder: (context, state) => const SmartNotificationsPage()),

      // Predictive
      GoRoute(path: '/predictive', builder: (context, state) => const PredictivePage()),

      // Settings
      GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),
      GoRoute(path: '/notification-settings', builder: (context, state) => const NotificationSettingsPage()),
      GoRoute(path: '/privacy-settings', builder: (context, state) => const PrivacySettingsPage()),
      GoRoute(path: '/account-settings', builder: (context, state) => const AccountSettingsPage()),
      GoRoute(path: '/help', builder: (context, state) => const HelpPage()),
      GoRoute(path: '/about', builder: (context, state) => const AboutPage()),

      // Health
      GoRoute(path: '/sleep-tracker', builder: (context, state) => const SleepTrackerPage()),
      GoRoute(path: '/hydration-tracker', builder: (context, state) => const HydrationTrackerPage()),
      GoRoute(path: '/weight-tracker', builder: (context, state) => const WeightTrackerPage()),
      GoRoute(path: '/steps-counter', builder: (context, state) => const StepsCounterPage()),

      // Home extras
      GoRoute(path: '/daily-summary', builder: (context, state) => const DailySummaryPage()),
      GoRoute(path: '/activity-heatmap', builder: (context, state) => const ActivityHeatmapPage()),

      // Auth extras
      GoRoute(path: '/change-password', builder: (context, state) => const ChangePasswordPage()),
      GoRoute(path: '/email-verification', builder: (context, state) => EmailVerificationPage(email: state.uri.queryParameters['email'] ?? '')),

      // Coach AI extras
      GoRoute(path: '/ai-settings', builder: (context, state) => const AiSettingsPage()),
      GoRoute(path: '/workout-suggestion/:id', builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return WorkoutSuggestionDetailPage(workout: extra);
      }),

      // Progress extras
      GoRoute(path: '/weekly-summary', builder: (context, state) => const WeeklySummaryPage()),
      GoRoute(path: '/monthly-summary', builder: (context, state) => const MonthlySummaryPage()),
      GoRoute(path: '/add-measurement', builder: (context, state) => const AddMeasurementPage()),

      // Profile extras
      GoRoute(path: '/change-photo', builder: (context, state) => const ChangePhotoPage()),

      // Nutrition extras
      GoRoute(path: '/food-detail', builder: (context, state) {
        final name = state.uri.queryParameters['name'];
        return FoodDetailPage(foodName: name);
      }),

      // Body Analysis extras
      GoRoute(path: '/body-composition-detail', builder: (context, state) => const BodyCompositionDetailPage()),

      // Community extras
      GoRoute(path: '/followers', builder: (context, state) => const FollowersPage()),
      GoRoute(path: '/following', builder: (context, state) => const FollowingPage()),
      GoRoute(path: '/share-progress', builder: (context, state) => const ShareProgressPage()),

      // Gamification extras
      GoRoute(path: '/reward/:id', builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RewardDetailPage(reward: extra);
      }),

      // Premium extras
      GoRoute(path: '/subscription-management', builder: (context, state) => const SubscriptionManagementPage()),

      // Notifications extras
      GoRoute(path: '/notification/:id', builder: (context, state) => NotificationDetailPage(notificationId: state.pathParameters['id']!)),

      // Settings extras
      GoRoute(path: '/language-settings', builder: (context, state) => const LanguageSettingsPage()),
      GoRoute(path: '/theme-settings', builder: (context, state) => const ThemeSettingsPage()),

      // Workouts extras
      GoRoute(path: '/previous-workouts', builder: (context, state) => const PreviousWorkoutsPage()),

      // LGPD
      GoRoute(path: '/lgpd-consent', builder: (context, state) => const LgpdConsentPage()),
      GoRoute(path: '/data-export', builder: (context, state) => const DataExportPage()),
      GoRoute(path: '/account-deletion', builder: (context, state) => const AccountDeletionPage()),
      GoRoute(path: '/privacy-policy', builder: (context, state) => const PrivacyPolicyPage()),
      GoRoute(path: '/terms-of-service', builder: (context, state) => const TermsOfServicePage()),
    ],
  );
}

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _getCurrentIndex(context),
        onDestinationSelected: (index) => _onItemTapped(context, index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Treinos'),
          NavigationDestination(icon: Icon(Icons.smart_toy_outlined), selectedIcon: Icon(Icons.smart_toy), label: 'Coach'),
          NavigationDestination(icon: Icon(Icons.trending_up_outlined), selectedIcon: Icon(Icons.trending_up), label: 'Evolução'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/workouts')) return 1;
    if (location.startsWith('/coach')) return 2;
    if (location.startsWith('/progress')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/home');
      case 1: context.go('/workouts');
      case 2: context.go('/coach');
      case 3: context.go('/progress');
      case 4: context.go('/profile');
    }
  }
}
