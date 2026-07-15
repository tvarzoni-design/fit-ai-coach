import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  Users,
  Dumbbell,
  MessageSquare,
  CreditCard,
  Bell,
  Settings,
  LogOut,
} from 'lucide-react';

const menuItems = [
  { to: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
  { to: '/users', icon: Users, label: 'Usuários' },
  { to: '/exercises', icon: Dumbbell, label: 'Exercícios' },
  { to: '/ai', icon: MessageSquare, label: 'IA Coach' },
  { to: '/subscriptions', icon: CreditCard, label: 'Assinaturas' },
  { to: '/notifications', icon: Bell, label: 'Notificações' },
  { to: '/settings', icon: Settings, label: 'Configurações' },
];

export default function Sidebar() {
  return (
    <aside className="w-64 bg-gray-800 flex flex-col">
      <div className="p-6">
        <h1 className="text-xl font-bold text-white">Fit AI Coach</h1>
        <p className="text-sm text-gray-400">Admin Panel</p>
      </div>
      
      <nav className="flex-1 px-4">
        {menuItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            className={({ isActive }) =>
              `flex items-center gap-3 px-4 py-3 rounded-lg mb-2 transition-colors ${
                isActive
                  ? 'bg-indigo-600 text-white'
                  : 'text-gray-400 hover:bg-gray-700 hover:text-white'
              }`
            }
          >
            <item.icon size={20} />
            <span>{item.label}</span>
          </NavLink>
        ))}
      </nav>
      
      <div className="p-4 border-t border-gray-700">
        <button className="flex items-center gap-3 px-4 py-3 text-gray-400 hover:text-white w-full">
          <LogOut size={20} />
          <span>Sair</span>
        </button>
      </div>
    </aside>
  );
}
