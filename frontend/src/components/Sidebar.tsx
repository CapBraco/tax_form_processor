'use client'

import { 
  LayoutDashboard, 
  Upload, 
  FileText,
  FileCheck,
  Calculator,
  LogOut,
  Settings,
  KeyRound  // ✅ ADD THIS
} from 'lucide-react'
import { useState } from 'react'  // ✅ ADD THIS
import Link from 'next/link'  // ✅ ADD THIS
import ClientesSection from './ClientesSection'
import ThemeToggle from './ThemeToggle'
import { useAuth } from '@/contexts/AuthContext'

interface SidebarProps {
  activeSection: string
  setActiveSection: (section: string) => void
  selectedClient: string | null
  onClientSelect: (razonSocial: string) => void
  clientsRefreshTrigger?: number
}

export default function Sidebar({ 
  activeSection, 
  setActiveSection,
  selectedClient,
  onClientSelect,
  clientsRefreshTrigger = 0
}: SidebarProps) {
  const { logout, user } = useAuth()
  const [showUserMenu, setShowUserMenu] = useState(false)  // ✅ ADD THIS

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
            refreshTrigger={clientsRefreshTrigger}
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

      {/* Footer with User Info, Theme Toggle, and Logout */}
      <div className="border-t border-gray-200 dark:border-gray-700 p-4 space-y-3">
        {/* ✅ NEW: User Profile with Dropdown */}
        {user && (
          <div className="relative">
            <button
              onClick={() => setShowUserMenu(!showUserMenu)}
              className="w-full flex items-center gap-3 px-3 py-2 rounded-lg
                hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors
                text-left"
            >
              <div className="w-10 h-10 rounded-full bg-blue-100 dark:bg-blue-900 
                flex items-center justify-center flex-shrink-0">
                <span className="text-blue-600 dark:text-blue-400 font-semibold text-sm">
                  {user.username.substring(0, 2).toUpperCase()}
                </span>
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900 dark:text-gray-100 truncate">
                  {user.username}
                </p>
                <p className="text-xs text-gray-500 dark:text-gray-400 truncate">
                  {user.email}
                </p>
              </div>
              <Settings className="w-4 h-4 text-gray-400 flex-shrink-0" />
            </button>

            {/* ✅ Dropdown Menu */}
            {showUserMenu && (
              <>
                {/* Backdrop to close menu */}
                <div 
                  className="fixed inset-0 z-10" 
                  onClick={() => setShowUserMenu(false)}
                />
                
                {/* Menu */}
                <div className="absolute bottom-full left-0 right-0 mb-2 bg-white dark:bg-gray-800 
                  rounded-lg shadow-lg border border-gray-200 dark:border-gray-700 overflow-hidden z-20">
                  <Link
                    href="/change-password"
                    className="flex items-center gap-3 px-4 py-3 text-sm
                      text-gray-700 dark:text-gray-300
                      hover:bg-gray-100 dark:hover:bg-gray-700
                      transition-colors"
                    onClick={() => setShowUserMenu(false)}
                  >
                    <KeyRound className="w-4 h-4" />
                    Cambiar Contraseña
                  </Link>
                  
                  <div className="border-t border-gray-200 dark:border-gray-700" />
                  
                  <button
                    onClick={() => {
                      setShowUserMenu(false)
                      logout()
                    }}
                    className="w-full flex items-center gap-3 px-4 py-3 text-sm
                      text-red-600 dark:text-red-400
                      hover:bg-red-50 dark:hover:bg-red-900/20
                      transition-colors"
                  >
                    <LogOut className="w-4 h-4" />
                    Cerrar Sesión
                  </button>
                </div>
              </>
            )}
          </div>
        )}
        
        <div className="text-sm text-gray-500 dark:text-gray-400">
          <p className="font-medium">Enhanced PDF Processor</p>
          <p className="text-xs mt-1">v2.0.0 - With Form Parsing</p>
        </div>
        
        <ThemeToggle />
      </div>
    </aside>
  )
}