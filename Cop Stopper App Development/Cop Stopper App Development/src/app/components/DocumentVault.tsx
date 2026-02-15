import { Search, User, Lock, FileText, Shield, Car, File } from 'lucide-react';
import exampleImage from 'figma:asset/b39e80524beadd298106b3e800fb7e80ab210750.png';

interface Document {
  id: string;
  title: string;
  subtitle: string;
  icon: any;
  locked: boolean;
  image?: string;
}

export default function DocumentVault() {
  const documents: Document[] = [
    {
      id: '1',
      title: "Driver's License",
      subtitle: "Expires Sep 2025",
      icon: Car,
      locked: true,
      image: exampleImage,
    },
    {
      id: '2',
      title: "Traffic Stop #402",
      subtitle: "Oct 14, 2023 • 2:43p",
      icon: FileText,
      locked: true,
    },
    {
      id: '3',
      title: "Atty. J. Morgan",
      subtitle: "Contact Card",
      icon: User,
      locked: true,
    },
    {
      id: '4',
      title: "Insurance Policy",
      subtitle: "Active",
      icon: Shield,
      locked: true,
    },
  ];

  return (
    <div className="min-h-screen bg-[#0a0a0a] text-white pb-20">
      {/* Header */}
      <div className="flex items-center justify-between p-4">
        <div className="flex items-center gap-2">
          <Lock className="text-blue-500" size={20} />
          <h1 className="text-xl font-bold">Document Vault</h1>
        </div>
        <button className="p-2">
          <Search className="text-white" size={20} />
        </button>
        <button className="w-10 h-10 rounded-full bg-orange-400"></button>
      </div>

      {/* Present Credentials Card */}
      <div className="mx-4 mt-4 bg-gradient-to-r from-blue-600 to-blue-500 rounded-2xl p-4 flex items-center justify-between">
        <div>
          <h2 className="text-lg font-bold">Present Credentials</h2>
          <p className="text-sm text-blue-100">Tap to display active ID</p>
        </div>
        <div className="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center">
          <FileText className="text-white" size={24} />
        </div>
      </div>

      {/* Vault Status */}
      <div className="mx-4 mt-4 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Lock className="text-green-500" size={16} />
          <span className="text-sm">Vault Status</span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-2 h-2 rounded-full bg-green-500"></div>
          <span className="text-sm text-green-500">Encrypted</span>
        </div>
      </div>

      {/* Categories */}
      <div className="mx-4 mt-6">
        <h3 className="text-xs text-gray-400 mb-3">CATEGORIES</h3>
        <div className="flex gap-2 overflow-x-auto pb-2">
          <button className="px-4 py-2 bg-blue-500 rounded-full text-sm whitespace-nowrap flex items-center gap-2">
            <FileText size={16} />
            Recordings
          </button>
          <button className="px-4 py-2 bg-[#1a1a1a] rounded-full text-sm whitespace-nowrap flex items-center gap-2">
            <Car size={16} />
            License & ID
          </button>
          <button className="px-4 py-2 bg-[#1a1a1a] rounded-full text-sm whitespace-nowrap flex items-center gap-2">
            <User size={16} />
            Contacts
          </button>
        </div>
      </div>

      {/* Recent Files */}
      <div className="mx-4 mt-6">
        <div className="flex justify-between items-center mb-3">
          <h3 className="text-xs text-gray-400">RECENT FILES</h3>
          <button className="text-blue-500 text-sm">View All</button>
        </div>

        <div className="grid grid-cols-2 gap-3">
          {documents.map((doc) => {
            const Icon = doc.icon;
            return (
              <div
                key={doc.id}
                className="bg-[#1a1a1a] rounded-2xl border border-gray-800 overflow-hidden relative"
              >
                {doc.image ? (
                  <div className="aspect-[3/4] bg-gray-800 relative">
                    <img src={doc.image} alt={doc.title} className="w-full h-full object-cover" />
                  </div>
                ) : (
                  <div className="aspect-[3/4] bg-gray-800 flex items-center justify-center">
                    <Icon className="text-gray-600" size={48} />
                  </div>
                )}
                
                {doc.locked && (
                  <div className="absolute top-2 right-2 w-6 h-6 rounded-full bg-black/50 backdrop-blur-sm flex items-center justify-center">
                    <Lock className="text-white" size={14} />
                  </div>
                )}
                
                <div className="p-3">
                  <p className="font-medium text-sm">{doc.title}</p>
                  <p className="text-xs text-gray-400">{doc.subtitle}</p>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Add Button */}
      <button className="fixed bottom-24 right-6 w-14 h-14 rounded-full bg-blue-500 flex items-center justify-center shadow-lg shadow-blue-500/50">
        <span className="text-2xl text-white">+</span>
      </button>
    </div>
  );
}
