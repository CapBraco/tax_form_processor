'use client'

import { useEffect, useState } from 'react'
import { getDocumentsStats } from '@/lib/api'
import { FileText, CheckCircle, Clock, AlertCircle, FileCheck, Calculator } from 'lucide-react'

interface DashboardProps {
  onNavigate: (section: string) => void
}

export default function Dashboard({ onNavigate }: DashboardProps) {
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

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  const statCards = [
    {
      title: 'Total Documents',
      value: stats?.total_documents || 0,
      icon: FileText,
      color: 'bg-blue-500',
      textColor: 'text-blue-600',
      bgColor: 'bg-blue-50',
      onClick: () => onNavigate('documents')
    },
    {
      title: 'Completed',
      value: stats?.by_status?.completed || 0,
      icon: CheckCircle,
      color: 'bg-green-500',
      textColor: 'text-green-600',
      bgColor: 'bg-green-50',
      onClick: () => onNavigate('documents')
    },
    {
      title: 'Processing',
      value: stats?.by_status?.processing || 0,
      icon: Clock,
      color: 'bg-yellow-500',
      textColor: 'text-yellow-600',
      bgColor: 'bg-yellow-50',
      onClick: () => onNavigate('documents')
    },
    {
      title: 'Failed',
      value: stats?.by_status?.failed || 0,
      icon: AlertCircle,
      color: 'bg-red-500',
      textColor: 'text-red-600',
      bgColor: 'bg-red-50',
      onClick: () => onNavigate('documents')
    },
  ]

  return (
    <div className="space-y-6">
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

      {/* Form Types */}
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Tax Forms by Type</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div 
            onClick={() => onNavigate('form103')}
            className="border-2 border-blue-200 rounded-lg p-6 hover:shadow-lg cursor-pointer transition-all hover:border-blue-400"
          >
            <div className="flex items-center space-x-4">
              <div className="bg-blue-100 p-4 rounded-lg">
                <FileCheck className="text-blue-600" size={32} />
              </div>
              <div>
                <h4 className="text-xl font-bold text-gray-900">Form 103</h4>
                <p className="text-sm text-gray-600">Declaración de Retenciones</p>
                <p className="text-xs text-gray-500 mt-1">Income Tax Withholdings</p>
              </div>
            </div>
            <div className="mt-4 pt-4 border-t">
              <p className="text-sm text-gray-600">View BASE IMPONIBLE & VALOR RETENIDO tables</p>
            </div>
          </div>

          <div 
            onClick={() => onNavigate('form104')}
            className="border-2 border-purple-200 rounded-lg p-6 hover:shadow-lg cursor-pointer transition-all hover:border-purple-400"
          >
            <div className="flex items-center space-x-4">
              <div className="bg-purple-100 p-4 rounded-lg">
                <Calculator className="text-purple-600" size={32} />
              </div>
              <div>
                <h4 className="text-xl font-bold text-gray-900">Form 104</h4>
                <p className="text-sm text-gray-600">Declaración de IVA</p>
                <p className="text-xs text-gray-500 mt-1">VAT Declaration</p>
              </div>
            </div>
            <div className="mt-4 pt-4 border-t">
              <p className="text-sm text-gray-600">View Ventas, Compras & Retenciones</p>
            </div>
          </div>
        </div>
      </div>

      {/* Extraction Statistics */}
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Extraction Statistics</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="border rounded-lg p-4">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm text-gray-600">Total Pages Extracted</span>
              <FileText className="text-blue-600" size={20} />
            </div>
            <p className="text-2xl font-bold text-blue-600">
              {(stats?.total_pages_extracted || 0).toLocaleString()}
            </p>
          </div>

          <div className="border rounded-lg p-4">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm text-gray-600">Total Characters Extracted</span>
              <FileText className="text-green-600" size={20} />
            </div>
            <p className="text-2xl font-bold text-green-600">
              {(stats?.total_characters_extracted || 0).toLocaleString()}
            </p>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-lg shadow p-6">
        <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <button
            onClick={() => onNavigate('upload')}
            className="flex items-center justify-center space-x-2 bg-blue-600 text-white px-6 py-4 rounded-lg hover:bg-blue-700 transition-colors"
          >
            <FileText size={20} />
            <span>Upload Forms</span>
          </button>
          
          <button
            onClick={() => onNavigate('form103')}
            className="flex items-center justify-center space-x-2 bg-blue-500 text-white px-6 py-4 rounded-lg hover:bg-blue-600 transition-colors"
          >
            <FileCheck size={20} />
            <span>View Form 103</span>
          </button>
          
          <button
            onClick={() => onNavigate('form104')}
            className="flex items-center justify-center space-x-2 bg-purple-600 text-white px-6 py-4 rounded-lg hover:bg-purple-700 transition-colors"
          >
            <Calculator size={20} />
            <span>View Form 104</span>
          </button>
        </div>
      </div>

      {/* Getting Started */}
      {stats?.total_documents === 0 && (
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
          <h3 className="text-lg font-semibold text-blue-900 mb-2">
            Welcome to Enhanced PDF Processor! 🎉
          </h3>
          <p className="text-blue-700 mb-4">
            Upload your Form 103 and Form 104 PDFs to automatically extract structured data 
            including BASE IMPONIBLE, VALOR RETENIDO, Ventas, Compras, and more.
          </p>
          <ul className="text-sm text-blue-800 space-y-1 mb-4">
            <li>✓ Automatic form type detection</li>
            <li>✓ Extract line items into tables</li>
            <li>✓ View structured data</li>
            <li>✓ Export to CSV for accountants</li>
          </ul>
          <button
            onClick={() => onNavigate('upload')}
            className="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700 transition-colors"
          >
            Upload Your First Form
          </button>
        </div>
      )}
    </div>
  )
}
