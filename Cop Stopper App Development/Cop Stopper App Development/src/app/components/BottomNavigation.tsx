import { Home, FileText, Search, MessageCircle, Settings } from 'lucide-react';

interface BottomNavigationProps {
  activeScreen: string;
  onNavigate: (screen: string) => void;
}

export default function BottomNavigation({ activeScreen, onNavigate }: BottomNavigationProps) {
  const navItems = [
    { id: 'dashboard', icon: Home, label: 'Home' },
    { id: 'documents', icon: FileText, label: 'Vault' },
    { id: 'search', icon: Search, label: 'Search' },
    { id: 'legal', icon: MessageCircle, label: 'Legal' },
    { id: 'settings', icon: Settings, label: 'Settings' },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-[#0a0a0a] border-t border-gray-800 flex justify-around items-center h-16 z-50">
      {navItems.map((item) => {
        const Icon = item.icon;
        const isActive = activeScreen === item.id;
        
        return (
          <button
            key={item.id}
            onClick={() => onNavigate(item.id)}
            className="flex flex-col items-center justify-center flex-1 h-full"
          >
            <Icon
              size={24}
              className={isActive ? 'text-blue-500' : 'text-gray-400'}
            />
            <span className={`text-xs mt-1 ${isActive ? 'text-blue-500' : 'text-gray-400'}`}>
              {item.label}
            </span>
          </button>
        );
      })}
    </div>
  );
}
