import { Search, ArrowLeft, Filter, AlertTriangle } from 'lucide-react';
import { useState } from 'react';

interface Officer {
  id: string;
  name: string;
  badge: string;
  department: string;
  avatar?: string;
  complaints: number;
}

export default function OfficerSearch() {
  const [searchQuery, setSearchQuery] = useState('');

  const recentSearches = ['Miller', 'Badge #4492', '14th Precinct'];

  const officers: Officer[] = [
    {
      id: '1',
      name: 'Ofc. John Doe',
      badge: 'Badge #1053',
      department: 'NYPD - 14th Pct',
      complaints: 3,
    },
    {
      id: '2',
      name: 'Sgt. Sarah Miller',
      badge: 'Badge #4492',
      department: 'Highway Patrol',
      complaints: 0,
    },
    {
      id: '3',
      name: 'Ofc. Michael Chen',
      badge: 'Badge #8129',
      department: 'Transit Bureau',
      complaints: 1,
    },
    {
      id: '4',
      name: 'Det. Robert Vance',
      badge: 'Badge #2847',
      department: 'Internal Affairs',
      complaints: 2,
    },
  ];

  return (
    <div className="min-h-screen bg-[#0a0a0a] text-white pb-20">
      {/* Header */}
      <div className="flex items-center justify-between p-4">
        <button className="p-2">
          <ArrowLeft size={24} />
        </button>
        <h1 className="text-xl font-bold">Officer Search</h1>
        <button className="p-2">
          <Filter size={24} />
        </button>
      </div>

      {/* Search Bar */}
      <div className="px-4">
        <div className="relative">
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400" size={20} />
          <input
            type="text"
            placeholder="Search name, badge #, or precinct"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-[#1a1a1a] border border-gray-800 rounded-full py-3 pl-12 pr-4 text-white placeholder-gray-500 focus:outline-none focus:border-blue-500"
          />
        </div>
      </div>

      {/* Filter Chips */}
      <div className="px-4 mt-4 flex gap-2 overflow-x-auto pb-2">
        <button className="px-4 py-2 bg-blue-500 rounded-full text-sm whitespace-nowrap">
          All Departments
        </button>
        <button className="px-4 py-2 bg-[#1a1a1a] border border-gray-800 rounded-full text-sm whitespace-nowrap">
          Nearby
        </button>
        <button className="px-4 py-2 bg-[#1a1a1a] border border-gray-800 rounded-full text-sm whitespace-nowrap">
          High Complaints
        </button>
      </div>

      {/* Recent Searches */}
      <div className="px-4 mt-6">
        <h3 className="text-xs text-gray-400 mb-3">RECENT SEARCHES</h3>
        <div className="flex flex-wrap gap-2">
          {recentSearches.map((search, index) => (
            <button
              key={index}
              className="flex items-center gap-2 px-4 py-2 bg-[#1a1a1a] border border-gray-800 rounded-full text-sm"
            >
              <Search size={14} className="text-gray-400" />
              {search}
            </button>
          ))}
        </div>
      </div>

      {/* Results */}
      <div className="px-4 mt-6">
        <h3 className="text-xs text-gray-400 mb-3">RESULTS</h3>
        <div className="space-y-3">
          {officers.map((officer) => (
            <div
              key={officer.id}
              className="bg-[#1a1a1a] border border-gray-800 rounded-2xl p-4 flex items-center gap-3"
            >
              <div className="w-12 h-12 rounded-full bg-gray-700 flex items-center justify-center text-xl">
                {officer.name.split(' ')[1]?.[0] || 'O'}
              </div>
              <div className="flex-1">
                <p className="font-medium">{officer.name}</p>
                <p className="text-sm text-gray-400">{officer.badge}</p>
                <p className="text-xs text-gray-500">{officer.department}</p>
              </div>
              {officer.complaints > 0 && (
                <div className="flex items-center gap-1 px-2 py-1 bg-orange-500/10 border border-orange-500/20 rounded-full">
                  <AlertTriangle className="text-orange-500" size={12} />
                  <span className="text-xs text-orange-500">{officer.complaints}</span>
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
