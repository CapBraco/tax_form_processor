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
    <div className="space-y-4 max-w-7xl mx-auto">
      {/* Welcome Section - Compact */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-700 dark:from-blue-700 dark:to-blue-800 rounded-lg shadow-lg p-4 text-white">
        <h1 className="text-2xl font-bold mb-1">Tax Forms Dashboard</h1>
        <p className="text-sm text-blue-100">
          Gestiona y procesa tus formularios 103 y 104{!isAuthenticated && ' • Modo Invitado'}
        </p>
      </div>

      {/* Stats Grid - Compact */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        {statCards.map((card, index) => {
          const Icon = card.icon
          return (
            <div
              key={index}
              onClick={card.onClick}
              className="bg-white dark:bg-gray-800 rounded-lg shadow p-4 cursor-pointer hover:shadow-lg transition-shadow"
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-xs text-gray-600 dark:text-gray-400 mb-1">{card.title}</p>
                  <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">{card.value}</p>
                </div>
                <div className={`${card.bgColor} p-2 rounded-lg`}>
                  <Icon className={card.textColor} size={20} />
                </div>
              </div>
            </div>
          )
        })}
      </div>

      {/* ✅ NEW LAYOUT: Forms Information Section - Centered & Compact */}
      <div className="bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-gray-800 dark:to-gray-700 rounded-lg shadow-lg p-6">
        <div className="text-center mb-4">
          <h2 className="text-xl font-bold text-gray-900 dark:text-gray-100 mb-1">
            📄 Formularios Soportados
          </h2>
          <p className="text-sm text-gray-600 dark:text-gray-300">
            Procesa automáticamente formularios oficiales del SRI (Ecuador)
          </p>
        </div>
        
        {/* Forms Illustration - Centered & Smaller */}
        <div className="flex justify-center items-center my-4">
          <img 
            src="/forms-illustration.png" 
            alt="Form 103 y Form 104 - SRI Ecuador" 
            className="max-w-full h-auto rounded-lg shadow-xl"
            style={{ maxHeight: '280px' }}
          />
        </div>

        {/* Quick Actions - Below Illustration */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3 mt-4 mb-4">
          <button
            onClick={() => onNavigate('upload')}
            className="flex items-center justify-center gap-2 px-4 py-2.5 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm font-medium"
          >
            <FileText className="w-4 h-4" />
            Subir Documentos
          </button>
          <button
            onClick={() => onNavigate('form103')}
            className="flex items-center justify-center gap-2 px-4 py-2.5 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors text-sm font-medium"
          >
            <CheckCircle className="w-4 h-4" />
            Ver Form 103
          </button>
          <button
            onClick={() => onNavigate('form104')}
            className="flex items-center justify-center gap-2 px-4 py-2.5 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors text-sm font-medium"
          >
            <CheckCircle className="w-4 h-4" />
            Ver Form 104
          </button>
        </div>

        {/* Form Info Cards - Compact */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {/* Form 103 Info */}
          <div className="bg-white dark:bg-gray-800 rounded-lg p-4 shadow-md border-l-4 border-blue-500">
            <div className="flex items-center gap-2 mb-2">
              <div className="bg-blue-100 dark:bg-blue-900/30 p-1.5 rounded">
                <FileText className="w-4 h-4 text-blue-600 dark:text-blue-400" />
              </div>
              <h3 className="text-sm font-semibold text-gray-900 dark:text-gray-100">Form 103</h3>
            </div>
            <p className="text-xs text-gray-700 dark:text-gray-300 font-medium mb-1">
              Declaración de Retenciones en la Fuente
            </p>
            <ul className="text-xs text-gray-600 dark:text-gray-400 space-y-0.5 ml-3">
              <li>• Retenciones de impuesto a la renta</li>
              <li>• Base imponible y valores retenidos</li>
            </ul>
          </div>

          {/* Form 104 Info */}
          <div className="bg-white dark:bg-gray-800 rounded-lg p-4 shadow-md border-l-4 border-purple-500">
            <div className="flex items-center gap-2 mb-2">
              <div className="bg-purple-100 dark:bg-purple-900/30 p-1.5 rounded">
                <FileText className="w-4 h-4 text-purple-600 dark:text-purple-400" />
              </div>
              <h3 className="text-sm font-semibold text-gray-900 dark:text-gray-100">Form 104</h3>
            </div>
            <p className="text-xs text-gray-700 dark:text-gray-300 font-medium mb-1">
              Declaración de IVA
            </p>
            <ul className="text-xs text-gray-600 dark:text-gray-400 space-y-0.5 ml-3">
              <li>• Ventas, compras y exportaciones</li>
              <li>• Crédito tributario y retenciones</li>
            </ul>
          </div>
        </div>

        <div className="mt-4 text-center">
          <p className="text-xs text-gray-600 dark:text-gray-400">
            💡 <strong>Tip:</strong> Solo sube archivos PDF oficiales del SRI
          </p>
        </div>
      </div>

      {/* Recent Activity - Compact & Optional */}
      {stats?.recent_uploads && stats.recent_uploads.length > 0 && (
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-4">
          <h2 className="text-sm font-semibold text-gray-900 dark:text-gray-100 mb-3">Actividad Reciente</h2>
          <div className="space-y-2">
            {stats.recent_uploads.slice(0, 3).map((upload: any, index: number) => (
              <div key={index} className="flex items-center justify-between py-1.5 border-b border-gray-200 dark:border-gray-700 last:border-0">
                <div className="flex items-center gap-2">
                  <FileText className="w-3.5 h-3.5 text-gray-400 flex-shrink-0" />
                  <div className="min-w-0">
                    <p className="text-xs font-medium text-gray-900 dark:text-gray-100 truncate">{upload.filename}</p>
                    <p className="text-xs text-gray-500 dark:text-gray-400 truncate">{upload.razon_social}</p>
                  </div>
                </div>
                <span className="text-xs text-gray-500 dark:text-gray-400 flex-shrink-0">{upload.created_at}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
