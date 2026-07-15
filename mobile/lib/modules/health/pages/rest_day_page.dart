import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class RestDayPage extends StatefulWidget {
  const RestDayPage({super.key});

  @override
  State<RestDayPage> createState() => _RestDayPageState();
}

class _RestDayPageState extends State<RestDayPage> {
  int _selectedCategory = 0;

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.directions_walk, 'label': 'Atividades Leves'},
    {'icon': Icons.fitness_center, 'label': 'Rola de Espuma'},
    {'icon': Icons.self_improvement, 'label': 'Meditação'},
    {'icon': Icons.restaurant, 'label': 'Nutrição'},
  ];

  final List<Map<String, dynamic>> _lightActivities = [
    {
      'name': 'Caminhada ao Ar Livre',
      'duration': '20-30 min',
      'intensity': 'Leve',
      'description': 'Caminhada leve em ritmo confortável. Ajuda na recuperação ativa sem sobrecarregar.',
      'color': AppColors.success,
    },
    {
      'name': 'Alongamento Dinâmico',
      'duration': '15-20 min',
      'intensity': 'Muito Leve',
      'description': 'Movimentos suaves para manter a flexibilidade e aliviar tensão muscular.',
      'color': AppColors.info,
    },
    {
      'name': 'Yoga Restaurativo',
      'duration': '20-30 min',
      'intensity': 'Leve',
      'description': 'Posturas suaves com foco em respiração e relaxamento profundo.',
      'color': AppColors.primary,
    },
    {
      'name': 'Natação Leve',
      'duration': '20-30 min',
      'intensity': 'Leve',
      'description': 'Exercício de baixo impacto que trabalha todo o corpo sem sobrecarregar articulações.',
      'color': AppColors.info,
    },
    {
      'name': 'Ciclismo Leve',
      'duration': '30 min',
      'intensity': 'Leve',
      'description': 'Pedalada em ritmo fácil para manter o fluxo sanguíneo.',
      'color': AppColors.warning,
    },
  ];

  final List<Map<String, dynamic>> _foamRolling = [
    {
      'area': 'Quadríceps',
      'duration': '2 min por lado',
      'instructions': 'Deite de barriga para baixo, apoie a coxa na rola e role de baixo para cima lentamente.',
      'color': AppColors.primary,
    },
    {
      'area': 'Isquiotibiais',
      'duration': '2 min por lado',
      'instructions': 'Sentado, apoie a coxa posterior na rola e role da origem até o joelho.',
      'color': AppColors.success,
    },
    {
      'area': 'Costas',
      'duration': '3 min',
      'instructions': 'Deite de costas com a rola sob as escápulas, cruze os braços e role.',
      'color': AppColors.info,
    },
    {
      'area': 'Panturrilhas',
      'duration': '2 min por lado',
      'instructions': 'Sentado, apoie a panturrilha na rola e alterne a pressão.',
      'color': AppColors.warning,
    },
    {
      'area': 'Glúteos',
      'duration': '2 min por lado',
      'instructions': 'Sentado na rola, cruze uma perna sobre a outra e role a região glútea.',
      'color': AppColors.secondary,
    },
  ];

  final List<Map<String, dynamic>> _meditation = [
    {
      'name': 'Respiração 4-7-8',
      'duration': '5 min',
      'description': 'Inspire por 4 segundos, segure por 7, expire por 8. Repita 4 vezes.',
      'color': AppColors.info,
    },
    {
      'name': 'Meditação Guiada',
      'duration': '10 min',
      'description': 'Sessão de relaxamento guiado focando em cada parte do corpo.',
      'color': AppColors.primary,
    },
    {
      'name': 'Body Scan',
      'duration': '15 min',
      'description': 'Escaneie cada parte do corpo mentalmente, soltando a tensão.',
      'color': AppColors.success,
    },
    {
      'name': 'Visualização',
      'duration': '10 min',
      'description': 'Visualize um lugar tranquilo e desfrute do momento.',
      'color': AppColors.secondary,
    },
  ];

  final List<Map<String, dynamic>> _nutrition = [
    {
      'area': 'Proteínas',
      'icon': Icons.set_meal,
      'focus': 'Mantenha ingestão adequada para reparo muscular',
      'tips': ['2g por kg de peso corporal', 'Fontes magras: frango, peixe, tofu', 'Distribua ao longo do dia'],
      'color': AppColors.primary,
    },
    {
      'area': 'Carboidratos',
      'icon': Icons.bakery_dining,
      'focus': 'Recarregue glicogênio para próxima sessão',
      'tips': ['Foque em carboidratos complexos', 'Inclua vegetais em todas as refeições', 'Ajuste conforme atividade do dia'],
      'color': AppColors.warning,
    },
    {
      'area': 'Gorduras',
      'icon': Icons.local_dining,
      'focus': 'Gorduras saudáveis para hormônios e inflamação',
      'tips': ['Abacate, azeite, nozes', 'Ácidos graxos ômega-3', 'Evite gorduras trans'],
      'color': AppColors.secondary,
    },
    {
      'area': 'Micronutrientes',
      'icon': Icons.eco,
      'focus': 'Vitaminas e minerais essenciais para recuperação',
      'tips': ['Magnésio para relaxamento', 'Vitamina D para ossos', 'Zinc para imunidade'],
      'color': AppColors.success,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => context.pop()),
        title: const Text('Dia de Descanso'),
      ),
      body: Column(
        children: [
          _buildCategorySelector(),
          Expanded(
            child: IndexedStack(
              index: _selectedCategory,
              children: [
                _buildLightActivities(),
                _buildFoamRolling(),
                _buildMeditation(),
                _buildNutrition(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat['icon'] as IconData, color: isSelected ? AppColors.primary : AppColors.textMuted, size: 22),
                  const SizedBox(height: 6),
                  Text(cat['label'], style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLightActivities() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lightActivities.length,
      itemBuilder: (context, index) {
        final activity = _lightActivities[index];
        final color = activity['color'] as Color;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.directions_walk, color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(activity['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('${activity['duration']} • ${activity['intensity']}', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(activity['description'], style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFoamRolling() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _foamRolling.length,
      itemBuilder: (context, index) {
        final item = _foamRolling[index];
        final color = item['color'] as Color;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.fitness_center, color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['area'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(item['duration'], style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(item['instructions'], style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeditation() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _meditation.length,
      itemBuilder: (context, index) {
        final item = _meditation[index];
        final color = item['color'] as Color;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Icon(Icons.self_improvement, color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(item['duration'], style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(item['description'], style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutrition() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _nutrition.length,
      itemBuilder: (context, index) {
        final item = _nutrition[index];
        final color = item['color'] as Color;
        final tips = item['tips'] as List<String>;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Icon(item['icon'] as IconData, color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['area'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(item['focus'], style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check, color: color, size: 14),
                      const SizedBox(width: 8),
                      Expanded(child: Text(tip, style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}
