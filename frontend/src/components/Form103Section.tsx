/**
 * Form103Section.tsx - UPDATED
 * ✅ Displays all 10 totals fields including codes 332, 3440, 3940
 * 
 * Replace: frontend/components/Form103Section.tsx
 */

'use client'

import { useState, useEffect } from 'react'
import { getForm103Data, listDocumentsByFormType } from '@/lib/api'
import { FileText, Download, ArrowLeft, Eye, EyeOff } from 'lucide-react'

export default function Form103Section() {
  const [documents, setDocuments] = useState<any[]>([])
  const [selectedDoc, setSelectedDoc] = useState<any>(null)
  const [formData, setFormData] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const [detailLoading, setDetailLoading] = useState(false)
  const [hideZeroValues, setHideZeroValues] = useState(false)

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
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-4">
            Form 103 - Declaración de Retenciones en la Fuente
          </h2>
          
          {documents.length === 0 ? (
            <div className="text-center py-12 text-gray-500">
              <FileText size={48} className="mx-auto mb-4" />
              <p>No Form 103 documents uploaded yet</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {documents.map((doc) => (
                <div
                  key={doc.id}
                  onClick={() => handleViewForm(doc)}
                  className="border rounded-lg p-4 hover:shadow-lg cursor-pointer transition-shadow"
                >
                  <div className="flex items-start justify-between mb-2">
                    <FileText className="text-blue-600" size={24} />
                    <span className="text-xs text-gray-500">{doc.periodo}</span>
                  </div>
                  <h3 className="font-medium text-gray-900 mb-1 truncate">{doc.filename}</h3>
                  <p className="text-sm text-gray-600 truncate">{doc.razon_social}</p>
                  <p className="text-xs text-gray-500 mt-2">
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

  // Detail View with Table
  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-white rounded-lg shadow p-6">
        <button
          onClick={handleBack}
          className="flex items-center text-blue-600 hover:text-blue-800 mb-4"
        >
          <ArrowLeft size={20} className="mr-2" />
          Back to list
        </button>

        {detailLoading ? (
          <div className="flex items-center justify-center py-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
          </div>
        ) : formData ? (
          <>
            {/* Header with Toggle and Export */}
            <div className="flex items-center justify-between mb-6">
              <div>
                <h2 className="text-2xl font-bold text-gray-900">{formData.filename}</h2>
                <p className="text-gray-600">{formData.razon_social}</p>
                <p className="text-sm text-gray-500">
                  {formData.periodo} | Fecha: {formData.fecha_recaudacion}
                </p>
              </div>
              <div className="flex items-center gap-3">
                <button
                  onClick={() => setHideZeroValues(!hideZeroValues)}
                  className={`flex items-center gap-2 px-4 py-2 rounded-lg border-2 transition-all ${
                    hideZeroValues 
                      ? 'bg-blue-600 text-white border-blue-600' 
                      : 'bg-white text-gray-700 border-gray-300 hover:border-gray-400'
                  }`}
                >
                  {hideZeroValues ? <EyeOff size={18} /> : <Eye size={18} />}
                  <span className="text-sm font-medium">
                    {hideZeroValues ? 'Show All' : 'Hide Zeros'}
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
                  <tr className="bg-gray-100 border-b-2 border-gray-300">
                    <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">Concepto</th>
                    <th className="px-4 py-3 text-center text-sm font-semibold text-gray-700">Código Base</th>
                    <th className="px-4 py-3 text-right text-sm font-semibold text-gray-700">BASE IMPONIBLE</th>
                    <th className="px-4 py-3 text-center text-sm font-semibold text-gray-700">Código Ret.</th>
                    <th className="px-4 py-3 text-right text-sm font-semibold text-gray-700">VALOR RETENIDO</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {filteredLineItems.map((item: any, index: number) => (
                    <tr key={item.id} className="hover:bg-gray-50">
                      <td className="px-4 py-3 text-sm text-gray-900">{item.concepto}</td>
                      <td className="px-4 py-3 text-sm text-center text-gray-700">{item.codigo_base}</td>
                      <td className="px-4 py-3 text-sm text-right font-medium text-blue-700">
                        ${item.base_imponible.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                      </td>
                      <td className="px-4 py-3 text-sm text-center text-gray-700">{item.codigo_retencion}</td>
                      <td className="px-4 py-3 text-sm text-right font-medium text-green-700">
                        ${item.valor_retenido.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                      </td>
                    </tr>
                  ))}
                </tbody>
                <tfoot className="bg-gray-50 border-t-2 border-gray-300">
                  <tr>
                    <td colSpan={2} className="px-4 py-3 text-sm font-semibold text-gray-900">
                      TOTAL {hideZeroValues && `(${filteredLineItems.length} of ${formData.line_items.length} items)`}
                    </td>
                    <td className="px-4 py-3 text-sm text-right font-bold text-blue-900">
                      ${filteredLineItems.reduce((sum: number, item: any) => sum + item.base_imponible, 0).toLocaleString('en-US', { minimumFractionDigits: 2 })}
                    </td>
                    <td className="px-4 py-3"></td>
                    <td className="px-4 py-3 text-sm text-right font-bold text-green-900">
                      ${filteredLineItems.reduce((sum: number, item: any) => sum + item.valor_retenido, 0).toLocaleString('en-US', { minimumFractionDigits: 2 })}
                    </td>
                  </tr>
                </tfoot>
              </table>
            </div>

            {hideZeroValues && (
              <div className="mt-2 text-sm text-gray-500 text-center">
                Showing {filteredLineItems.length} items with non-zero values (hiding {formData.line_items.length - filteredLineItems.length} zero-value items)
              </div>
            )}

            {/* ✅ UPDATED: Summary Totals - 10 Fields */}
            {formData.totals && (
              <div className="mt-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-4">📊 Resumen de Totales</h3>
                
                {/* Row 1: Main Totals (4 fields) */}
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-4">
                  <div className="border rounded-lg p-4 bg-blue-50 border-blue-200">
                    <p className="text-xs text-gray-600 font-semibold">Subtotal Operaciones País (349)</p>
                    <p className="text-xl font-bold text-blue-700">
                      ${formData.totals.subtotal_operaciones_pais?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
                    </p>
                  </div>

                  <div className="border rounded-lg p-4 bg-cyan-50 border-cyan-200">
                    <p className="text-xs text-gray-600 font-semibold">Subtotal Retención (399)</p>
                    <p className="text-xl font-bold text-cyan-700">
                      ${formData.totals.subtotal_retencion?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
                    </p>
                  </div>

                  <div className="border rounded-lg p-4 bg-green-50 border-green-200">
                    <p className="text-xs text-gray-600 font-semibold">Total Retención (499)</p>
                    <p className="text-xl font-bold text-green-700">
                      ${formData.totals.total_retencion?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
                    </p>
                  </div>

                  <div className="border rounded-lg p-4 bg-purple-50 border-purple-200">
                    <p className="text-xs text-gray-600 font-semibold">Total Pagado (999)</p>
                    <p className="text-xl font-bold text-purple-700">
                      ${formData.totals.total_pagado?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
                    </p>
                  </div>
                </div>

                {/* Row 2: ✅ NEW Additional Fields (3 fields) */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                  <div className="border rounded-lg p-4 bg-gray-50 border-gray-300">
                    <p className="text-xs text-gray-600 font-semibold">Pagos No Sujetos (332)</p>
                    <p className="text-xl font-bold text-gray-700">
                      ${formData.totals.pagos_no_sujetos?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
                    </p>
                  </div>

                  <div className="border rounded-lg p-4 bg-amber-50 border-amber-200">
                    <p className="text-xs text-gray-600 font-semibold">Otras Ret. Base (3440)</p>
                    <p className="text-xl font-bold text-amber-700">
                      ${formData.totals.otras_retenciones_base?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
                    </p>
                  </div>

                  <div className="border rounded-lg p-4 bg-orange-50 border-orange-200">
                    <p className="text-xs text-gray-600 font-semibold">Otras Ret. Retenido (3940)</p>
                    <p className="text-xl font-bold text-orange-700">
                      ${formData.totals.otras_retenciones_retenido?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
                    </p>
                  </div>
                </div>

                {/* Row 3: Additional Info (3 fields) */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="border rounded-lg p-4 bg-yellow-50 border-yellow-200">
                    <p className="text-xs text-gray-600 font-semibold">Total Impuesto a Pagar (902)</p>
                    <p className="text-xl font-bold text-yellow-700">
                      ${formData.totals.total_impuesto_pagar?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
                    </p>
                  </div>

                  <div className="border rounded-lg p-4 bg-red-50 border-red-200">
                    <p className="text-xs text-gray-600 font-semibold">Interés Mora (903)</p>
                    <p className="text-xl font-bold text-red-700">
                      ${formData.totals.interes_mora?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
                    </p>
                  </div>

                  <div className="border rounded-lg p-4 bg-red-50 border-red-200">
                    <p className="text-xs text-gray-600 font-semibold">Multa (904)</p>
                    <p className="text-xl font-bold text-red-700">
                      ${formData.totals.multa?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
                    </p>
                  </div>
                </div>
              </div>
            )}
          </>
        ) : (
          <div className="text-center py-12 text-gray-500">
            Error loading form data
          </div>
        )}
      </div>
    </div>
  )
}
