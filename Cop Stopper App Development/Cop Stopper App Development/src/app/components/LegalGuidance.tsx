import { ArrowLeft, AlertTriangle, Send, MoreVertical } from 'lucide-react';
import { useState } from 'react';

interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  timestamp: string;
}

export default function LegalGuidance() {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      role: 'assistant',
      content: "You have the right to remain silent. You don't have the right to refuse a search. You have the right to leave if you are not being detained.",
      timestamp: 'TODAY, 9:18 AM',
    },
    {
      id: '2',
      role: 'assistant',
      content: "Hello. I'm here to help you understand your rights during this interaction. Ask me anything right now!",
      timestamp: '',
    },
    {
      id: '3',
      role: 'user',
      content: "They just pulled me over. They are asking for my license and registration.",
      timestamp: '',
    },
    {
      id: '4',
      role: 'assistant',
      content: "Okay. You are required to provide your license, registration, and proof of insurance. Keep your hands where the officer can see them. Only provide these documents.",
      timestamp: '',
    },
    {
      id: '5',
      role: 'user',
      content: "They are saying I was speeding. I wasn't though.",
      timestamp: '',
    },
    {
      id: '6',
      role: 'assistant',
      content: "*Have a cop license and registration officers*\n\nOkay. I gotta let them. But they are saying I was speeding. Should I tell them I wasn't or should I just say silent?",
      timestamp: '',
    },
  ]);

  const [inputValue, setInputValue] = useState('');

  const handleSend = () => {
    if (inputValue.trim()) {
      setMessages([...messages, {
        id: Date.now().toString(),
        role: 'user',
        content: inputValue,
        timestamp: '',
      }]);
      setInputValue('');
    }
  };

  return (
    <div className="min-h-screen bg-[#0a0a0a] text-white pb-20 flex flex-col">
      {/* Header */}
      <div className="flex items-center justify-between p-4 border-b border-gray-800">
        <button className="p-2">
          <ArrowLeft size={24} />
        </button>
        <div className="flex-1 text-center">
          <div className="flex items-center justify-center gap-2">
            <AlertTriangle className="text-orange-500" size={16} />
            <span className="text-sm text-orange-500">THIS IS AN URGENT, NOT LEGAL ADVICE</span>
          </div>
          <h1 className="text-lg font-bold mt-1">Legal Guidance <span className="text-blue-500">AI</span></h1>
        </div>
        <button className="p-2">
          <MoreVertical size={24} />
        </button>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.map((message) => (
          <div key={message.id} className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}>
            <div className="flex items-start gap-2 max-w-[80%]">
              {message.role === 'assistant' && (
                <div className="w-8 h-8 rounded-full bg-purple-500 flex items-center justify-center flex-shrink-0">
                  <span className="text-sm">AI</span>
                </div>
              )}
              <div className={`rounded-2xl p-4 ${
                message.role === 'user' 
                  ? 'bg-blue-600 rounded-tr-none' 
                  : 'bg-[#1a1a1a] border border-gray-800 rounded-tl-none'
              }`}>
                <p className="text-sm leading-relaxed">{message.content}</p>
                {message.timestamp && (
                  <p className="text-xs text-gray-400 mt-2">{message.timestamp}</p>
                )}
              </div>
              {message.role === 'user' && (
                <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center flex-shrink-0">
                  <span className="text-sm">U</span>
                </div>
              )}
            </div>
          </div>
        ))}
        
        <div className="flex justify-center">
          <button className="text-sm text-gray-400 flex items-center gap-2">
            <span>• • •</span>
          </button>
        </div>
      </div>

      {/* Warning Banner */}
      <div className="px-4 py-3 bg-gray-900/50 border-t border-gray-800">
        <div className="flex items-start gap-2">
          <AlertTriangle className="text-orange-500 flex-shrink-0" size={16} />
          <p className="text-xs text-gray-400">
            Am I being detained? <span className="text-white">I do not consent to searches</span>
          </p>
        </div>
      </div>

      {/* Input */}
      <div className="p-4 border-t border-gray-800">
        <div className="flex items-center gap-2">
          <input
            type="text"
            placeholder="Describe the situation..."
            value={inputValue}
            onChange={(e) => setInputValue(e.target.value)}
            onKeyPress={(e) => e.key === 'Enter' && handleSend()}
            className="flex-1 bg-[#1a1a1a] border border-gray-800 rounded-full py-3 px-4 text-white placeholder-gray-500 focus:outline-none focus:border-blue-500"
          />
          <button
            onClick={handleSend}
            className="w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center"
          >
            <Send size={20} />
          </button>
        </div>
      </div>
    </div>
  );
}
