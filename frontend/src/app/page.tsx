'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { useAuth } from '@/contexts/AuthContext'
import Sidebar from '@/components/Sidebar'
import Dashboard from '@/components/Dashboard'

export default function Home() {
  // ✅ MOVE ALL HOOKS TO THE TOP - Before any conditionals
  const [activeSection, setActiveSection] = useState('dashboard')
  const [selectedClient, setSelectedClient] = useState<string | null>(null)
  const [clientsRefreshTrigger, setClientsRefreshTrigger] = useState(0)
  
  const { isAuthenticated, isLoading } = useAuth()
  const router = useRouter()

  // ✅ Auth check AFTER hooks are declared
  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.push('/login')
    }
  }, [isAuthenticated, isLoading, router])

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

  // ✅ Handle document uploads
  const handleDocumentsUploaded = () => {
    console.log('📤 Documents uploaded, refreshing clients list...')
    setClientsRefreshTrigger(prev => prev + 1)
  }

  // ✅ Show loading AFTER hooks (conditional rendering at the end)
  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-100 dark:bg-gray-900">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  // ✅ Don't render if not authenticated (after hooks)
  if (!isAuthenticated) {
    return null
  }

  return (
    <div className="flex h-screen bg-gray-100 dark:bg-gray-900">
      {/* Sidebar */}
      <Sidebar 
        activeSection={activeSection}
        setActiveSection={handleSectionChange}
        selectedClient={selectedClient}
        onClientSelect={handleClientSelect}
        clientsRefreshTrigger={clientsRefreshTrigger}
      />

      {/* Main Content */}
      <main className="flex-1 overflow-y-auto">
        <div className="p-6">
          <Dashboard
            activeSection={activeSection}
            onNavigate={handleSectionChange}
            selectedClient={selectedClient}
            onClientSelect={handleClientSelect}
            onDocumentsUploaded={handleDocumentsUploaded}
          />
        </div>
      </main>

      {/* Debug Display - Only in Development */}
      {process.env.NODE_ENV === 'development' && (
        <div className="fixed bottom-4 right-4 bg-black dark:bg-gray-800 text-white p-3 rounded-lg shadow-lg text-xs font-mono">
          <div className="font-bold mb-1">🐛 Debug Info</div>
          <div>Section: <span className="text-blue-300">{activeSection}</span></div>
          <div>Client: <span className="text-green-300">{selectedClient || 'none'}</span></div>
          <div>Auth: <span className="text-yellow-300">{isAuthenticated ? 'Yes' : 'No'}</span></div>
        </div>
      )}
    </div>
  )
}