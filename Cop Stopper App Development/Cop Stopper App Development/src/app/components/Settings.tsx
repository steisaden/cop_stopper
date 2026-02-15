import { ArrowLeft, ChevronRight, Video, Heart, Mic, Globe, Download, Lock, MapPin, BookOpen, HelpCircle, Edit } from 'lucide-react';
import { Switch } from './ui/switch';

export default function Settings() {
  return (
    <div className="min-h-screen bg-[#0a0a0a] text-white pb-20">
      {/* Header */}
      <div className="flex items-center justify-between p-4">
        <button className="p-2">
          <ArrowLeft size={24} />
        </button>
        <h1 className="text-xl font-bold">Settings</h1>
        <div className="w-10"></div>
      </div>

      {/* Profile */}
      <div className="px-4 mt-4">
        <div className="bg-[#1a1a1a] border border-gray-800 rounded-2xl p-4 flex items-center gap-3">
          <div className="w-14 h-14 rounded-full bg-orange-400"></div>
          <div className="flex-1">
            <p className="font-medium">Alex Doe</p>
            <p className="text-sm text-gray-400">Premium Member</p>
          </div>
          <button className="px-4 py-2 bg-gray-800 rounded-full text-sm">Edit</button>
        </div>
      </div>

      {/* Recording Settings */}
      <div className="px-4 mt-6">
        <h3 className="text-xs text-gray-400 mb-3">RECORDING</h3>
        <div className="bg-[#1a1a1a] border border-gray-800 rounded-2xl overflow-hidden">
          <div className="flex items-center justify-between p-4 border-b border-gray-800">
            <div className="flex items-center gap-3">
              <Video className="text-blue-500" size={20} />
              <div>
                <p className="font-medium">Video Quality</p>
                <p className="text-sm text-gray-400">1080p</p>
              </div>
            </div>
            <ChevronRight className="text-gray-400" size={20} />
          </div>
          
          <div className="flex items-center justify-between p-4">
            <div className="flex items-center gap-3">
              <Heart className="text-red-500" size={20} />
              <div>
                <p className="font-medium">Health Mode</p>
                <p className="text-sm text-gray-400">Reduces stress with calming recording</p>
              </div>
            </div>
            <Switch />
          </div>
        </div>
      </div>

      {/* AI Features */}
      <div className="px-4 mt-6">
        <h3 className="text-xs text-gray-400 mb-3">AI FEATURES</h3>
        <div className="bg-gradient-to-br from-purple-950/40 via-purple-900/20 to-purple-950/10 border border-purple-800/30 rounded-2xl overflow-hidden">
          <div className="flex items-center justify-between p-4 border-b border-purple-800/20">
            <div className="flex items-center gap-3">
              <div className="relative">
                <Mic className="text-purple-400" size={20} />
                <span className="absolute -top-1 -right-1 px-1 text-[8px] bg-purple-500 rounded text-white">PRO</span>
              </div>
              <div>
                <p className="font-medium">Whisper AI</p>
                <p className="text-sm text-gray-400">On-device transcription model</p>
              </div>
            </div>
            <Switch defaultChecked />
          </div>
          
          <div className="p-4">
            <div className="flex items-center justify-between mb-4">
              <span className="text-sm text-gray-400">Language</span>
              <span className="text-sm">English (US)</span>
            </div>
            
            <div className="mb-4">
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm text-gray-400">Model Size</span>
                <span className="text-sm">Medium</span>
              </div>
              <div className="relative w-full h-1 bg-purple-950/50 rounded-full">
                <div className="absolute left-0 top-0 h-full w-1/2 bg-purple-500 rounded-full"></div>
                <div className="absolute left-1/2 top-1/2 -translate-y-1/2 w-4 h-4 bg-white rounded-full border-2 border-purple-500"></div>
              </div>
              <div className="flex justify-between mt-1">
                <span className="text-xs text-gray-500">SMALL</span>
                <span className="text-xs text-gray-500">MEDIUM</span>
                <span className="text-xs text-gray-500">LARGE</span>
              </div>
            </div>
            
            <button className="w-full flex items-center justify-center gap-2 py-3 bg-purple-900/30 border border-purple-700/30 rounded-full hover:bg-purple-900/50 transition-colors">
              <Download size={16} />
              <span className="text-sm">Download Model</span>
            </button>
          </div>
        </div>
      </div>

      {/* Privacy & Security */}
      <div className="px-4 mt-6">
        <h3 className="text-xs text-gray-400 mb-3">PRIVACY & SECURITY</h3>
        <div className="bg-[#1a1a1a] border border-gray-800 rounded-2xl overflow-hidden">
          <div className="flex items-center justify-between p-4 border-b border-gray-800">
            <div className="flex items-center gap-3">
              <Lock className="text-green-500" size={20} />
              <span className="font-medium">Biometric Lock</span>
            </div>
            <Switch defaultChecked />
          </div>
          
          <div className="flex items-center justify-between p-4">
            <div className="flex items-center gap-3">
              <MapPin className="text-orange-500" size={20} />
              <div>
                <p className="font-medium">Storage Location</p>
                <p className="text-sm text-gray-400">Local Only</p>
              </div>
            </div>
            <ChevronRight className="text-gray-400" size={20} />
          </div>
        </div>
      </div>

      {/* Legal & Support */}
      <div className="px-4 mt-6">
        <h3 className="text-xs text-gray-400 mb-3">LEGAL & SUPPORT</h3>
        <div className="bg-[#1a1a1a] border border-gray-800 rounded-2xl overflow-hidden">
          <button className="flex items-center justify-between p-4 border-b border-gray-800 w-full">
            <div className="flex items-center gap-3">
              <BookOpen className="text-blue-500" size={20} />
              <span className="font-medium">Legal Rights Guide</span>
            </div>
            <ChevronRight className="text-gray-400" size={20} />
          </button>
          
          <button className="flex items-center justify-between p-4 w-full">
            <div className="flex items-center gap-3">
              <HelpCircle className="text-blue-500" size={20} />
              <span className="font-medium">Help Center</span>
            </div>
            <ChevronRight className="text-gray-400" size={20} />
          </button>
        </div>
      </div>

      <div className="px-4 mt-8 text-center">
        <p className="text-xs text-gray-500">App Version: 2.4.0 (Build 145)</p>
      </div>
    </div>
  );
}