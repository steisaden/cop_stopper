import React, { useState } from 'react';
import { ArrowLeft, Play, Pause, Share, Trash2, MapPin, Clock, FileText, Download, MessageSquare } from 'lucide-react';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Badge } from './ui/badge';
import { Separator } from './ui/separator';
import { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle, AlertDialogTrigger } from './ui/alert-dialog';
import { Textarea } from './ui/textarea';

interface SessionDetailScreenProps {
  session: any;
  onBack: () => void;
}

const mockTranscript = [
  { time: '00:00', speaker: 'System', text: 'Recording started at 2:47 PM' },
  { time: '00:15', speaker: 'Officer', text: 'License and registration please.' },
  { time: '00:18', speaker: 'You', text: 'Of course, here you go.' },
  { time: '00:35', speaker: 'Officer', text: 'Do you know why I pulled you over today?' },
  { time: '00:38', speaker: 'You', text: 'No sir, I was going the speed limit.' },
  { time: '01:12', speaker: 'Officer', text: 'Your brake light is out. I\'m going to give you a warning.' },
  { time: '01:15', speaker: 'You', text: 'Thank you, I\'ll get that fixed right away.' },
];

export function SessionDetailScreen({ session, onBack }: SessionDetailScreenProps) {
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState('00:00');
  const [notes, setNotes] = useState('');
  const [showNotesDialog, setShowNotesDialog] = useState(false);

  if (!session) {
    return null;
  }

  const handlePlayPause = () => {
    setIsPlaying(!isPlaying);
  };

  const handleTranscriptClick = (time: string) => {
    setCurrentTime(time);
    // In a real app, this would seek the video to this time
  };

  return (
    <div className="h-full bg-slate-50 dark:bg-slate-900 flex flex-col">
      {/* Header */}
      <div className="bg-white dark:bg-slate-800 border-b border-slate-200 dark:border-slate-700 p-4 pt-safe">
        <div className="flex items-center gap-3 mb-4">
          <Button
            variant="ghost"
            size="sm"
            onClick={onBack}
            className="p-2"
          >
            <ArrowLeft className="w-5 h-5" />
          </Button>
          <div className="flex-1">
            <h1 className="font-semibold text-slate-800 dark:text-slate-200">
              {session.date} • {session.time}
            </h1>
            <p className="text-sm text-slate-500 dark:text-slate-400">
              Session Details
            </p>
          </div>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto">
        {/* Video Player */}
        <Card className="m-4 bg-white dark:bg-slate-800 border-slate-200 dark:border-slate-700 overflow-hidden">
          <div className="aspect-video bg-slate-900 relative flex items-center justify-center">
            <Button
              onClick={handlePlayPause}
              size="lg"
              className="w-16 h-16 rounded-full bg-white/20 hover:bg-white/30 border-white/30"
            >
              {isPlaying ? (
                <Pause className="w-8 h-8 text-white" />
              ) : (
                <Play className="w-8 h-8 text-white ml-1" />
              )}
            </Button>
            
            {/* Video Controls Overlay */}
            <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/60 to-transparent p-4">
              <div className="flex items-center justify-between text-white text-sm">
                <span>{currentTime}</span>
                <div className="flex-1 mx-4 h-1 bg-white/30 rounded-full">
                  <div className="h-full w-1/4 bg-white rounded-full"></div>
                </div>
                <span>{session.duration}</span>
              </div>
            </div>
          </div>
        </Card>

        {/* Session Metadata */}
        <Card className="m-4 mt-0 bg-white dark:bg-slate-800 border-slate-200 dark:border-slate-700">
          <div className="p-4">
            <h3 className="font-medium text-slate-800 dark:text-slate-200 mb-3">Session Information</h3>
            <div className="space-y-3">
              <div className="flex items-center gap-3">
                <Clock className="w-4 h-4 text-slate-500" />
                <div>
                  <p className="text-sm text-slate-600 dark:text-slate-400">Duration</p>
                  <p className="font-medium text-slate-800 dark:text-slate-200">{session.duration}</p>
                </div>
              </div>
              
              <div className="flex items-start gap-3">
                <MapPin className="w-4 h-4 text-slate-500 mt-1" />
                <div>
                  <p className="text-sm text-slate-600 dark:text-slate-400">Location</p>
                  <p className="font-medium text-slate-800 dark:text-slate-200">{session.location}</p>
                  <p className="text-xs text-slate-500 dark:text-slate-500 mt-1">
                    GPS: 40.7128° N, 74.0060° W
                  </p>
                </div>
              </div>
            </div>
          </div>
        </Card>

        {/* Interactive Transcript */}
        {session.hasTranscript && (
          <Card className="m-4 mt-0 bg-white dark:bg-slate-800 border-slate-200 dark:border-slate-700">
            <div className="p-4 border-b border-slate-200 dark:border-slate-700">
              <div className="flex items-center gap-2">
                <FileText className="w-4 h-4 text-blue-500" />
                <h3 className="font-medium text-slate-800 dark:text-slate-200">Transcript</h3>
                <Badge variant="secondary" className="bg-blue-50 text-blue-700 border-blue-200 dark:bg-blue-900 dark:text-blue-300 text-xs">
                  Interactive
                </Badge>
              </div>
            </div>
            <div className="max-h-64 overflow-y-auto">
              {mockTranscript.map((entry, index) => (
                <div
                  key={index}
                  className="p-3 border-b border-slate-100 dark:border-slate-700 last:border-b-0 cursor-pointer hover:bg-slate-50 dark:hover:bg-slate-700/50"
                  onClick={() => handleTranscriptClick(entry.time)}
                >
                  <div className="flex gap-3">
                    <span className="text-xs text-blue-600 dark:text-blue-400 font-mono w-12 flex-shrink-0 mt-1">
                      {entry.time}
                    </span>
                    <div className="flex-1">
                      <span className="text-xs font-medium text-slate-600 dark:text-slate-400 uppercase tracking-wide">
                        {entry.speaker}
                      </span>
                      <p className="text-sm text-slate-800 dark:text-slate-200 mt-1 leading-relaxed">
                        {entry.text}
                      </p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </Card>
        )}

        {/* Notes Section */}
        <Card className="m-4 mt-0 bg-white dark:bg-slate-800 border-slate-200 dark:border-slate-700">
          <div className="p-4">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <MessageSquare className="w-4 h-4 text-slate-500" />
                <h3 className="font-medium text-slate-800 dark:text-slate-200">Notes</h3>
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={() => setShowNotesDialog(true)}
                className="text-xs"
              >
                Add Notes
              </Button>
            </div>
            {notes ? (
              <p className="text-sm text-slate-600 dark:text-slate-400 bg-slate-50 dark:bg-slate-700 p-3 rounded-lg">
                {notes}
              </p>
            ) : (
              <p className="text-sm text-slate-500 dark:text-slate-500 italic">
                No notes added yet. Click "Add Notes" to document additional details.
              </p>
            )}
          </div>
        </Card>
      </div>

      {/* Action Bar */}
      <div className="bg-white dark:bg-slate-800 border-t border-slate-200 dark:border-slate-700 p-4">
        <div className="flex gap-2 max-w-md mx-auto">
          <Button className="flex-1 flex items-center gap-2 bg-blue-600 hover:bg-blue-700">
            <Share className="w-4 h-4" />
            Export
          </Button>
          
          <Button variant="outline" className="flex items-center gap-2">
            <Download className="w-4 h-4" />
            Download
          </Button>
          
          <AlertDialog>
            <AlertDialogTrigger asChild>
              <Button variant="outline" className="text-red-600 border-red-200 hover:bg-red-50 dark:text-red-400 dark:border-red-800 dark:hover:bg-red-900/20">
                <Trash2 className="w-4 h-4" />
              </Button>
            </AlertDialogTrigger>
            <AlertDialogContent>
              <AlertDialogHeader>
                <AlertDialogTitle>Delete Session?</AlertDialogTitle>
                <AlertDialogDescription>
                  This action cannot be undone. This will permanently delete this recording session and all associated data.
                </AlertDialogDescription>
              </AlertDialogHeader>
              <AlertDialogFooter>
                <AlertDialogCancel>Cancel</AlertDialogCancel>
                <AlertDialogAction className="bg-red-600 hover:bg-red-700">
                  Delete
                </AlertDialogAction>
              </AlertDialogFooter>
            </AlertDialogContent>
          </AlertDialog>
        </div>
      </div>

      {/* Notes Dialog */}
      {showNotesDialog && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
          <Card className="w-full max-w-md bg-white dark:bg-slate-800 border-slate-200 dark:border-slate-700">
            <div className="p-4">
              <h3 className="font-medium text-slate-800 dark:text-slate-200 mb-3">Add Notes</h3>
              <Textarea
                placeholder="Add any additional details about this encounter..."
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                className="min-h-24 resize-none"
              />
              <div className="flex gap-2 mt-4">
                <Button
                  onClick={() => setShowNotesDialog(false)}
                  className="flex-1"
                >
                  Save Notes
                </Button>
                <Button
                  variant="outline"
                  onClick={() => setShowNotesDialog(false)}
                >
                  Cancel
                </Button>
              </div>
            </div>
          </Card>
        </div>
      )}
    </div>
  );
}