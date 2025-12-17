'use client'

import { useState, useEffect } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { Menu, X } from 'lucide-react'
import { useAuth } from '@/contexts/AuthContext'
import Sidebar from '@/components/Sidebar'
import Dashboard from '@/components/Dashboard'

export default function Home() {
  // ✅ MOVE ALL HOOKS TO THE TOP - Before any conditionals
  const [activeSection, setActiveSection] = useState('dashboard')
  const [selectedClient, setSelectedClient] = useState<string | null>(null)
  const [clientsRefreshTrigger, setClientsRefreshTrigger] = useState(0)
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false)
  
  const { isAuthenticated, isLoading } = useAuth()
  const router = useRouter()
  const searchParams = useSearchParams()

  // ✅ Handle OAuth redirect (Google OAuth callback)
  useEffect(() => {
    // Check if redirected from Google OAuth
    const urlParams = new URLSearchParams(window.location.search)
    const oauthSuccess = urlParams.get('oauth')
    
    if (oauthSuccess === 'success') {
      console.log('✅ OAuth login successful')
      
      // Remove oauth parameter from URL
      const newUrl = window.location.pathname
      window.history.replaceState({}, '', newUrl)
      
      // Force auth context to refresh
      window.location.reload()
    }
    
    // Check for OAuth errors
    const oauthError = urlParams.get('error')
    if (oauthError === 'oauth_failed') {
      console.error('❌ OAuth login failed')
      alert('Error al iniciar sesión con Google. Por favor intenta de nuevo.')
      
      // Remove error parameter from URL
      const newUrl = window.location.pathname
      window.history.replaceState({}, '', newUrl)
    }
  }, [])

  // Handle client selection from sidebar
  const handleClientSelect = (razonSocial: string) => {
    console.log('📍 Client selected:', razonSocial)
    
    // ✅ Check authentication before allowing client access
    if (!isAuthenticated) {
      router.push('/login?redirect=clientes')
      return
    }
    
    setSelectedClient(razonSocial)
    setActiveSection('clientes')
    setIsMobileSidebarOpen(false) // Close sidebar on mobile
  }

  // Handle section navigation
  const handleSectionChange = (section: string) => {
    console.log('🔀 Section changed to:', section)
    
    // ✅ Check authentication for Clientes section
    if (section === 'clientes' && !isAuthenticated) {
      router.push('/login?redirect=clientes')
      return
    }
    
    setActiveSection(section)
    setIsMobileSidebarOpen(false) // Close sidebar on mobile
    
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

  return (
    <div className="flex min-h-screen bg-gray-100 dark:bg-gray-900">
      {/* Mobile Menu Button */}
      <button
        onClick={() => setIsMobileSidebarOpen(!isMobileSidebarOpen)}
        className="lg:hidden fixed top-4 left-4 z-50 p-2 rounded-lg bg-white dark:bg-gray-800 
          shadow-lg border border-gray-200 dark:border-gray-700
          text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700
          transition-colors"
        aria-label="Toggle menu"
      >
        {isMobileSidebarOpen ? <X size={24} /> : <Menu size={24} />}
      </button>

      {/* Mobile Overlay */}
      {isMobileSidebarOpen && (
        <div
          className="lg:hidden fixed inset-0 bg-black bg-opacity-50 z-30"
          onClick={() => setIsMobileSidebarOpen(false)}
        />
      )}

      {/* Sidebar - Hidden on mobile unless toggled */}
      <div className={`
        fixed lg:sticky lg:top-0 inset-y-0 left-0 z-40 h-screen
        transform lg:transform-none transition-transform duration-300 ease-in-out
        ${isMobileSidebarOpen ? 'translate-x-0' : '-translate-x-full lg:translate-x-0'}
      `}>
        <Sidebar 
          activeSection={activeSection}
          setActiveSection={handleSectionChange}
          selectedClient={selectedClient}
          onClientSelect={handleClientSelect}
          clientsRefreshTrigger={clientsRefreshTrigger}
        />
      </div>

      {/* Main Content - WITH BACKGROUND COLOR */}
      <main className="flex-1 min-h-screen w-full lg:w-auto bg-gray-100 dark:bg-gray-900">
        {/* Add padding on mobile to account for the menu button */}
        <div className="p-6 pt-16 lg:pt-6">
          <Dashboard
            activeSection={activeSection}
            onNavigate={setActiveSection}
            selectedClient={selectedClient}
            onClientSelect={handleClientSelect}
            onDocumentsUploaded={handleDocumentsUploaded}
          />
        </div>
      </main>

      {/* Debug Display - Only in Development - FIXED POSITION */}
      {process.env.NODE_ENV === 'development' && (
        <div className="hidden lg:block fixed bottom-4 right-4 bg-black/90 dark:bg-gray-800/90 text-white p-3 rounded-lg shadow-lg text-xs font-mono z-10 backdrop-blur-sm">
          <div className="font-bold mb-1">🐛 Debug Info</div>
          <div>Section: <span className="text-blue-300">{activeSection}</span></div>
          <div>Client: <span className="text-green-300">{selectedClient || 'none'}</span></div>
          <div>Auth: <span className="text-yellow-300">{isAuthenticated ? 'Yes' : 'Guest'}</span></div>
        </div>
      )}
    </div>
  )
}