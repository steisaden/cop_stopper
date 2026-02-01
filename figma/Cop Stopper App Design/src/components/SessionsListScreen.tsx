import React, { useState } from 'react';
import { Search, MapPin, Clock, Video, Plus, Filter } from 'lucide-react';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Input } from './ui/input';
import { Badge } from './ui/badge';

interface Session {
  id: string;
  date: string;
  time: string;
  duration: string;
  location: string;
  thumbnail?: string;
  hasTranscript: boolean;
}

interface SessionsListScreenProps {
  onSelectSession: (session: Session) => void;
}

const mockSessions: Session[] = [
  {
    id: '1',
    date: 'Sep 23, 2025',
    time: '2:47 PM',
    duration: '4:32',
    location: 'Downtown, Anytown',
    hasTranscript: true,
  },
  {
    id: '2',
    date: 'Sep 20, 2025',
    time: '6:15 PM',
    duration: '2:18',
    location: 'Highway 101, Exit 45',
    hasTranscript: true,
  },
  {
    id: '3',
    date: 'Sep 18, 2025',
    time: '11:30 AM',
    duration: '1:45',
    location: 'Residential Area, Oak St',
    hasTranscript: false,
  },
  {
    id: '4',
    date: 'Sep 15, 2025',
    time: '9:22 PM',
    duration: '7:14',
    location: 'Shopping Center, Main St',
    hasTranscript: true,
  },
];

export function SessionsListScreen({ onSelectSession }: SessionsListScreenProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [filteredSessions, setFilteredSessions] = useState(mockSessions);

  const handleSearch = (query: string) => {
    setSearchQuery(query);
    if (query.trim() === '') {
      setFilteredSessions(mockSessions);
    } else {
      const filtered = mockSessions.filter(session =>
        session.location.toLowerCase().includes(query.toLowerCase()) ||
        session.date.toLowerCase().includes(query.toLowerCase())
      );
      setFilteredSessions(filtered);
    }
  };

  return (
    <div className="h-full bg-slate-50 dark:bg-slate-900 flex flex-col">
      {/* Header */}
      <div className="bg-white dark:bg-slate-800 border-b border-slate-200 dark:border-slate-700 p-4 pt-safe">
        <div className="flex items-center justify-between mb-4">
          <h1 className="text-xl font-semibold text-slate-800 dark:text-slate-200">
            My Sessions
          </h1>
          <Badge variant="secondary" className="bg-blue-50 text-blue-700 border-blue-200 dark:bg-blue-900 dark:text-blue-300">
            {filteredSessions.length} recordings
          </Badge>
        </div>

        {/* Search Bar */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input
            placeholder="Search by location or date..."
            value={searchQuery}
            onChange={(e) => handleSearch(e.target.value)}
            className="pl-10 bg-slate-50 dark:bg-slate-700 border-slate-200 dark:border-slate-600"
          />
        </div>
      </div>

      {/* Sessions List */}
      <div className="flex-1 overflow-y-auto p-4">
        {filteredSessions.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full text-center">
            <Video className="w-16 h-16 text-slate-300 dark:text-slate-600 mb-4" />
            <h3 className="text-lg font-medium text-slate-600 dark:text-slate-400 mb-2">
              No recordings found
            </h3>
            <p className="text-slate-500 dark:text-slate-500 text-sm max-w-xs">
              {searchQuery ? 'Try adjusting your search terms' : 'Your recorded sessions will appear here'}
            </p>
          </div>
        ) : (
          <div className="space-y-3 max-w-2xl mx-auto">
            {filteredSessions.map((session) => (
              <Card
                key={session.id}
                className="p-4 hover:shadow-md transition-shadow cursor-pointer bg-white dark:bg-slate-800 border-slate-200 dark:border-slate-700"
                onClick={() => onSelectSession(session)}
              >
                <div className="flex items-start gap-4">
                  {/* Video Thumbnail */}
                  <div className="w-16 h-16 bg-slate-100 dark:bg-slate-700 rounded-lg flex items-center justify-center flex-shrink-0">
                    <Video className="w-6 h-6 text-slate-400 dark:text-slate-500" />
                  </div>

                  {/* Session Info */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-start justify-between mb-2">
                      <div>
                        <h3 className="font-medium text-slate-800 dark:text-slate-200">
                          {session.date} • {session.time}
                        </h3>
                        <div className="flex items-center gap-2 text-sm text-slate-500 dark:text-slate-400 mt-1">
                          <Clock className="w-3 h-3" />
                          <span>{session.duration}</span>
                        </div>
                      </div>
                      {session.hasTranscript && (
                        <Badge variant="secondary" className="bg-green-50 text-green-700 border-green-200 dark:bg-green-900 dark:text-green-300 text-xs">
                          Transcript
                        </Badge>
                      )}
                    </div>

                    <div className="flex items-center gap-1 text-sm text-slate-600 dark:text-slate-400">
                      <MapPin className="w-3 h-3" />
                      <span className="truncate">{session.location}</span>
                    </div>
                  </div>
                </div>
              </Card>
            ))}
          </div>
        )}
      </div>

      {/* Floating Action Button */}
      <div className="absolute bottom-20 right-4">
        <Button
          size="lg"
          className="w-14 h-14 rounded-full shadow-lg bg-blue-600 hover:bg-blue-700 dark:bg-blue-700 dark:hover:bg-blue-600"
        >
          <Plus className="w-6 h-6" />
        </Button>
      </div>
    </div>
  );
}