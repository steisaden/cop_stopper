import React from 'react';
import { Circle, MapPin, Battery, Wifi, Signal } from 'lucide-react';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Badge } from './ui/badge';

interface HomeScreenProps {
  onStartRecording: () => void;
}

export function HomeScreen({ onStartRecording }: HomeScreenProps) {
  return (
    <div className="h-full bg-gradient-to-br from-slate-50 to-blue-50 dark:from-slate-900 dark:to-slate-800 flex flex-col">
      {/* Status Bar */}
      <div className="p-4 pt-safe">
        <div className="flex justify-between items-center mb-6">
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-1">
              <MapPin className="w-4 h-4 text-green-600" />
              <Badge variant="secondary" className="text-xs bg-green-50 text-green-700 border-green-200">
                GPS Ready
              </Badge>
            </div>
            <div className="flex items-center gap-1">
              <Wifi className="w-4 h-4 text-blue-600" />
              <Badge variant="secondary" className="text-xs bg-blue-50 text-blue-700 border-blue-200">
                Connected
              </Badge>
            </div>
          </div>
          <div className="flex items-center gap-1">
            <Battery className="w-4 h-4 text-slate-600" />
            <span className="text-sm text-slate-600 dark:text-slate-400">89%</span>
          </div>
        </div>

        {/* App Title */}
        <div className="text-center mb-8">
          <h1 className="text-2xl font-semibold text-slate-800 dark:text-slate-200 mb-2">
            Cop Stopper
          </h1>
          <p className="text-slate-600 dark:text-slate-400 text-sm">
            Secure documentation for your safety
          </p>
        </div>
      </div>

      {/* Main Recording Button */}
      <div className="flex-1 flex items-center justify-center px-8">
        <div className="text-center">
          <Button
            onClick={onStartRecording}
            className="w-48 h-48 rounded-full bg-slate-700 hover:bg-slate-800 dark:bg-slate-600 dark:hover:bg-slate-500 border-4 border-slate-300 dark:border-slate-500 shadow-2xl transition-all duration-200 hover:scale-105 active:scale-95"
          >
            <div className="flex flex-col items-center gap-3">
              <Circle className="w-16 h-16 text-white fill-current" />
              <span className="text-white font-medium text-lg">
                Tap to Record
              </span>
            </div>
          </Button>
          
          <p className="text-slate-500 dark:text-slate-400 text-sm mt-6 max-w-xs">
            Press and hold to start recording. Your location and audio will be securely documented.
          </p>
        </div>
      </div>

      {/* Quick Info Cards */}
      <div className="p-4 pb-6">
        <div className="grid grid-cols-2 gap-3 max-w-md mx-auto">
          <Card className="p-3 bg-white/70 dark:bg-slate-800/70 backdrop-blur-sm border-slate-200 dark:border-slate-700">
            <div className="flex items-center gap-2">
              <Signal className="w-4 h-4 text-blue-600" />
              <div>
                <p className="text-xs text-slate-500 dark:text-slate-400">Network</p>
                <p className="text-sm font-medium text-slate-700 dark:text-slate-300">Strong</p>
              </div>
            </div>
          </Card>
          
          <Card className="p-3 bg-white/70 dark:bg-slate-800/70 backdrop-blur-sm border-slate-200 dark:border-slate-700">
            <div className="flex items-center gap-2">
              <MapPin className="w-4 h-4 text-green-600" />
              <div>
                <p className="text-xs text-slate-500 dark:text-slate-400">Location</p>
                <p className="text-sm font-medium text-slate-700 dark:text-slate-300">Acquired</p>
              </div>
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}