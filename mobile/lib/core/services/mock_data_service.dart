class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  bool _isLoggedIn = false;
  String? _userName;
  final List<Map<String, dynamic>> _mealLogs = [];
  int _waterGlasses = 0;
  final List<Map<String, dynamic>> _bodyPhotos = [];
  final List<Map<String, dynamic>> _bodyMeasurements = [];
  final List<Map<String, dynamic>> _dailyChallenges = [];

  bool get isLoggedIn => _isLoggedIn;

  void login(String name) {
    _isLoggedIn = true;
    _userName = name;
    _initDefaultData();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = null;
  }

  String get userName => _userName ?? 'Atleta';

  void _initDefaultData() {
    _waterGlasses = 5;
    _mealLogs.clear();
    _bodyPhotos.clear();
    _bodyMeasurements.clear();
    _dailyChallenges.clear();

    _bodyMeasurements.addAll([
      {
        'date': '2026-07-14',
        'weight': 82.5,
        'bodyFat': 16.2,
        'muscleMass': 38.5,
        'measurements': [
          {'name': 'Braço D', 'value': 38.5, 'unit': 'cm'},
          {'name': 'Braço E', 'value': 38.0, 'unit': 'cm'},
          {'name': 'Peito', 'value': 102.0, 'unit': 'cm'},
          {'name': 'Cintura', 'value': 82.0, 'unit': 'cm'},
          {'name': 'Quadril', 'value': 98.0, 'unit': 'cm'},
          {'name': 'Coxa D', 'value': 60.5, 'unit': 'cm'},
          {'name': 'Coxa E', 'value': 60.0, 'unit': 'cm'},
          {'name': 'Panturrilha', 'value': 38.0, 'unit': 'cm'},
        ],
      },
      {
        'date': '2026-07-07',
        'weight': 83.0,
        'bodyFat': 16.5,
        'muscleMass': 38.3,
        'measurements': [
          {'name': 'Braço D', 'value': 38.0, 'unit': 'cm'},
          {'name': 'Braço E', 'value': 37.5, 'unit': 'cm'},
          {'name': 'Peito', 'value': 101.5, 'unit': 'cm'},
          {'name': 'Cintura', 'value': 83.0, 'unit': 'cm'},
          {'name': 'Quadril', 'value': 98.5, 'unit': 'cm'},
          {'name': 'Coxa D', 'value': 60.0, 'unit': 'cm'},
          {'name': 'Coxa E', 'value': 59.5, 'unit': 'cm'},
          {'name': 'Panturrilha', 'value': 37.5, 'unit': 'cm'},
        ],
      },
      {
        'date': '2026-06-30',
        'weight': 83.8,
        'bodyFat': 17.0,
        'muscleMass': 38.0,
        'measurements': [
          {'name': 'Braço D', 'value': 37.5, 'unit': 'cm'},
          {'name': 'Braço E', 'value': 37.0, 'unit': 'cm'},
          {'name': 'Peito', 'value': 101.0, 'unit': 'cm'},
          {'name': 'Cintura', 'value': 84.0, 'unit': 'cm'},
          {'name': 'Quadril', 'value': 99.0, 'unit': 'cm'},
          {'name': 'Coxa D', 'value': 59.5, 'unit': 'cm'},
          {'name': 'Coxa E', 'value': 59.0, 'unit': 'cm'},
          {'name': 'Panturrilha', 'value': 37.0, 'unit': 'cm'},
        ],
      },
      {
        'date': '2026-06-23',
        'weight': 84.5,
        'bodyFat': 17.5,
        'muscleMass': 37.8,
        'measurements': [
          {'name': 'Braço D', 'value': 37.0, 'unit': 'cm'},
          {'name': 'Braço E', 'value': 36.5, 'unit': 'cm'},
          {'name': 'Peito', 'value': 100.5, 'unit': 'cm'},
          {'name': 'Cintura', 'value': 85.0, 'unit': 'cm'},
          {'name': 'Quadril', 'value': 99.5, 'unit': 'cm'},
          {'name': 'Coxa D', 'value': 59.0, 'unit': 'cm'},
          {'name': 'Coxa E', 'value': 58.5, 'unit': 'cm'},
          {'name': 'Panturrilha', 'value': 36.5, 'unit': 'cm'},
        ],
      },
    ]);

    _dailyChallenges.addAll([
      {
        'id': 'dc-001',
        'title': '100 Flexões',
        'description': 'Faça 100 flexões hoje',
        'xpReward': 150,
        'completed': false,
        'progress': 0,
        'target': 100,
        'category': 'strength',
        'expiresAt': '2026-07-14T23:59:59',
      },
      {
        'id': 'dc-002',
        'title': 'Beber 3L de Água',
        'description': 'Mantenha-se hidratado hoje',
        'xpReward': 100,
        'completed': false,
        'progress': 1500,
        'target': 3000,
        'category': 'health',
        'expiresAt': '2026-07-14T23:59:59',
      },
      {
        'id': 'dc-003',
        'title': '30 Minutos de Cardio',
        'description': 'Faça 30 min de qualquer cardio',
        'xpReward': 120,
        'completed': true,
        'progress': 35,
        'target': 30,
        'category': 'cardio',
        'expiresAt': '2026-07-14T23:59:59',
      },
    ]);

    _mealLogs.addAll([
      {
        'id': 'ml-001',
        'name': 'Café da Manhã',
        'mealType': 'breakfast',
        'time': '07:30',
        'calories': 450,
        'protein': 30,
        'carbs': 45,
        'fat': 15,
        'foods': [
          {'name': 'Ovos mexidos (3)', 'calories': 210, 'protein': 18, 'carbs': 2, 'fat': 15},
          {'name': 'Pão integral (2 fatias)', 'calories': 140, 'protein': 6, 'carbs': 24, 'fat': 2},
          {'name': 'Banana (1)', 'calories': 100, 'protein': 1, 'carbs': 27, 'fat': 0},
        ],
      },
      {
        'id': 'ml-002',
        'name': 'Lanche da Manhã',
        'mealType': 'morning_snack',
        'time': '10:00',
        'calories': 280,
        'protein': 25,
        'carbs': 30,
        'fat': 8,
        'foods': [
          {'name': 'Whey protein (1 scoop)', 'calories': 120, 'protein': 24, 'carbs': 3, 'fat': 1},
          {'name': 'Iogurte grego', 'calories': 100, 'protein': 1, 'carbs': 15, 'fat': 3},
          {'name': 'Castanhas (15g)', 'calories': 60, 'protein': 0, 'carbs': 1, 'fat': 4},
        ],
      },
      {
        'id': 'ml-003',
        'name': 'Almoço',
        'mealType': 'lunch',
        'time': '12:30',
        'calories': 650,
        'protein': 45,
        'carbs': 65,
        'fat': 18,
        'foods': [
          {'name': 'Peito de frango (200g)', 'calories': 330, 'protein': 40, 'carbs': 0, 'fat': 8},
          {'name': 'Arroz integral (150g)', 'calories': 170, 'protein': 4, 'carbs': 36, 'fat': 1},
          {'name': 'Salada (alface, tomate, cenoura)', 'calories': 50, 'protein': 2, 'carbs': 10, 'fat': 0},
          {'name': 'Azeite (1 colher)', 'calories': 100, 'protein': 0, 'carbs': 0, 'fat': 9},
        ],
      },
    ]);
  }

  Map<String, dynamic> getProfile() {
    return {
      'id': 'user-001',
      'firstName': _userName ?? 'Atleta',
      'lastName': 'Silva',
      'email': 'atleta@email.com',
      'weight': 82.5,
      'height': 178,
      'targetWeight': 78,
      'goal': 'hypertrophy',
      'experienceLevel': 'intermediate',
      'trainingDays': 4,
      'trainingTime': 60,
      'totalWorkouts': 47,
      'totalCalories': 15680,
      'totalMinutes': 2350,
      'records': 12,
      'streak': 8,
      'plan': 'premium',
      'avatarUrl': null,
      'dateOfBirth': '1995-06-15',
      'gender': 'male',
    };
  }

  Map<String, dynamic> getGamification() {
    return {
      'level': 8,
      'xp': 3450,
      'xpToNextLevel': 5000,
      'streak': 8,
      'achievements': 15,
      'rank': 'Ouro',
      'weeklyRank': 12,
      'totalUsers': 15420,
      'badges': [
        {'name': 'Sequência de 7 dias', 'icon': '🔥', 'earned': true},
        {'name': '100 Treinos', 'icon': '💪', 'earned': false},
        {'name': 'Maratonista', 'icon': '🏃', 'earned': false},
        {'name': 'Nutrição Perfeita', 'icon': '🥗', 'earned': false},
      ],
    };
  }

  List<Map<String, dynamic>> getWorkouts() {
    return [
      {
        'id': 'w-001',
        'name': 'Treino A - Peito + Tríceps',
        'muscleGroups': 'Peitoral, Tríceps, Ombro anterior',
        'estimatedDuration': 55,
        'status': 'active',
        'weekDay': 'Segunda',
        'difficulty': 'intermediate',
        'exercises': [
          {
            'id': 'e-001',
            'name': 'Supino Reto com Barra',
            'sets': 4,
            'reps': '10-12',
            'rest': 90,
            'muscleGroup': 'Peitoral',
            'equipment': 'Barra',
            'instructions': 'Deite no banco, segure a barra com pegada ligeiramente mais larga que os ombros. Desça até o peito e empurre para cima.',
            'tips': 'Mantenha os pés firmes no chão e as escápulas retraídas.',
            'difficulty': 'intermediate',
            'primaryMuscles': ['Peitoral Maior'],
            'secondaryMuscles': ['Deltóide Anterior', 'Tríceps'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-002',
            'name': 'Supino Inclinado com Halteres',
            'sets': 4,
            'reps': '10-12',
            'rest': 90,
            'muscleGroup': 'Peitoral',
            'equipment': 'Halteres',
            'instructions': 'Ajuste o banco em 30-45°. Empurre os halteres para cima e junte no topo.',
            'tips': 'Controle a descida para máxima ativação do peitoral.',
            'difficulty': 'intermediate',
            'primaryMuscles': ['Peitoral Superior'],
            'secondaryMuscles': ['Deltóide Anterior', 'Tríceps'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-003',
            'name': 'Crucifixo na Máquina',
            'sets': 3,
            'reps': '12-15',
            'rest': 60,
            'muscleGroup': 'Peitoral',
            'equipment': 'Máquina',
            'instructions': 'Sente-se e ajuste o apoio dos braços. Junte as alavancas à frente do corpo.',
            'tips': 'Foque na contração do peitoral no ponto de encontro.',
            'difficulty': 'beginner',
            'primaryMuscles': ['Peitoral Maior'],
            'secondaryMuscles': [],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-004',
            'name': 'Crossover',
            'sets': 3,
            'reps': '12-15',
            'rest': 60,
            'muscleGroup': 'Peitoral',
            'equipment': 'Polia',
            'instructions': 'Em pé entre as polias, puxe as alavancas para baixo e à frente, cruzando as mãos.',
            'tips': 'Incline levemente o tronco para frente para melhor isolamento.',
            'difficulty': 'intermediate',
            'primaryMuscles': ['Peitoral Maior'],
            'secondaryMuscles': ['Deltóide Anterior'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-005',
            'name': 'Tríceps Pulley',
            'sets': 4,
            'reps': '10-12',
            'rest': 60,
            'muscleGroup': 'Tríceps',
            'equipment': 'Polia',
            'instructions': 'Em pé diante da polia alta, empurre a barra para baixo estendendo os cotovelos.',
            'tips': 'Mantenha os cotovelos fixos ao lado do corpo.',
            'difficulty': 'beginner',
            'primaryMuscles': ['Tríceps'],
            'secondaryMuscles': [],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-006',
            'name': 'Tríceps Testa',
            'sets': 3,
            'reps': '10-12',
            'rest': 60,
            'muscleGroup': 'Tríceps',
            'equipment': 'Barra EZ',
            'instructions': 'Deite no banco, segure a barra EZ com pegada pronada. Flexione os cotovelos levando a barra à testa.',
            'tips': 'Mantenha os cotovelos apontando para cima e fixos.',
            'difficulty': 'intermediate',
            'primaryMuscles': ['Tríceps'],
            'secondaryMuscles': [],
            'videoUrl': null,
            'imageUrl': null,
          },
        ],
      },
      {
        'id': 'w-002',
        'name': 'Treino B - Costas + Bíceps',
        'muscleGroups': 'Costas, Bíceps, Antebraço',
        'estimatedDuration': 50,
        'status': 'active',
        'weekDay': 'Terça',
        'difficulty': 'intermediate',
        'exercises': [
          {
            'id': 'e-007',
            'name': 'Puxada Frontal',
            'sets': 4,
            'reps': '10-12',
            'rest': 90,
            'muscleGroup': 'Costas',
            'equipment': 'Máquina',
            'instructions': 'Sente-se e puxe a barra até o queixo, contraindo as costas.',
            'tips': 'Imagine puxar com os cotovelos, não com as mãos.',
            'difficulty': 'beginner',
            'primaryMuscles': ['Grande Dorsal'],
            'secondaryMuscles': ['Bíceps', 'Trapézio'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-008',
            'name': 'Remada Curvada',
            'sets': 4,
            'reps': '10-12',
            'rest': 90,
            'muscleGroup': 'Costas',
            'equipment': 'Barra',
            'instructions': 'Em pé, incline o tronco para frente (~45°). Puxe a barra até o abdômen.',
            'tips': 'Mantenha a costas retas e o core contraído.',
            'difficulty': 'intermediate',
            'primaryMuscles': ['Grande Dorsal', 'Romboide'],
            'secondaryMuscles': ['Bíceps', 'Deltóide Posterior'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-009',
            'name': 'Remada Unilateral',
            'sets': 3,
            'reps': '10-12',
            'rest': 60,
            'muscleGroup': 'Costas',
            'equipment': 'Haltere',
            'instructions': 'Apoie um joelho e mão no banco. Puxe o haltere até o abdômen com o outro braço.',
            'tips': 'Gire levemente o tronco para máxima contração.',
            'difficulty': 'beginner',
            'primaryMuscles': ['Grande Dorsal'],
            'secondaryMuscles': ['Bíceps', 'Romboide'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-010',
            'name': 'Pulldown',
            'sets': 3,
            'reps': '12-15',
            'rest': 60,
            'muscleGroup': 'Costas',
            'equipment': 'Máquina',
            'instructions': 'Sente-se e puxe a barra atrás do pescoço com pegada larga.',
            'tips': 'Cuidado com a mobilidade dos ombros. Não force se houver dor.',
            'difficulty': 'intermediate',
            'primaryMuscles': ['Grande Dorsal'],
            'secondaryMuscles': ['Trapézio', 'Bíceps'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-011',
            'name': 'Rosca Direta com Barra',
            'sets': 4,
            'reps': '10-12',
            'rest': 60,
            'muscleGroup': 'Bíceps',
            'equipment': 'Barra',
            'instructions': 'Em pé, segure a barra com pegada supina. Flexione os cotovelos levando a barra aos ombros.',
            'tips': 'Mantenha os cotovelos fixos ao lado do corpo.',
            'difficulty': 'beginner',
            'primaryMuscles': ['Bíceps Braquial'],
            'secondaryMuscles': ['Braquial', 'Antebraço'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-012',
            'name': 'Rosca Alternada',
            'sets': 3,
            'reps': '10-12',
            'rest': 60,
            'muscleGroup': 'Bíceps',
            'equipment': 'Halteres',
            'instructions': 'Em pé, alterne a flexão dos braços com halteres, girando o pulso no topo.',
            'tips': 'Controle a descida para maximizar o tempo sob tensão.',
            'difficulty': 'beginner',
            'primaryMuscles': ['Bíceps Braquial'],
            'secondaryMuscles': ['Braquial'],
            'videoUrl': null,
            'imageUrl': null,
          },
        ],
      },
      {
        'id': 'w-003',
        'name': 'Treino C - Pernas',
        'muscleGroups': 'Quadríceps, Posterior, Glúteos, Panturrilha',
        'estimatedDuration': 65,
        'status': 'active',
        'weekDay': 'Quinta',
        'difficulty': 'advanced',
        'exercises': [
          {
            'id': 'e-013',
            'name': 'Agachamento Livre',
            'sets': 4,
            'reps': '8-10',
            'rest': 120,
            'muscleGroup': 'Pernas',
            'equipment': 'Barra',
            'instructions': 'Barra nos ombros, pés na largura dos ombros. Agache até as coxas ficarem paralelas ao chão.',
            'tips': 'Mantenha o peito erguido e os joelhos alinhados com os pés.',
            'difficulty': 'advanced',
            'primaryMuscles': ['Quadríceps', 'Glúteos'],
            'secondaryMuscles': ['Posterior', 'Core'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-014',
            'name': 'Leg Press 45°',
            'sets': 4,
            'reps': '10-12',
            'rest': 90,
            'muscleGroup': 'Pernas',
            'equipment': 'Máquina',
            'instructions': 'Sente-se na máquina e empurre a plataforma com os pés na largura dos ombros.',
            'tips': 'Não trave os joelhos no topo do movimento.',
            'difficulty': 'beginner',
            'primaryMuscles': ['Quadríceps'],
            'secondaryMuscles': ['Glúteos', 'Posterior'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-015',
            'name': 'Cadeira Extensora',
            'sets': 3,
            'reps': '12-15',
            'rest': 60,
            'muscleGroup': 'Pernas',
            'equipment': 'Máquina',
            'instructions': 'Sente-se e estenda as pernas contra a resistência.',
            'tips': 'Segure a contração no topo por 1 segundo.',
            'difficulty': 'beginner',
            'primaryMuscles': ['Quadríceps'],
            'secondaryMuscles': [],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-016',
            'name': 'Mesa Flexora',
            'sets': 4,
            'reps': '10-12',
            'rest': 60,
            'muscleGroup': 'Pernas',
            'equipment': 'Máquina',
            'instructions': 'Deite de bruços e flexione os joelhos puxando a almofada.',
            'tips': 'Mantenha os quadris em contato com o banco.',
            'difficulty': 'beginner',
            'primaryMuscles': ['Posterior da Coxa'],
            'secondaryMuscles': ['Gastrocnêmio'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-017',
            'name': 'Stiff',
            'sets': 3,
            'reps': '10-12',
            'rest': 90,
            'muscleGroup': 'Pernas',
            'equipment': 'Barra',
            'instructions': 'Em pé com a barra, flexione os quadris para trás descendo a barra pelas pernas.',
            'tips': 'Mantenha as pernas levemente flexionadas e a costas retas.',
            'difficulty': 'intermediate',
            'primaryMuscles': ['Posterior da Coxa'],
            'secondaryMuscles': ['Glúteos', 'Lombar'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-018',
            'name': 'Panturrilha em Pé',
            'sets': 4,
            'reps': '15-20',
            'rest': 45,
            'muscleGroup': 'Pernas',
            'equipment': 'Máquina',
            'instructions': 'Em pé na máquina, eleve-se na ponta dos pés e desça controladamente.',
            'tips': 'Faça o movimento completo para melhor ativação.',
            'difficulty': 'beginner',
            'primaryMuscles': ['Gastrocnêmio'],
            'secondaryMuscles': ['Sóleo'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-019',
            'name': 'Elevação Pélvica',
            'sets': 3,
            'reps': '12-15',
            'rest': 60,
            'muscleGroup': 'Pernas',
            'equipment': 'Barra',
            'instructions': 'Deite de costas com os pés no banco. Eleve o quadril empurrando a barra.',
            'tips': 'Segure a contração dos glúteos por 2 segundos no topo.',
            'difficulty': 'intermediate',
            'primaryMuscles': ['Glúteos'],
            'secondaryMuscles': ['Posterior', 'Lombar'],
            'videoUrl': null,
            'imageUrl': null,
          },
        ],
      },
      {
        'id': 'w-004',
        'name': 'Treino D - Ombros + Braços',
        'muscleGroups': 'Deltóide, Bíceps, Tríceps',
        'estimatedDuration': 50,
        'status': 'active',
        'weekDay': 'Sexta',
        'difficulty': 'intermediate',
        'exercises': [
          {
            'id': 'e-020',
            'name': 'Desenvolvimento com Halteres',
            'sets': 4,
            'reps': '10-12',
            'rest': 90,
            'muscleGroup': 'Ombros',
            'equipment': 'Halteres',
            'instructions': 'Sentado ou em pé, empurre os halteres acima da cabeça até estender os braços.',
            'tips': 'Não bata os halteres no topo. Mantenha o core contraído.',
            'difficulty': 'intermediate',
            'primaryMuscles': ['Deltóide Anterior'],
            'secondaryMuscles': ['Deltóide Lateral', 'Tríceps'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-021',
            'name': 'Elevação Lateral',
            'sets': 4,
            'reps': '12-15',
            'rest': 60,
            'muscleGroup': 'Ombros',
            'equipment': 'Halteres',
            'instructions': 'Em pé, eleve os halteres lateralmente até a altura dos ombros.',
            'tips': 'Leve inclinação para frente melhora a ativação do deltóide lateral.',
            'difficulty': 'beginner',
            'primaryMuscles': ['Deltóide Lateral'],
            'secondaryMuscles': ['Trapézio'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-022',
            'name': 'Elevação Frontal',
            'sets': 3,
            'reps': '12-15',
            'rest': 60,
            'muscleGroup': 'Ombros',
            'equipment': 'Halteres',
            'instructions': 'Em pé, eleve os halteres à frente até a altura dos olhos.',
            'tips': 'Alterne os braços para melhor foco em cada lado.',
            'difficulty': 'beginner',
            'primaryMuscles': ['Deltóide Anterior'],
            'secondaryMuscles': ['Peitoral Superior'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-023',
            'name': 'Face Pull',
            'sets': 3,
            'reps': '15-20',
            'rest': 45,
            'muscleGroup': 'Ombros',
            'equipment': 'Polia',
            'instructions': 'Em pé diante da polia alta, puxe a corda até o rosto, abrindo os braços.',
            'tips': 'Rotação externa no topo para fortalecer o manguito rotador.',
            'difficulty': 'intermediate',
            'primaryMuscles': ['Deltóide Posterior'],
            'secondaryMuscles': ['Trapézio', 'Rombóide'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-024',
            'name': 'Rosca Martelo',
            'sets': 3,
            'reps': '10-12',
            'rest': 60,
            'muscleGroup': 'Bíceps',
            'equipment': 'Halteres',
            'instructions': 'Em pé, alterne a flexão dos braços com halteres em pegada neutra.',
            'tips': 'Gire o pulso para fora no topo para maior ativação.',
            'difficulty': 'beginner',
            'primaryMuscles': ['Bíceps Braquial', 'Braquial'],
            'secondaryMuscles': ['Antebraço'],
            'videoUrl': null,
            'imageUrl': null,
          },
          {
            'id': 'e-025',
            'name': 'Tríceps Francês',
            'sets': 3,
            'reps': '10-12',
            'rest': 60,
            'muscleGroup': 'Tríceps',
            'equipment': 'Haltere',
            'instructions': 'Deite no banco, segure o halter com ambos os braços estendidos. Flexione os cotovelos descendo o halter atrás da cabeça.',
            'tips': 'Mantenha os cotovelos apontando para o teto.',
            'difficulty': 'intermediate',
            'primaryMuscles': ['Tríceps'],
            'secondaryMuscles': [],
            'videoUrl': null,
            'imageUrl': null,
          },
        ],
      },
    ];
  }

  Map<String, dynamic> getWorkout(String id) {
    return getWorkouts().firstWhere(
      (w) => w['id'] == id,
      orElse: () => getWorkouts().first,
    );
  }

  Map<String, dynamic> getExercise(String id) {
    final exercises = getWorkouts().expand((w) => (w['exercises'] as List)).toList();
    return exercises.firstWhere(
      (e) => e['id'] == id,
      orElse: () => exercises.first,
    );
  }

  Map<String, dynamic> getDailyCoach() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Bom dia';
    } else if (hour < 18) {
      greeting = 'Boa tarde';
    } else {
      greeting = 'Boa noite';
    }

    return {
      'message': '$greeting, $userName! 💪 Seu treino de hoje é Peito + Tríceps. Você está numa sequência de 8 dias! Continue assim!',
      'suggestions': [
        'Treine peito e tríceps hoje',
        'Beba pelo menos 2L de água',
        'Durma 7-8 horas esta noite',
      ],
      'tip': 'Dica: Descanse 90 segundos entre as séries de supino para máxima hipertrofia.',
      'motivation': 'A consistência é mais importante que a intensidade. Você está no caminho certo!',
      'weeklySummary': {
        'workoutsCompleted': 3,
        'workoutsPlanned': 4,
        'caloriesBurned': 1850,
        'avgHeartRate': 145,
        'totalVolume': '12,450 kg',
      },
    };
  }

  // ===== NUTRITION =====

  Map<String, dynamic> getNutritionGoals() {
    return {
      'targetCalories': 2500,
      'caloriesConsumed': _mealLogs.fold<int>(0, (sum, m) => sum + (m['calories'] as int)),
      'targetProtein': 165,
      'protein': _mealLogs.fold<int>(0, (sum, m) => sum + (m['protein'] as int)),
      'targetCarbs': 310,
      'carbs': _mealLogs.fold<int>(0, (sum, m) => sum + (m['carbs'] as int)),
      'targetFat': 83,
      'fat': _mealLogs.fold<int>(0, (sum, m) => sum + (m['fat'] as int)),
      'waterTarget': 3000,
      'waterCurrent': _waterGlasses * 250,
      'waterGlasses': _waterGlasses,
      'meals': List.from(_mealLogs),
    };
  }

  void addMeal(Map<String, dynamic> meal) {
    _mealLogs.add(meal);
  }

  void removeMeal(String id) {
    _mealLogs.removeWhere((m) => m['id'] == id);
  }

  void addWaterGlass() {
    _waterGlasses++;
  }

  void removeWaterGlass() {
    if (_waterGlasses > 0) _waterGlasses--;
  }

  List<Map<String, dynamic>> getMealSuggestions() {
    return [
      {
        'name': 'Frango com Arroz e Feijão',
        'calories': 550,
        'protein': 40,
        'carbs': 55,
        'fat': 12,
        'mealType': 'lunch',
        'foods': [
          {'name': 'Peito de frango (150g)', 'calories': 250, 'protein': 30, 'carbs': 0, 'fat': 6},
          {'name': 'Arroz (100g)', 'calories': 130, 'protein': 3, 'carbs': 28, 'fat': 0},
          {'name': 'Feijão (100g)', 'calories': 90, 'protein': 6, 'carbs': 16, 'fat': 0},
          {'name': 'Salada', 'calories': 30, 'protein': 1, 'carbs': 6, 'fat': 0},
        ],
      },
      {
        'name': 'Omelete com Aveia',
        'calories': 380,
        'protein': 28,
        'carbs': 30,
        'fat': 16,
        'mealType': 'breakfast',
        'foods': [
          {'name': 'Ovos (4)', 'calories': 280, 'protein': 24, 'carbs': 2, 'fat': 20},
          {'name': 'Aveia (40g)', 'calories': 100, 'protein': 4, 'carbs': 28, 'fat': -4},
        ],
      },
      {
        'name': 'Batata Doce com Carne Moída',
        'calories': 480,
        'protein': 35,
        'carbs': 50,
        'fat': 12,
        'mealType': 'dinner',
        'foods': [
          {'name': 'Batata doce (200g)', 'calories': 170, 'protein': 3, 'carbs': 40, 'fat': 0},
          {'name': 'Carne moída (150g)', 'calories': 250, 'protein': 28, 'carbs': 0, 'fat': 10},
          {'name': 'Brócolis', 'calories': 60, 'protein': 4, 'carbs': 10, 'fat': 2},
        ],
      },
    ];
  }

  // ===== BODY ANALYSIS =====

  Map<String, dynamic> getMeasurements() {
    if (_bodyMeasurements.isEmpty) {
      return {
        'weight': 82.5,
        'bodyFat': 16.2,
        'muscleMass': 38.5,
        'measurements': [
          {'name': 'Braço', 'value': 38, 'unit': 'cm'},
          {'name': 'Peito', 'value': 102, 'unit': 'cm'},
          {'name': 'Cintura', 'value': 82, 'unit': 'cm'},
          {'name': 'Quadril', 'value': 98, 'unit': 'cm'},
          {'name': 'Coxa', 'value': 60, 'unit': 'cm'},
        ],
      };
    }
    final latest = _bodyMeasurements.first;
    return {
      'weight': latest['weight'],
      'bodyFat': latest['bodyFat'],
      'muscleMass': latest['muscleMass'],
      'measurements': latest['measurements'],
    };
  }

  List<Map<String, dynamic>> getBodyMeasurements() {
    return List.from(_bodyMeasurements);
  }

  void addBodyMeasurement(Map<String, dynamic> measurement) {
    _bodyMeasurements.insert(0, measurement);
  }

  List<Map<String, dynamic>> getBodyPhotos() {
    return List.from(_bodyPhotos);
  }

  void addBodyPhoto(Map<String, dynamic> photo) {
    _bodyPhotos.insert(0, photo);
  }

  Map<String, dynamic> getBodyComposition() {
    final latest = _bodyMeasurements.isNotEmpty ? _bodyMeasurements.first : null;
    return {
      'weight': latest?['weight'] ?? 82.5,
      'bodyFat': latest?['bodyFat'] ?? 16.2,
      'muscleMass': latest?['muscleMass'] ?? 38.5,
      'bmi': 26.0,
      'leanMass': (latest?['weight'] ?? 82.5) * (1 - (latest?['bodyFat'] ?? 16.2) / 100),
      'fatMass': (latest?['weight'] ?? 82.5) * (latest?['bodyFat'] ?? 16.2) / 100,
      'basalMetabolicRate': 1820,
      'dailyCalorieExpenditure': 2450,
      'visceralFat': '12',
      'waterPercentage': 55.0,
      'history': _bodyMeasurements.map((m) => {
        'date': m['date'],
        'weight': m['weight'],
        'bodyFat': m['bodyFat'],
        'muscleMass': m['muscleMass'],
      }).toList(),
    };
  }

  // ===== PREDICTIVE AI =====

  Map<String, dynamic> getPredictions() {
    return {
      'currentWeight': 82.5,
      'targetWeight': 78.0,
      'prediction': {
        'weeksToGoal': 12,
        'estimatedDate': '2026-10-06',
        'confidence': 87,
        'strategy': 'Perda de 0.4-0.5kg por semana com déficit calórico moderado de 300-500 kcal/dia',
      },
      'projections': [
        {'week': 0, 'weight': 82.5, 'bodyFat': 16.2, 'muscleMass': 38.5},
        {'week': 2, 'weight': 81.8, 'bodyFat': 15.9, 'muscleMass': 38.3},
        {'week': 4, 'weight': 81.1, 'bodyFat': 15.6, 'muscleMass': 38.1},
        {'week': 6, 'weight': 80.4, 'bodyFat': 15.2, 'muscleMass': 38.0},
        {'week': 8, 'weight': 79.7, 'bodyFat': 14.9, 'muscleMass': 37.8},
        {'week': 10, 'weight': 79.0, 'bodyFat': 14.5, 'muscleMass': 37.6},
        {'week': 12, 'weight': 78.3, 'bodyFat': 14.2, 'muscleMass': 37.5},
      ],
      'recommendations': [
        'Mantenha o déficit calórico de 400 kcal/dia',
        'Aumente a proteína para 2g/kg (165g/dia)',
        'Adicione 2 sessões de cardio intervalado por semana',
        'Durma mínimo 7h por noite para otimizar a recuperação',
      ],
      'riskFactors': [
        'Peso pode estagnar na semana 6-8 (platô)',
        'Redução de massa muscular é possível se proteína for insuficiente',
      ],
    };
  }

  // ===== COMMUNITY =====

  List<Map<String, dynamic>> getCommunityFeed() {
    return [
      {
        'id': 'cf-001',
        'userName': 'Carlos M.',
        'avatar': null,
        'type': 'workout_completed',
        'content': 'Completou Treino A - Peito + Tríceps',
        'detail': '47 min • 2,340 kg de volume total',
        'time': '2h atrás',
        'likes': 23,
        'comments': 5,
        'liked': false,
      },
      {
        'id': 'cf-002',
        'userName': 'Ana P.',
        'avatar': null,
        'type': 'achievement',
        'content': 'Desbloqueou: "Sequência de 30 dias"',
        'detail': '🔥 30 dias consecutivos treinando!',
        'time': '3h atrás',
        'likes': 67,
        'comments': 12,
        'liked': true,
      },
      {
        'id': 'cf-003',
        'userName': 'Pedro L.',
        'avatar': null,
        'type': 'personal_record',
        'content': 'Novo recorde no Supino Reto!',
        'detail': '80kg × 8 reps (anterior: 75kg × 8)',
        'time': '5h atrás',
        'likes': 45,
        'comments': 8,
        'liked': false,
      },
      {
        'id': 'cf-004',
        'userName': 'Maria S.',
        'avatar': null,
        'type': 'level_up',
        'content': 'Subiu para o Nível 15!',
        'detail': 'Rank: Diamante 💎',
        'time': '6h atrás',
        'likes': 89,
        'comments': 15,
        'liked': true,
      },
      {
        'id': 'cf-005',
        'userName': 'Lucas R.',
        'avatar': null,
        'type': 'workout_completed',
        'content': 'Completou Treino C - Pernas',
        'detail': '62 min • 5,120 kg de volume total',
        'time': '8h atrás',
        'likes': 31,
        'comments': 3,
        'liked': false,
      },
    ];
  }

  List<Map<String, dynamic>> getLeaderboard() {
    return [
      {'rank': 1, 'name': 'Ana P.', 'xp': 8920, 'level': 15, 'streak': 30, 'avatar': null},
      {'rank': 2, 'name': 'Pedro L.', 'xp': 7650, 'level': 13, 'streak': 22, 'avatar': null},
      {'rank': 3, 'name': 'Carlos M.', 'xp': 6800, 'level': 12, 'streak': 18, 'avatar': null},
      {'rank': 4, 'name': 'Maria S.', 'xp': 6200, 'level': 11, 'streak': 15, 'avatar': null},
      {'rank': 5, 'name': 'Lucas R.', 'xp': 5800, 'level': 10, 'streak': 12, 'avatar': null},
      {'rank': 6, 'name': 'Julia F.', 'xp': 5400, 'level': 9, 'streak': 10, 'avatar': null},
      {'rank': 7, 'name': 'Rafael O.', 'xp': 4900, 'level': 9, 'streak': 9, 'avatar': null},
      {'rank': 8, 'name': userName, 'xp': 3450, 'level': 8, 'streak': 8, 'avatar': null},
      {'rank': 9, 'name': 'Camila D.', 'xp': 3200, 'level': 7, 'streak': 6, 'avatar': null},
      {'rank': 10, 'name': 'Bruno H.', 'xp': 2800, 'level': 6, 'streak': 5, 'avatar': null},
    ];
  }

  // ===== GAMIFICATION =====

  List<Map<String, dynamic>> getAchievements() {
    return [
      {'id': 'a-001', 'name': 'Primeiro Treino', 'description': 'Complete seu primeiro treino', 'icon': '🏋️', 'earned': true, 'date': '2026-05-01'},
      {'id': 'a-002', 'name': 'Sequência de 7 dias', 'description': 'Treine 7 dias consecutivos', 'icon': '🔥', 'earned': true, 'date': '2026-05-10'},
      {'id': 'a-003', 'name': 'Sequência de 30 dias', 'description': 'Treine 30 dias consecutivos', 'icon': '🔥', 'earned': false},
      {'id': 'a-004', 'name': '10 Treinos', 'description': 'Complete 10 treinos', 'icon': '💪', 'earned': true, 'date': '2026-05-15'},
      {'id': 'a-005', 'name': '50 Treinos', 'description': 'Complete 50 treinos', 'icon': '💪', 'earned': false},
      {'id': 'a-006', 'name': '100 Treinos', 'description': 'Complete 100 treinos', 'icon': '💪', 'earned': false},
      {'id': 'a-007', 'name': 'Maratonista', 'description': 'Complete 10km de corrida', 'icon': '🏃', 'earned': false},
      {'id': 'a-008', 'name': 'Nutrição Perfeita', 'description': 'Atinja suas metas nutricionais 7 dias seguidos', 'icon': '🥗', 'earned': false},
      {'id': 'a-009', 'name': 'Hidratação', 'description': 'Beba 3L de água por 5 dias', 'icon': '💧', 'earned': false},
      {'id': 'a-010', 'name': 'Atleta Dedicado', 'description': 'Complete 25 treinos no mês', 'icon': '⭐', 'earned': true, 'date': '2026-06-01'},
      {'id': 'a-011', 'name': 'Primeiro Recorde', 'description': 'Quebre seu primeiro recorde pessoal', 'icon': '🏆', 'earned': true, 'date': '2026-05-20'},
      {'id': 'a-012', 'name': '5 Recordes', 'description': 'Quebre 5 recordes pessoais', 'icon': '🏆', 'earned': true, 'date': '2026-06-25'},
      {'id': 'a-013', 'name': 'Nível 5', 'description': 'Alcance o nível 5', 'icon': '⭐', 'earned': true, 'date': '2026-05-25'},
      {'id': 'a-014', 'name': 'Nível 10', 'description': 'Alcance o nível 10', 'icon': '⭐', 'earned': false},
      {'id': 'a-015', 'name': 'Rank Ouro', 'description': 'Alcance o rank Ouro', 'icon': '🥇', 'earned': true, 'date': '2026-06-15'},
    ];
  }

  List<Map<String, dynamic>> getDailyChallenges() {
    return List.from(_dailyChallenges);
  }

  void completeChallenge(String id) {
    final idx = _dailyChallenges.indexWhere((c) => c['id'] == id);
    if (idx != -1) {
      _dailyChallenges[idx]['completed'] = true;
      _dailyChallenges[idx]['progress'] = _dailyChallenges[idx]['target'];
    }
  }

  List<Map<String, dynamic>> getLeagues() {
    return [
      {'name': 'Bronze', 'minXp': 0, 'maxXp': 1000, 'color': '0xFFCD7F32', 'icon': '🥉'},
      {'name': 'Prata', 'minXp': 1000, 'maxXp': 3000, 'color': '0xFFC0C0C0', 'icon': '🥈'},
      {'name': 'Ouro', 'minXp': 3000, 'maxXp': 6000, 'color': '0xFFFFD700', 'icon': '🥇', 'current': true},
      {'name': 'Platina', 'minXp': 6000, 'maxXp': 10000, 'color': '0xFFE5E4E2', 'icon': '💎'},
      {'name': 'Diamante', 'minXp': 10000, 'maxXp': 99999, 'color': '0xFFB9F2FF', 'icon': '💠'},
    ];
  }

  // ===== NOTIFICATIONS =====

  List<Map<String, dynamic>> getNotifications() {
    return [
      {'id': 'n-001', 'title': 'Treino Concluído!', 'body': 'Você completou o Treino A. Parabéns!', 'time': '2h atrás', 'read': false, 'type': 'workout'},
      {'id': 'n-002', 'title': 'Sequência de 8 dias', 'body': 'Continue assim! Você está numa sequência impressionante.', 'time': '5h atrás', 'read': false, 'type': 'gamification'},
      {'id': 'n-003', 'title': 'Nova conquista', 'body': 'Você desbloqueou: "Atleta Dedicado"', 'time': '1 dia atrás', 'read': true, 'type': 'achievement'},
      {'id': 'n-004', 'title': 'Lembrete de treino', 'body': 'Hora de treinar! Seu treino de hoje é Peito + Tríceps.', 'time': '2 dias atrás', 'read': true, 'type': 'reminder'},
      {'id': 'n-005', 'title': 'Dica de nutrição', 'body': 'Você está 300 calorias abaixo da meta. Que tal um lanche saudável?', 'time': '3 dias atrás', 'read': true, 'type': 'nutrition'},
      {'id': 'n-006', 'title': 'Recomendação de descanso', 'body': 'Você treinou 4 dias seguidos. Considere um dia de descanso.', 'time': '4 dias atrás', 'read': true, 'type': 'health'},
    ];
  }

  List<Map<String, dynamic>> getSmartNotifications() {
    return [
      {
        'id': 'sn-001',
        'title': 'Lembrete de treino',
        'description': 'Diário às 17:00',
        'enabled': true,
        'time': '17:00',
        'days': 'Seg, Ter, Qua, Qui, Sex',
        'type': 'reminder',
      },
      {
        'id': 'sn-002',
        'title': 'Lembrete de água',
        'description': 'A cada 2 horas',
        'enabled': true,
        'time': 'A cada 2h',
        'days': 'Todos',
        'type': 'water',
      },
      {
        'id': 'sn-003',
        'title': 'Dica do Coach IA',
        'description': 'Diário às 08:00',
        'enabled': true,
        'time': '08:00',
        'days': 'Todos',
        'type': 'ai_tip',
      },
      {
        'id': 'sn-004',
        'title': 'Lembrete de pesagem',
        'description': 'Toda segunda às 07:00',
        'enabled': false,
        'time': '07:00',
        'days': 'Segunda',
        'type': 'weigh_in',
      },
      {
        'id': 'sn-005',
        'title': 'Motivação semanal',
        'description': 'Domingo às 20:00',
        'enabled': true,
        'time': '20:00',
        'days': 'Domingo',
        'type': 'motivation',
      },
    ];
  }

  void toggleNotification(String id) {
    final notifications = getSmartNotifications();
    final notif = notifications.firstWhere((n) => n['id'] == id);
    notif['enabled'] = !notif['enabled'];
  }

  // ===== PREMIUM =====

  List<Map<String, dynamic>> getPlans() {
    return [
      {
        'id': 'free',
        'name': 'Gratuito',
        'price': 0,
        'period': '',
        'popular': false,
        'features': [
          '3 treinos por semana',
          'Coach IA limitado (5 msg/dia)',
          'Histórico básico',
          '1 exercício por grupo muscular',
        ],
        'highlighted': false,
      },
      {
        'id': 'premium_monthly',
        'name': 'Premium',
        'price': 29.90,
        'period': '/mês',
        'popular': true,
        'features': [
          'Treinos ilimitados',
          'Coach IA ilimitado',
          'Nutrição automática com IA',
          'Relatórios avançados',
          'Análise corporal com fotos',
          'Predições de evolução',
          'Comunidade completa',
          'Desafios diários',
          'Sem anúncios',
        ],
        'highlighted': true,
      },
      {
        'id': 'premium_yearly',
        'name': 'Premium Anual',
        'price': 199.90,
        'period': '/ano',
        'popular': false,
        'features': [
          'Tudo do Premium',
          '2 meses grátis (R\$ 59,80 de economia)',
          'Suporte prioritário',
          'Planos 100% personalizados',
          'Acesso antecipado a novidades',
        ],
        'highlighted': false,
      },
    ];
  }

  // ===== SETTINGS =====

  Map<String, dynamic> getSettings() {
    return {
      'notifications': {
        'pushEnabled': true,
        'workoutReminders': true,
        'waterReminders': true,
        'aiTips': true,
        'weeklyReport': true,
        'communityUpdates': false,
        'marketingEmails': false,
      },
      'privacy': {
        'profileVisibility': 'friends',
        'activityVisibility': 'public',
        'showInLeaderboard': true,
        'shareWorkouts': true,
      },
      'preferences': {
        'language': 'pt_BR',
        'units': 'metric',
        'darkMode': true,
        '24HourTime': true,
      },
    };
  }

  // ===== EXERCISES =====

  List<Map<String, dynamic>> getExercises() {
    return getWorkouts().expand((w) => (w['exercises'] as List).map((e) => {
      ...e as Map<String, dynamic>,
      'muscleGroup': w['muscleGroups'].toString().split(',')[0].trim(),
    })).toList();
  }

  List<Map<String, dynamic>> getExerciseCategories() {
    return [
      {'name': 'Peitoral', 'icon': 'chest', 'count': 12},
      {'name': 'Costas', 'icon': 'back', 'count': 10},
      {'name': 'Ombros', 'icon': 'shoulders', 'count': 8},
      {'name': 'Bíceps', 'icon': 'biceps', 'count': 6},
      {'name': 'Tríceps', 'icon': 'triceps', 'count': 6},
      {'name': 'Pernas', 'icon': 'legs', 'count': 10},
      {'name': 'Abdômen', 'icon': 'abs', 'count': 8},
    ];
  }

  // ===== AI CHAT =====

  String chatWithAi(String message) {
    final lowerMsg = message.toLowerCase();

    if (lowerMsg.contains('treino') || lowerMsg.contains('treinar')) {
      return 'Baseado no seu histórico, recomendo focar em hipertrofia esta semana. Seu último treino de peito está 15% mais forte! Que tal aumentar a carga no supino?';
    }
    if (lowerMsg.contains('dor') || lowerMsg.contains('machuc')) {
      return 'Se estiver sentindo dor muscular (DOMS), é normal após treinos intensos. Descanse o grupo muscular afetado por 48h e faça alongamento suave. Se a dor persistir, consulte um médico.';
    }
    if (lowerMsg.contains('nutri') || lowerMsg.contains('comida') || lowerMsg.contains('dieta')) {
      return 'Para ganho de massa muscular, consuma 1.6-2.2g de proteína por kg corporal. Com 82.5kg, seu ideal é 132-182g de proteína diária. Priorize fontes magras como peito de frango, ovos e whey.';
    }
    if (lowerMsg.contains('descanso') || lowerMsg.contains('dormir')) {
      return 'O descanso é fundamental! Durma 7-9 horas por noite. Evite telas 1h antes de dormir e mantenha um horário fixo. O sono é quando seus músculos se recuperam e crescem.';
    }
    if (lowerMsg.contains('água') || lowerMsg.contains('agua') || lowerMsg.contains('hidrat')) {
      return 'Beiba pelo menos 2-3 litros de água por dia. Durante o treino, tome 200-300ml a cada 15 minutos. A desidratação pode reduzir sua performance em até 20%.';
    }
    if (lowerMsg.contains('perder') || lowerMsg.contains('peso') || lowerMsg.contains('emagrecer')) {
      return 'Para perda de peso saudável, mantenha um déficit calórico de 300-500 kcal/dia. Combine treino de força (para manter massa muscular) com cardio intervalado. Meta realista: 0.5-1kg por semana.';
    }
    if (lowerMsg.contains('ganhar') || lowerMsg.contains('massa') || lowerMsg.contains('hipertrofia')) {
      return 'Para hipertrofia: supercálida de 200-300 kcal/dia, 1.6-2.2g proteína/kg, treinos com volume adequado (10-20 séries/grupo/semana) eprogressão de carga semanal.';
    }
    if (lowerMsg.contains('along') || lowerMsg.contains('flexibil')) {
      return 'Alongue após o treino, mantendo cada posição por 20-30 segundos. Foque nos grupos musculares trabalhados. Flexibilidade melhora recuperação e previne lesões.';
    }
    if (lowerMsg.contains('cardio') || lowerMsg.contains('correr')) {
      return 'Para cardio, recomendo 2-3 sessões por semana. HIIT (20-30 min) é mais eficiente para queima de gordura. Cardio em jejum pode aumentar a lipólise, mas não é obrigatório.';
    }

    return 'Entendi! Com base no seu objetivo de hipertrofia e seu nível intermediário, vou te ajudar com isso. Lembre-se: consistência é a chave. Treine 4x por semana, durma bem e coma proteína suficiente. Quer mais detalhes sobre algum aspecto específico?';
  }

  // ===== PROGRESS HISTORY =====

  List<Map<String, dynamic>> getWorkoutHistory() {
    return [
      {'date': '2026-07-14', 'workout': 'Treino A - Peito + Tríceps', 'duration': 52, 'volume': 2340, 'exercises': 6, 'calories': 420},
      {'date': '2026-07-13', 'workout': 'Treino D - Ombros + Braços', 'duration': 48, 'volume': 1890, 'exercises': 6, 'calories': 380},
      {'date': '2026-07-11', 'workout': 'Treino C - Pernas', 'duration': 63, 'volume': 5120, 'exercises': 7, 'calories': 520},
      {'date': '2026-07-10', 'workout': 'Treino B - Costas + Bíceps', 'duration': 50, 'volume': 3080, 'exercises': 6, 'calories': 410},
      {'date': '2026-07-09', 'workout': 'Treino A - Peito + Tríceps', 'duration': 55, 'volume': 2280, 'exercises': 6, 'calories': 405},
      {'date': '2026-07-07', 'workout': 'Treino C - Pernas', 'duration': 65, 'volume': 5050, 'exercises': 7, 'calories': 510},
      {'date': '2026-07-06', 'workout': 'Treino B - Costas + Bíceps', 'duration': 49, 'volume': 3020, 'exercises': 6, 'calories': 395},
    ];
  }

  List<Map<String, dynamic>> getWeeklyStats() {
    return [
      {'week': 'Sem 1', 'workouts': 4, 'volume': 12450, 'calories': 1715},
      {'week': 'Sem 2', 'workouts': 3, 'volume': 9800, 'calories': 1290},
      {'week': 'Sem 3', 'workouts': 4, 'volume': 13200, 'calories': 1820},
      {'week': 'Sem 4', 'workouts': 4, 'volume': 14720, 'calories': 1935},
    ];
  }

  List<Map<String, dynamic>> getMonthlyStats() {
    return [
      {'month': 'Jan', 'weight': 85.0, 'bodyFat': 18.5, 'workouts': 14},
      {'month': 'Fev', 'weight': 84.5, 'bodyFat': 18.0, 'workouts': 15},
      {'month': 'Mar', 'weight': 84.0, 'bodyFat': 17.5, 'workouts': 16},
      {'month': 'Abr', 'weight': 83.8, 'bodyFat': 17.2, 'workouts': 15},
      {'month': 'Mai', 'weight': 83.2, 'bodyFat': 16.8, 'workouts': 16},
      {'month': 'Jun', 'weight': 82.8, 'bodyFat': 16.5, 'workouts': 14},
      {'month': 'Jul', 'weight': 82.5, 'bodyFat': 16.2, 'workouts': 12},
    ];
  }
}
