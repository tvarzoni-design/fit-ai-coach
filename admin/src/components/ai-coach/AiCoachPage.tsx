import { useState, useEffect } from 'react';
import { Send, Bot, User } from 'lucide-react';
import { adminApi } from '../../services/api';

interface Conversation {
  id: string;
  user: string;
  lastMessage: string;
  time: string;
  status: string;
}

export default function AiCoachPage() {
  const [conversations, setConversations] = useState<Conversation[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedConv, setSelectedConv] = useState<Conversation | null>(null);

  useEffect(() => {
    loadConversations();
  }, []);

  const loadConversations = async () => {
    try {
      const response = await adminApi.getDashboard();
      const data = response.data;
      const mockConversations: Conversation[] = [
        { 
          id: '1', 
          user: 'Sistema', 
          lastMessage: `Total de conversas IA: ${data?.ai?.conversations || 0}`, 
          time: 'Agora', 
          status: 'active' 
        },
      ];
      setConversations(mockConversations);
    } catch (error) {
      console.error('Erro ao carregar conversas:', error);
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

  return (
    <div>
      <div className="flex items-center justify-between mb-8">
        <h1 className="text-2xl font-bold text-white">IA Coach</h1>
        <div className="flex gap-4">
          <span className="bg-green-500/20 text-green-500 px-3 py-1 rounded-full text-sm">
            {conversations.filter(c => c.status === 'active').length} ativas
          </span>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="bg-gray-800 rounded-xl p-4">
          <h2 className="text-lg font-semibold text-white mb-4">Conversas</h2>
          <div className="space-y-3">
            {conversations.map((conv) => (
              <div 
                key={conv.id} 
                onClick={() => setSelectedConv(conv)}
                className={`p-3 rounded-lg cursor-pointer ${
                  selectedConv?.id === conv.id 
                    ? 'bg-indigo-600/20 border border-indigo-500' 
                    : 'bg-gray-700 hover:bg-gray-600'
                }`}
              >
                <div className="flex items-center justify-between mb-1">
                  <span className="text-white font-medium">{conv.user}</span>
                  <span className="text-gray-400 text-xs">{conv.time}</span>
                </div>
                <p className="text-gray-400 text-sm truncate">{conv.lastMessage}</p>
              </div>
            ))}
          </div>
        </div>

        <div className="lg:col-span-2 bg-gray-800 rounded-xl p-4 flex flex-col">
          {selectedConv ? (
            <>
              <div className="flex items-center gap-3 pb-4 border-b border-gray-700">
                <div className="w-10 h-10 bg-indigo-500 rounded-full flex items-center justify-center">
                  <User size={20} className="text-white" />
                </div>
                <div>
                  <p className="text-white font-medium">{selectedConv.user}</p>
                  <p className="text-green-500 text-sm">Online</p>
                </div>
              </div>

              <div className="flex-1 p-4 space-y-4">
                <div className="flex gap-3">
                  <div className="w-8 h-8 bg-gray-600 rounded-full flex items-center justify-center">
                    <User size={16} className="text-white" />
                  </div>
                  <div className="bg-gray-700 rounded-lg p-3 max-w-md">
                    <p className="text-white">{selectedConv.lastMessage}</p>
                  </div>
                </div>
                <div className="flex gap-3 justify-end">
                  <div className="bg-indigo-600 rounded-lg p-3 max-w-md">
                    <p className="text-white">Resposta automática do sistema</p>
                  </div>
                  <div className="w-8 h-8 bg-indigo-500 rounded-full flex items-center justify-center">
                    <Bot size={16} className="text-white" />
                  </div>
                </div>
              </div>

              <div className="p-4 border-t border-gray-700">
                <div className="flex gap-3">
                  <input
                    type="text"
                    placeholder="Responder como IA..."
                    className="flex-1 bg-gray-700 text-white px-4 py-2 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                  />
                  <button className="bg-indigo-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-indigo-700">
                    <Send size={20} />
                  </button>
                </div>
              </div>
            </>
          ) : (
            <div className="flex-1 flex items-center justify-center text-gray-400">
              Selecione uma conversa
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
