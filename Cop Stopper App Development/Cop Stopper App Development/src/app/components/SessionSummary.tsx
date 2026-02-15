import { ArrowLeft, Share2, MapPin, Clock, MessageSquare, FileText, Send, MoreVertical, Play } from 'lucide-react';

interface SessionSummaryProps {
  onBack: () => void;
}

export default function SessionSummary({ onBack }: SessionSummaryProps) {
  const keyMoments = [
    { time: '00:14', label: 'Miranda Rights Read', type: 'info' },
    { time: '04:28', label: 'Search Denied', type: 'warning' },
    { time: '8:47:08', label: 'Recording Ended', type: 'info' },
  ];

  const transcript = [
    { role: 'user', text: 'One out of the vehicle, or I need to check the plates.', time: '00:03' },
    { role: 'officer', text: 'Use your', time: '00:08' },
    { role: 'user', text: 'I am not consenting to any searches. Is there anything else?', time: '00:11' },
    { role: 'officer', text: 'Yes', time: '00:14' },
    { role: 'user', text: 'I understand. Just keep your hands where I can see them.', time: '00:21' },
  ];

  return (
    <div className="min-h-screen bg-[#0a0a0a] text-white pb-32">
      {/* Header */}
      <div className="flex items-center justify-between p-4">
        <button onClick={onBack} className="p-2">
          <ArrowLeft size={24} />
        </button>
        <h1 className="text-lg font-bold">Session Summary</h1>
        <button className="p-2">
          <Share2 size={24} />
        </button>
      </div>

      {/* Date & Time */}
      <div className="px-4 mt-2 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Clock size={14} className="text-gray-400" />
          <span className="text-sm text-gray-400">Oct 24, 2023</span>
        </div>
        <div className="flex items-center gap-2">
          <Clock size={14} className="text-blue-500" />
          <span className="text-sm text-gray-400">11:43 PM</span>
        </div>
      </div>

      {/* Recording Duration */}
      <div className="px-4 mt-6">
        <div className="bg-gradient-to-br from-[#1a1a1a] via-[#141414] to-[#0f0f0f] border border-gray-800 rounded-2xl p-8 text-center">
          <p className="text-[10px] text-gray-500 tracking-wider mb-3">RECORDING DURATION</p>
          <p className="text-6xl font-bold tracking-tight">14<span className="text-gray-600">:</span>20</p>
        </div>
      </div>

      {/* Location */}
      <div className="px-4 mt-4">
        <div className="bg-[#1a1a1a] border border-gray-800 rounded-xl p-3 flex items-center gap-3">
          <MapPin className="text-red-500" size={18} />
          <div className="flex-1">
            <p className="text-sm">Downtown Metro Area • Hwy 101</p>
          </div>
        </div>
      </div>

      {/* Key Moments */}
      <div className="px-4 mt-6">
        <h3 className="text-[10px] text-gray-500 tracking-wider mb-3">KEY MOMENTS</h3>
        <div className="space-y-2">
          {keyMoments.map((moment, index) => (
            <div
              key={index}
              className="bg-[#1a1a1a] border border-gray-800 rounded-xl p-3 flex items-center gap-3"
            >
              <div className={`w-2 h-2 rounded-full flex-shrink-0 ${
                moment.type === 'warning' ? 'bg-orange-500' : 'bg-blue-500'
              }`}></div>
              <span className="text-sm font-mono text-gray-400">{moment.time}</span>
              <span className="text-sm flex-1">{moment.label}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Transcript */}
      <div className="px-4 mt-6 mb-24">
        <div className="flex items-center justify-between mb-3">
          <h3 className="text-[10px] text-gray-500 tracking-wider">TRANSCRIPT</h3>
          <button className="text-xs text-blue-500">Auto-Generated</button>
        </div>
        
        <div className="bg-[#1a1a1a] border border-gray-800 rounded-2xl p-4 space-y-4 max-h-[300px] overflow-y-auto">
          {transcript.map((message, index) => (
            <div key={index} className="flex gap-3">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 text-sm font-medium ${
                message.role === 'officer' ? 'bg-gray-700' : 'bg-blue-600'
              }`}>
                {message.role === 'officer' ? 'O' : 'U'}
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-[10px] text-gray-500 uppercase tracking-wide">{message.role}</span>
                  <span className="text-[10px] text-gray-600">{message.time}</span>
                </div>
                <p className="text-sm leading-relaxed text-gray-200">{message.text}</p>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Audio Player - Fixed at bottom */}
      <div className="fixed bottom-0 left-0 right-0 bg-[#0a0a0a] px-4 pb-4 pt-2">
        <div className="max-w-md mx-auto bg-[#1c1c1c] border border-gray-800 rounded-2xl px-4 py-3 flex items-center gap-4">
          <button className="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center flex-shrink-0 hover:bg-blue-600 transition-colors">
            <Play size={16} fill="white" className="text-white ml-0.5" />
          </button>
          <div className="flex-1 min-w-0">
            <div className="flex justify-between items-center mb-1.5">
              <span className="text-sm text-gray-300">Audio</span>
              <span className="text-sm text-gray-400">14:20</span>
            </div>
            <div className="relative w-full h-1 bg-gray-800 rounded-full">
              <div className="absolute left-0 top-0 h-full w-[15%] bg-blue-500 rounded-full"></div>
            </div>
          </div>
          <button className="p-2 flex-shrink-0">
            <MoreVertical size={20} className="text-gray-400" />
          </button>
        </div>
      </div>
    </div>
  );
}