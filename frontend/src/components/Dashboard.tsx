'use client'

import { useEffect, useState, Dispatch, SetStateAction } from 'react'
import { getDocumentsStats } from '@/lib/api'
import { useAuth } from '@/contexts/AuthContext'
import UploadSection from './UploadSection'
import DocumentsSection from './DocumentsSection'
import Form103Section from './Form103Section'
import Form104Section from './Form104Section'
import ClientDetail from './ClientDetail'
import { FileText, CheckCircle, Clock, AlertCircle, LogIn, Lock } from 'lucide-react'
import { useRouter } from 'next/navigation'

interface DashboardProps {
  activeSection: string
  onNavigate: Dispatch<SetStateAction<string>>
  selectedClient: string | null
  onClientSelect: (razonSocial: string) => void
  onDocumentsUploaded?: () => void
}

export default function Dashboard({ activeSection, onNavigate, selectedClient, onClientSelect, onDocumentsUploaded }: DashboardProps) {
  const [refreshTrigger, setRefreshTrigger] = useState(0)
  const [stats, setStats] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const { isAuthenticated } = useAuth()
  const router = useRouter()

  useEffect(() => {
    loadStats()
  }, [])

  const loadStats = async () => {
    try {
      const data = await getDocumentsStats()
      setStats(data)
    } catch (error) {
      console.error('Error loading stats:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleUploadSuccess = () => {
    setRefreshTrigger(prev => prev + 1)
    loadStats()
    onDocumentsUploaded?.() 
    onNavigate('documents')
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  // Render main content based on active section
  const renderMainContent = () => {
    // ✅ CLIENTES SECTION - Require Authentication
    if (activeSection === 'clientes') {
      if (!isAuthenticated) {
        return (
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-12 text-center">
            <Lock className="w-16 h-16 mx-auto mb-4 text-blue-600" />
            <h3 className="text-2xl font-semibold text-gray-900 dark:text-gray-100 mb-2">
              Autenticación Requerida
            </h3>
            <p className="text-gray-600 dark:text-gray-400 mb-6">
              La sección de clientes está disponible solo para usuarios registrados
            </p>
            <button
              onClick={() => router.push('/login?redirect=clientes')}
              className="inline-flex items-center gap-2 px-6 py-3 
                bg-blue-600 text-white rounded-lg 
                hover:bg-blue-700 transition-colors font-medium"
            >
              <LogIn size={20} />
              Iniciar Sesión
            </button>
            <div className="mt-4">
              <p className="text-sm text-gray-500 dark:text-gray-400">
                ¿No tienes cuenta?{' '}
                <button
                  onClick={() => router.push('/register')}
                  className="text-blue-600 hover:text-blue-700 font-medium"
                >
                  Regístrate aquí
                </button>
              </p>
            </div>
          </div>
        )
      }

      // CLIENT DETAIL VIEW - Show when client is selected
      if (selectedClient) {
        return <ClientDetail razonSocial={selectedClient} />
      }

      // Show message if clientes section but no client selected
      return (
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-12 text-center">
          <div className="text-gray-400 mb-4">
            <FileText className="w-16 h-16 mx-auto" />
          </div>
          <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-2">
            Selecciona un Cliente
          </h3>
          <p className="text-gray-600 dark:text-gray-400">
            Elige un cliente de la barra lateral para ver sus documentos
          </p>
        </div>
      )
    }

    // OTHER SECTIONS - Available to guests
    switch (activeSection) {
      case 'upload':
        return <UploadSection onUploadSuccess={onDocumentsUploaded} />
      
      case 'documents':
        return <DocumentsSection refreshTrigger={refreshTrigger} />
      
      case 'form103':
        return <Form103Section />
      
      case 'form104':
        return <Form104Section />
      
      case 'dashboard':
      default:
        return <DashboardHome stats={stats} onNavigate={onNavigate} isAuthenticated={isAuthenticated} />
    }
  }

  return (
    <div className="space-y-6">
      {/* ✅ Guest Mode Banner - Show for non-authenticated users */}
      {!isAuthenticated && (
        <div className="bg-gradient-to-r from-blue-500 to-blue-600 rounded-lg shadow-lg p-4 text-white">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="bg-white/20 p-2 rounded-lg">
                <FileText className="w-6 h-6" />
              </div>
              <div>
                <p className="font-semibold">Modo Invitado</p>
                <p className="text-sm text-blue-100">
                  Puedes procesar hasta <strong>5 documentos</strong> sin registrarte
                </p>
              </div>
            </div>
            <button
              onClick={() => router.push('/register')}
              className="px-4 py-2 bg-white text-blue-600 rounded-lg 
                hover:bg-blue-50 transition-colors font-medium text-sm
                whitespace-nowrap"
            >
              Crear Cuenta Gratis
            </button>
          </div>
        </div>
      )}

      {/* Debug info in development */}
      {process.env.NODE_ENV === 'development' && (
        <div className="bg-gray-100 dark:bg-gray-800 border border-gray-300 dark:border-gray-700 rounded-lg p-3 text-xs font-mono">
          <details>
            <summary className="cursor-pointer font-semibold text-gray-700 dark:text-gray-300">
              🐛 Debug Info (Development Only)
            </summary>
            <div className="mt-2 space-y-1 text-gray-600 dark:text-gray-400">
              <div>Active Section: <span className="font-bold">{activeSection}</span></div>
              <div>Selected Client: <span className="font-bold">{selectedClient || 'none'}</span></div>
              <div>Stats Loaded: <span className="font-bold">{stats ? 'Yes' : 'No'}</span></div>
              <div>Authenticated: <span className="font-bold">{isAuthenticated ? 'Yes' : 'Guest'}</span></div>
            </div>
          </details>
        </div>
      )}

      {/* Main content area */}
      {renderMainContent()}
    </div>
  )
}

// Separate component for dashboard home view
interface DashboardHomeProps {
  stats: any
  onNavigate: (section: string) => void
  isAuthenticated: boolean
}

function DashboardHome({ stats, onNavigate, isAuthenticated }: DashboardHomeProps) {
  const statCards = [
    { 
      title: 'Total Documents', 
      value: stats?.total_documents || 0, 
      icon: FileText, 
      bgColor: 'bg-blue-50 dark:bg-blue-900/20', 
      textColor: 'text-blue-600 dark:text-blue-400', 
      onClick: () => onNavigate('documents') 
    },
    { 
      title: 'Completed', 
      value: stats?.by_status?.completed || 0, 
      icon: CheckCircle, 
      bgColor: 'bg-green-50 dark:bg-green-900/20', 
      textColor: 'text-green-600 dark:text-green-400', 
      onClick: () => onNavigate('documents') 
    },
    { 
      title: 'Processing', 
      value: stats?.by_status?.processing || 0, 
      icon: Clock, 
      bgColor: 'bg-yellow-50 dark:bg-yellow-900/20', 
      textColor: 'text-yellow-600 dark:text-yellow-400', 
      onClick: () => onNavigate('documents') 
    },
    { 
      title: 'Failed', 
      value: stats?.by_status?.failed || 0, 
      icon: AlertCircle, 
      bgColor: 'bg-red-50 dark:bg-red-900/20', 
      textColor: 'text-red-600 dark:text-red-400', 
      onClick: () => onNavigate('documents') 
    },
  ]

  return (
    <div className="space-y-6">
      {/* Welcome Section */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-lg shadow-lg p-6 text-white">
        <h1 className="text-3xl font-bold mb-2">Tax Forms Dashboard</h1>
        <p className="text-blue-100">
          Gestiona y procesa tus formularios 103 y 104
          {!isAuthenticated && ' • Modo Invitado'}
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {statCards.map((card, index) => {
          const Icon = card.icon
          return (
            <div
              key={index}
              onClick={card.onClick}
              className="bg-white dark:bg-gray-800 rounded-lg shadow p-6 cursor-pointer hover:shadow-lg transition-shadow"
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-600 dark:text-gray-400 mb-1">{card.title}</p>
                  <p className="text-3xl font-bold text-gray-900 dark:text-gray-100">{card.value}</p>
                </div>
                <div className={`${card.bgColor} p-3 rounded-lg`}>
                  <Icon className={card.textColor} size={24} />
                </div>
              </div>
            </div>
          )
        })}
      </div>

      {/* Quick Actions */}
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Acciones Rápidas</h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button
            onClick={() => onNavigate('upload')}
            className="flex items-center justify-center gap-2 px-4 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            <FileText className="w-5 h-5" />
            Subir Documentos
          </button>
          <button
            onClick={() => onNavigate('form103')}
            className="flex items-center justify-center gap-2 px-4 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
          >
            <CheckCircle className="w-5 h-5" />
            Ver Form 103
          </button>
          <button
            onClick={() => onNavigate('form104')}
            className="flex items-center justify-center gap-2 px-4 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors"
          >
            <CheckCircle className="w-5 h-5" />
            Ver Form 104
          </button>
        </div>
      </div>

      {/* Recent Activity - Optional */}
      {stats?.recent_uploads && stats.recent_uploads.length > 0 && (
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Actividad Reciente</h2>
          <div className="space-y-3">
            {stats.recent_uploads.slice(0, 5).map((upload: any, index: number) => (
              <div key={index} className="flex items-center justify-between py-2 border-b border-gray-200 dark:border-gray-700 last:border-0">
                <div className="flex items-center gap-3">
                  <FileText className="w-4 h-4 text-gray-400" />
                  <div>
                    <p className="text-sm font-medium text-gray-900 dark:text-gray-100">{upload.filename}</p>
                    <p className="text-xs text-gray-500 dark:text-gray-400">{upload.razon_social}</p>
                  </div>
                </div>
                <span className="text-xs text-gray-500 dark:text-gray-400">{upload.created_at}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
