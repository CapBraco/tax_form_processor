/**
 * Form103Section.tsx - UPDATED WITH ACCORDION STYLE
 * ✅ Matches Form104Display design with accordions
 * ✅ Displays all 10 totals fields including codes 332, 3440, 3940
 * ✅ Professional table layout with proper contrast
 * 
 * Replace: frontend/components/Form103Section.tsx
 */

'use client'

import { useState, useEffect } from 'react'
import { getForm103Data, listDocumentsByFormType } from '@/lib/api'
import { FileText, Download, ArrowLeft, Eye, EyeOff, ChevronDown, ChevronUp } from 'lucide-react'

export default function Form103Section() {
  const [documents, setDocuments] = useState<any[]>([])
  const [selectedDoc, setSelectedDoc] = useState<any>(null)
  const [formData, setFormData] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const [detailLoading, setDetailLoading] = useState(false)
  const [hideZeroValues, setHideZeroValues] = useState(false)
  
  // Accordion state
  const [openSections, setOpenSections] = useState<Record<string, boolean>>({
    lineItems: true,
    totals: true
  })

  const toggleSection = (section: string) => {
    setOpenSections(prev => ({ ...prev, [section]: !prev[section] }))
  }

  useEffect(() => {
    loadDocuments()
  }, [])

  const loadDocuments = async () => {
    setLoading(true)
    try {
      const data = await listDocumentsByFormType('form_103')
      setDocuments(data)
    } catch (error) {
      console.error('Error loading Form 103 documents:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleViewForm = async (doc: any) => {
    setSelectedDoc(doc)
    setDetailLoading(true)
    try {
      const data = await getForm103Data(doc.id)
      setFormData(data)
    } catch (error) {
      console.error('Error loading form data:', error)
    } finally {
      setDetailLoading(false)
    }
  }

  const handleBack = () => {
    setSelectedDoc(null)
    setFormData(null)
  }

  const exportToCSV = () => {
    if (!formData) return

    const headers = ['Concepto', 'Código Base', 'BASE IMPONIBLE', 'Código Retención', 'VALOR RETENIDO']
    const rows = formData.line_items.map((item: any) => [
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
    a.download = `form_103_${selectedDoc.filename.replace('.pdf', '')}.csv`
    a.click()
  }

  const filteredLineItems = formData?.line_items?.filter((item: any) => {
    if (!hideZeroValues) return true
    return item.base_imponible !== 0 || item.valor_retenido !== 0
  }) || []

  const formatValue = (value: any) => {
    if (typeof value === 'number') {
      return value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
    }
    return value || '0.00'
  }

  // Accordion Section Component
  const AccordionSection = ({ 
    id, 
    title, 
    bgColor, 
    children 
  }: { 
    id: string
    title: string
    bgColor: string
    children: React.ReactNode 
  }) => (
    <div className="mb-4 border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden">
      <button
        onClick={() => toggleSection(id)}
        className={`w-full flex items-center justify-between p-3 md:p-4 ${bgColor} text-white font-semibold hover:opacity-90 transition-opacity`}
      >
        <span className="text-sm md:text-base">{title}</span>
        {openSections[id] ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
      </button>
      {openSections[id] && (
        <div className="bg-white dark:bg-gray-800 p-2 md:p-4">
          {children}
        </div>
      )}
    </div>
  )

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  // Document List View
  if (!selectedDoc) {
    return (
      <div className="space-y-6">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-gray-100 mb-4">
            Form 103 - Declaración de Retenciones en la Fuente
          </h2>
          
          {documents.length === 0 ? (
            <div className="text-center py-12 text-gray-500 dark:text-gray-400">
              <FileText size={48} className="mx-auto mb-4" />
              <p>No Form 103 documents uploaded yet</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {documents.map((doc) => (
                <div
                  key={doc.id}
                  onClick={() => handleViewForm(doc)}
                  className="border border-gray-200 dark:border-gray-700 rounded-lg p-4 hover:shadow-lg cursor-pointer transition-shadow bg-white dark:bg-gray-800"
                >
                  <div className="flex items-start justify-between mb-2">
                    <FileText className="text-blue-600 dark:text-blue-400" size={24} />
                    <span className="text-xs text-gray-500 dark:text-gray-400">{doc.periodo}</span>
                  </div>
                  <h3 className="font-medium text-gray-900 dark:text-gray-100 mb-1 truncate">{doc.filename}</h3>
                  <p className="text-sm text-gray-600 dark:text-gray-400 truncate">{doc.razon_social}</p>
                  <p className="text-xs text-gray-500 dark:text-gray-500 mt-2">
                    {doc.uploaded_at ? `Uploaded: ${new Date(doc.uploaded_at).toLocaleDateString()}` : ''}
                  </p>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    )
  }

  // Detail View with Accordion Layout
  return (
    <div className="space-y-6">
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-4 md:p-6">
        <button
          onClick={handleBack}
          className="flex items-center text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 mb-4"
        >
          <ArrowLeft size={20} className="mr-2" />
          Volver a la vista general
        </button>

        {detailLoading ? (
          <div className="flex items-center justify-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
          </div>
        ) : formData ? (
          <>
            {/* Header with Toggle and Export */}
            <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-6 gap-4">
              <div className="min-w-0">
                <h2 className="text-xl md:text-2xl font-bold text-gray-900 dark:text-gray-100 truncate">
                  {formData.filename}
                </h2>
                <p className="text-gray-600 dark:text-gray-400 truncate">{formData.razon_social}</p>
                <p className="text-xs md:text-sm text-gray-500 dark:text-gray-500">
                  {formData.periodo} | Fecha: {formData.fecha_recaudacion}
                </p>
              </div>
              
              <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-2">
                <button
                  onClick={() => setHideZeroValues(!hideZeroValues)}
                  className={`flex items-center justify-center gap-2 px-3 py-2 rounded-lg border-2 transition-all text-xs md:text-sm ${
                    hideZeroValues 
                      ? 'bg-purple-600 text-white border-purple-600' 
                      : 'bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-200 border-gray-300 dark:border-gray-600'
                  }`}
                >
                  {hideZeroValues ? <EyeOff size={16} /> : <Eye size={16} />}
                  <span className="font-medium whitespace-nowrap">
                    {hideZeroValues ? 'Mostrar Ceros' : 'Ocultar Ceros'}
                  </span>
                </button>

                <button
                  onClick={exportToCSV}
                  className="flex items-center justify-center gap-2 bg-green-600 text-white px-3 py-2 rounded-lg hover:bg-green-700 text-xs md:text-sm"
                >
                  <Download size={16} />
                  <span className="whitespace-nowrap">Export CSV</span>
                </button>
              </div>
            </div>

            {/* SECTION 1: LINE ITEMS */}
            <AccordionSection 
              id="lineItems" 
              title="DETALLE DE RETENCIONES EN LA FUENTE" 
              bgColor="bg-blue-600"
            >
              <div className="overflow-x-auto">
                <table className="w-full border-collapse text-xs">
                  <thead>
                    <tr className="bg-blue-600 text-white">
                      <th className="px-2 py-2 text-left border border-blue-700">Concepto</th>
                      <th className="px-2 py-2 text-center border border-blue-700 w-16">Cód Base</th>
                      <th className="px-2 py-2 text-right border border-blue-700 min-w-[100px]">BASE IMPONIBLE</th>
                      <th className="px-2 py-2 text-center border border-blue-700 w-16">Cód Ret.</th>
                      <th className="px-2 py-2 text-right border border-blue-700 min-w-[100px]">VALOR RETENIDO</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredLineItems.map((item: any, index: number) => (
                      <tr key={item.id} className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                        <td className="px-2 py-1 border dark:border-gray-700 text-gray-900 dark:text-gray-100">{item.concepto}</td>
                        <td className="px-2 py-1 text-center border dark:border-gray-700 bg-blue-50 dark:bg-blue-900/20 text-gray-600 dark:text-gray-400">{item.codigo_base}</td>
                        <td className="px-2 py-1 text-right border dark:border-gray-700 font-medium text-blue-700 dark:text-blue-400">
                          ${formatValue(item.base_imponible)}
                        </td>
                        <td className="px-2 py-1 text-center border dark:border-gray-700 bg-blue-50 dark:bg-blue-900/20 text-gray-600 dark:text-gray-400">{item.codigo_retencion}</td>
                        <td className="px-2 py-1 text-right border dark:border-gray-700 font-medium text-green-700 dark:text-green-400">
                          ${formatValue(item.valor_retenido)}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                  <tfoot className="bg-yellow-50 dark:bg-yellow-900/20 border-t-2 border-yellow-600">
                    <tr>
                      <td colSpan={2} className="px-2 py-3 text-sm font-semibold border dark:border-gray-700 text-gray-900 dark:text-gray-100">
                        TOTAL {hideZeroValues && `(${filteredLineItems.length} de ${formData.line_items.length})`}
                      </td>
                      <td className="px-2 py-3 text-sm text-right font-bold border dark:border-gray-700 text-blue-900 dark:text-blue-300">
                        ${formatValue(filteredLineItems.reduce((sum: number, item: any) => sum + item.base_imponible, 0))}
                      </td>
                      <td className="px-2 py-3 border dark:border-gray-700"></td>
                      <td className="px-2 py-3 text-sm text-right font-bold border dark:border-gray-700 text-green-900 dark:text-green-300">
                        ${formatValue(filteredLineItems.reduce((sum: number, item: any) => sum + item.valor_retenido, 0))}
                      </td>
                    </tr>
                  </tfoot>
                </table>
              </div>

              {hideZeroValues && (
                <div className="mt-2 text-xs text-gray-500 dark:text-gray-400 text-center">
                  Mostrando {filteredLineItems.length} items con valores (ocultando {formData.line_items.length - filteredLineItems.length} items en cero)
                </div>
              )}
            </AccordionSection>

            {/* SECTION 2: TOTALS SUMMARY */}
            {formData.totals && (
              <AccordionSection 
                id="totals" 
                title="RESUMEN DE TOTALES" 
                bgColor="bg-green-600"
              >
                {/* Row 1: Main Totals (4 fields) */}
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 md:gap-4 mb-4">
                  <div className="border-2 rounded-lg p-3 md:p-4 bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800">
                    <p className="text-xs text-gray-600 dark:text-gray-400 font-semibold">Subtotal Operaciones País</p>
                    <p className="text-sm text-gray-500 dark:text-gray-500 mb-1">(349)</p>
                    <p className="text-lg md:text-xl font-bold text-blue-700 dark:text-blue-400">
                      ${formatValue(formData.totals.subtotal_operaciones_pais)}
                    </p>
                  </div>

                  <div className="border-2 rounded-lg p-3 md:p-4 bg-cyan-50 dark:bg-cyan-900/20 border-cyan-200 dark:border-cyan-800">
                    <p className="text-xs text-gray-600 dark:text-gray-400 font-semibold">Subtotal Retención</p>
                    <p className="text-sm text-gray-500 dark:text-gray-500 mb-1">(399)</p>
                    <p className="text-lg md:text-xl font-bold text-cyan-700 dark:text-cyan-400">
                      ${formatValue(formData.totals.subtotal_retencion)}
                    </p>
                  </div>

                  <div className="border-2 rounded-lg p-3 md:p-4 bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800">
                    <p className="text-xs text-gray-600 dark:text-gray-400 font-semibold">Total Retención</p>
                    <p className="text-sm text-gray-500 dark:text-gray-500 mb-1">(499)</p>
                    <p className="text-lg md:text-xl font-bold text-green-700 dark:text-green-400">
                      ${formatValue(formData.totals.total_retencion)}
                    </p>
                  </div>

                  <div className="border-2 rounded-lg p-3 md:p-4 bg-purple-50 dark:bg-purple-900/20 border-purple-200 dark:border-purple-800">
                    <p className="text-xs text-gray-600 dark:text-gray-400 font-semibold">Total Pagado</p>
                    <p className="text-sm text-gray-500 dark:text-gray-500 mb-1">(999)</p>
                    <p className="text-xl md:text-2xl font-bold text-purple-700 dark:text-purple-400">
                      ${formatValue(formData.totals.total_pagado)}
                    </p>
                  </div>
                </div>

                {/* Row 2: Additional Fields (3 fields) */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-3 md:gap-4 mb-4">
                  <div className="border-2 rounded-lg p-3 md:p-4 bg-gray-50 dark:bg-gray-700/50 border-gray-300 dark:border-gray-600">
                    <p className="text-xs text-gray-600 dark:text-gray-400 font-semibold">Pagos No Sujetos</p>
                    <p className="text-sm text-gray-500 dark:text-gray-500 mb-1">(332)</p>
                    <p className="text-lg md:text-xl font-bold text-gray-700 dark:text-gray-300">
                      ${formatValue(formData.totals.pagos_no_sujetos)}
                    </p>
                  </div>

                  <div className="border-2 rounded-lg p-3 md:p-4 bg-amber-50 dark:bg-amber-900/20 border-amber-200 dark:border-amber-800">
                    <p className="text-xs text-gray-600 dark:text-gray-400 font-semibold">Otras Retenciones Base</p>
                    <p className="text-sm text-gray-500 dark:text-gray-500 mb-1">(3440)</p>
                    <p className="text-lg md:text-xl font-bold text-amber-700 dark:text-amber-400">
                      ${formatValue(formData.totals.otras_retenciones_base)}
                    </p>
                  </div>

                  <div className="border-2 rounded-lg p-3 md:p-4 bg-orange-50 dark:bg-orange-900/20 border-orange-200 dark:border-orange-800">
                    <p className="text-xs text-gray-600 dark:text-gray-400 font-semibold">Otras Retenciones Retenido</p>
                    <p className="text-sm text-gray-500 dark:text-gray-500 mb-1">(3940)</p>
                    <p className="text-lg md:text-xl font-bold text-orange-700 dark:text-orange-400">
                      ${formatValue(formData.totals.otras_retenciones_retenido)}
                    </p>
                  </div>
                </div>

                {/* Row 3: Final Fields (3 fields) */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-3 md:gap-4">
                  <div className="border-2 rounded-lg p-3 md:p-4 bg-yellow-50 dark:bg-yellow-900/20 border-yellow-200 dark:border-yellow-800">
                    <p className="text-xs text-gray-600 dark:text-gray-400 font-semibold">Total Impuesto a Pagar</p>
                    <p className="text-sm text-gray-500 dark:text-gray-500 mb-1">(902)</p>
                    <p className="text-lg md:text-xl font-bold text-yellow-700 dark:text-yellow-400">
                      ${formatValue(formData.totals.total_impuesto_pagar)}
                    </p>
                  </div>

                  <div className="border-2 rounded-lg p-3 md:p-4 bg-red-50 dark:bg-red-900/20 border-red-200 dark:border-red-800">
                    <p className="text-xs text-gray-600 dark:text-gray-400 font-semibold">Interés Mora</p>
                    <p className="text-sm text-gray-500 dark:text-gray-500 mb-1">(903)</p>
                    <p className="text-lg md:text-xl font-bold text-red-700 dark:text-red-400">
                      ${formatValue(formData.totals.interes_mora)}
                    </p>
                  </div>

                  <div className="border-2 rounded-lg p-3 md:p-4 bg-red-50 dark:bg-red-900/20 border-red-200 dark:border-red-800">
                    <p className="text-xs text-gray-600 dark:text-gray-400 font-semibold">Multa</p>
                    <p className="text-sm text-gray-500 dark:text-gray-500 mb-1">(904)</p>
                    <p className="text-lg md:text-xl font-bold text-red-700 dark:text-red-400">
                      ${formatValue(formData.totals.multa)}
                    </p>
                  </div>
                </div>
              </AccordionSection>
            )}
          </>
        ) : (
          <div className="text-center py-12 text-gray-500 dark:text-gray-400">
            Error loading form data
          </div>
        )}
      </div>
    </div>
  )
}
