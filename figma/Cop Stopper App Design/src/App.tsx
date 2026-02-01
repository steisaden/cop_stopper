import React, { useState } from 'react';
import { Home, List, Settings, Video, MapPin, Clock, Battery, Wifi } from 'lucide-react';
import { Button } from './components/ui/button';
import { Card } from './components/ui/card';
import { Badge } from './components/ui/badge';
import { Separator } from './components/ui/separator';
import { HomeScreen } from './components/HomeScreen';
import { LiveRecordingScreen } from './components/LiveRecordingScreen';
import { SessionsListScreen } from './components/SessionsListScreen';
import { SessionDetailScreen } from './components/SessionDetailScreen';
import { SettingsScreen } from './components/SettingsScreen';

export default function App() {
  const [activeScreen, setActiveScreen] = useState('home');
  const [isRecording, setIsRecording] = useState(false);
  const [selectedSession, setSelectedSession] = useState(null);

  const renderScreen = () => {
    if (isRecording) {
      return (
        <LiveRecordingScreen 
          onStopRecording={() => setIsRecording(false)}
          onBackToHome={() => setActiveScreen('home')}
        />
      );
    }

    switch (activeScreen) {
      case 'home':
        return (
          <HomeScreen 
            onStartRecording={() => setIsRecording(true)}
          />
        );
      case 'sessions':
        return (
          <SessionsListScreen 
            onSelectSession={(session) => {
              setSelectedSession(session);
              setActiveScreen('session-detail');
            }}
          />
        );
      case 'session-detail':
        return (
          <SessionDetailScreen 
            session={selectedSession}
            onBack={() => setActiveScreen('sessions')}
          />
        );
      case 'settings':
        return <SettingsScreen />;
      default:
        return <HomeScreen onStartRecording={() => setIsRecording(true)} />;
    }
  };

  return (
    <div className="size-full bg-slate-50 dark:bg-slate-900 flex flex-col">
      {/* Main Content */}
      <div className="flex-1 overflow-hidden">
        {renderScreen()}
      </div>

      {/* Bottom Navigation - Hidden during recording */}
      {!isRecording && (
        <div className="bg-white dark:bg-slate-800 border-t border-slate-200 dark:border-slate-700 px-4 py-2 pb-safe">
          <div className="flex justify-around items-center max-w-md mx-auto">
            <Button
              variant={activeScreen === 'home' ? 'default' : 'ghost'}
              size="sm"
              onClick={() => setActiveScreen('home')}
              className="flex flex-col items-center gap-1 h-auto py-2 px-3"
            >
              <Home className="w-5 h-5" />
              <span className="text-xs">Record</span>
            </Button>
            
            <Button
              variant={activeScreen === 'sessions' ? 'default' : 'ghost'}
              size="sm"
              onClick={() => setActiveScreen('sessions')}
              className="flex flex-col items-center gap-1 h-auto py-2 px-3"
            >
              <List className="w-5 h-5" />
              <span className="text-xs">Sessions</span>
            </Button>
            
            <Button
              variant={activeScreen === 'settings' ? 'default' : 'ghost'}
              size="sm"
              onClick={() => setActiveScreen('settings')}
              className="flex flex-col items-center gap-1 h-auto py-2 px-3"
            >
              <Settings className="w-5 h-5" />
              <span className="text-xs">Settings</span>
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}