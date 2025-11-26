'use client'

import { useState, useEffect } from 'react'
import { Calendar, FileText, AlertCircle, TrendingUp, X, CheckCircle2, XCircle, ArrowRight, Download, ArrowLeft, RefreshCw, Eye, EyeOff } from 'lucide-react'
import { getClientDocuments, getForm103Data, getForm104Data } from '@/lib/api'
import type { ClientDocuments, MonthData } from '@/types'
import YearlySummary from './YearlySummary'
import Form104Display from './Form104Display'

interface ClientDetailProps {
  razonSocial: string
}

const MONTH_NAMES = [
  '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
]

type ViewMode = 'overview' | 'form103' | 'form104' | 'yearly-summary'

// ✅ NEW: Helper function to validate year
function isValidYear(year: string | null): boolean {
  if (!year) return false
  if (year.toUpperCase() === 'UNKNOWN' || year.toUpperCase() === 'N/A') return false
  const yearNum = parseInt(year, 10)
  return !isNaN(yearNum) && yearNum >= 1900 && yearNum <= 2100
}

export default function ClientDetail({ razonSocial }: ClientDetailProps) {
  const [data, setData] = useState<ClientDocuments | null>(null)
  const [loading, setLoading] = useState(true)
  const [refreshing, setRefreshing] = useState(false)
  const [selectedYear, setSelectedYear] = useState<string | null>(null)
  const [viewMode, setViewMode] = useState<ViewMode>('overview')
  const [error, setError] = useState<string | null>(null)
  
  // Form detail states
  const [selectedFormType, setSelectedFormType] = useState<'103' | '104' | null>(null)
  const [selectedDocumentId, setSelectedDocumentId] = useState<number | null>(null)
  const [formData, setFormData] = useState<any>(null)
  const [formLoading, setFormLoading] = useState(false)

  useEffect(() => {
    loadClientData()
  }, [razonSocial])

  const loadClientData = async (forceRefresh = false) => {
    try {
      if (forceRefresh) {
        setRefreshing(true)
      } else {
        setLoading(true)
      }
      setError(null)
      
      console.log('🔍 Fetching client documents for:', razonSocial)
      const clientData = await getClientDocuments(razonSocial)
      console.log('📦 Received client data:', clientData)
      
      if (!clientData || !clientData.years || clientData.years.length === 0) {
        console.warn('⚠️ No years data in response:', clientData)
        setError('No se encontraron datos con períodos válidos para este cliente')
        setData(null)
      } else {
        setData(clientData)
        
        // ✅ FIX: Auto-select the most recent VALID year
        const firstValidYear = clientData.years.find((y: any) => isValidYear(y.year))
        if (firstValidYear) {
          setSelectedYear(firstValidYear.year)
          console.log('✅ Auto-selected year:', firstValidYear.year)
        } else {
          console.warn('⚠️ No valid years found in data')
          setError('No se encontraron períodos válidos en los documentos')
        }
      }
    } catch (err) {
      console.error('❌ Error loading client data:', err)
      if (err instanceof Error && err.message.includes('no documents have valid period information')) {
        setError('Este cliente tiene documentos sin información de período válida. Por favor, reprocese los documentos.')
      } else {
        setError(err instanceof Error ? err.message : 'Error desconocido al cargar datos')
      }
    } finally {
      setLoading(false)
      setRefreshing(false)
    }
  }

  const handleRefresh = () => {
    console.log('🔄 Manual refresh triggered')
    loadClientData(true)
  }

  const handleViewForm = async (formType: string, documentId: number) => {
    console.log(`📄 Loading form ${formType} with ID ${documentId}`)
    setSelectedFormType(formType as '103' | '104')
    setSelectedDocumentId(documentId)
    setFormLoading(true)
    
    try {
      let data
      if (formType === '103') {
        console.log('🔍 Fetching Form 103 data...')
        data = await getForm103Data(documentId)
        setViewMode('form103')
      } else {
        console.log('🔍 Fetching Form 104 data...')
        data = await getForm104Data(documentId)
        setViewMode('form104')
      }
      console.log('✅ Form data loaded:', data)
      setFormData(data)
    } catch (error) {
      console.error('❌ Error loading form data:', error)
      alert('Error al cargar el formulario. Por favor, intente de nuevo.')
    } finally {
      setFormLoading(false)
    }
  }

  const handleBackToOverview = () => {
    setViewMode('overview')
    setSelectedFormType(null)
    setSelectedDocumentId(null)
    setFormData(null)
  }

  const handleShowSummary = (year: string) => {
    // ✅ FIX: Validate year before showing summary
    if (!isValidYear(year)) {
      alert(`No se puede mostrar el resumen para el año "${year}". El período no es válido.`)
      return
    }
    setSelectedYear(year)
    setViewMode('yearly-summary')
  }

  const handleBackFromSummary = () => {
    setViewMode('overview')
  }

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center h-64 space-y-4">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
        <p className="text-gray-500 dark:text-gray-400 text-sm">Cargando documentos del cliente...</p>
      </div>
    )
  }

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center h-64 text-gray-500 dark:text-gray-400 space-y-4">
        <AlertCircle className="w-12 h-12 text-red-400" />
        <div className="text-center">
          <p className="font-medium text-red-600 dark:text-red-400">Error al cargar datos</p>
          <p className="text-sm mt-1 text-gray-600 dark:text-gray-400 max-w-md">{error}</p>
          <button
            onClick={handleRefresh}
            className="mt-4 flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 mx-auto"
          >
            <RefreshCw className="w-4 h-4" />
            Reintentar
          </button>
        </div>
      </div>
    )
  }

  if (!data) {
    return (
      <div className="flex flex-col items-center justify-center h-64 text-gray-500 dark:text-gray-400 space-y-4">
        <AlertCircle className="w-12 h-12 text-red-400" />
        <div className="text-center">
          <p className="font-medium">No se pudieron cargar los datos del cliente</p>
          <p className="text-sm mt-1">Por favor, intente nuevamente más tarde</p>
          <button
            onClick={handleRefresh}
            className="mt-4 flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 mx-auto"
          >
            <RefreshCw className="w-4 h-4" />
            Reintentar
          </button>
        </div>
      </div>
    )
  }

  // Show Yearly Summary
  if (viewMode === 'yearly-summary' && selectedYear && isValidYear(selectedYear)) {
    return (
      <div className="relative">
        <button
          onClick={handleBackFromSummary}
          className="flex items-center text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 mb-4"
        >
          <ArrowLeft size={20} className="mr-2" />
          Volver a la vista general
        </button>
        <YearlySummary razonSocial={razonSocial} year={selectedYear} />
      </div>
    )
  }

  // Show Form 103 Detail
  if (viewMode === 'form103' && formData) {
    return <Form103DetailView formData={formData} onBack={handleBackToOverview} formLoading={formLoading} />
  }

  // Show Form 104 Detail - NOW USES REUSABLE COMPONENT
  if (viewMode === 'form104' && formData) {
    if (formLoading) {
      return (
        <div className="flex items-center justify-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
        </div>
      )
    }
    return <Form104Display formData={formData} onBack={handleBackToOverview} showBackButton={true} />
  }

  // Show Overview (default)
  return (
    <div className="space-y-6">
      {/* Client Header */}
      <div className="bg-gradient-to-r from-blue-600 to-blue-700 dark:from-blue-700 dark:to-blue-800 rounded-lg shadow-lg p-6 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold mb-2">{data.razon_social}</h1>
            <p className="text-blue-100 dark:text-blue-200">Documentos fiscales organizados por período</p>
          </div>
          <div className="flex items-center gap-4">
            <button
              onClick={handleRefresh}
              disabled={refreshing}
              className="flex items-center gap-2 px-4 py-2 bg-white/20 hover:bg-white/30 rounded-lg transition-colors disabled:opacity-50"
              title="Actualizar datos"
            >
              <RefreshCw className={`w-5 h-5 ${refreshing ? 'animate-spin' : ''}`} />
              <span className="text-sm">Actualizar</span>
            </button>
            <div className="text-right">
              <div className="text-sm text-blue-100 dark:text-blue-200">Total de años</div>
              <div className="text-3xl font-bold">{data.years.length}</div>
            </div>
          </div>
        </div>
      </div>

      {/* Years Overview */}
      {data.years.length > 0 ? (
        data.years.map((yearData) => {
          // ✅ FIX: Check if year is valid before rendering
          const yearIsValid = isValidYear(yearData.year)
          
          const totalMonths = yearData.months.length
          const completeMonths = yearData.months.filter(m => 
            m.forms.form_103 !== null && m.forms.form_104 !== null
          ).length
          const completionRate = Math.round((completeMonths / totalMonths) * 100)

          return (
            <div key={yearData.year} className="bg-white dark:bg-gray-800 rounded-lg shadow-lg overflow-hidden">
              {/* Year Header */}
              <div className="bg-gradient-to-r from-gray-50 to-gray-100 dark:from-gray-700 dark:to-gray-800 border-b border-gray-200 dark:border-gray-700 p-6">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="bg-blue-100 dark:bg-blue-900 rounded-full p-3">
                      <Calendar className="w-6 h-6 text-blue-600 dark:text-blue-400" />
                    </div>
                    <div>
                      <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                        Año {yearData.year}
                        {!yearIsValid && (
                          <span className="ml-2 text-sm text-red-500 dark:text-red-400">(Período inválido)</span>
                        )}
                      </h2>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        {completeMonths} de {totalMonths} meses completos
                      </p>
                    </div>
                  </div>
                  
                  <div className="flex items-center gap-4">
                    {/* Completion Badge */}
                    <div className="text-right">
                      <div className="text-sm text-gray-600 dark:text-gray-400 mb-1">Completitud</div>
                      <div className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-semibold ${
                        completionRate === 100 
                          ? 'bg-green-100 dark:bg-green-900/30 text-green-800 dark:text-green-400' 
                          : completionRate >= 50 
                          ? 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-800 dark:text-yellow-400'
                          : 'bg-red-100 dark:bg-red-900/30 text-red-800 dark:text-red-400'
                      }`}>
                        {completionRate}%
                      </div>
                    </div>

                    {/* Summary Button */}
                    {yearIsValid ? (
                      <button
                        onClick={() => handleShowSummary(yearData.year)}
                        className="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-blue-500 to-blue-600 text-white rounded-lg hover:from-blue-600 hover:to-blue-700 transition-all shadow-md hover:shadow-lg"
                      >
                        <TrendingUp className="w-5 h-5" />
                        <span className="font-medium">Ver Resumen Anual</span>
                      </button>
                    ) : (
                      <div className="px-6 py-3 bg-gray-300 dark:bg-gray-700 text-gray-500 dark:text-gray-400 rounded-lg cursor-not-allowed" title="No se puede generar resumen para período inválido">
                        <TrendingUp className="w-5 h-5 inline mr-2" />
                        <span className="font-medium">Resumen No Disponible</span>
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Months Grid */}
              <div className="p-6">
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                  {yearData.months.map((monthData) => (
                    <MonthCard
                      key={monthData.month}
                      monthData={monthData}
                      onViewForm={handleViewForm}
                    />
                  ))}
                </div>
              </div>
            </div>
          )
        })
      ) : (
        /* Empty State */
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-12 text-center">
          <FileText className="w-16 h-16 text-gray-400 dark:text-gray-600 mx-auto mb-4" />
          <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-2">
            No hay documentos disponibles
          </h3>
          <p className="text-gray-600 dark:text-gray-400 mb-4">
            No se encontraron documentos fiscales con períodos válidos para este cliente
          </p>
          <button
            onClick={handleRefresh}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 mx-auto"
          >
            <RefreshCw className="w-4 h-4" />
            Actualizar
          </button>
        </div>
      )}
    </div>
  )
}

interface MonthCardProps {
  monthData: MonthData
  onViewForm: (formType: string, documentId: number) => void
}

function MonthCard({ monthData, onViewForm }: MonthCardProps) {
  const hasForm103 = monthData.forms.form_103 !== null
  const hasForm104 = monthData.forms.form_104 !== null
  const isComplete = hasForm103 && hasForm104

  return (
    <div className={`
      relative rounded-lg border-2 transition-all duration-200 hover:shadow-lg
      ${isComplete 
        ? 'bg-white dark:bg-gray-800 border-green-200 dark:border-green-800 hover:border-green-300 dark:hover:border-green-700' 
        : 'bg-gradient-to-br from-yellow-50 to-orange-50 dark:from-yellow-900/20 dark:to-orange-900/20 border-yellow-300 dark:border-yellow-700 hover:border-yellow-400 dark:hover:border-yellow-600'
      }
    `}>
      {/* Status Badge */}
      <div className="absolute -top-2 -right-2">
        {isComplete ? (
          <div className="bg-green-500 text-white rounded-full p-1.5 shadow-lg">
            <CheckCircle2 className="w-4 h-4" />
          </div>
        ) : (
          <div className="bg-yellow-500 text-white rounded-full p-1.5 shadow-lg">
            <AlertCircle className="w-4 h-4" />
          </div>
        )}
      </div>

      <div className="p-5">
        {/* Month Header */}
        <div className="mb-4">
          <h3 className="text-lg font-bold text-gray-900 dark:text-gray-100">
            {MONTH_NAMES[monthData.month]}
          </h3>
          <p className="text-xs text-gray-500 dark:text-gray-400 mt-1">
            {monthData.periodo_fiscal || 'Sin período'}
          </p>
        </div>

        {/* Forms Status */}
        <div className="space-y-2">
          <FormStatusButton
            formType="103"
            formName="Retenciones"
            formData={monthData.forms.form_103}
            onView={onViewForm}
            color="blue"
          />
          <FormStatusButton
            formType="104"
            formName="IVA"
            formData={monthData.forms.form_104}
            onView={onViewForm}
            color="purple"
          />
        </div>

        {/* Completion Status */}
        {!isComplete && (
          <div className="mt-4 pt-4 border-t border-yellow-200 dark:border-yellow-800">
            <div className="flex items-center gap-2 text-xs text-yellow-700 dark:text-yellow-400">
              <AlertCircle className="w-3.5 h-3.5" />
              <span className="font-medium">Documentos pendientes</span>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

interface FormStatusButtonProps {
  formType: string
  formName: string
  formData: any
  onView: (formType: string, documentId: number) => void
  color: 'blue' | 'purple'
}

function FormStatusButton({ formType, formName, formData, onView, color }: FormStatusButtonProps) {
  const colorClasses = {
    blue: {
      available: 'bg-blue-50 dark:bg-blue-900/30 hover:bg-blue-100 dark:hover:bg-blue-900/50 border-blue-200 dark:border-blue-800 text-blue-700 dark:text-blue-400',
      unavailable: 'bg-gray-50 dark:bg-gray-700 border-gray-200 dark:border-gray-600 text-gray-400 dark:text-gray-500',
      icon: 'text-blue-600 dark:text-blue-400'
    },
    purple: {
      available: 'bg-purple-50 dark:bg-purple-900/30 hover:bg-purple-100 dark:hover:bg-purple-900/50 border-purple-200 dark:border-purple-800 text-purple-700 dark:text-purple-400',
      unavailable: 'bg-gray-50 dark:bg-gray-700 border-gray-200 dark:border-gray-600 text-gray-400 dark:text-gray-500',
      icon: 'text-purple-600 dark:text-purple-400'
    }
  }

  const colors = colorClasses[color]

  if (!formData) {
    return (
      <div className={`px-3 py-2.5 rounded-lg border-2 flex items-center justify-between ${colors.unavailable}`}>
        <div className="flex items-center gap-2">
          <XCircle className="w-4 h-4" />
          <div className="text-left">
            <div className="text-xs font-semibold">Form {formType}</div>
            <div className="text-[10px]">{formName}</div>
          </div>
        </div>
        <span className="text-[10px] font-medium">No disponible</span>
      </div>
    )
  }

  return (
    <button
      onClick={() => onView(formType, formData.id)}
      className={`w-full px-3 py-2.5 rounded-lg border-2 flex items-center justify-between transition-all ${colors.available}`}
    >
      <div className="flex items-center gap-2">
        <CheckCircle2 className={`w-4 h-4 ${colors.icon}`} />
        <div className="text-left">
          <div className="text-xs font-semibold">Form {formType}</div>
          <div className="text-[10px]">{formName}</div>
        </div>
      </div>
      <ArrowRight className="w-4 h-4" />
    </button>
  )
}

// ✅ Form 103 Detail View Component WITH FILTER
interface FormDetailViewProps {
  formData: any
  onBack: () => void
  formLoading: boolean
}

function Form103DetailView({ formData, onBack, formLoading }: FormDetailViewProps) {
  const [hideZeroValues, setHideZeroValues] = useState(false)
  
  // Filter line items based on hideZeroValues state
  const filteredLineItems = formData?.line_items?.filter((item: any) => {
    if (!hideZeroValues) return true
    return item.base_imponible !== 0 || item.valor_retenido !== 0
  }) || []

  const exportToCSV = () => {
    const headers = ['Concepto', 'Código Base', 'BASE IMPONIBLE', 'Código Retención', 'VALOR RETENIDO']
    const rows = filteredLineItems.map((item: any) => [
      item.concepto,
      item.codigo_base,
      item.base_imponible.toFixed(2),
      item.codigo_retencion,
      item.valor_retenido.toFixed(2)
    ])

    const csv = [
      headers.join(','),
      ...rows.map((row: any) => row.map((cell: any) => `"${cell}"`).join(','))
    ].join('\n')

    const blob = new Blob([csv], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `form_103_${formData.filename.replace('.pdf', '')}.csv`
    a.click()
  }

  if (formLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
        <button
          onClick={onBack}
          className="flex items-center text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 mb-4"
        >
          <ArrowLeft size={20} className="mr-2" />
          Volver a la vista general
        </button>

        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{formData.filename}</h2>
            <p className="text-gray-600 dark:text-gray-400">{formData.razon_social}</p>
            <p className="text-sm text-gray-500 dark:text-gray-500">
              {formData.periodo} | Fecha: {formData.fecha_recaudacion}
            </p>
          </div>
          <div className="flex items-center gap-2">
            {/* Hide Zeros Toggle */}
            <button
              onClick={() => setHideZeroValues(!hideZeroValues)}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg border-2 transition-all ${
                hideZeroValues
                  ? 'bg-blue-600 text-white border-blue-600 hover:bg-blue-700'
                  : 'bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 border-gray-300 dark:border-gray-600 hover:bg-gray-50 dark:hover:bg-gray-600'
              }`}
            >
              {hideZeroValues ? <EyeOff size={18} /> : <Eye size={18} />}
              <span className="text-sm font-medium">
                {hideZeroValues ? 'Mostrar Todos' : 'Ocultar Ceros'}
              </span>
            </button>
            <button
              onClick={exportToCSV}
              className="flex items-center space-x-2 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700"
            >
              <Download size={18} />
              <span>Export CSV</span>
            </button>
          </div>
        </div>

        {/* Line Items Table */}
        <div className="overflow-x-auto">
          <table className="w-full border-collapse">
            <thead>
              <tr className="bg-gray-100 dark:bg-gray-700 border-b-2 border-gray-300 dark:border-gray-600">
                <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700 dark:text-gray-300">Concepto</th>
                <th className="px-4 py-3 text-center text-sm font-semibold text-gray-700 dark:text-gray-300">Código Base</th>
                <th className="px-4 py-3 text-right text-sm font-semibold text-gray-700 dark:text-gray-300">BASE IMPONIBLE</th>
                <th className="px-4 py-3 text-center text-sm font-semibold text-gray-700 dark:text-gray-300">Código Ret.</th>
                <th className="px-4 py-3 text-right text-sm font-semibold text-gray-700 dark:text-gray-300">VALOR RETENIDO</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200 dark:divide-gray-700">
              {filteredLineItems.map((item: any) => (
                <tr key={item.id} className="hover:bg-gray-50 dark:hover:bg-gray-700">
                  <td className="px-4 py-3 text-sm text-gray-900 dark:text-gray-100">{item.concepto}</td>
                  <td className="px-4 py-3 text-sm text-center text-gray-700 dark:text-gray-300">{item.codigo_base}</td>
                  <td className="px-4 py-3 text-sm text-right font-medium text-blue-700 dark:text-blue-400">
                    ${item.base_imponible.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                  </td>
                  <td className="px-4 py-3 text-sm text-center text-gray-700 dark:text-gray-300">{item.codigo_retencion}</td>
                  <td className="px-4 py-3 text-sm text-right font-medium text-green-700 dark:text-green-400">
                    ${item.valor_retenido.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                  </td>
                </tr>
              ))}
            </tbody>
            <tfoot className="bg-gray-50 dark:bg-gray-700 border-t-2 border-gray-300 dark:border-gray-600">
              <tr>
                <td colSpan={2} className="px-4 py-3 text-sm font-semibold text-gray-900 dark:text-gray-100">TOTAL</td>
                <td className="px-4 py-3 text-sm text-right font-bold text-blue-900 dark:text-blue-400">
                  ${filteredLineItems.reduce((sum: number, item: any) => sum + item.base_imponible, 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                </td>
                <td className="px-4 py-3"></td>
                <td className="px-4 py-3 text-sm text-right font-bold text-green-900 dark:text-green-400">
                  ${filteredLineItems.reduce((sum: number, item: any) => sum + item.valor_retenido, 0).toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                </td>
              </tr>
            </tfoot>
          </table>
        </div>

        {/* Filter Info Message */}
        {hideZeroValues && formData.line_items && (
          <div className="mt-3 text-sm text-gray-600 dark:text-gray-400">
            Mostrando {filteredLineItems.length} de {formData.line_items.length} items 
            {filteredLineItems.length < formData.line_items.length && (
              <span className="ml-1 text-blue-600 dark:text-blue-400">
                (ocultando {formData.line_items.length - filteredLineItems.length} items con valores en cero)
              </span>
            )}
          </div>
        )}

        {/* Summary Totals */}
        {formData.totals && (
          <div className="mt-6 grid grid-cols-1 md:grid-cols-4 gap-4">
            <div className="border rounded-lg p-4 bg-blue-50 dark:bg-blue-900/20 dark:border-blue-800">
              <p className="text-sm text-gray-600 dark:text-gray-400">Subtotal Operaciones País</p>
              <p className="text-xl font-bold text-blue-700 dark:text-blue-400">
                ${formData.totals.subtotal_operaciones?.toLocaleString('en-US', { minimumFractionDigits: 2 })}
              </p>
            </div>
            <div className="border rounded-lg p-4 bg-green-50 dark:bg-green-900/20 dark:border-green-800">
              <p className="text-sm text-gray-600 dark:text-gray-400">Total Retención</p>
              <p className="text-xl font-bold text-green-700 dark:text-green-400">
                ${formData.totals.total_retencion?.toLocaleString('en-US', { minimumFractionDigits: 2 })}
              </p>
            </div>
            <div className="border rounded-lg p-4 bg-yellow-50 dark:bg-yellow-900/20 dark:border-yellow-800">
              <p className="text-sm text-gray-600 dark:text-gray-400">Total Impuesto a Pagar</p>
              <p className="text-xl font-bold text-yellow-700 dark:text-yellow-400">
                ${formData.totals.total_impuesto_pagar?.toLocaleString('en-US', { minimumFractionDigits: 2 })}
              </p>
            </div>
            <div className="border rounded-lg p-4 bg-purple-50 dark:bg-purple-900/20 dark:border-purple-800">
              <p className="text-sm text-gray-600 dark:text-gray-400">Total Pagado</p>
              <p className="text-xl font-bold text-purple-700 dark:text-purple-400">
                ${formData.totals.total_pagado?.toLocaleString('en-US', { minimumFractionDigits: 2 })}
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
