-- ===========================================
-- FIT AI COACH - Complete Database Schema
-- PostgreSQL Migration v2 - Unified & LGPD Compliant
-- ===========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===========================================
-- USERS
-- ===========================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    birth_date DATE,
    gender VARCHAR(10),
    avatar VARCHAR(500),
    language VARCHAR(10) DEFAULT 'pt-BR',
    country VARCHAR(100) DEFAULT 'Brasil',
    status VARCHAR(20) DEFAULT 'active',
    email_verified BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP,
    fcm_token VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);

-- ===========================================
-- USER PROFILES
-- ===========================================
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    height DECIMAL(5,2),
    weight DECIMAL(5,2),
    target_weight DECIMAL(5,2),
    body_fat DECIMAL(5,2),
    muscle_mass DECIMAL(5,2),
    goal VARCHAR(50),
    secondary_goals TEXT[],
    experience_level VARCHAR(20),
    training_days INT DEFAULT 3,
    training_time INT DEFAULT 60,
    training_location VARCHAR(50),
    equipment_available TEXT[],
    injuries TEXT[],
    sleep_hours DECIMAL(3,1),
    stress_level INT,
    training_preferences TEXT[],
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- LGPD: USER CONSENTS
-- ===========================================
CREATE TABLE user_consents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    consent_type VARCHAR(50) NOT NULL,
    granted BOOLEAN NOT NULL,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_consents_user_id ON user_consents(user_id);

-- ===========================================
-- LGPD: DATA PROCESSING LOG
-- ===========================================
CREATE TABLE data_processing_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    data_type VARCHAR(50) NOT NULL,
    description TEXT,
    legal_basis VARCHAR(50),
    processed_by VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_data_processing_logs_user_id ON data_processing_logs(user_id);

-- ===========================================
-- MUSCLE GROUPS
-- ===========================================
CREATE TABLE muscle_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    image VARCHAR(500),
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- EXERCISES
-- ===========================================
CREATE TABLE exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    english_name VARCHAR(200),
    main_muscle VARCHAR(100) NOT NULL,
    secondary_muscles TEXT[],
    equipment VARCHAR(100),
    difficulty VARCHAR(50),
    movement_type VARCHAR(50),
    description TEXT,
    instructions TEXT,
    tips TEXT,
    breathing VARCHAR(500),
    common_errors TEXT,
    video_url VARCHAR(500),
    thumbnail_url VARCHAR(500),
    gif_url VARCHAR(500),
    contraindications TEXT,
    is_composite BOOLEAN DEFAULT FALSE,
    is_unilateral BOOLEAN DEFAULT FALSE,
    note_hypertrophy INT DEFAULT 0,
    note_strength INT DEFAULT 0,
    note_fat_loss INT DEFAULT 0,
    note_safety INT DEFAULT 0,
    note_beginners INT DEFAULT 0,
    status BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_exercises_main_muscle ON exercises(main_muscle);
CREATE INDEX idx_exercises_equipment ON exercises(equipment);

-- ===========================================
-- WORKOUTS
-- ===========================================
CREATE TABLE workouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(200) NOT NULL,
    goal VARCHAR(50),
    week_number INT DEFAULT 1,
    estimated_duration INT,
    status VARCHAR(20) DEFAULT 'active',
    generated_by VARCHAR(20) DEFAULT 'ai',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_workouts_user_id ON workouts(user_id);

-- ===========================================
-- WORKOUT EXERCISES
-- ===========================================
CREATE TABLE workout_exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workout_id UUID REFERENCES workouts(id) ON DELETE CASCADE,
    exercise_id UUID REFERENCES exercises(id),
    order_number INT NOT NULL,
    sets INT DEFAULT 3,
    repetitions VARCHAR(20) DEFAULT '10',
    target_weight DECIMAL(6,2),
    rest_time INT DEFAULT 90,
    tempo VARCHAR(10),
    rpe_target INT,
    rir_target INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_workout_exercises_workout_id ON workout_exercises(workout_id);

-- ===========================================
-- TRAINING HISTORY
-- ===========================================
CREATE TABLE training_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    workout_id UUID REFERENCES workouts(id),
    exercise_id UUID REFERENCES exercises(id),
    date DATE NOT NULL,
    set_number INT NOT NULL,
    sets_completed INT NOT NULL,
    repetitions_done VARCHAR(50),
    weight_used DECIMAL(6,2),
    rpe INT,
    rir INT,
    pain_level INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_training_history_user_id ON training_history(user_id);
CREATE INDEX idx_training_history_date ON training_history(date);

-- ===========================================
-- CARDIO SESSIONS
-- ===========================================
CREATE TABLE cardio_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    duration INT NOT NULL,
    distance DECIMAL(6,2),
    speed DECIMAL(5,1),
    inclination DECIMAL(5,1),
    heart_rate INT,
    calories INT,
    location VARCHAR(100),
    zone INT,
    effort_level INT,
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_cardio_sessions_user_id ON cardio_sessions(user_id);

-- ===========================================
-- FOODS
-- ===========================================
CREATE TABLE foods (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    serving_size VARCHAR(50),
    serving_grams DECIMAL(6,2) DEFAULT 100,
    calories DECIMAL(7,2) NOT NULL,
    protein DECIMAL(6,2) NOT NULL,
    carbohydrates DECIMAL(6,2) NOT NULL,
    fat DECIMAL(6,2) NOT NULL,
    fiber DECIMAL(6,2),
    sodium DECIMAL(6,2),
    sugar DECIMAL(6,2),
    status BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- MEAL LOGS
-- ===========================================
CREATE TABLE meal_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    food_id UUID REFERENCES foods(id),
    meal_type VARCHAR(50) NOT NULL,
    quantity DECIMAL(6,2) DEFAULT 100,
    calories DECIMAL(7,2) NOT NULL,
    protein DECIMAL(6,2) NOT NULL,
    carbs DECIMAL(6,2) NOT NULL,
    fat DECIMAL(6,2) NOT NULL,
    fiber DECIMAL(6,2),
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_meal_logs_user_id ON meal_logs(user_id);
CREATE INDEX idx_meal_logs_date ON meal_logs(date);

-- ===========================================
-- NUTRITION GOALS
-- ===========================================
CREATE TABLE nutrition_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    daily_calories INT,
    protein_target DECIMAL(6,2),
    carb_target DECIMAL(6,2),
    fat_target DECIMAL(6,2),
    water_target INT DEFAULT 2500,
    goal VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- WATER INTAKE LOG
-- ===========================================
CREATE TABLE water_intake_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    amount_ml INT NOT NULL DEFAULT 250,
    date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_water_intake_user_id ON water_intake_logs(user_id);
CREATE INDEX idx_water_intake_date ON water_intake_logs(date);

-- ===========================================
-- BODY MEASUREMENTS
-- ===========================================
CREATE TABLE body_measurements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    weight DECIMAL(5,2),
    body_fat DECIMAL(5,2),
    muscle_mass DECIMAL(5,2),
    chest DECIMAL(5,2),
    waist DECIMAL(5,2),
    hip DECIMAL(5,2),
    arm_left DECIMAL(5,2),
    arm_right DECIMAL(5,2),
    thigh_left DECIMAL(5,2),
    thigh_right DECIMAL(5,2),
    calf_left DECIMAL(5,2),
    calf_right DECIMAL(5,2),
    neck DECIMAL(5,2),
    observation TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_body_measurements_user_id ON body_measurements(user_id);

-- ===========================================
-- PROGRESS PHOTOS
-- ===========================================
CREATE TABLE progress_photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    front_url VARCHAR(500),
    side_url VARCHAR(500),
    back_url VARCHAR(500),
    analysis_status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- AI CONVERSATIONS
-- ===========================================
CREATE TABLE ai_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- AI MESSAGES
-- ===========================================
CREATE TABLE ai_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES ai_conversations(id) ON DELETE CASCADE,
    sender VARCHAR(20) NOT NULL,
    message TEXT NOT NULL,
    tokens_used INT,
    context_used TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- AI MEMORY
-- ===========================================
CREATE TABLE ai_memory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    key VARCHAR(100) NOT NULL,
    value TEXT NOT NULL,
    priority INT DEFAULT 5,
    memory_type VARCHAR(50) DEFAULT 'preference',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- AI PREDICTIONS
-- ===========================================
CREATE TABLE ai_predictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    prediction_type VARCHAR(50) NOT NULL,
    confidence DECIMAL(5,2),
    recommendation TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- AI ALERTS
-- ===========================================
CREATE TABLE ai_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    priority VARCHAR(20) DEFAULT 'low',
    read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- USER BEHAVIORS
-- ===========================================
CREATE TABLE user_behaviors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    value TEXT,
    metadata TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- PLANS
-- ===========================================
CREATE TABLE plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    billing_cycle VARCHAR(20) NOT NULL,
    currency VARCHAR(10) DEFAULT 'BRL',
    features TEXT[],
    is_popular BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- SUBSCRIPTIONS
-- ===========================================
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES plans(id),
    status VARCHAR(50) DEFAULT 'active',
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    trial_end TIMESTAMP,
    auto_renew BOOLEAN DEFAULT TRUE,
    payment_provider VARCHAR(50),
    provider_subscription_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- NOTIFICATIONS
-- ===========================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'info',
    priority VARCHAR(50) DEFAULT 'low',
    read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(read);

-- ===========================================
-- SMART NOTIFICATION SETTINGS
-- ===========================================
CREATE TABLE smart_notification_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL,
    enabled BOOLEAN DEFAULT TRUE,
    schedule_time VARCHAR(20),
    schedule_days VARCHAR(100),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, notification_type)
);

CREATE INDEX idx_smart_notifications_user_id ON smart_notification_settings(user_id);

-- ===========================================
-- ACHIEVEMENTS
-- ===========================================
CREATE TABLE achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50),
    icon VARCHAR(100),
    xp_reward INT DEFAULT 0,
    requirement_type VARCHAR(50),
    requirement_value INT,
    is_hidden BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- USER ACHIEVEMENTS
-- ===========================================
CREATE TABLE user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    achievement_id UUID REFERENCES achievements(id),
    unlocked_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- USER XP
-- ===========================================
CREATE TABLE user_xp (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    xp_total INT DEFAULT 0,
    level INT DEFAULT 1,
    current_streak INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    last_workout_date DATE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- DAILY CHALLENGES
-- ===========================================
CREATE TABLE daily_challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    description TEXT,
    xp_reward INT DEFAULT 100,
    category VARCHAR(50),
    requirement_type VARCHAR(50),
    requirement_value INT,
    status BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- USER DAILY CHALLENGES
-- ===========================================
CREATE TABLE user_daily_challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    challenge_id UUID REFERENCES daily_challenges(id),
    date DATE NOT NULL,
    progress INT DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, challenge_id, date)
);

CREATE INDEX idx_user_daily_challenges_user_id ON user_daily_challenges(user_id);
CREATE INDEX idx_user_daily_challenges_date ON user_daily_challenges(date);

-- ===========================================
-- COMMUNITY: POSTS
-- ===========================================
CREATE TABLE community_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    post_type VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    detail TEXT,
    workout_id UUID,
    visibility VARCHAR(20) DEFAULT 'public',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_community_posts_user_id ON community_posts(user_id);
CREATE INDEX idx_community_posts_created_at ON community_posts(created_at);

-- ===========================================
-- COMMUNITY: LIKES
-- ===========================================
CREATE TABLE community_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, post_id)
);

CREATE INDEX idx_community_likes_post_id ON community_likes(post_id);

-- ===========================================
-- COMMUNITY: COMMENTS
-- ===========================================
CREATE TABLE community_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_community_comments_post_id ON community_comments(post_id);

-- ===========================================
-- COMMUNITY: FOLLOWS
-- ===========================================
CREATE TABLE community_follows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id UUID REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(follower_id, following_id)
);

CREATE INDEX idx_community_follows_follower ON community_follows(follower_id);
CREATE INDEX idx_community_follows_following ON community_follows(following_id);

-- ===========================================
-- ADMINS
-- ===========================================
CREATE TABLE admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'admin',
    status VARCHAR(20) DEFAULT 'active',
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- AUDIT LOGS
-- ===========================================
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID REFERENCES admins(id),
    user_id UUID,
    action VARCHAR(100) NOT NULL,
    module VARCHAR(100),
    description TEXT,
    old_data JSONB,
    new_data JSONB,
    ip_address VARCHAR(50),
    device VARCHAR(200),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===========================================
-- SEED DATA - Muscle Groups
-- ===========================================
INSERT INTO muscle_groups (name, category) VALUES
('Peitoral Superior', 'Peito'),
('Peitoral Médio', 'Peito'),
('Peitoral Inferior', 'Peito'),
('Dorsal', 'Costas'),
('Trapézio', 'Costas'),
('Romboides', 'Costas'),
('Redondo Maior', 'Costas'),
('Lombar', 'Costas'),
('Deltoide Anterior', 'Ombros'),
('Deltoide Lateral', 'Ombros'),
('Deltoide Posterior', 'Ombros'),
('Bíceps Braquial', 'Braços'),
('Braquial', 'Braços'),
('Braquiorradial', 'Braços'),
('Tríceps Cabeça Longa', 'Braços'),
('Tríceps Cabeça Lateral', 'Braços'),
('Tríceps Cabeça Medial', 'Braços'),
('Quadríceps', 'Pernas'),
('Posterior de Coxa', 'Pernas'),
('Glúteo Máximo', 'Pernas'),
('Glúteo Médio', 'Pernas'),
('Adutores', 'Pernas'),
('Abdutores', 'Pernas'),
('Sóleo', 'Panturrilha'),
('Gastrocnêmio', 'Panturrilha'),
('Reto Abdominal', 'Abdômen'),
('Oblíquos', 'Abdômen'),
('Transverso', 'Abdômen');

-- ===========================================
-- SEED DATA - Achievements
-- ===========================================
INSERT INTO achievements (name, description, category, icon, xp_reward, requirement_type, requirement_value) VALUES
('Primeiro Treino', 'Complete seu primeiro treino', 'treino', '🏋️', 200, 'workouts', 1),
('Semana Completa', 'Treine 7 dias seguidos', 'consistencia', '🔥', 500, 'streak', 7),
('Sequência de 30 Dias', 'Treine 30 dias consecutivos', 'consistencia', '🔥', 1500, 'streak', 30),
('10 Treinos', 'Complete 10 treinos', 'treino', '💪', 300, 'workouts', 10),
('50 Treinos', 'Complete 50 treinos', 'treino', '🏆', 1000, 'workouts', 50),
('100 Treinos', 'Complete 100 treinos', 'treino', '👑', 2000, 'workouts', 100),
('Primeira Foto', 'Envie sua primeira foto de evolução', 'evolução', '📸', 120, 'photos', 1),
('Mês Completo', 'Treine todo o mês', 'consistencia', '📅', 800, 'monthly_workouts', 20),
('Primeiro Recorde', 'Batendo seu primeiro recorde pessoal', 'força', '🎯', 150, 'records', 1),
('5 Recordes', 'Quebre 5 recordes pessoais', 'força', '🏆', 500, 'records', 5),
('10 Recordes', 'Quebre 10 recordes pessoais', 'força', '🏆', 1000, 'records', 10),
('Cardio Master', 'Complete 100 km de cardio', 'cardio', '🏃', 1500, 'distance', 100),
('Nutrição Fiel', '30 dias registrando alimentação', 'nutrição', '🥗', 600, 'nutrition_streak', 30),
('Hidratação', 'Beba 3L de água por 5 dias', 'saúde', '💧', 300, 'water_streak', 5),
('Coach Fiel', '100 conversas com o Coach IA', 'ia', '🤖', 400, 'ai_chats', 100),
('Nível 5', 'Alcance o nível 5', 'progresso', '⭐', 300, 'level', 5),
('Nível 10', 'Alcance o nível 10', 'progresso', '⭐', 600, 'level', 10),
('Nível 15', 'Alcance o nível 15', 'progresso', '⭐', 1000, 'level', 15),
('Rank Prata', 'Alcance o rank Prata', 'rank', '🥈', 400, 'level', 4),
('Rank Ouro', 'Alcance o rank Ouro', 'rank', '🥇', 600, 'level', 8),
('Rank Platina', 'Alcance o rank Platina', 'rank', '💎', 800, 'level', 12),
('Rank Diamante', 'Alcance o rank Diamante', 'rank', '💠', 1200, 'level', 15),
('Early Bird', 'Treine antes das 7h da manhã', 'especial', '🌅', 200, 'early_workout', 1),
('Fim de Semana', 'Treine no sábado ou domingo', 'especial', '🎉', 100, 'weekend_workout', 1),
('Pioneiro', 'Use o app por 30 dias', 'lealdade', '🏅', 500, 'days_active', 30),
('Veterano', 'Use o app por 90 dias', 'lealdade', '🏅', 1000, 'days_active', 90),
('Lenda', 'Use o app por 365 dias', 'lealdade', '🏅', 5000, 'days_active', 365);

-- ===========================================
-- SEED DATA - Plans
-- ===========================================
INSERT INTO plans (name, description, price, billing_cycle, features, is_popular) VALUES
('Gratuito', 'Acesso básico ao aplicativo', 0, 'free', ARRAY['Treinos básicos (3/semana)', 'Chat IA limitado (5 msg/dia)', 'Histórico básico'], false),
('Premium Mensal', 'Acesso completo ao Coach IA', 29.90, 'monthly', ARRAY['Treinos ilimitados', 'Coach IA ilimitado', 'Nutrição automática', 'Relatórios avançados', 'Análise corporal', 'Predições IA', 'Comunidade', 'Sem anúncios'], true),
('Premium Anual', 'Acesso completo com desconto', 199.90, 'yearly', ARRAY['Tudo do Premium', '2 meses grátis', 'Suporte prioritário', 'Planos personalizados'], false);

-- ===========================================
-- SEED DATA - Foods (Brazilian common foods)
-- ===========================================
INSERT INTO foods (name, category, serving_size, serving_grams, calories, protein, carbohydrates, fat, fiber) VALUES
('Peito de Frango', 'proteína', '100g', 100, 165, 31, 0, 3.6, 0),
('Ovo Inteiro', 'proteína', '1 unidade', 50, 78, 13, 0.6, 5, 0),
('Whey Protein', 'proteína', '1 scoop', 30, 120, 24, 3, 1, 0),
('Salmão', 'proteína', '100g', 100, 208, 20, 0, 13, 0),
('Carne Bovina Magra', 'proteína', '100g', 100, 250, 26, 0, 15, 0),
('Atum', 'proteína', '100g', 100, 132, 28, 0, 1.3, 0),
('Iogurte Grego', 'proteína', '170g', 170, 100, 17, 6, 0.7, 0),
('Ricota', 'proteína', '100g', 100, 98, 11, 3.4, 4.3, 0),
('Arroz Integral', 'carboidrato', '100g', 100, 123, 2.7, 26, 1, 1.6),
('Batata Doça', 'carboidrato', '100g', 100, 86, 1.6, 20, 0.1, 3),
('Aveia', 'carboidrato', '100g', 100, 389, 17, 66, 7, 11),
('Banana', 'carboidrato', '1 unidade', 120, 89, 1.1, 23, 0.3, 2.6),
('Pão Integral', 'carboidrato', '2 fatias', 60, 247, 13, 41, 3.4, 7),
('Macarrão Integral', 'carboidrato', '100g', 100, 131, 5, 27, 0.5, 3.2),
('Feijão', 'carboidrato', '100g', 100, 127, 8.7, 23, 0.5, 8.7),
('Abacate', 'gordura', '1 unidade', 150, 160, 2, 9, 15, 7),
('Azeite de Oliva', 'gordura', '1 colher', 15, 119, 0, 0, 14, 0),
('Amêndoas', 'gordura', '30g', 30, 579, 21, 22, 50, 12),
('Pasta de Amendoim', 'gordura', '32g', 32, 588, 25, 20, 50, 6),
('Nozes', 'gordura', '30g', 30, 654, 15, 14, 65, 7),
('Brócolis', 'legume', '100g', 100, 34, 2.8, 7, 0.4, 2.6),
('Espinafre', 'legume', '100g', 100, 23, 2.9, 3.6, 0.4, 2.2),
('Cenoura', 'legume', '100g', 100, 41, 0.9, 10, 0.2, 2.8),
('Tomate', 'legume', '100g', 100, 18, 0.9, 3.9, 0.2, 1.2),
('Alface', 'legume', '100g', 100, 15, 1.4, 2.9, 0.2, 1.3);

-- ===========================================
-- SEED DATA - Exercises (40 exercises)
-- ===========================================
INSERT INTO exercises (name, english_name, main_muscle, secondary_muscles, equipment, difficulty, instructions, tips, is_composite) VALUES
('Supino Reto com Barra', 'Barbell Bench Press', 'Peitoral Médio', ARRAY['Deltoide Anterior', 'Tríceps Cabeça Longa'], 'Barra', 'intermediate', 'Deite no banco, segure a barra com pegada ligeiramente mais larga que os ombros. Desça até o peito e empurre para cima.', 'Mantenha os pés firmes no chão e as escápulas retraídas.', true),
('Supino Inclinado com Halteres', 'Incline Dumbbell Press', 'Peitoral Superior', ARRAY['Deltoide Anterior', 'Tríceps Cabeça Longa'], 'Halteres', 'intermediate', 'Ajuste o banco em 30-45°. Empurre os halteres para cima e junte no topo.', 'Controle a descida para máxima ativação do peitoral.', true),
('Crucifixo na Máquina', 'Pec Deck Fly', 'Peitoral Médio', ARRAY[]::text[], 'Máquina', 'beginner', 'Sente-se e ajuste o apoio dos braços. Junte as alavancas à frente do corpo.', 'Foque na contração do peitoral no ponto de encontro.', false),
('Crossover', 'Cable Crossover', 'Peitoral Médio', ARRAY['Deltoide Anterior'], 'Polia', 'intermediate', 'Em pé entre as polias, puxe as alavancas para baixo e à frente.', 'Incline levemente o tronco para frente para melhor isolamento.', false),
('Supino com Halteres no Chão', 'Floor Press', 'Peitoral Médio', ARRAY['Tríceps Cabeça Longa'], 'Halteres', 'beginner', 'Deite no chão com halteres. Empurre para cima até estender os braços.', 'O chão previne hiperextensão dos cotovelos.', true),
('Puxada Frontal', 'Lat Pulldown', 'Dorsal', ARRAY['Bíceps Braquial', 'Trapézio'], 'Máquina', 'beginner', 'Sente-se e puxe a barra até o queixo, contraindo as costas.', 'Imagine puxar com os cotovelos, não com as mãos.', true),
('Remada Curvada', 'Barbell Row', 'Dorsal', ARRAY['Bíceps Braquial', 'Deltoide Posterior'], 'Barra', 'intermediate', 'Em pé, incline o tronco para frente (~45°). Puxe a barra até o abdômen.', 'Mantenha as costas retas e o core contraído.', true),
('Remada Unilateral', 'One Arm Dumbbell Row', 'Dorsal', ARRAY['Bíceps Braquial', 'Romboides'], 'Haltere', 'beginner', 'Apoie um joelho e mão no banco. Puxe o haltere até o abdômen.', 'Gire levemente o tronco para máxima contração.', false),
('Pull-up', 'Pull-up', 'Dorsal', ARRAY['Bíceps Braquial', 'Trapézio'], 'Barra', 'advanced', 'Segure a barra e puxe o corpo para cima até o queixo passar a barra.', 'Use um elástico se não conseguir fazer sozinho.', true),
('Remada Cavalinho', 'Seal Row', 'Romboides', ARRAY['Bíceps Braquial'], 'Haltere', 'intermediate', 'Deite de bruços e puxe o haltere até o abdômen.', 'Squeeze as escápulas no topo do movimento.', false),
('Desenvolvimento com Halteres', 'Dumbbell Shoulder Press', 'Deltoide Anterior', ARRAY['Deltoide Lateral', 'Tríceps Cabeça Longa'], 'Halteres', 'intermediate', 'Sentado ou em pé, empurre os halteres acima da cabeça.', 'Não bata os halteres no topo. Mantenha o core contraído.', true),
('Elevação Lateral', 'Lateral Raise', 'Deltoide Lateral', ARRAY['Trapézio'], 'Halteres', 'beginner', 'Em pé, eleve os halteres lateralmente até a altura dos ombros.', 'Leve inclinação para frente melhora a ativação.', false),
('Elevação Frontal', 'Front Raise', 'Deltoide Anterior', ARRAY['Peitoral Superior'], 'Halteres', 'beginner', 'Em pé, eleve os halteres à frente até a altura dos olhos.', 'Alterne os braços para melhor foco.', false),
('Face Pull', 'Face Pull', 'Deltoide Posterior', ARRAY['Trapézio', 'Romboides'], 'Polia', 'intermediate', 'Em pé diante da polia alta, puxe a corda até o rosto.', 'Rotação externa no topo para proteger o ombro.', false),
('Arnold Press', 'Arnold Press', 'Deltoide Anterior', ARRAY['Deltoide Lateral', 'Tríceps Cabeça Longa'], 'Halteres', 'intermediate', 'Comece com halteres à frente do rosto e gire ao empurrar.', 'A rotação ativa mais o deltóide lateral.', true),
('Rosca Direta com Barra', 'Barbell Curl', 'Bíceps Braquial', ARRAY['Braquial', 'Braquiorradial'], 'Barra', 'beginner', 'Em pé, segure a barra com pegada supina. Flexione os cotovelos.', 'Mantenha os cotovelos fixos ao lado do corpo.', false),
('Rosca Alternada', 'Dumbbell Curl', 'Bíceps Braquial', ARRAY['Braquial'], 'Halteres', 'beginner', 'Em pé, alterne a flexão dos braços com halteres, girando o pulso.', 'Controle a descida para maximizar o tempo sob tensão.', false),
('Rosca Martelo', 'Hammer Curl', 'Bíceps Braquial', ARRAY['Braquial', 'Braquiorradial'], 'Halteres', 'beginner', 'Em pé, alterne a flexão dos braços com halteres em pegada neutra.', 'Gire o pulso para fora no topo para maior ativação.', false),
('Rosca Scott', 'Preacher Curl', 'Bíceps Braquial', ARRAY['Braquial'], 'Barra EZ', 'intermediate', 'Sente-se no banco de Scott e faça rosca com barra EZ.', 'Não trave os cotovelos no topo.', false),
('Tríceps Pulley', 'Tricep Pushdown', 'Tríceps Cabeça Lateral', ARRAY['Tríceps Cabeça Longa'], 'Polia', 'beginner', 'Em pé diante da polia alta, empurre a barra para baixo.', 'Mantenha os cotovelos fixos ao lado do corpo.', false),
('Tríceps Testa', 'Skull Crusher', 'Tríceps Cabeça Longa', ARRAY[]::text[], 'Barra EZ', 'intermediate', 'Deite no banco, segure a barra EZ. Flexione os cotovelos descendo à testa.', 'Mantenha os cotovelos apontando para cima.', false),
('Tríceps Francês', 'French Press', 'Tríceps Cabeça Longa', ARRAY[]::text[], 'Haltere', 'intermediate', 'Deite no banco, segure o halter com braços estendidos. Flexione os cotovelos.', 'Mantenha os cotovelos fixos e apontando para o teto.', false),
('Mergulho em Banco', 'Bench Dip', 'Tríceps Cabeça Lateral', ARRAY['Peitoral Médio', 'Deltoide Anterior'], 'Peso Corporal', 'beginner', 'Apoie as mãos no banco atrás de você e desça flexionando os cotovelos.', 'Mantenha as costas próximas ao banco.', false),
('Agachamento Livre', 'Barbell Squat', 'Quadríceps', ARRAY['Glúteo Máximo', 'Posterior de Coxa', 'Reto Abdominal'], 'Barra', 'advanced', 'Barra nos ombros, pés na largura dos ombros. Agache até as coxas ficarem paralelas.', 'Mantenha o peito erguido e os joelhos alinhados com os pés.', true),
('Leg Press 45°', 'Leg Press', 'Quadríceps', ARRAY['Glúteo Máximo', 'Posterior de Coxa'], 'Máquina', 'beginner', 'Sente-se na máquina e empurre a plataforma com os pés na largura dos ombros.', 'Não trave os joelhos no topo do movimento.', true),
('Cadeira Extensora', 'Leg Extension', 'Quadríceps', ARRAY[]::text[], 'Máquina', 'beginner', 'Sente-se e estenda as pernas contra a resistência.', 'Segure a contração no topo por 1 segundo.', false),
('Mesa Flexora', 'Leg Curl', 'Posterior de Coxa', ARRAY['Gastrocnêmio'], 'Máquina', 'beginner', 'Deite de bruços e flexione os joelhos puxando a almofada.', 'Mantenha os quadris em contato com o banco.', false),
('Stiff', 'Romanian Deadlift', 'Posterior de Coxa', ARRAY['Glúteo Máximo', 'Lombar'], 'Barra', 'intermediate', 'Em pé com a barra, flexione os quadris para trás.', 'Mantenha as pernas levemente flexionadas e as costas retas.', true),
('Panturrilha em Pé', 'Standing Calf Raise', 'Gastrocnêmio', ARRAY['Sóleo'], 'Máquina', 'beginner', 'Em pé na máquina, eleve-se na ponta dos pés.', 'Faça o movimento completo para melhor ativação.', false),
('Elevação Pélvica', 'Hip Thrust', 'Glúteo Máximo', ARRAY['Posterior de Coxa', 'Lombar'], 'Barra', 'intermediate', 'Deite de costas com os pés no banco. Eleve o quadril empurrando a barra.', 'Segure a contração dos glúteos por 2 segundos no topo.', true),
('Afundo com Halteres', 'Dumbbell Lunge', 'Quadríceps', ARRAY['Glúteo Máximo', 'Posterior de Coxa'], 'Halteres', 'intermediate', 'Dê passos à frente flexionando os joelhos a 90°.', 'Alterne as pernas a cada repetição.', true),
('Prancha Frontal', 'Plank', 'Reto Abdominal', ARRAY['Transverso', 'Lombar'], 'Peso Corporal', 'beginner', 'Apoie os antebraços e pontas dos pés. Mantenha o corpo reto.', 'Não deixe o quadril cair nem subir demais.', false),
('Crunch na Máquina', 'Crunch Machine', 'Reto Abdominal', ARRAY['Oblíquos'], 'Máquina', 'beginner', 'Sente-se na máquina e flexione o tronco para frente.', 'Controle o movimento, não use impulso.', false),
('Elevação de Pernas', 'Leg Raise', 'Reto Abdominal', ARRAY['Flexores do Quadril'], 'Peso Corporal', 'intermediate', 'Deite de costas e eleve as pernas até 90°.', 'Mantenha as costas coladas no chão.', false),
('Russian Twist', 'Russian Twist', 'Oblíquos', ARRAY['Reto Abdominal'], 'Peso Corporal', 'intermediate', 'Sentado, gire o tronco de um lado para o outro.', 'Mantenha os pés levemente elevados para maior dificuldade.', false),
('Ab Wheel', 'Ab Wheel Rollout', 'Reto Abdominal', ARRAY['Transverso', 'Deltoide Anterior', 'Lombar'], 'Ab Wheel', 'advanced', 'Ajoelhe e role a roda para frente até estender os braços.', 'Mantenha o core contraído durante todo o movimento.', false),
('Bicicleta no Ar', 'Bicycle Crunch', 'Reto Abdominal', ARRAY['Oblíquos', 'Flexores do Quadril'], 'Peso Corporal', 'beginner', 'Deite de costas e alterne levar cotovelo ao joelho oposto.', 'Faça o movimento lentamente para máxima ativação.', false);

-- ===========================================
-- SEED DATA - Daily Challenges
-- ===========================================
INSERT INTO daily_challenges (title, description, xp_reward, category, requirement_type, requirement_value) VALUES
('100 Flexões', 'Faça 100 flexões hoje', 150, 'strength', 'reps', 100),
('Beber 3L de Água', 'Mantenha-se hidratado hoje', 100, 'health', 'water_ml', 3000),
('30 Minutos de Cardio', 'Faça 30 min de qualquer cardio', 120, 'cardio', 'minutes', 30),
('Treino Completo', 'Complete qualquer treino', 200, 'training', 'workout', 1),
('50 Repetições de Prancha', 'Faça 50 seg de prancha total', 80, 'core', 'seconds', 50),
('10.000 Passos', 'Caminhe 10.000 passos hoje', 130, 'cardio', 'steps', 10000),
('Refeição Saudável', 'Registre 3 refeições saudáveis', 100, 'nutrition', 'meals', 3),
('Sem Açúcar', 'Não consuma açúcar refinado hoje', 150, 'health', 'sugar_free', 1);

-- ===========================================
-- SEED DATA - Admin user (password: admin123)
-- ===========================================
INSERT INTO admins (name, email, password_hash, role) VALUES
('Administrador', 'admin@fitcoach.com', '$2b$10$8K1p/a0dL1LXMc.0zK3Hq.X5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q5Q', 'super_admin');
