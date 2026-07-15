import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { GoogleGenerativeAI } from '@google/generative-ai';
import { AiConversation } from './entities/ai-conversation.entity';
import { AiMessage } from './entities/ai-message.entity';
import { AiMemory } from './entities/ai-memory.entity';
import { AiPrediction } from './entities/ai-prediction.entity';
import { AiAlert } from './entities/ai-alert.entity';
import { UserBehavior } from './entities/user-behavior.entity';
import { UsersService } from '../users/users.service';
import { WorkoutsService } from '../workouts/workouts.service';

@Injectable()
export class AiCoachService {
  private readonly genAI: GoogleGenerativeAI | null = null;
  private readonly logger = new Logger(AiCoachService.name);
  private readonly aiEnabled: boolean;

  constructor(
    private configService: ConfigService,
    @InjectRepository(AiConversation)
    private conversationRepository: Repository<AiConversation>,
    @InjectRepository(AiMessage)
    private messageRepository: Repository<AiMessage>,
    @InjectRepository(AiMemory)
    private memoryRepository: Repository<AiMemory>,
    @InjectRepository(AiPrediction)
    private predictionRepository: Repository<AiPrediction>,
    @InjectRepository(AiAlert)
    private alertRepository: Repository<AiAlert>,
    @InjectRepository(UserBehavior)
    private behaviorRepository: Repository<UserBehavior>,
    private usersService: UsersService,
    private workoutsService: WorkoutsService,
  ) {
    const apiKey = this.configService.get<string>('GEMINI_API_KEY');
    if (apiKey && !apiKey.startsWith('your-')) {
      this.genAI = new GoogleGenerativeAI(apiKey);
      this.aiEnabled = true;
      this.logger.log('Gemini initialized successfully');
    } else {
      this.aiEnabled = false;
      this.logger.warn('Gemini not configured - AI features use intelligent fallbacks');
    }
  }

  async chat(userId: string, message: string): Promise<{ response: string }> {
    let conversation = await this.conversationRepository.findOne({
      where: { userId },
      order: { createdAt: 'DESC' },
    });

    if (!conversation) {
      conversation = this.conversationRepository.create({ userId });
      await this.conversationRepository.save(conversation);
    }

    const userMessage = this.messageRepository.create({
      conversationId: conversation.id,
      sender: 'user',
      message,
    });
    await this.messageRepository.save(userMessage);

    const user = await this.usersService.findById(userId);
    const memories = await this.memoryRepository.find({
      where: { userId },
      order: { priority: 'DESC' },
      take: 20,
    });

    const context = this.buildContext(user, memories);

    let response: string;
    if (this.aiEnabled) {
      response = await this.generateResponse(message, context);
    } else {
      response = this.generateFallbackResponse(message, user, memories);
    }

    const aiMessage = this.messageRepository.create({
      conversationId: conversation.id,
      sender: 'assistant',
      message: response,
    });
    await this.messageRepository.save(aiMessage);

    await this.recordBehavior(userId, 'ai_chat', message);

    return { response };
  }

  async generateWorkout(userId: string): Promise<any> {
    const user = await this.usersService.findById(userId);
    const profile = user.profile;

    let workoutPlan: any;

    if (this.aiEnabled && this.genAI) {
      try {
        const prompt = `Gere um treino personalizado para o usuário com as seguintes informações:
    - Nome: ${user.firstName}
    - Objetivo: ${profile?.goal || 'geral'}
    - Nível de experiência: ${profile?.experienceLevel || 'iniciante'}
    - Dias disponíveis por semana: ${profile?.trainingDays || 3}
    - Tempo disponível por treino: ${profile?.trainingTime || 60} minutos
    - Lesões ou restrições: ${profile?.injuries || 'nenhuma'}
    
    Retorne APENAS um JSON válido (sem markdown, sem blocos de codigo) com a estrutura:
    {
      "name": "nome do treino",
      "exercises": [
        {
          "name": "nome do exercício",
          "sets": número de séries,
          "reps": "repetições",
          "rest": "descanso em segundos",
          "notes": "observações"
        }
      ]
    }`;

        const model = this.genAI.getGenerativeModel({ 
          model: this.configService.get<string>('GEMINI_MODEL') || 'gemini-2.0-flash-lite',
          systemInstruction: 'Você é um personal trainer especializado em criar treinos personalizados. Retorne sempre em formato JSON válido, sem markdown.',
        });
        const result = await model.generateContent(prompt);
        let response = result.response.text() || '';
        
        response = response.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
        
        workoutPlan = JSON.parse(response);
      } catch (error) {
        this.logger.error('Erro ao gerar treino com Gemini, usando fallback', error);
        workoutPlan = this.getFallbackWorkout(user, profile);
      }
    } else {
      workoutPlan = this.getFallbackWorkout(user, profile);
    }

    try {
      const workout = await this.workoutsService.create(userId, {
        name: workoutPlan.name || 'Treino Personalizado',
        goal: profile?.goal || 'general',
        estimatedDuration: profile?.trainingTime || 60,
      });

      if (workoutPlan.exercises && Array.isArray(workoutPlan.exercises)) {
        for (let i = 0; i < workoutPlan.exercises.length; i++) {
          const ex = workoutPlan.exercises[i];
          await this.workoutsService.addExercise(workout.id, {
            name: ex.name,
            orderNumber: i + 1,
            sets: ex.sets || 3,
            repetitions: ex.reps || '10-12',
            restTime: parseInt(String(ex.rest || '60'), 10),
            notes: ex.notes || '',
          });
        }
      }

      return {
        id: workout.id,
        ...workoutPlan,
        goal: profile?.goal,
        weekNumber: 1,
        estimatedDuration: profile?.trainingTime || 60,
      };
    } catch (error) {
      this.logger.error('Erro ao salvar treino gerado', error);
      return workoutPlan;
    }
  }

  async analyzeProgress(userId: string): Promise<any> {
    const user = await this.usersService.findById(userId);
    const memories = await this.memoryRepository.find({
      where: { userId },
      order: { createdAt: 'DESC' },
      take: 50,
    });

    const prompt = `Analise o progresso do usuário e forneça uma avaliação detalhada:
    
    Dados do usuário:
    - Nome: ${user.firstName}
    - Objetivo: ${user.profile?.goal || 'não definido'}
    
    Histórico de atividades:
    ${memories.map(m => `- ${m.key}: ${m.value}`).join('\n')}
    
    Forneça uma análise com:
    1. Resumo do progresso
    2. Pontos fortes
    3. Áreas para melhorar
    4. Recomendações específicas
    5. Próximos passos`;

      if (this.aiEnabled && this.genAI) {
        try {
          const model = this.genAI.getGenerativeModel({ 
            model: this.configService.get<string>('GEMINI_MODEL') || 'gemini-2.5-flash',
            systemInstruction: 'Você é um analista de fitness especializado. Forneça análises detalhadas e constructive do progresso do usuário.',
          });
          const result = await model.generateContent(prompt);
          const response = result.response.text();

          return {
            summary: response,
            recommendations: [],
          };
        } catch (error) {
          this.logger.error('Erro ao analisar progresso', error);
        }
      }

      return {
        summary: `Análise de progresso para ${user.firstName}: Para uma análise completa com IA, configure sua chave OpenAI no .env. Por enquanto, continue registrando seus treinos e medidas para acompanharmos sua evolução!`,
        recommendations: ['Mantenha a consistência nos treinos', 'Registre suas medidas semanalmente', 'Durma pelo menos 7h por noite'],
      };
  }

  async getDailyCoach(userId: string): Promise<any> {
    const user = await this.usersService.findById(userId);
    const memories = await this.memoryRepository.find({
      where: { userId },
      order: { priority: 'DESC' },
      take: 10,
    });

    if (this.aiEnabled && this.genAI) {
      const prompt = `Gere uma mensagem motivacional diária para o usuário:
      
      Nome: ${user.firstName}
      Últimas atividades:
      ${memories.map(m => `- ${m.key}: ${m.value}`).join('\n')}
      
      Forneça:
      1. Uma mensagem motivacional personalizada
      2. 3 sugestões de atividades para hoje
      3. Uma dica de nutrição`;

      try {
        const model = this.genAI.getGenerativeModel({ 
          model: this.configService.get<string>('GEMINI_MODEL') || 'gemini-2.5-flash',
          systemInstruction: 'Você é um coach motivacional. Forneça mensagens inspiradoras e práticas.',
        });
        const result = await model.generateContent(prompt);
        const response = result.response.text();
        return {
          message: response,
          suggestions: [],
        };
      } catch (error) {
        this.logger.error('Erro ao gerar mensagem diária', error);
      }
    }

    return this.getFallbackDailyCoach(user);
  }

  async getRecommendations(userId: string): Promise<any[]> {
    return this.predictionRepository.find({
      where: { userId, status: 'pending' },
      order: { createdAt: 'DESC' },
      take: 5,
    });
  }

  async getAlerts(userId: string): Promise<any[]> {
    return this.alertRepository.find({
      where: { userId, read: false },
      order: { createdAt: 'DESC' },
      take: 10,
    });
  }

  async recordBehavior(userId: string, eventType: string, value?: string): Promise<void> {
    const behavior = this.behaviorRepository.create({
      userId,
      eventType,
      value,
    });
    await this.behaviorRepository.save(behavior);
  }

  async getMemory(userId: string): Promise<AiMemory[]> {
    return this.memoryRepository.find({
      where: { userId },
      order: { priority: 'DESC' },
    });
  }

  async getPredictions(userId: string): Promise<any> {
    const user = await this.usersService.findById(userId);
    const profile = user.profile;

    const currentWeight = profile?.weight || 82.5;
    const targetWeight = profile?.targetWeight || 78;
    const goal = profile?.goal || 'hypertrophy';
    const experienceLevel = profile?.experienceLevel || 'intermediate';

    const weightDiff = currentWeight - targetWeight;
    const weeklyDeficit = goal === 'fat_loss' ? 0.5 : 0.3;
    const weeksToGoal = Math.ceil(weightDiff / weeklyDeficit);
    const estimatedDate = new Date();
    estimatedDate.setDate(estimatedDate.getDate() + weeksToGoal * 7);

    const projections: Array<{ week: number; weight: number; bodyFat: number; muscleMass: number }> = [];
    for (let week = 0; week <= weeksToGoal; week += 2) {
      const progress = week / weeksToGoal;
      projections.push({
        week,
        weight: Math.round((currentWeight - weightDiff * progress) * 10) / 10,
        bodyFat: Math.round((16.2 - progress * 2) * 10) / 10,
        muscleMass: Math.round((38.5 - progress * 0.8) * 10) / 10,
      });
    }

    const recommendations = [
      'Mantenha o déficit calórico de 300-500 kcal/dia',
      `Aumente a proteína para 2g/kg (${Math.round(currentWeight * 2)}g/dia)`,
      'Adicione 2 sessões de cardio intervalado por semana',
      'Durma mínimo 7h por noite para otimizar a recuperação',
    ];

    const riskFactors = [
      'Peso pode estagnar na semana 6-8 (platô metabólico)',
      'Redução de massa muscular é possível se proteína for insuficiente',
    ];

    let confidence = 85;
    if (experienceLevel === 'advanced') confidence += 5;
    if (experienceLevel === 'beginner') confidence -= 5;
    if (goal === 'fat_loss') confidence += 3;

    return {
      currentWeight,
      targetWeight,
      prediction: {
        weeksToGoal,
        estimatedDate: estimatedDate.toISOString().split('T')[0],
        confidence,
        strategy: `Perda de ${weeklyDeficit}kg por semana com déficit calórico moderado de 300-500 kcal/dia`,
      },
      projections,
      recommendations,
      riskFactors,
    };
  }

  private buildContext(user: any, memories: AiMemory[]): string {
    const profile = user.profile;
    let context = `Usuário: ${user.firstName}\n`;

    if (profile) {
      context += `Objetivo: ${profile.goal || 'não definido'}\n`;
      context += `Nível: ${profile.experienceLevel || 'não definido'}\n`;
      context += `Dias disponíveis: ${profile.trainingDays || 'não definido'}\n`;
    }

    if (memories.length > 0) {
      context += '\nMemórias:\n';
      memories.forEach((m) => {
        context += `- ${m.key}: ${m.value}\n`;
      });
    }

    return context;
  }

  private async generateResponse(message: string, context: string): Promise<string> {
    if (!this.genAI) {
      return 'Desculpe, o coach IA não está configurado no momento.';
    }
    try {
      const model = this.genAI.getGenerativeModel({ 
        model: this.configService.get<string>('GEMINI_MODEL') || 'gemini-2.5-flash',
        systemInstruction: `Você é um coach de fitness pessoal especializado e motivador. 
            Seu objetivo é ajudar o usuário a alcançar seus objetivos de treino e saúde.
            Seja encorajador, profissional e forneça conselhos práticos.
            
            Diretrizes:
            - Responda sempre em português brasileiro
            - Seja motivador e positivo
            - Forneça dicas práticas e específicas
            - Se não souber algo, admita honestamente
            - Nunca forneça conselhos médicos, sempre recomende consultar um profissional
            
            Contexto do usuário:
            ${context}`,
      });
      const result = await model.generateContent(message);
      return result.response.text() || 'Desculpe, não consegui processar sua mensagem.';
    } catch (error) {
      this.logger.error('Erro ao gerar resposta com Gemini', error);
      return 'Desculpe, estou com dificuldades para processar sua mensagem no momento. Tente novamente mais tarde.';
    }
  }

  private getWorkoutName(profile: any): string {
    if (!profile) return 'Treino Personalizado';

    const days = profile.trainingDays || 3;
    const goal = profile.goal || 'general';

    const goalNames: Record<string, string> = {
      hypertrophy: 'Hipertrofia',
      fat_loss: 'Emagrecimento',
      definition: 'Definição',
      strength: 'Força',
      health: 'Saúde',
      conditioning: 'Condicionamento',
    };

    return `${goalNames[goal] || 'Personalizado'} - ${days}x por semana`;
  }

  private generateFallbackResponse(message: string, user: any, memories: AiMemory[]): string {
    const lowerMessage = message.toLowerCase();

    if (lowerMessage.includes('treino') || lowerMessage.includes('exercício')) {
      return `Olá ${user.firstName}! Para um treino eficiente, foque nos exercícios compostos como agachamento, supino e deadlift. Comece com 3 séries de 8-12 repetições. Quer que eu gere um treino personalizado para você?`;
    }
    if (lowerMessage.includes('dieta') || lowerMessage.includes('nutrição') || lowerMessage.includes('alimentação')) {
      return `Uma boa alimentação é fundamental, ${user.firstName}! Para ganho de massa, consuma 1.6-2.2g de proteína por kg de peso corporal. Distribua em 4-5 refeições ao dia. Preciso de mais detalhes sobre seus objetivos para personalizar suas recomendações.`;
    }
    if (lowerMessage.includes('descanso') || lowerMessage.includes('dormir') || lowerMessage.includes('sono')) {
      return `O descanso é tão importante quanto o treino, ${user.firstName}! Procure dormir 7-9 horas por noite. Evite telas 1h antes de dormir e mantenha um horário regular. Isso é crucial para a recuperação muscular.`;
    }
    if (lowerMessage.includes('motiv') || lowerMessage.includes('desanim')) {
      return `Não desanime, ${user.firstName}! Cada treino é um passo em direção ao seu objetivo. Lembre-se: progresso é progresso, mesmo que pequeno. Continue firme que os resultados vão aparecer! 💪`;
    }
    if (lowerMessage.includes('lesão') || lowerMessage.includes('dor')) {
      return `Em caso de dor ou lesão, ${user.firstName}, é importante consultar um profissional de saúde. Não treine áreas lesionadas. Posso ajudar com exercícios adaptados para a recuperação, mas sempre consulte um médico primeiro.`;
    }
    if (lowerMessage.includes('obrigad') || lowerMessage.includes('valeu')) {
      return `De nada, ${user.firstName}! Estou aqui para ajudar. Se tiver mais dúvidas, é só perguntar. Bons treinos! 🏋️`;
    }

    return `Entendido, ${user.firstName}! Como seu coach de fitness, posso ajudar com treinos, nutrição, dicas de descanso e motivação. O que você gostaria de saber? Lembre-se: para funcionalidades avançadas de IA, configure sua chave da OpenAI no .env.`;
  }

  private getFallbackWorkout(user: any, profile: any): any {
    const goal = profile?.goal || 'hypertrophy';
    const days = profile?.trainingDays || 3;
    const level = profile?.experienceLevel || 'beginner';

    const workoutTemplates: Record<string, any> = {
      hypertrophy: {
        name: `Hipertrofia - ${days}x por semana`,
        exercises: [
          { name: 'Supino Reto com Barra', sets: 4, reps: '10-12', rest: '90s', notes: 'Foque na contração do peitoral' },
          { name: 'Agachamento Livre', sets: 4, reps: '8-10', rest: '120s', notes: 'Mantenha o core contraído' },
          { name: 'Remada Curvada', sets: 4, reps: '10-12', rest: '90s', notes: 'Escápulas juntas no topo' },
          { name: 'Desenvolvimento com Halteres', sets: 3, reps: '10-12', rest: '60s', notes: 'Não trave os cotovelos' },
          { name: 'Rosca Direta com Barra', sets: 3, reps: '12-15', rest: '60s', notes: 'Cotovelos fixos' },
          { name: 'Tríceps Pulley', sets: 3, reps: '12-15', rest: '60s', notes: 'Cotovelos ao lado do corpo' },
        ],
      },
      fat_loss: {
        name: `Emagrecimento - ${days}x por semana`,
        exercises: [
          { name: 'Burpees', sets: 3, reps: '10', rest: '45s', notes: 'Mantenha o ritmo alto' },
          { name: 'Agachamento com Salto', sets: 3, reps: '15', rest: '30s', notes: 'Aterrissagem suave' },
          { name: 'Flexão de Braços', sets: 3, reps: '12-15', rest: '30s', notes: 'Core contraído' },
          { name: 'Mountain Climbers', sets: 3, reps: '30s', rest: '30s', notes: 'Rápido e controlado' },
          { name: 'Prancha Frontal', sets: 3, reps: '45s', rest: '30s', notes: 'Não deixe o quadril cair' },
          { name: 'Prancha Lateral', sets: 3, reps: '30s cada lado', rest: '30s', notes: 'Alinhe o corpo' },
        ],
      },
      definition: {
        name: `Definição - ${days}x por semana`,
        exercises: [
          { name: 'Supino Inclinado com Halteres', sets: 4, reps: '12-15', rest: '60s', notes: 'Controle a descida' },
          { name: 'Cadeira Extensora', sets: 3, reps: '15-20', rest: '45s', notes: 'Contração no topo' },
          { name: 'Puxada Frontal', sets: 4, reps: '12-15', rest: '60s', notes: 'Puxe com os cotovelos' },
          { name: 'Elevação Lateral', sets: 3, reps: '15-20', rest: '45s', notes: 'Leve inclinação para frente' },
          { name: 'Rosca Martelo', sets: 3, reps: '12-15', rest: '45s', notes: 'Gire o pulso no topo' },
          { name: 'Tríceps Francês', sets: 3, reps: '12-15', rest: '45s', notes: 'Cotovelos fixos' },
        ],
      },
      strength: {
        name: `Força - ${days}x por semana`,
        exercises: [
          { name: 'Supino Reto com Barra', sets: 5, reps: '3-5', rest: '180s', notes: 'Carga pesada, controle total' },
          { name: 'Agachamento Livre', sets: 5, reps: '3-5', rest: '180s', notes: 'Profundidade completa' },
          { name: 'Levantamento Terra', sets: 5, reps: '3-5', rest: '180s', notes: 'Costas retas sempre' },
          { name: 'Desenvolvimento Militar', sets: 4, reps: '5-6', rest: '120s', notes: 'Core firme' },
          { name: 'Barra Fixa (Pull-up)', sets: 4, reps: '5-8', rest: '120s', notes: 'Amplitude completa' },
          { name: 'Mergulho em Barras', sets: 3, reps: '6-8', rest: '90s', notes: 'Incline para frente' },
        ],
      },
    };

    const template = workoutTemplates[goal] || workoutTemplates.hypertrophy;
    return {
      ...template,
      goal,
      weekNumber: 1,
      estimatedDuration: profile?.trainingTime || 60,
      source: 'fallback',
    };
  }

  private getFallbackDailyCoach(user: any): any {
    const hour = new Date().getHours();
    let timeGreeting = 'Bom dia';
    if (hour >= 12 && hour < 18) timeGreeting = 'Boa tarde';
    else if (hour >= 18) timeGreeting = 'Boa noite';

    const suggestions = [
      'Faça 30 minutos de caminhada rápida',
      'Treine os músculos do dia com 4 exercícios',
      'Pratique 10 minutos de alongamento',
    ];

    return {
      message: `${timeGreeting}, ${user.firstName}! 💪 Cada dia é uma nova oportunidade para evoluir. Lembre-se: consistência é mais importante que intensidade. Que tal começar com uma atividade leve hoje?`,
      suggestions,
      nutritionTip: 'Beba pelo menos 2L de água ao dia e inclua proteína em todas as refeições.',
      source: 'fallback',
    };
  }
}
