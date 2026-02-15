import { useState } from 'react';
import Dashboard from './components/Dashboard';
import DocumentVault from './components/DocumentVault';
import OfficerSearch from './components/OfficerSearch';
import LegalGuidance from './components/LegalGuidance';
import Settings from './components/Settings';
import RecordingLive from './components/RecordingLive';
import SessionSummary from './components/SessionSummary';
import BottomNavigation from './components/BottomNavigation';

type Screen = 'dashboard' | 'documents' | 'search' | 'legal' | 'settings' | 'recording' | 'sessions';

export default function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('dashboard');

  const handleStartRecording = () => {
    setCurrentScreen('recording');
  };

  const handleStopRecording = () => {
    setCurrentScreen('sessions');
  };

  const renderScreen = () => {
    switch (currentScreen) {
      case 'dashboard':
        return <Dashboard onNavigate={setCurrentScreen} onStartRecording={handleStartRecording} />;
      case 'documents':
        return <DocumentVault />;
      case 'search':
        return <OfficerSearch />;
      case 'legal':
        return <LegalGuidance />;
      case 'settings':
        return <Settings />;
      case 'recording':
        return <RecordingLive onStop={handleStopRecording} />;
      case 'sessions':
        return <SessionSummary onBack={() => setCurrentScreen('dashboard')} />;
      default:
        return <Dashboard onNavigate={setCurrentScreen} onStartRecording={handleStartRecording} />;
    }
  };

  return (
    <div className="max-w-md mx-auto bg-[#0a0a0a] min-h-screen relative">
      {renderScreen()}
      {currentScreen !== 'recording' && currentScreen !== 'sessions' && (
        <BottomNavigation activeScreen={currentScreen} onNavigate={setCurrentScreen} />
      )}
    </div>
  );
}
