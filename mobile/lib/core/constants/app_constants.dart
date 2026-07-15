import 'dart:io' show Platform;

class AppConstants {
  // API - Cloud deployment
  static String get apiBaseUrl => 'https://fit-ai-coach-api-iv09.onrender.com/v1';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String onboardingKey = 'onboarding_completed';
  
  // Goals
  static const Map<String, String> goals = {
    'hypertrophy': 'Hipertrofia',
    'fat_loss': 'Emagrecimento',
    'definition': 'Definição',
    'strength': 'Força',
    'health': 'Saúde',
    'conditioning': 'Condicionamento',
  };
  
  // Experience Levels
  static const Map<String, String> experienceLevels = {
    'beginner': 'Iniciante',
    'intermediate': 'Intermediário',
    'advanced': 'Avançado',
  };
  
  // Training Locations
  static const Map<String, String> trainingLocations = {
    'full_gym': 'Academia Completa',
    'small_gym': 'Academia Pequena',
    'home': 'Em Casa',
    'condo': 'Condomínio',
    'outdoor': 'Ao Ar Livre',
  };
  
  // Muscle Groups
  static const List<String> muscleGroups = [
    'Peitoral',
    'Costas',
    'Ombros',
    'Bíceps',
    'Tríceps',
    'Quadríceps',
    'Posterior',
    'Glúteos',
    'Panturrilha',
    'Abdômen',
  ];
  
  // Cardio Types
  static const Map<String, String> cardioTypes = {
    'treadmill': 'Esteira',
    'bike': 'Bicicleta',
    'elliptical': 'Elíptico',
    'stair': 'Escada',
    'rowing': 'Remo',
    'running': 'Corrida',
    'walking': 'Caminhada',
    'hiit': 'HIIT',
    'jump_rope': 'Corda',
  };
  
  // Meal Types
  static const Map<String, String> mealTypes = {
    'breakfast': 'Café da Manhã',
    'morning_snack': 'Lanche da Manhã',
    'lunch': 'Almoço',
    'afternoon_snack': 'Lanche da Tarde',
    'dinner': 'Jantar',
    'supper': 'Ceia',
  };
}
