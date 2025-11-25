'use client'

import { useState } from 'react'
import Sidebar from '@/components/Sidebar'
import Dashboard from '@/components/Dashboard'

export default function Home() {
  const [activeSection, setActiveSection] = useState('dashboard')
  const [selectedClient, setSelectedClient] = useState<string | null>(null)

  // Handle client selection from sidebar
  const handleClientSelect = (razonSocial: string) => {
    console.log('📍 Client selected:', razonSocial)
    setSelectedClient(razonSocial)
    setActiveSection('clientes')
  }

  // Handle section navigation
  const handleSectionChange = (section: string) => {
    console.log('🔀 Section changed to:', section)
    setActiveSection(section)
    
    // Reset selected client when navigating away from client section
    if (section !== 'clientes') {
      setSelectedClient(null)
    }
  }

  return (
    <div className="flex h-screen bg-gray-100 dark:bg-gray-900">
      {/* Sidebar - ThemeToggle is now INSIDE Sidebar component */}
      <Sidebar 
        activeSection={activeSection}
        setActiveSection={handleSectionChange}
        selectedClient={selectedClient}
        onClientSelect={handleClientSelect}
      />

      {/* Main Content */}
      <main className="flex-1 overflow-y-auto">
        <div className="p-6">
          <Dashboard
            activeSection={activeSection}
            onNavigate={handleSectionChange}
            selectedClient={selectedClient}
            onClientSelect={handleClientSelect}
          />
        </div>
      </main>

      {/* Debug Display - Only in Development */}
      {process.env.NODE_ENV === 'development' && (
        <div className="fixed bottom-4 right-4 bg-black dark:bg-gray-800 text-white p-3 rounded-lg shadow-lg text-xs font-mono">
          <div className="font-bold mb-1">🐛 Debug Info</div>
          <div>Section: <span className="text-blue-300">{activeSection}</span></div>
          <div>Client: <span className="text-green-300">{selectedClient || 'none'}</span></div>
        </div>
      )}
    </div>
  )
}
