'use client'

import { 
  LayoutDashboard, 
  Upload, 
  FileText,
  FileCheck,
  Calculator
} from 'lucide-react'
import ClientesSection from './ClientesSection'
import ThemeToggle from './ThemeToggle'

interface SidebarProps {
  activeSection: string
  setActiveSection: (section: string) => void
  selectedClient: string | null
  onClientSelect: (razonSocial: string) => void
}

export default function Sidebar({ 
  activeSection, 
  setActiveSection,
  selectedClient,
  onClientSelect
}: SidebarProps) {
  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
    { id: 'upload', label: 'Upload', icon: Upload },
    { id: 'documents', label: 'All Documents', icon: FileText },
    { id: 'form103', label: 'Form 103', icon: FileCheck, color: 'text-blue-600' },
    { id: 'form104', label: 'Form 104', icon: Calculator, color: 'text-purple-600' },
  ]

  return (
    <aside className="w-64 bg-white dark:bg-gray-800 shadow-lg flex flex-col">
      {/* Logo/Header */}
      <div className="p-6 border-b border-gray-200 dark:border-gray-700">
        <h2 className="text-xl font-bold text-gray-800 dark:text-gray-100">Tax Forms</h2>
        <p className="text-sm text-gray-500 dark:text-gray-400">Form 103 & 104 Processor</p>
      </div>

      {/* Navigation - Scrollable */}
      <nav className="flex-1 overflow-y-auto p-4">
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
                      : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
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

        {/* Clientes Section */}
        <div className="border-t border-gray-200 dark:border-gray-700 mt-4 pt-4">
          <div className="px-4 mb-2">
            <h3 className="text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wider">
              👥 Clientes
            </h3>
          </div>
          <ClientesSection 
            onClientSelect={onClientSelect}
            selectedClient={selectedClient}
          />
        </div>

        {/* Forms Legend (colors only) */}
        <div className="border-t border-gray-200 dark:border-gray-700 mt-4 pt-4">
          <div className="mt-6 p-4 bg-gray-50 dark:bg-gray-900 rounded-lg">
            <p className="text-xs font-semibold text-gray-700 dark:text-gray-300 mb-2">Form Types:</p>
            <div className="space-y-1 text-xs text-gray-600 dark:text-gray-400">
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
        </div>
      </nav>

      {/* Footer with Version and Theme Toggle */}
      <div className="border-t border-gray-200 dark:border-gray-700 p-4 space-y-3">
        <div className="text-sm text-gray-500 dark:text-gray-400">
          <p className="font-medium">Enhanced PDF Processor</p>
          <p className="text-xs mt-1">v2.0.0 - With Form Parsing</p>
        </div>
        
        {/* ✅ ThemeToggle HERE - Inside Sidebar */}
        <ThemeToggle />
      </div>
    </aside>
  )
}
