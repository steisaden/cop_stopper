import React, { useState } from 'react';
import { User, Video, Users, Cloud, Shield, ChevronRight, Bell, Smartphone, Wifi, HardDrive } from 'lucide-react';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Separator } from './ui/separator';
import { Switch } from './ui/switch';
import { Badge } from './ui/badge';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';

export function SettingsScreen() {
  const [autoRecord, setAutoRecord] = useState(false);
  const [wifiOnly, setWifiOnly] = useState(true);
  const [notifications, setNotifications] = useState(true);
  const [videoQuality, setVideoQuality] = useState('medium');

  const SettingItem = ({ icon: Icon, title, subtitle, children }: any) => (
    <div className="flex items-center gap-3 p-4">
      <Icon className="w-5 h-5 text-slate-500 flex-shrink-0" />
      <div className="flex-1 min-w-0">
        <p className="font-medium text-slate-800 dark:text-slate-200">{title}</p>
        {subtitle && (
          <p className="text-sm text-slate-500 dark:text-slate-400">{subtitle}</p>
        )}
      </div>
      {children}
    </div>
  );

  const SettingSection = ({ title, children }: any) => (
    <Card className="bg-white dark:bg-slate-800 border-slate-200 dark:border-slate-700">
      <div className="p-4 border-b border-slate-200 dark:border-slate-700">
        <h3 className="font-medium text-slate-800 dark:text-slate-200">{title}</h3>
      </div>
      <div className="divide-y divide-slate-200 dark:divide-slate-700">
        {children}
      </div>
    </Card>
  );

  return (
    <div className="h-full bg-slate-50 dark:bg-slate-900 overflow-y-auto">
      {/* Header */}
      <div className="bg-white dark:bg-slate-800 border-b border-slate-200 dark:border-slate-700 p-4 pt-safe">
        <h1 className="text-xl font-semibold text-slate-800 dark:text-slate-200">Settings</h1>
        <p className="text-sm text-slate-500 dark:text-slate-400 mt-1">
          Configure your app preferences and security settings
        </p>
      </div>

      <div className="p-4 space-y-6 max-w-2xl mx-auto">
        {/* Account Section */}
        <SettingSection title="Account">
          <SettingItem
            icon={User}
            title="Profile"
            subtitle="John Doe • john.doe@email.com"
          >
            <ChevronRight className="w-4 h-4 text-slate-400" />
          </SettingItem>
          <SettingItem
            icon={Shield}
            title="Change Password"
            subtitle="Last changed 30 days ago"
          >
            <ChevronRight className="w-4 h-4 text-slate-400" />
          </SettingItem>
        </SettingSection>

        {/* Recording Settings */}
        <SettingSection title="Recording">
          <SettingItem
            icon={Video}
            title="Video Quality"
            subtitle="Higher quality uses more storage"
          >
            <Select value={videoQuality} onValueChange={setVideoQuality}>
              <SelectTrigger className="w-24">
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="low">Low</SelectItem>
                <SelectItem value="medium">Medium</SelectItem>
                <SelectItem value="high">High</SelectItem>
              </SelectContent>
            </Select>
          </SettingItem>
          <SettingItem
            icon={Smartphone}
            title="Auto-start Recording"
            subtitle="Start recording with voice command or shortcut"
          >
            <Switch
              checked={autoRecord}
              onCheckedChange={setAutoRecord}
            />
          </SettingItem>
          <SettingItem
            icon={Bell}
            title="Recording Notifications"
            subtitle="Show alerts during active recording"
          >
            <Switch
              checked={notifications}
              onCheckedChange={setNotifications}
            />
          </SettingItem>
        </SettingSection>

        {/* Trusted Contacts */}
        <SettingSection title="Emergency Contacts">
          <SettingItem
            icon={Users}
            title="Trusted Contacts"
            subtitle="2 contacts configured"
          >
            <div className="flex items-center gap-2">
              <Badge variant="secondary" className="bg-green-50 text-green-700 border-green-200 dark:bg-green-900 dark:text-green-300">
                Active
              </Badge>
              <ChevronRight className="w-4 h-4 text-slate-400" />
            </div>
          </SettingItem>
          <SettingItem
            icon={Bell}
            title="Auto-alert Contacts"
            subtitle="Notify contacts when recording starts"
          >
            <Switch defaultChecked />
          </SettingItem>
        </SettingSection>

        {/* Cloud Storage */}
        <SettingSection title="Storage & Sync">
          <SettingItem
            icon={Cloud}
            title="Cloud Storage"
            subtitle="2.1 GB used of 5 GB"
          >
            <div className="flex items-center gap-2">
              <Badge variant="secondary" className="bg-blue-50 text-blue-700 border-blue-200 dark:bg-blue-900 dark:text-blue-300">
                Pro Plan
              </Badge>
              <ChevronRight className="w-4 h-4 text-slate-400" />
            </div>
          </SettingItem>
          <SettingItem
            icon={Wifi}
            title="Sync on Wi-Fi Only"
            subtitle="Save cellular data usage"
          >
            <Switch
              checked={wifiOnly}
              onCheckedChange={setWifiOnly}
            />
          </SettingItem>
          <SettingItem
            icon={HardDrive}
            title="Local Storage"
            subtitle="Manage device storage usage"
          >
            <ChevronRight className="w-4 h-4 text-slate-400" />
          </SettingItem>
        </SettingSection>

        {/* Legal & Privacy */}
        <SettingSection title="Legal & Privacy">
          <SettingItem
            icon={Shield}
            title="Privacy Policy"
          >
            <ChevronRight className="w-4 h-4 text-slate-400" />
          </SettingItem>
          <SettingItem
            icon={Shield}
            title="Terms of Service"
          >
            <ChevronRight className="w-4 h-4 text-slate-400" />
          </SettingItem>
          <SettingItem
            icon={Shield}
            title="Recording Laws"
            subtitle="Know your local recording rights"
          >
            <ChevronRight className="w-4 h-4 text-slate-400" />
          </SettingItem>
        </SettingSection>

        {/* App Info */}
        <Card className="bg-white dark:bg-slate-800 border-slate-200 dark:border-slate-700">
          <div className="p-4 text-center">
            <h3 className="font-medium text-slate-800 dark:text-slate-200 mb-1">Cop Stopper</h3>
            <p className="text-sm text-slate-500 dark:text-slate-400">Version 1.0.0</p>
            <p className="text-xs text-slate-400 dark:text-slate-500 mt-2">
              Secure personal safety documentation
            </p>
          </div>
        </Card>

        <div className="pb-6">
          <Button 
            variant="outline" 
            className="w-full text-red-600 border-red-200 hover:bg-red-50 dark:text-red-400 dark:border-red-800 dark:hover:bg-red-900/20"
          >
            Sign Out
          </Button>
        </div>
      </div>
    </div>
  );
}