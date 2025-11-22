'use client'

import { 
  LayoutDashboard, 
  Upload, 
  FileText,
  FileCheck,
  Calculator
} from 'lucide-react'

interface SidebarProps {
  activeSection: string
  setActiveSection: (section: string) => void
}

export default function Sidebar({ activeSection, setActiveSection }: SidebarProps) {
  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
    { id: 'upload', label: 'Upload', icon: Upload },
    { id: 'documents', label: 'All Documents', icon: FileText },
    { id: 'form103', label: 'Form 103', icon: FileCheck, color: 'text-blue-600' },
    { id: 'form104', label: 'Form 104', icon: Calculator, color: 'text-purple-600' },
  ]

  return (
    <aside className="w-64 bg-white shadow-lg">
      {/* Logo/Header */}
      <div className="p-6 border-b">
        <h2 className="text-xl font-bold text-gray-800">Tax Forms</h2>
        <p className="text-sm text-gray-500">Form 103 & 104 Processor</p>
      </div>

      {/* Navigation */}
      <nav className="p-4">
        <ul className="space-y-2">
          {menuItems.map((item) => {
            const Icon = item.icon
            const isActive = activeSection === item.id
            
            return (
              <li key={item.id}>
                <button
                  onClick={() => setActiveSection(item.id)}
                  className={`
                    w-full flex items-center space-x-3 px-4 py-3 rounded-lg
                    transition-colors duration-200
                    ${isActive 
                      ? 'bg-blue-600 text-white' 
                      : 'text-gray-700 hover:bg-gray-100'
                    }
                  `}
                >
                  <Icon size={20} className={!isActive && item.color ? item.color : ''} />
                  <span className="font-medium">{item.label}</span>
                </button>
              </li>
            )
          })}
        </ul>

        {/* Forms Legend */}
        <div className="mt-6 p-4 bg-gray-50 rounded-lg">
          <p className="text-xs font-semibold text-gray-700 mb-2">Form Types:</p>
          <div className="space-y-1 text-xs text-gray-600">
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 rounded bg-blue-500"></div>
              <span>Form 103 - Retenciones</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 rounded bg-purple-500"></div>
              <span>Form 104 - IVA</span>
            </div>
          </div>
        </div>
      </nav>

      {/* Footer */}
      <div className="absolute bottom-0 w-64 p-4 border-t">
        <div className="text-sm text-gray-500">
          <p>Enhanced PDF Processor</p>
          <p className="text-xs mt-1">v2.0.0 - With Form Parsing</p>
        </div>
      </div>
    </aside>
  )
}
