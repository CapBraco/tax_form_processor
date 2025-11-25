'use client'

import { useEffect, useState, Dispatch, SetStateAction } from 'react'
import { getDocumentsStats } from '@/lib/api'
import UploadSection from './UploadSection'
import DocumentsSection from './DocumentsSection'
import Form103Section from './Form103Section'
import Form104Section from './Form104Section'
import ClientDetail from './ClientDetail'
import { FileText, CheckCircle, Clock, AlertCircle } from 'lucide-react'

interface DashboardProps {
  activeSection: string
  onNavigate: Dispatch<SetStateAction<string>>
  selectedClient: string | null
  onClientSelect: (razonSocial: string) => void
}

export default function Dashboard({ activeSection, onNavigate, selectedClient, onClientSelect }: DashboardProps) {
  const [refreshTrigger, setRefreshTrigger] = useState(0)
  const [stats, setStats] = useState<any>(null)
  const [loading, setLoading] = useState(true)

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
    loadStats() // Refresh stats after upload
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
    // CLIENT DETAIL VIEW - Show when client is selected
    if (activeSection === 'clientes' && selectedClient) {
      return <ClientDetail razonSocial={selectedClient} />
    }

    // Show message if clientes section but no client selected
    if (activeSection === 'clientes' && !selectedClient) {
      return (
        <div className="bg-white rounded-lg shadow p-12 text-center">
          <div className="text-gray-400 mb-4">
            <FileText className="w-16 h-16 mx-auto" />
          </div>
          <h3 className="text-lg font-semibold text-gray-900 mb-2">
            Selecciona un Cliente
          </h3>
          <p className="text-gray-600">
            Elige un cliente de la barra lateral para ver sus documentos
          </p>
        </div>
      )
    }

    // OTHER SECTIONS
    switch (activeSection) {
      case 'upload':
        return <UploadSection onUploadSuccess={handleUploadSuccess} />
      
      case 'documents':
        return <DocumentsSection refreshTrigger={refreshTrigger} />
      
      case 'form103':
        return <Form103Section />
      
      case 'form104':
        return <Form104Section />
      
      case 'dashboard':
      default:
        return <DashboardHome stats={stats} onNavigate={onNavigate} />
    }
  }

  return (
    <div className="space-y-6">
      {/* Debug info in development */}
      {process.env.NODE_ENV === 'development' && (
        <div className="bg-gray-100 border border-gray-300 rounded-lg p-3 text-xs font-mono">
          <details>
            <summary className="cursor-pointer font-semibold text-gray-700">
              🐛 Debug Info (Development Only)
            </summary>
            <div className="mt-2 space-y-1 text-gray-600">
              <div>Active Section: <span className="font-bold">{activeSection}</span></div>
              <div>Selected Client: <span className="font-bold">{selectedClient || 'none'}</span></div>
              <div>Stats Loaded: <span className="font-bold">{stats ? 'Yes' : 'No'}</span></div>
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
}

function DashboardHome({ stats, onNavigate }: DashboardHomeProps) {
  const statCards = [
    { 
      title: 'Total Documents', 
      value: stats?.total_documents || 0, 
      icon: FileText, 
      bgColor: 'bg-blue-50', 
      textColor: 'text-blue-600', 
      onClick: () => onNavigate('documents') 
    },
    { 
      title: 'Completed', 
      value: stats?.by_status?.completed || 0, 
      icon: CheckCircle, 
      bgColor: 'bg-green-50', 
      textColor: 'text-green-600', 
      onClick: () => onNavigate('documents') 
    },
    { 
      title: 'Processing', 
      value: stats?.by_status?.processing || 0, 
      icon: Clock, 
      bgColor: 'bg-yellow-50', 
      textColor: 'text-yellow-600', 
      onClick: () => onNavigate('documents') 
    },
    { 
      title: 'Failed', 
      value: stats?.by_status?.failed || 0, 
      icon: AlertCircle, 
      bgColor: 'bg-red-50', 
      textColor: 'text-red-600', 
      onClick: () => onNavigate('documents') 
    },
  ]

  return (
    <div className="space-y-6">
      {/* Welcome Section */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-lg shadow-lg p-6 text-white">
        <h1 className="text-3xl font-bold mb-2">Tax Forms Dashboard</h1>
        <p className="text-blue-100">Gestiona y procesa tus formularios 103 y 104</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {statCards.map((card, index) => {
          const Icon = card.icon
          return (
            <div
              key={index}
              onClick={card.onClick}
              className="bg-white rounded-lg shadow p-6 cursor-pointer hover:shadow-lg transition-shadow"
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm text-gray-600 mb-1">{card.title}</p>
                  <p className="text-3xl font-bold text-gray-900">{card.value}</p>
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
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-4">Acciones Rápidas</h2>
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
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Actividad Reciente</h2>
          <div className="space-y-3">
            {stats.recent_uploads.slice(0, 5).map((upload: any, index: number) => (
              <div key={index} className="flex items-center justify-between py-2 border-b last:border-0">
                <div className="flex items-center gap-3">
                  <FileText className="w-4 h-4 text-gray-400" />
                  <div>
                    <p className="text-sm font-medium text-gray-900">{upload.filename}</p>
                    <p className="text-xs text-gray-500">{upload.razon_social}</p>
                  </div>
                </div>
                <span className="text-xs text-gray-500">{upload.created_at}</span>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
