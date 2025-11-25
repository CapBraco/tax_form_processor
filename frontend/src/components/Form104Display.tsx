'use client'

import { useState } from 'react'
import { Download, ArrowLeft, Eye, EyeOff } from 'lucide-react'

interface Form104DisplayProps {
  formData: any
  onBack?: () => void
  showBackButton?: boolean
}

export default function Form104Display({ 
  formData, 
  onBack, 
  showBackButton = true 
}: Form104DisplayProps) {
  const [hideZeroValues, setHideZeroValues] = useState(false)

  // Helper function to format field names
  const formatFieldName = (key: string): string => {
    return key
      .replace(/_/g, ' ')
      .split(' ')
      .map(word => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ')
  }

  // Filter functions for each section
  const filterEntries = (entries: [string, any][]) => {
    if (!hideZeroValues) return entries
    return entries.filter(([key, value]) => {
      if (typeof value === 'number') return value !== 0
      return true
    })
  }

  const filteredRetenciones = formData?.retenciones_iva?.filter((ret: any) => {
    if (!hideZeroValues) return true
    return ret.valor !== 0
  }) || []

  const exportToCSV = () => {
    if (!formData) return

    const lines = [
      '=== VENTAS (Sales) ===',
      'Concepto,Valor',
      ...Object.entries(formData.ventas).map(([key, value]) => 
        `${key},${typeof value === 'number' ? value.toFixed(2) : value}`
      ),
      '',
      '=== COMPRAS (Purchases) ===',
      'Concepto,Valor',
      ...Object.entries(formData.compras).map(([key, value]) => 
        `${key},${typeof value === 'number' ? value.toFixed(2) : value}`
      ),
      '',
      '=== RETENCIONES IVA ===',
      'Porcentaje,Valor',
      ...formData.retenciones_iva.map((r: any) => `${r.porcentaje}%,${r.valor.toFixed(2)}`),
      '',
      '=== TOTALS ===',
      'Concepto,Valor',
      ...Object.entries(formData.totals).map(([key, value]) => 
        `${key},${typeof value === 'number' ? value.toFixed(2) : value}`
      ),
    ]

    const csv = lines.join('\n')
    const blob = new Blob([csv], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `form_104_${formData.filename.replace('.pdf', '')}.csv`
    a.click()
  }

  if (!formData) {
    return (
      <div className="text-center py-12 text-gray-500">
        Error loading form data
      </div>
    )
  }

  return (
    <div className="space-y-6">
      <div className="bg-white rounded-lg shadow p-6">
        {showBackButton && onBack && (
          <button
            onClick={onBack}
            className="flex items-center text-blue-600 hover:text-blue-800 mb-4"
          >
            <ArrowLeft size={20} className="mr-2" />
            Volver a la vista general
          </button>
        )}

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
            {/* Zero Values Toggle */}
            <button
              onClick={() => setHideZeroValues(!hideZeroValues)}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg border-2 transition-all ${
                hideZeroValues 
                  ? 'bg-purple-600 text-white border-purple-600' 
                  : 'bg-white text-gray-700 border-gray-300 hover:border-gray-400'
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

        {/* VENTAS (Sales) - Complete Table */}
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-3 bg-blue-100 p-2 rounded">
            VENTAS (Sales)
          </h3>
          <div className="overflow-x-auto">
            <table className="w-full border-collapse">
              <thead>
                <tr className="bg-gray-100 border-b-2 border-gray-300">
                  <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">
                    Concepto
                  </th>
                  <th className="px-4 py-3 text-right text-sm font-semibold text-gray-700">
                    Valor
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filterEntries(Object.entries(formData.ventas)).map(([key, value]) => (
                  <tr key={key} className="hover:bg-gray-50">
                    <td className="px-4 py-3 text-sm text-gray-900">
                      {formatFieldName(key)}
                    </td>
                    <td className="px-4 py-3 text-sm text-right font-medium text-blue-700">
                      ${typeof value === 'number' ? value.toLocaleString('en-US', { 
                        minimumFractionDigits: 2, 
                        maximumFractionDigits: 2 
                      }) : value}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          {hideZeroValues && (
            <div className="mt-2 text-xs text-gray-500 text-right">
              Mostrando {filterEntries(Object.entries(formData.ventas)).length} de {Object.keys(formData.ventas).length} campos
            </div>
          )}
        </div>

        {/* COMPRAS (Purchases) - Complete Table */}
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-3 bg-purple-100 p-2 rounded">
            COMPRAS (Purchases)
          </h3>
          <div className="overflow-x-auto">
            <table className="w-full border-collapse">
              <thead>
                <tr className="bg-gray-100 border-b-2 border-gray-300">
                  <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">
                    Concepto
                  </th>
                  <th className="px-4 py-3 text-right text-sm font-semibold text-gray-700">
                    Valor
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filterEntries(Object.entries(formData.compras)).map(([key, value]) => (
                  <tr key={key} className="hover:bg-gray-50">
                    <td className="px-4 py-3 text-sm text-gray-900">
                      {formatFieldName(key)}
                    </td>
                    <td className="px-4 py-3 text-sm text-right font-medium text-purple-700">
                      ${typeof value === 'number' ? value.toLocaleString('en-US', { 
                        minimumFractionDigits: 2, 
                        maximumFractionDigits: 2 
                      }) : value}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          {hideZeroValues && (
            <div className="mt-2 text-xs text-gray-500 text-right">
              Mostrando {filterEntries(Object.entries(formData.compras)).length} de {Object.keys(formData.compras).length} campos
            </div>
          )}
        </div>

        {/* RETENCIONES IVA - Table */}
        {formData.retenciones_iva && formData.retenciones_iva.length > 0 && (
          <div className="mb-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-3 bg-yellow-100 p-2 rounded">
              RETENCIONES IVA
            </h3>
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
                  {filteredRetenciones.map((ret: any, index: number) => (
                    <tr key={index} className="hover:bg-gray-50">
                      <td className="px-4 py-3 text-sm text-gray-900">
                        Retención del {ret.porcentaje}%
                      </td>
                      <td className="px-4 py-3 text-sm text-right font-medium text-yellow-700">
                        ${ret.valor.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                      </td>
                    </tr>
                  ))}
                </tbody>
                <tfoot className="bg-gray-50 border-t-2 border-gray-300">
                  <tr>
                    <td className="px-4 py-3 text-sm font-semibold text-gray-900">
                      TOTAL RETENCIONES {hideZeroValues && `(${filteredRetenciones.length} de ${formData.retenciones_iva.length})`}
                    </td>
                    <td className="px-4 py-3 text-sm text-right font-bold text-yellow-900">
                      ${filteredRetenciones
                        .reduce((sum: number, ret: any) => sum + ret.valor, 0)
                        .toLocaleString('en-US', { minimumFractionDigits: 2 })}
                    </td>
                  </tr>
                </tfoot>
              </table>
            </div>
            {hideZeroValues && formData.retenciones_iva && (
              <div className="mt-2 text-xs text-gray-500 text-right">
                Mostrando {filteredRetenciones.length} de {formData.retenciones_iva.length} retenciones
              </div>
            )}
          </div>
        )}

        {/* TOTALS - Complete Table */}
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-3 bg-green-100 p-2 rounded">
            TOTALS
          </h3>
          <div className="overflow-x-auto">
            <table className="w-full border-collapse">
              <thead>
                <tr className="bg-gray-100 border-b-2 border-gray-300">
                  <th className="px-4 py-3 text-left text-sm font-semibold text-gray-700">
                    Concepto
                  </th>
                  <th className="px-4 py-3 text-right text-sm font-semibold text-gray-700">
                    Valor
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filterEntries(Object.entries(formData.totals)).map(([key, value]) => {
                  // Highlight important totals
                  const isHighlight = [
                    'total_consolidado_iva',
                    'total_pagado',
                    'total_impuesto_a_pagar',
                    'total_impuesto_pagar_percepcion'
                  ].includes(key)
                  
                  return (
                    <tr 
                      key={key} 
                      className={isHighlight ? 'bg-green-50 hover:bg-green-100' : 'hover:bg-gray-50'}
                    >
                      <td className={`px-4 py-3 text-sm ${isHighlight ? 'font-semibold' : ''} text-gray-900`}>
                        {formatFieldName(key)}
                      </td>
                      <td className={`px-4 py-3 text-sm text-right ${isHighlight ? 'font-bold text-green-900' : 'font-medium text-green-700'}`}>
                        ${typeof value === 'number' ? value.toLocaleString('en-US', { 
                          minimumFractionDigits: 2, 
                          maximumFractionDigits: 2 
                        }) : value}
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>
          {hideZeroValues && (
            <div className="mt-2 text-xs text-gray-500 text-right">
              Mostrando {filterEntries(Object.entries(formData.totals)).length} de {Object.keys(formData.totals).length} campos
            </div>
          )}
        </div>

        {/* Summary Cards - Key Totals */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mt-6">
          <div className="border-2 rounded-lg p-4 bg-blue-50 border-blue-200">
            <p className="text-sm text-gray-600 font-medium">Impuesto Causado</p>
            <p className="text-2xl font-bold text-blue-700">
              ${formData.totals.impuesto_causado?.toLocaleString('en-US', { minimumFractionDigits: 2 })}
            </p>
          </div>
          <div className="border-2 rounded-lg p-4 bg-yellow-50 border-yellow-200">
            <p className="text-sm text-gray-600 font-medium">Retenciones Efectuadas</p>
            <p className="text-2xl font-bold text-yellow-700">
              ${formData.totals.retenciones_efectuadas?.toLocaleString('en-US', { minimumFractionDigits: 2 })}
            </p>
          </div>
          <div className="border-2 rounded-lg p-4 bg-purple-50 border-purple-200">
            <p className="text-sm text-gray-600 font-medium">Total Consolidado IVA</p>
            <p className="text-2xl font-bold text-purple-700">
              ${formData.totals.total_consolidado_iva?.toLocaleString('en-US', { minimumFractionDigits: 2 })}
            </p>
          </div>
          <div className="border-2 rounded-lg p-4 bg-green-50 border-green-200">
            <p className="text-sm text-gray-600 font-medium">Total Pagado</p>
            <p className="text-3xl font-bold text-green-700">
              ${formData.totals.total_pagado?.toLocaleString('en-US', { minimumFractionDigits: 2 })}
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
