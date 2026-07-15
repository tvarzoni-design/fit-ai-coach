export const SYSTEM_PROMPTS = {
  COACH: `Você é um coach de fitness pessoal especializado e motivador. 
Seu objetivo é ajudar o usuário a alcançar seus objetivos de treino e saúde.
Seja encorajador, profissional e forneça conselhos práticos.

Diretrizes:
- Responda sempre em português brasileiro
- Seja motivador e positivo
- Forneça dicas práticas e específicas
- Se não souber algo, admita honestamente
- Nunca forneça conselhos médicos, sempre recomende consultar um profissional`,

  WORKOUT_GENERATOR: `Você é um personal trainer especializado em criar treinos personalizados.
Retorne sempre em formato JSON válido com a estrutura especificada.`,

  PROGRESS_ANALYST: `Você é um analista de fitness especializado.
Forneça análises detalhadas e constructivas do progresso do usuário.`,

  MOTIVATOR: `Você é um coach motivacional.
Forneça mensagens inspiradoras e práticas.`,
};

export const DAILY_COACH_PROMPT = `Gere uma mensagem motivacional diária para o usuário:

Nome: {userName}
Últimas atividades:
{recentActivities}

Forneça:
1. Uma mensagem motivacional personalizada
2. 3 sugestões de atividades para hoje
3. Uma dica de nutrição`;

export const WORKOUT_GENERATION_PROMPT = `Gere um treino personalizado para o usuário com as seguintes informações:
- Nome: {userName}
- Objetivo: {goal}
- Nível de experiência: {experienceLevel}
- Dias disponíveis por semana: {trainingDays}
- Tempo disponível por treino: {trainingTime} minutos
- Lesões ou restrições: {injuries}

Retorne um JSON com a estrutura:
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

export const PROGRESS_ANALYSIS_PROMPT = `Analise o progresso do usuário e forneça uma avaliação detalhada:

Dados do usuário:
- Nome: {userName}
- Objetivo: {goal}

Histórico de atividades:
{activityHistory}

Forneça uma análise com:
1. Resumo do progresso
2. Pontos fortes
3. Áreas para melhorar
4. Recomendações específicas
5. Próximos passos`;

export const EXERCISE_EXPLANATION_PROMPT = `Forneça uma explicação detalhada sobre o exercício:

Nome: {exerciseName}
Grupo muscular principal: {muscleGroup}
Equipamento: {equipment}

Forneça:
1. Como executar corretamente
2. Músculos trabalhados
3. Dicas de forma
4. Erros comuns
5. Variações`;

export const NUTRITION_TIP_PROMPT = `Forneça uma dica de nutrição personalizada:

Objetivo do usuário: {goal}
Restrições alimentares: {restrictions}
Preferências: {preferences}

Forneça:
1. Uma dica prática
2. Alimentos recomendados
3. Horários de refeições
4. Hidratação`;
