import { X, MessageSquare, Pause, Flag } from 'lucide-react';
import { useState, useEffect } from 'react';

interface RecordingLiveProps {
  onStop: () => void;
}

export default function RecordingLive({ onStop }: RecordingLiveProps) {
  const [duration, setDuration] = useState(14);
  const [transcript, setTranscript] = useState([
    { role: 'officer', text: 'Step out of the vehicle, please.' },
    { role: 'user', text: 'Am I being detained or am I free to go?' },
    { role: 'officer', text: 'Just answer the question.' },
    { role: 'user', text: 'I am invoking my right to remain silent.' },
  ]);

  useEffect(() => {
    const timer = setInterval(() => {
      setDuration(prev => prev + 1);
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const formatTime = (seconds: number) => {
    const hrs = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    return `${hrs.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <div className="min-h-screen bg-[#0a0a0a] text-white flex flex-col">
      {/* Header */}
      <div className="flex items-center justify-between p-4">
        <button onClick={onStop} className="flex items-center gap-2 text-red-500">
          <X size={20} />
          <span className="text-sm font-medium">RECORDING LIVE</span>
        </button>
      </div>

      {/* Timer */}
      <div className="text-center mt-8">
        <p className="text-6xl font-bold tracking-wider">{formatTime(duration)}</p>
      </div>

      {/* Waveform */}
      <div className="flex items-center justify-center gap-1 px-8 mt-12 h-24">
        {Array.from({ length: 60 }).map((_, i) => {
          const height = Math.random() * 80 + 20;
          const isActive = i % 3 === 0;
          return (
            <div
              key={i}
              className={`flex-1 rounded-full ${isActive ? 'bg-red-500' : 'bg-gray-600'}`}
              style={{ height: `${height}%` }}
            />
          );
        })}
      </div>

      {/* Transcript */}
      <div className="mt-8 mx-4 flex-1">
        <div className="bg-[#1a1a1a] border border-gray-800 rounded-2xl p-4 h-[300px] overflow-y-auto">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-sm font-medium">TRANSCRIPT</h3>
            <span className="text-xs text-blue-500">Auto-scrolling</span>
          </div>
          
          <div className="space-y-3">
            {transcript.map((message, index) => (
              <div key={index}>
                <p className="text-xs text-gray-500 mb-1">
                  {message.role === 'officer' ? 'OFFICER' : 'USER'} • 00:{(14 - transcript.length + index + 1).toString().padStart(2, '0')}
                </p>
                <div className={`p-3 rounded-xl ${
                  message.role === 'user' 
                    ? 'bg-blue-600/20 border border-blue-500/30' 
                    : 'bg-gray-800'
                }`}>
                  <p className="text-sm">{message.text}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="px-4 mb-4 grid grid-cols-3 gap-3">
        <button className="bg-[#1a1a1a] border border-gray-800 rounded-2xl py-3 flex flex-col items-center gap-1">
          <MessageSquare size={20} />
          <span className="text-xs">No Consent</span>
        </button>
        <button className="bg-[#1a1a1a] border border-gray-800 rounded-2xl py-3 flex flex-col items-center gap-1">
          <MessageSquare size={20} />
          <span className="text-xs">Am I Detained?</span>
        </button>
        <button className="bg-[#1a1a1a] border border-gray-800 rounded-2xl py-3 flex flex-col items-center gap-1">
          <Flag size={20} />
          <span className="text-xs">Mark Event</span>
        </button>
      </div>

      {/* Control Buttons */}
      <div className="px-4 pb-8 flex items-center justify-center gap-4">
        <button className="w-12 h-12 rounded-full bg-[#1a1a1a] border border-gray-800 flex items-center justify-center">
          <MessageSquare size={20} />
        </button>
        
        <button
          onClick={onStop}
          className="w-24 h-24 rounded-full bg-red-500 flex items-center justify-center text-white font-bold shadow-lg shadow-red-500/50"
        >
          STOP
        </button>
        
        <button className="w-12 h-12 rounded-full bg-[#1a1a1a] border border-gray-800 flex items-center justify-center">
          <Pause size={20} />
        </button>
      </div>
    </div>
  );
}
