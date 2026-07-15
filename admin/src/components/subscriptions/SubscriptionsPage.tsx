import { useState, useEffect } from 'react';
import { CreditCard, Check, X } from 'lucide-react';
import { adminApi } from '../../services/api';

interface Subscription {
  id: string;
  user: string;
  planId: string;
  status: string;
  startDate: string | null;
  endDate: string | null;
  autoRenew: boolean;
}

export default function SubscriptionsPage() {
  const [subscriptions, setSubscriptions] = useState<Subscription[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadSubscriptions();
  }, []);

  const loadSubscriptions = async () => {
    try {
      const response = await adminApi.getSubscriptions();
      setSubscriptions(response.data || []);
    } catch (error) {
      console.error('Erro ao carregar assinaturas:', error);
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

  const activeSubscriptions = subscriptions.filter(s => s.status === 'active');

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <h1 className="text-2xl font-bold text-white">Assinaturas</h1>
        <div className="flex gap-4">
          <div className="bg-gray-800 px-4 py-2 rounded-lg">
            <p className="text-gray-400 text-sm">Assinantes Ativos</p>
            <p className="text-white font-bold text-xl">{activeSubscriptions.length}</p>
          </div>
          <div className="bg-gray-800 px-4 py-2 rounded-lg">
            <p className="text-gray-400 text-sm">Total Assinaturas</p>
            <p className="text-white font-bold text-xl">{subscriptions.length}</p>
          </div>
        </div>
      </div>

      <div className="bg-gray-800 rounded-xl overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-gray-700">
              <th className="text-left p-4 text-gray-400 font-medium">Usuário</th>
              <th className="text-left p-4 text-gray-400 font-medium">Plano</th>
              <th className="text-left p-4 text-gray-400 font-medium">Status</th>
              <th className="text-left p-4 text-gray-400 font-medium">Início</th>
              <th className="text-left p-4 text-gray-400 font-medium">Fim</th>
            </tr>
          </thead>
          <tbody>
            {subscriptions.map((sub) => (
              <tr key={sub.id} className="border-b border-gray-700">
                <td className="p-4 text-white">{sub.user}</td>
                <td className="p-4">
                  <span className="flex items-center gap-2 text-white">
                    <CreditCard size={16} />
                    {sub.planId || 'Premium'}
                  </span>
                </td>
                <td className="p-4">
                  <span className={`px-3 py-1 rounded-full text-sm flex items-center gap-1 w-fit ${
                    sub.status === 'active' ? 'bg-green-500/20 text-green-500' :
                    sub.status === 'cancelled' ? 'bg-red-500/20 text-red-500' :
                    'bg-gray-600 text-gray-300'
                  }`}>
                    {sub.status === 'active' ? <Check size={14} /> : <X size={14} />}
                    {sub.status === 'active' ? 'Ativa' : sub.status === 'cancelled' ? 'Cancelada' : 'Inativa'}
                  </span>
                </td>
                <td className="p-4 text-gray-400 text-sm">
                  {sub.startDate ? new Date(sub.startDate).toLocaleDateString('pt-BR') : '-'}
                </td>
                <td className="p-4 text-gray-400 text-sm">
                  {sub.endDate ? new Date(sub.endDate).toLocaleDateString('pt-BR') : '-'}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        {subscriptions.length === 0 && (
          <div className="p-8 text-center text-gray-400">
            Nenhuma assinatura encontrada
          </div>
        )}
      </div>
    </div>
  );
}
