import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth
import '../../modules/auth/pages/login_page.dart';
import '../../modules/auth/pages/register_page.dart';
import '../../modules/auth/pages/forgot_password_page.dart';
import '../../modules/auth/pages/reset_password_page.dart';

// Onboarding
import '../../modules/onboarding/pages/onboarding_page.dart';

// Splash
import '../../modules/splash/pages/splash_page.dart';

// Home
import '../../modules/home/pages/home_page.dart';

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

// Progress
import '../../modules/progress/pages/progress_page.dart';
import '../../modules/progress/pages/measurement_detail_page.dart';
import '../../modules/progress/pages/body_fat_chart_page.dart';
import '../../modules/progress/pages/strength_progress_page.dart';

// Profile
import '../../modules/profile/pages/profile_page.dart';
import '../../modules/profile/pages/profile_edit_page.dart';
import '../../modules/profile/pages/badges_page.dart';
import '../../modules/profile/pages/activity_timeline_page.dart';

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

// Premium
import '../../modules/premium/pages/premium_page.dart';
import '../../modules/premium/pages/plan_comparison_page.dart';
import '../../modules/premium/pages/payment_methods_page.dart';
import '../../modules/premium/pages/invoice_history_page.dart';

// Notifications
import '../../modules/notifications/pages/smart_notifications_page.dart';

// Predictive
import '../../modules/predictive/pages/predictive_page.dart';

// Settings
import '../../modules/settings/pages/settings_page.dart';
import '../../modules/settings/pages/notification_settings_page.dart';
import '../../modules/settings/pages/privacy_settings_page.dart';
import '../../modules/settings/pages/account_settings_page.dart';
import '../../modules/settings/pages/help_page.dart';
import '../../modules/settings/pages/about_page.dart';

// Health
import '../../modules/health/pages/sleep_tracker_page.dart';
import '../../modules/health/pages/hydration_tracker_page.dart';

// Search
import '../../modules/search/pages/search_page.dart';

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
