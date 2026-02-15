import { Shield, Play, BookOpen, User, AlertTriangle } from 'lucide-react';
import { useState } from 'react';

interface DashboardProps {
  onNavigate: (screen: string) => void;
  onStartRecording: () => void;
}

export default function Dashboard({ onNavigate, onStartRecording }: DashboardProps) {
  return (
    <div className="min-h-screen bg-gradient-to-b from-[#0a0a0a] via-[#0f1729] to-[#0a0a0a] text-white pb-20">
      {/* Header */}
      <div className="flex items-center justify-between p-4">
        <div className="flex items-center gap-2">
          <Shield className="text-blue-500" size={24} />
          <h1 className="text-xl font-bold">COPSTOPPER</h1>
        </div>
        <button className="p-2">
          <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
            <path d="M10 5h.01M10 10h.01M10 15h.01" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
      </div>

      {/* Status Cards */}
      <div className="px-4 mt-6 grid grid-cols-2 gap-4">
        <div className="bg-[#1a1a1a] rounded-2xl p-4 border border-gray-800">
          <div className="flex items-center gap-2 mb-2">
            <div className="w-2 h-2 rounded-full bg-green-500"></div>
            <span className="text-xs text-gray-400">READY TO RECORD</span>
          </div>
          <p className="text-2xl font-bold">System Online</p>
        </div>
        
        <div className="bg-[#1a1a1a] rounded-2xl p-4 border border-gray-800">
          <div className="flex items-center gap-2 mb-2">
            <span className="text-xs text-gray-400">STORAGE</span>
          </div>
          <p className="text-2xl font-bold">14.2 GB</p>
        </div>
      </div>

      {/* Recent Sessions */}
      <div className="px-4 mt-6">
        <div className="flex justify-between items-center mb-3">
          <h2 className="text-sm text-gray-400">RECENT SESSIONS</h2>
          <button className="text-blue-500 text-sm" onClick={() => onNavigate('sessions')}>View All</button>
        </div>
        
        <div className="bg-[#1a1a1a] rounded-2xl p-4 border border-gray-800">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-red-500/10 flex items-center justify-center">
              <Play className="text-red-500" size={20} />
            </div>
            <div className="flex-1">
              <p className="font-medium">Traffic Stop</p>
              <p className="text-sm text-gray-400">Today, 2:43 PM</p>
            </div>
            <p className="text-sm text-gray-400">4:12</p>
          </div>
        </div>
      </div>

      {/* Main Record Button */}
      <div className="flex flex-col items-center justify-center mt-12">
        <div className="relative">
          <div className="absolute inset-0 bg-blue-500/20 rounded-full blur-3xl animate-pulse"></div>
          <button 
            onClick={onStartRecording}
            className="relative w-40 h-40 rounded-full bg-gradient-to-br from-blue-600 to-blue-400 flex items-center justify-center shadow-lg shadow-blue-500/50"
          >
            <div className="w-32 h-32 rounded-full bg-gradient-to-br from-blue-500 to-blue-300 flex items-center justify-center">
              <div className="w-16 h-16 rounded-xl bg-white"></div>
            </div>
          </button>
        </div>
        
        <div className="text-center mt-6">
          <p className="text-2xl font-bold">START</p>
          <p className="text-xl font-bold">RECORDING</p>
          <p className="text-sm text-gray-400 mt-2">Tap to record • Hold for emergency SOS</p>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="px-4 mt-12 grid grid-cols-3 gap-3">
        <button 
          onClick={() => onNavigate('legal')}
          className="bg-[#1a1a1a] rounded-2xl p-4 border border-gray-800 flex flex-col items-center gap-2"
        >
          <BookOpen className="text-blue-500" size={24} />
          <span className="text-xs text-center">Know Your Rights</span>
        </button>
        
        <button 
          onClick={() => onNavigate('search')}
          className="bg-[#1a1a1a] rounded-2xl p-4 border border-gray-800 flex flex-col items-center gap-2"
        >
          <User className="text-blue-500" size={24} />
          <span className="text-xs text-center">Search Officer</span>
        </button>
        
        <button className="bg-[#1a1a1a] rounded-2xl p-4 border border-gray-800 flex flex-col items-center gap-2">
          <AlertTriangle className="text-red-500" size={24} />
          <span className="text-xs text-center">Emergency Contact</span>
        </button>
      </div>
    </div>
  );
}
