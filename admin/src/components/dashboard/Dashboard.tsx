import { useState, useEffect } from 'react';
import { Users, Dumbbell, CreditCard, TrendingUp } from 'lucide-react';
import { adminApi } from '../../services/api';

interface DashboardData {
  users: { total: number; active: number; premium: number };
  revenue: { monthly: number; yearly: number };
  workouts: { today: number; week: number };
  ai: { conversations: number };
}

export default function Dashboard() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadDashboard();
  }, []);

  const loadDashboard = async () => {
    try {
      const response = await adminApi.getDashboard();
      setData(response.data);
    } catch (error) {
      console.error('Erro ao carregar dashboard:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-white">Carregando...</div>
      </div>
    );
  }

  const stats = [
    { 
      label: 'Total Usuários', 
      value: data?.users?.total?.toString() || '0', 
      change: '+12%', 
      icon: Users, 
      color: 'bg-indigo-500' 
    },
    { 
      label: 'Assinantes Premium', 
      value: data?.users?.premium?.toString() || '0', 
      change: '+8%', 
      icon: CreditCard, 
      color: 'bg-green-500' 
    },
    { 
      label: 'Receita Mensal', 
      value: `R$ ${data?.revenue?.monthly?.toLocaleString('pt-BR', { minimumFractionDigits: 2 }) || '0,00'}`, 
      change: '+15%', 
      icon: TrendingUp, 
      color: 'bg-yellow-500' 
    },
    { 
      label: 'Conversas IA', 
      value: data?.ai?.conversations?.toString() || '0', 
      change: '+5%', 
      icon: Dumbbell, 
      color: 'bg-pink-500' 
    },
  ];

  return (
    <div>
      <h1 className="text-2xl font-bold text-white mb-8">Dashboard</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {stats.map((stat) => (
          <div key={stat.label} className="bg-gray-800 rounded-xl p-6">
            <div className="flex items-center justify-between mb-4">
              <div className={`${stat.color} p-3 rounded-lg`}>
                <stat.icon size={24} className="text-white" />
              </div>
              <span className="text-green-500 text-sm">{stat.change}</span>
            </div>
            <h3 className="text-2xl font-bold text-white">{stat.value}</h3>
            <p className="text-gray-400 text-sm">{stat.label}</p>
          </div>
        ))}
      </div>
      
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-gray-800 rounded-xl p-6">
          <h2 className="text-lg font-semibold text-white mb-4">Resumo</h2>
          <div className="space-y-4">
            <div className="flex items-center justify-between p-3 bg-gray-700 rounded-lg">
              <span className="text-gray-300">Usuários Ativos</span>
              <span className="text-white font-medium">{data?.users?.active || 0}</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-gray-700 rounded-lg">
              <span className="text-gray-300">Treinos Hoje</span>
              <span className="text-white font-medium">{data?.workouts?.today || 0}</span>
            </div>
            <div className="flex items-center justify-between p-3 bg-gray-700 rounded-lg">
              <span className="text-gray-300">Receita Anual</span>
              <span className="text-white font-medium">
                R$ {data?.revenue?.yearly?.toLocaleString('pt-BR', { minimumFractionDigits: 2 }) || '0,00'}
              </span>
            </div>
          </div>
        </div>
        
        <div className="bg-gray-800 rounded-xl p-6">
          <h2 className="text-lg font-semibold text-white mb-4">Ações Rápidas</h2>
          <div className="space-y-3">
            <button 
              onClick={() => window.location.href = '/users'}
              className="w-full p-3 bg-gray-700 rounded-lg text-left text-white hover:bg-gray-600 transition-colors"
            >
              Gerenciar Usuários
            </button>
            <button 
              onClick={() => window.location.href = '/exercises'}
              className="w-full p-3 bg-gray-700 rounded-lg text-left text-white hover:bg-gray-600 transition-colors"
            >
              Gerenciar Exercícios
            </button>
            <button 
              onClick={() => window.location.href = '/subscriptions'}
              className="w-full p-3 bg-gray-700 rounded-lg text-left text-white hover:bg-gray-600 transition-colors"
            >
              Ver Assinaturas
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
