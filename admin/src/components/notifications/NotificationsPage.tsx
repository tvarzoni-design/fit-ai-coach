import { useState, useEffect } from 'react';
import { Bell, Send, Users, Trophy } from 'lucide-react';
import { adminApi } from '../../services/api';

interface Notification {
  id: string;
  title: string;
  type: string;
  sent: number;
  opened: number;
  date: string;
}

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [formData, setFormData] = useState({ title: '', body: '', type: 'system' });

  useEffect(() => {
    loadNotifications();
  }, []);

  const loadNotifications = async () => {
    try {
      const response = await adminApi.getNotifications();
      setNotifications(response.data || []);
    } catch (error) {
      console.error('Erro ao carregar notificações:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSendNotification = async () => {
    try {
      await adminApi.sendNotification(formData);
      setShowForm(false);
      setFormData({ title: '', body: '', type: 'system' });
      loadNotifications();
    } catch (error) {
      console.error('Erro ao enviar notificação:', error);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-white">Carregando...</div>
      </div>
    );
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <h1 className="text-2xl font-bold text-white">Notificações</h1>
        <button 
          onClick={() => setShowForm(!showForm)}
          className="bg-indigo-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-indigo-700"
        >
          <Send size={20} />
          Nova Notificação
        </button>
      </div>

      {showForm && (
        <div className="bg-gray-800 rounded-xl p-6 mb-8">
          <h2 className="text-lg font-semibold text-white mb-4">Enviar Notificação</h2>
          <div className="space-y-4">
            <input
              type="text"
              placeholder="Título"
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              className="w-full bg-gray-700 text-white px-4 py-2 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
            <textarea
              placeholder="Mensagem"
              value={formData.body}
              onChange={(e) => setFormData({ ...formData, body: e.target.value })}
              className="w-full bg-gray-700 text-white px-4 py-2 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500 h-24"
            />
            <select
              value={formData.type}
              onChange={(e) => setFormData({ ...formData, type: e.target.value })}
              className="w-full bg-gray-700 text-white px-4 py-2 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <option value="system">Sistema</option>
              <option value="workout">Treino</option>
              <option value="achievement">Conquista</option>
              <option value="ai">IA</option>
            </select>
            <div className="flex gap-4">
              <button
                onClick={handleSendNotification}
                className="bg-indigo-600 text-white px-4 py-2 rounded-lg hover:bg-indigo-700"
              >
                Enviar
              </button>
              <button
                onClick={() => setShowForm(false)}
                className="bg-gray-700 text-white px-4 py-2 rounded-lg hover:bg-gray-600"
              >
                Cancelar
              </button>
            </div>
          </div>
        </div>
      )}

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="bg-gray-800 rounded-xl p-6">
          <div className="flex items-center gap-3 mb-2">
            <Bell size={20} className="text-indigo-500" />
            <p className="text-gray-400">Enviadas</p>
          </div>
          <p className="text-2xl font-bold text-white">{notifications.length}</p>
        </div>
        <div className="bg-gray-800 rounded-xl p-6">
          <div className="flex items-center gap-3 mb-2">
            <Users size={20} className="text-green-500" />
            <p className="text-gray-400">Total Enviadas</p>
          </div>
          <p className="text-2xl font-bold text-white">
            {notifications.reduce((acc, n) => acc + (n.sent || 0), 0).toLocaleString()}
          </p>
        </div>
        <div className="bg-gray-800 rounded-xl p-6">
          <div className="flex items-center gap-3 mb-2">
            <Trophy size={20} className="text-yellow-500" />
            <p className="text-gray-400">Total Abertas</p>
          </div>
          <p className="text-2xl font-bold text-white">
            {notifications.reduce((acc, n) => acc + (n.opened || 0), 0).toLocaleString()}
          </p>
        </div>
      </div>

      <div className="bg-gray-800 rounded-xl overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-gray-700">
              <th className="text-left p-4 text-gray-400 font-medium">Título</th>
              <th className="text-left p-4 text-gray-400 font-medium">Tipo</th>
              <th className="text-left p-4 text-gray-400 font-medium">Enviadas</th>
              <th className="text-left p-4 text-gray-400 font-medium">Abertas</th>
              <th className="text-left p-4 text-gray-400 font-medium">Data</th>
            </tr>
          </thead>
          <tbody>
            {notifications.map((notif) => (
              <tr key={notif.id} className="border-b border-gray-700">
                <td className="p-4 text-white">{notif.title}</td>
                <td className="p-4">
                  <span className="bg-gray-700 px-2 py-1 rounded text-sm text-gray-300">
                    {notif.type}
                  </span>
                </td>
                <td className="p-4 text-white">{(notif.sent || 0).toLocaleString()}</td>
                <td className="p-4 text-white">{(notif.opened || 0).toLocaleString()}</td>
                <td className="p-4 text-gray-400">{notif.date || '-'}</td>
              </tr>
            ))}
          </tbody>
        </table>
        {notifications.length === 0 && (
          <div className="p-8 text-center text-gray-400">
            Nenhuma notificação encontrada
          </div>
        )}
      </div>
    </div>
  );
}
