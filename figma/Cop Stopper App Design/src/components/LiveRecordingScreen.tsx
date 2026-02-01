import React, { useState, useEffect } from 'react';
import { Square, Video, MapPin, Mic, AlertCircle, Phone } from 'lucide-react';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle, AlertDialogTrigger } from './ui/alert-dialog';

interface LiveRecordingScreenProps {
  onStopRecording: () => void;
  onBackToHome: () => void;
}

export function LiveRecordingScreen({ onStopRecording, onBackToHome }: LiveRecordingScreenProps) {
  const [recordingTime, setRecordingTime] = useState(0);
  const [transcript, setTranscript] = useState([
    "Recording started at 2:47 PM",
    "Audio transcription will appear here in real-time...",
  ]);

  useEffect(() => {
    const interval = setInterval(() => {
      setRecordingTime(prev => prev + 1);
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  const formatTime = (seconds: number) => {
    const hrs = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    
    if (hrs > 0) {
      return `${hrs.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const handleStopRecording = () => {
    onStopRecording();
    onBackToHome();
  };

  return (
    <div className="h-full bg-slate-900 text-white flex flex-col">
      {/* Recording Status Header */}
      <div className="bg-red-600 p-4 pt-safe">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 bg-white rounded-full animate-pulse"></div>
              <span className="font-semibold text-lg">RECORDING LIVE</span>
            </div>
          </div>
          <div className="text-right">
            <div className="font-mono text-xl font-semibold">
              {formatTime(recordingTime)}
            </div>
          </div>
        </div>
      </div>

      {/* Content Area */}
      <div className="flex-1 overflow-hidden flex flex-col">
        {/* Video Preview */}
        <Card className="m-4 bg-slate-800 border-slate-700 overflow-hidden">
          <div className="aspect-video bg-slate-900 relative flex items-center justify-center">
            <Video className="w-12 h-12 text-slate-500" />
            <div className="absolute top-2 left-2">
              <Badge className="bg-red-600 text-white border-red-500">
                <div className="w-2 h-2 bg-white rounded-full mr-1 animate-pulse"></div>
                REC
              </Badge>
            </div>
            <div className="absolute bottom-2 right-2 text-xs text-slate-300 font-mono">
              {formatTime(recordingTime)}
            </div>
          </div>
        </Card>

        {/* Live Transcription */}
        <Card className="m-4 mt-0 flex-1 bg-slate-800 border-slate-700 flex flex-col">
          <div className="p-3 border-b border-slate-700">
            <div className="flex items-center gap-2">
              <Mic className="w-4 h-4 text-blue-400" />
              <h3 className="font-medium text-slate-200">Live Transcription</h3>
            </div>
          </div>
          <div className="flex-1 p-3 overflow-y-auto">
            <div className="space-y-2">
              {transcript.map((line, index) => (
                <p key={index} className="text-sm text-slate-300 leading-relaxed">
                  <span className="text-slate-500 text-xs mr-2">
                    {index === 0 ? '2:47 PM' : '2:48 PM'}
                  </span>
                  {line}
                </p>
              ))}
              <div className="flex items-center gap-2 text-blue-400">
                <div className="w-2 h-2 bg-blue-400 rounded-full animate-pulse"></div>
                <span className="text-xs">Listening...</span>
              </div>
            </div>
          </div>
        </Card>

        {/* Location Info */}
        <Card className="m-4 mt-0 bg-slate-800 border-slate-700">
          <div className="p-3">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <MapPin className="w-4 h-4 text-green-400" />
                <span className="text-sm text-slate-200">Current Location</span>
              </div>
              <Badge variant="secondary" className="bg-green-900 text-green-300 border-green-700">
                GPS Active
              </Badge>
            </div>
            <p className="text-xs text-slate-400 mt-1">
              123 Main Street, Anytown, ST 12345
            </p>
          </div>
        </Card>
      </div>

      {/* Action Buttons */}
      <div className="p-4 border-t border-slate-700 bg-slate-800">
        <div className="grid grid-cols-2 gap-3 max-w-md mx-auto">
          <Button
            variant="outline"
            className="flex items-center gap-2 bg-amber-600 hover:bg-amber-700 border-amber-500 text-white"
          >
            <Phone className="w-4 h-4" />
            Alert Contacts
          </Button>
          
          <AlertDialog>
            <AlertDialogTrigger asChild>
              <Button className="flex items-center gap-2 bg-red-600 hover:bg-red-700">
                <Square className="w-4 h-4" />
                Stop Recording
              </Button>
            </AlertDialogTrigger>
            <AlertDialogContent className="bg-slate-800 border-slate-700 text-white">
              <AlertDialogHeader>
                <AlertDialogTitle className="flex items-center gap-2">
                  <AlertCircle className="w-5 h-5 text-amber-500" />
                  Stop Recording?
                </AlertDialogTitle>
                <AlertDialogDescription className="text-slate-300">
                  Are you sure you want to end this recording session? The recording will be saved securely to your device and cloud storage.
                </AlertDialogDescription>
              </AlertDialogHeader>
              <AlertDialogFooter>
                <AlertDialogCancel className="bg-slate-700 border-slate-600 text-slate-200 hover:bg-slate-600">
                  Continue Recording
                </AlertDialogCancel>
                <AlertDialogAction 
                  onClick={handleStopRecording}
                  className="bg-red-600 hover:bg-red-700 text-white"
                >
                  Stop & Save
                </AlertDialogAction>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialog>
        </div>
      </div>
    </div>
  );
}