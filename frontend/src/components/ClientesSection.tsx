'use client'

import { useState, useEffect } from 'react'
import { ChevronDown, ChevronRight, User, FileText, Calendar, AlertTriangle, Search, X } from 'lucide-react'
import { getAllClients } from '@/lib/api'
import type { ClientSummary } from '@/types'

interface ClientesSectionProps {
  onClientSelect: (razonSocial: string) => void
  selectedClient: string | null
  refreshTrigger?: number
}

export default function ClientesSection({ 
  onClientSelect, 
  selectedClient,
  refreshTrigger = 0
}: ClientesSectionProps) {
  const [clients, setClients] = useState<ClientSummary[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [expandedClient, setExpandedClient] = useState<string | null>(null)
  const [searchQuery, setSearchQuery] = useState('')
  const [showRefreshIndicator, setShowRefreshIndicator] = useState(false)  // ✅ NEW: Visual feedback

  // ✅ UPDATED: Now refetches when refreshTrigger changes
  useEffect(() => {
    loadClients()
  }, [refreshTrigger])

  const loadClients = async () => {
    try {
      setLoading(true)
      setError(null)
      
      // ✅ Show refresh indicator if this is a refresh (not initial load)
      if (refreshTrigger > 0) {
        console.log(`🔄 Refreshing clients list (trigger #${refreshTrigger})...`)
        setShowRefreshIndicator(true)
      }
      
      const data = await getAllClients()
      console.log('✅ Clients loaded:', data.length)
      setClients(data)
      
      // ✅ Hide refresh indicator after 2 seconds
      if (refreshTrigger > 0) {
        setTimeout(() => setShowRefreshIndicator(false), 2000)
      }
    } catch (err) {
      console.error('❌ Error loading clients:', err)
      setError('Error al cargar clientes')
    } finally {
      setLoading(false)
    }
  }

  const toggleClient = (razonSocial: string) => {
    if (expandedClient === razonSocial) {
      setExpandedClient(null)
    } else {
      setExpandedClient(razonSocial)
      onClientSelect(razonSocial)
    }
  }

  const filteredClients = clients.filter((client) => {
    if (!searchQuery.trim()) return true
    const query = searchQuery.toLowerCase()
    return client.razon_social.toLowerCase().includes(query)
  })

  const clearSearch = () => {
    setSearchQuery('')
  }

  if (loading && refreshTrigger === 0) {  // ✅ Only show skeleton on initial load
    return (
      <div className="p-4">
        <div className="animate-pulse space-y-3">
          <div className="h-12 bg-gray-200 dark:bg-gray-700 rounded"></div>
          <div className="h-12 bg-gray-200 dark:bg-gray-700 rounded"></div>
          <div className="h-12 bg-gray-200 dark:bg-gray-700 rounded"></div>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="p-4">
        <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-3 flex items-start gap-2">
          <AlertTriangle className="w-5 h-5 text-red-500 dark:text-red-400 mt-0.5 flex-shrink-0" />
          <div className="text-sm text-red-700 dark:text-red-400">{error}</div>
        </div>
        <button
          onClick={loadClients}
          className="mt-2 w-full px-3 py-2 text-sm bg-red-100 dark:bg-red-900/30 hover:bg-red-200 dark:hover:bg-red-900/50 text-red-700 dark:text-red-400 rounded transition-colors"
        >
          Reintentar
        </button>
      </div>
    )
  }

  if (clients.length === 0) {
    return (
      <div className="p-4 text-center text-gray-500 dark:text-gray-400">
        <User className="w-12 h-12 mx-auto mb-2 opacity-30" />
        <p className="text-sm">No hay clientes registrados</p>
        <p className="text-xs mt-1">Sube documentos para comenzar</p>
      </div>
    )
  }

  return (
    <div className="space-y-2">
      {/* Search Bar */}
      <div className="px-3 mb-2">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 dark:text-gray-500" size={14} />
          <input
            type="text"
            placeholder="Buscar cliente..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full pl-8 pr-7 py-1.5 text-xs border border-gray-300 dark:border-gray-600 rounded-md 
              focus:outline-none focus:ring-2 focus:ring-blue-500 dark:focus:ring-blue-400 focus:border-transparent
              bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100
              placeholder-gray-400 dark:placeholder-gray-500"
          />
          {searchQuery && (
            <button
              onClick={clearSearch}
              className="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-400 dark:text-gray-500 hover:text-gray-600 dark:hover:text-gray-300"
            >
              <X size={14} />
            </button>
          )}
        </div>
      </div>

      {/* ✅ NEW: Show refresh indicator when data updates */}
      {showRefreshIndicator && (
        <div className="px-3 py-1.5 mx-3 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-md">
          <p className="text-xs text-green-700 dark:text-green-400 flex items-center gap-2">
            <span className="inline-block w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
            Lista actualizada
          </p>
        </div>
      )}

      {/* Clients list */}
      <div className="space-y-1 max-h-96 overflow-y-auto">
        {filteredClients.length === 0 ? (
          <div className="px-3 py-4 text-center text-gray-500 dark:text-gray-400">
            <p className="text-sm">
              {searchQuery ? 'No se encontraron clientes' : 'No hay clientes disponibles'}
            </p>
          </div>
        ) : (
          filteredClients.map((client) => (
            <div key={client.razon_social} className="border-b border-gray-100 dark:border-gray-800 last:border-0">
              <button
                onClick={() => toggleClient(client.razon_social)}
                className={`w-full px-3 py-2.5 flex items-center justify-between 
                  hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors
                  ${selectedClient === client.razon_social 
                    ? 'bg-blue-50 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 border-l-4 border-blue-600 dark:border-blue-400' 
                    : 'text-gray-900 dark:text-gray-100'
                  }`}
              >
                <div className="flex items-center gap-2 flex-1 min-w-0">
                  {expandedClient === client.razon_social ? (
                    <ChevronDown className="w-4 h-4 text-gray-400 dark:text-gray-500 flex-shrink-0" />
                  ) : (
                    <ChevronRight className="w-4 h-4 text-gray-400 dark:text-gray-500 flex-shrink-0" />
                  )}
                  <User className={`w-4 h-4 flex-shrink-0 ${
                    selectedClient === client.razon_social 
                      ? 'text-blue-500 dark:text-blue-400' 
                      : 'text-blue-500 dark:text-blue-400'
                  }`} />
                  <div className="text-left min-w-0 flex-1">
                    <div className="text-sm font-medium truncate" title={client.razon_social}>
                      {client.razon_social}
                    </div>
                    <div className={`text-xs flex items-center gap-2 ${
                      selectedClient === client.razon_social
                        ? 'text-blue-600 dark:text-blue-400'
                        : 'text-gray-500 dark:text-gray-400'
                    }`}>
                      <span className="flex items-center gap-1">
                        <FileText className="w-3 h-3" />
                        {client.document_count}
                      </span>
                      <span className="flex items-center gap-1">
                        <Calendar className="w-3 h-3" />
                        {client.first_year} - {client.last_year}
                      </span>
                    </div>
                  </div>
                </div>
              </button>
            </div>
          ))
        )}
      </div>

      {/* Results counter */}
      {searchQuery && filteredClients.length > 0 && (
        <div className="px-3 py-1 text-xs text-gray-500 dark:text-gray-400 text-center border-t border-gray-200 dark:border-gray-700">
          {filteredClients.length} de {clients.length} cliente{clients.length !== 1 ? 's' : ''}
        </div>
      )}
    </div>
  )
}
