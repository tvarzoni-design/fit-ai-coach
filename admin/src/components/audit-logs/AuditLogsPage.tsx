import { useState, useEffect } from 'react';
import { adminApi } from '../../services/api';
import { ScrollText, User, FileText, Shield } from 'lucide-react';

interface AuditLog {
  id: string;
  adminId: string;
  action: string;
  targetType?: string;
  targetId?: string;
  details?: any;
  createdAt: string;
  admin?: { name: string; email: string };
}

export default function AuditLogsPage() {
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [total, setTotal] = useState(0);
  const limit = 20;

  useEffect(() => {
    loadLogs();
  }, [page]);

  const loadLogs = async () => {
    try {
      setLoading(true);
      const response = await adminApi.getAuditLogs(limit);
      setLogs(response.data?.logs || response.data || []);
      setTotal(response.data?.total || 0);
    } catch (error) {
      console.error('Failed to load audit logs:', error);
    } finally {
      setLoading(false);
    }
  };

  const getActionIcon = (action: string) => {
    if (action.includes('user') || action.includes('User')) return <User size={16} />;
    if (action.includes('exercise') || action.includes('Exercise')) return <FileText size={16} />;
    if (action.includes('login') || action.includes('auth')) return <Shield size={16} />;
    return <ScrollText size={16} />;
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-white">Logs de Auditoria</h1>
        <p className="text-gray-400">Histórico de ações administrativas</p>
      </div>

      <div className="bg-gray-800 rounded-xl overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-gray-700">
              <th className="text-left px-6 py-4 text-sm font-medium text-gray-400">Ação</th>
              <th className="text-left px-6 py-4 text-sm font-medium text-gray-400">Admin</th>
              <th className="text-left px-6 py-4 text-sm font-medium text-gray-400">Alvo</th>
              <th className="text-left px-6 py-4 text-sm font-medium text-gray-400">Detalhes</th>
              <th className="text-left px-6 py-4 text-sm font-medium text-gray-400">Data</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan={5} className="text-center py-8 text-gray-400">Carregando...</td></tr>
            ) : logs.length === 0 ? (
              <tr><td colSpan={5} className="text-center py-8 text-gray-400">Nenhum log encontrado</td></tr>
            ) : (
              logs.map((log) => (
                <tr key={log.id} className="border-b border-gray-700/50 hover:bg-gray-700/30">
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2 text-white">
                      {getActionIcon(log.action)}
                      <span>{log.action}</span>
                    </div>
                  </td>
                  <td className="px-6 py-4 text-gray-300">
                    {log.admin?.name || log.adminId}
                  </td>
                  <td className="px-6 py-4 text-gray-400">
                    {log.targetType ? `${log.targetType}` : '-'}
                    {log.targetId && <span className="text-gray-500 ml-1">({log.targetId.slice(0, 8)}...)</span>}
                  </td>
                  <td className="px-6 py-4 text-gray-400 text-sm max-w-xs truncate">
                    {log.details ? JSON.stringify(log.details).slice(0, 60) : '-'}
                  </td>
                  <td className="px-6 py-4 text-gray-400 text-sm">
                    {new Date(log.createdAt).toLocaleString('pt-BR')}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {total > limit && (
        <div className="flex justify-center gap-2">
          <button
            onClick={() => setPage(Math.max(1, page - 1))}
            disabled={page === 1}
            className="px-4 py-2 bg-gray-700 text-white rounded-lg disabled:opacity-50"
          >
            Anterior
          </button>
          <span className="px-4 py-2 text-gray-400">Página {page}</span>
          <button
            onClick={() => setPage(page + 1)}
            disabled={logs.length < limit}
            className="px-4 py-2 bg-gray-700 text-white rounded-lg disabled:opacity-50"
          >
            Próxima
          </button>
        </div>
      )}
    </div>
  );
}
