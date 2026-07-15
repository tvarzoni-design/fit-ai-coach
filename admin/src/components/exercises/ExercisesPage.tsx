import { useState, useEffect } from 'react';
import { Search, Edit, Trash2 } from 'lucide-react';
import { adminApi } from '../../services/api';

interface Exercise {
  id: string;
  name: string;
  mainMuscle: string;
  equipment: string;
  difficulty: string;
  status: boolean;
}

export default function ExercisesPage() {
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    loadExercises();
  }, []);

  const loadExercises = async () => {
    try {
      const response = await adminApi.getExercises(1, 100);
      setExercises(response.data.data || []);
    } catch (error) {
      console.error('Erro ao carregar exercícios:', error);
    } finally {
      setLoading(false);
    }
  };

  const filteredExercises = exercises.filter(ex =>
    ex.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    ex.mainMuscle?.toLowerCase().includes(searchTerm.toLowerCase())
  );

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
        <h1 className="text-2xl font-bold text-white">Exercícios</h1>
        <div className="flex gap-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
            <input
              type="text"
              placeholder="Buscar exercício..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="bg-gray-700 text-white pl-10 pr-4 py-2 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>
        </div>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {filteredExercises.map((exercise) => (
          <div key={exercise.id} className="bg-gray-800 rounded-xl p-4">
            <div className="flex items-start justify-between mb-4">
              <div>
                <h3 className="text-white font-medium">{exercise.name}</h3>
                <p className="text-gray-400 text-sm">{exercise.mainMuscle}</p>
              </div>
              <span className={`px-2 py-1 rounded text-xs ${
                exercise.status ? 'bg-green-500/20 text-green-500' : 'bg-red-500/20 text-red-500'
              }`}>
                {exercise.status ? 'Ativo' : 'Inativo'}
              </span>
            </div>
            
            <div className="flex gap-2 mb-4">
              <span className="bg-gray-700 px-2 py-1 rounded text-xs text-gray-300">
                {exercise.equipment || 'Não informado'}
              </span>
              <span className="bg-gray-700 px-2 py-1 rounded text-xs text-gray-300">
                {exercise.difficulty || 'Não informado'}
              </span>
            </div>
            
            <div className="flex gap-2">
              <button className="flex-1 bg-gray-700 text-white py-2 rounded-lg flex items-center justify-center gap-2 hover:bg-gray-600">
                <Edit size={16} />
                Editar
              </button>
              <button className="bg-gray-700 text-red-500 p-2 rounded-lg hover:bg-gray-600">
                <Trash2 size={16} />
              </button>
            </div>
          </div>
        ))}
      </div>
      {filteredExercises.length === 0 && (
        <div className="bg-gray-800 rounded-xl p-8 text-center text-gray-400">
          Nenhum exercício encontrado
        </div>
      )}
    </div>
  );
}
