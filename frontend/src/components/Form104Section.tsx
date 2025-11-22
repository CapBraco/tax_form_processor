'use client'

import { useState, useEffect } from 'react'
import { getForm104Data, listDocumentsByFormType } from '@/lib/api'
import { FileText, Download, ArrowLeft } from 'lucide-react'

export default function Form104Section() {
  const [documents, setDocuments] = useState<any[]>([])
  const [selectedDoc, setSelectedDoc] = useState<any>(null)
  const [formData, setFormData] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const [detailLoading, setDetailLoading] = useState(false)

  useEffect(() => {
    loadDocuments()
  }, [])

  const loadDocuments = async () => {
    setLoading(true)
    try {
      const data = await listDocumentsByFormType('form_104')
      setDocuments(data.documents)
    } catch (error) {
      console.error('Error loading Form 104 documents:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleViewForm = async (doc: any) => {
    setSelectedDoc(doc)
    setDetailLoading(true)
    try {
      const data = await getForm104Data(doc.id)
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

    // Combine all data into CSV
    const lines = [
      '=== VENTAS (Sales) ===',
      'Concepto,Valor',
      `Ventas Tarifa Diferente Cero (Bruto),${formData.ventas.ventas_tarifa_diferente_cero_bruto.toFixed(2)}`,
      `Ventas Tarifa Diferente Cero (Neto),${formData.ventas.ventas_tarifa_diferente_cero_neto.toFixed(2)}`,
      `Impuesto Generado,${formData.ventas.impuesto_generado.toFixed(2)}`,
      '',
      '=== COMPRAS (Purchases) ===',
      'Concepto,Valor',
      `Adquisiciones Tarifa Diferente Cero (Bruto),${formData.compras.adquisiciones_tarifa_diferente_cero_bruto.toFixed(2)}`,
      `Impuesto Compras,${formData.compras.impuesto_compras.toFixed(2)}`,
      `Crédito Tributario Aplicable,${formData.compras.credito_tributario_aplicable.toFixed(2)}`,
      '',
      '=== RETENCIONES IVA ===',
      'Porcentaje,Valor',
      ...formData.retenciones_iva.map((r: any) => `${r.porcentaje}%,${r.valor.toFixed(2)}`),
      '',
      '=== TOTALS ===',
      'Concepto,Valor',
      `Total Consolidado IVA,${formData.totals.total_consolidado_iva.toFixed(2)}`,
      `Total Pagado,${formData.totals.total_pagado.toFixed(2)}`
    ]

    const csv = lines.join('\n')
    const blob = new Blob([csv], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `form_104_${selectedDoc.filename.replace('.pdf', '')}.csv`
    a.click()
  }

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
            Form 104 - Declaración de IVA
          </h2>
          
          {documents.length === 0 ? (
            <div className="text-center py-12 text-gray-500">
              <FileText size={48} className="mx-auto mb-4" />
              <p>No Form 104 documents uploaded yet</p>
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
                    <FileText className="text-purple-600" size={24} />
                    <span className="text-xs text-gray-500">{doc.periodo}</span>
                  </div>
                  <h3 className="font-medium text-gray-900 mb-1 truncate">{doc.filename}</h3>
                  <p className="text-sm text-gray-600 truncate">{doc.razon_social}</p>
                  <p className="text-xs text-gray-500 mt-2">Fecha: {doc.fecha_recaudacion}</p>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    )
  }

  // Detail View with Tables
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
            <div className="flex items-center justify-between mb-6">
              <div>
                <h2 className="text-2xl font-bold text-gray-900">{formData.filename}</h2>
                <p className="text-gray-600">{formData.razon_social}</p>
                <p className="text-sm text-gray-500">
                  {formData.periodo} | Fecha: {formData.fecha_recaudacion}
                </p>
              </div>
              <button
                onClick={exportToCSV}
                className="flex items-center space-x-2 bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700"
              >
                <Download size={18} />
                <span>Export CSV</span>
              </button>
            </div>

            {/* Ventas (Sales) */}
            <div className="mb-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-3">VENTAS (Sales)</h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="border rounded-lg p-4 bg-blue-50">
                  <p className="text-sm text-gray-600">Ventas Tarifa ≠ 0 (Bruto)</p>
                  <p className="text-xl font-bold text-blue-700">
                    ${formData.ventas.ventas_tarifa_diferente_cero_bruto.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                  </p>
                </div>
                <div className="border rounded-lg p-4 bg-blue-50">
                  <p className="text-sm text-gray-600">Ventas Tarifa ≠ 0 (Neto)</p>
                  <p className="text-xl font-bold text-blue-700">
                    ${formData.ventas.ventas_tarifa_diferente_cero_neto.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                  </p>
                </div>
                <div className="border rounded-lg p-4 bg-green-50">
                  <p className="text-sm text-gray-600">Impuesto Generado</p>
                  <p className="text-xl font-bold text-green-700">
                    ${formData.ventas.impuesto_generado.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                  </p>
                </div>
              </div>
            </div>

            {/* Compras (Purchases) */}
            <div className="mb-6">
              <h3 className="text-lg font-semibold text-gray-900 mb-3">COMPRAS (Purchases)</h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="border rounded-lg p-4 bg-purple-50">
                  <p className="text-sm text-gray-600">Adquisiciones Tarifa ≠ 0 (Bruto)</p>
                  <p className="text-xl font-bold text-purple-700">
                    ${formData.compras.adquisiciones_tarifa_diferente_cero_bruto.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                  </p>
                </div>
                <div className="border rounded-lg p-4 bg-purple-50">
                  <p className="text-sm text-gray-600">Impuesto Compras</p>
                  <p className="text-xl font-bold text-purple-700">
                    ${formData.compras.impuesto_compras.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                  </p>
                </div>
                <div className="border rounded-lg p-4 bg-yellow-50">
                  <p className="text-sm text-gray-600">Crédito Tributario Aplicable</p>
                  <p className="text-xl font-bold text-yellow-700">
                    ${formData.compras.credito_tributario_aplicable.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                  </p>
                </div>
              </div>
            </div>

            {/* Retenciones IVA */}
            {formData.retenciones_iva.length > 0 && (
              <div className="mb-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-3">RETENCIONES IVA</h3>
                <div className="overflow-x-auto">
                  <table className="w-full border-collapse">
                    <thead>
                      <tr className="bg-gray-100 border-b-2 border-gray-300">
                        <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">
                          Porcentaje
                        </th>
                        <th className="px-4 py-3 text-right text-sm font-semibold text-gray-700">
                          Valor
                        </th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200">
                      {formData.retenciones_iva.map((ret: any, index: number) => (
                        <tr key={index} className="hover:bg-gray-50">
                          <td className="px-4 py-3 text-sm text-gray-900">
                            Retención del {ret.porcentaje}%
                          </td>
                          <td className="px-4 py-3 text-sm text-right font-medium text-blue-700">
                            ${ret.valor.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {/* Totals */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-3">TOTALS</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <div className="border rounded-lg p-4 bg-blue-50">
                  <p className="text-sm text-gray-600">Impuesto Causado</p>
                  <p className="text-xl font-bold text-blue-700">
                    ${formData.totals.impuesto_causado.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                  </p>
                </div>
                <div className="border rounded-lg p-4 bg-yellow-50">
                  <p className="text-sm text-gray-600">Retenciones Efectuadas</p>
                  <p className="text-xl font-bold text-yellow-700">
                    ${formData.totals.retenciones_efectuadas.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                  </p>
                </div>
                <div className="border rounded-lg p-4 bg-purple-50">
                  <p className="text-sm text-gray-600">Total Consolidado IVA</p>
                  <p className="text-xl font-bold text-purple-700">
                    ${formData.totals.total_consolidado_iva.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                  </p>
                </div>
                <div className="border rounded-lg p-4 bg-green-50">
                  <p className="text-sm text-gray-600">Total Pagado</p>
                  <p className="text-2xl font-bold text-green-700">
                    ${formData.totals.total_pagado.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                  </p>
                </div>
              </div>
            </div>
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
