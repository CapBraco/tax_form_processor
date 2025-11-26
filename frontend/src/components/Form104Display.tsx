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
  const [hideBrutoValues, setHideBrutoValues] = useState(false)

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
    return entries.filter(([key, value]) => {
      // Filter out zero values if toggle is on
      if (hideZeroValues && typeof value === 'number' && value === 0) {
        return false
      }
      // Filter out bruto fields if toggle is on
      if (hideBrutoValues && key.toLowerCase().includes('bruto')) {
        return false
      }
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
                {hideZeroValues ? 'Mostrar Ceros' : 'Ocultar Ceros'}
              </span>
            </button>

            {/* Bruto Values Toggle */}
            <button
              onClick={() => setHideBrutoValues(!hideBrutoValues)}
              className={`flex items-center gap-2 px-4 py-2 rounded-lg border-2 transition-all ${
                hideBrutoValues 
                  ? 'bg-blue-600 text-white border-blue-600' 
                  : 'bg-white text-gray-700 border-gray-300 hover:border-gray-400'
              }`}
            >
              {hideBrutoValues ? <EyeOff size={18} /> : <Eye size={18} />}
              <span className="text-sm font-medium">
                {hideBrutoValues ? 'Mostrar Bruto' : 'Ocultar Bruto'}
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

        {/* VENTAS (Sales) - Original Format with Codes */}
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-3 bg-blue-100 p-2 rounded">
            RESUMEN DE VENTAS Y OTRAS OPERACIONES DEL PERÍODO QUE DECLARA
          </h3>
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-sm">
              <thead>
                <tr className="bg-blue-600 text-white">
                  <th className="px-3 py-2 text-left font-semibold border border-blue-700">
                    Concepto
                  </th>
                  <th className="px-3 py-2 text-center font-semibold border border-blue-700">
                    Código
                  </th>
                  <th className="px-3 py-2 text-right font-semibold border border-blue-700">
                    VALOR BRUTO
                  </th>
                  <th className="px-3 py-2 text-center font-semibold border border-blue-700">
                    Código
                  </th>
                  <th className="px-3 py-2 text-right font-semibold border border-blue-700">
                    VALOR NETO<br/>
                    <span className="text-xs font-normal">(VALOR BRUTO - N/C)</span>
                  </th>
                  <th className="px-3 py-2 text-center font-semibold border border-blue-700">
                    Código
                  </th>
                  <th className="px-3 py-2 text-right font-semibold border border-blue-700">
                    IMPUESTO<br/>GENERADO
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {/* Ventas locales gravadas tarifa diferente de cero */}
                {(!hideZeroValues || (formData.ventas.ventas_tarifa_diferente_cero_bruto !== 0 || 
                  formData.ventas.ventas_tarifa_diferente_cero_neto !== 0 || 
                  formData.ventas.impuesto_generado !== 0)) && (
                  <tr className="hover:bg-gray-50">
                    <td className="px-3 py-2 text-gray-900 border border-gray-200">
                      Ventas locales (excluye activos fijos) gravadas tarifa diferente de cero
                    </td>
                    <td className="px-3 py-2 text-center text-xs text-gray-600 bg-blue-50 border border-gray-200">401</td>
                    {!hideBrutoValues ? (
                      <td className="px-3 py-2 text-right font-medium text-blue-700 border border-gray-200">
                        ${formData.ventas.ventas_tarifa_diferente_cero_bruto?.toLocaleString('en-US', { 
                          minimumFractionDigits: 2, maximumFractionDigits: 2 
                        }) || '0.00'}
                      </td>
                    ) : (
                      <td className="px-3 py-2 text-center text-xs text-gray-400 bg-gray-50 border border-gray-200">-</td>
                    )}
                    <td className="px-3 py-2 text-center text-xs text-gray-600 bg-blue-50 border border-gray-200">411</td>
                    <td className="px-3 py-2 text-right font-medium text-blue-700 border border-gray-200">
                      ${formData.ventas.ventas_tarifa_diferente_cero_neto?.toLocaleString('en-US', { 
                        minimumFractionDigits: 2, maximumFractionDigits: 2 
                      }) || '0.00'}
                    </td>
                    <td className="px-3 py-2 text-center text-xs text-gray-600 bg-blue-50 border border-gray-200">421</td>
                    <td className="px-3 py-2 text-right font-medium text-green-700 border border-gray-200">
                      ${formData.ventas.impuesto_generado?.toLocaleString('en-US', { 
                        minimumFractionDigits: 2, maximumFractionDigits: 2 
                      }) || '0.00'}
                    </td>
                  </tr>
                )}

                {/* Other VENTAS rows - dynamically show remaining fields */}
                {Object.entries(formData.ventas)
                  .filter(([key]) => !['ventas_tarifa_diferente_cero_bruto', 'ventas_tarifa_diferente_cero_neto', 'impuesto_generado'].includes(key))
                  .filter(([key, value]) => {
                    if (hideZeroValues && typeof value === 'number' && value === 0) return false
                    if (hideBrutoValues && key.toLowerCase().includes('bruto')) return false
                    return true
                  })
                  .map(([key, value]) => (
                    <tr key={key} className="hover:bg-gray-50">
                      <td className="px-3 py-2 text-gray-900 border border-gray-200" colSpan={7}>
                        <div className="flex justify-between items-center">
                          <span>{formatFieldName(key)}</span>
                          <span className="font-medium text-blue-700">
                            ${typeof value === 'number' ? value.toLocaleString('en-US', { 
                              minimumFractionDigits: 2, maximumFractionDigits: 2 
                            }) : value}
                          </span>
                        </div>
                      </td>
                    </tr>
                  ))
                }
              </tbody>
            </table>
          </div>
          {(hideZeroValues || hideBrutoValues) && (
            <div className="mt-2 text-xs text-gray-500 text-right">
              {hideZeroValues && <span className="ml-1 text-purple-600">(ocultando ceros)</span>}
              {hideBrutoValues && <span className="ml-1 text-blue-600">(ocultando bruto)</span>}
            </div>
          )}
        </div>

        {/* COMPRAS (Purchases) - Original Format with Codes */}
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-3 bg-purple-100 p-2 rounded">
            RESUMEN DE ADQUISICIONES Y PAGOS DEL PERÍODO QUE DECLARA
          </h3>
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-sm">
              <thead>
                <tr className="bg-purple-600 text-white">
                  <th className="px-3 py-2 text-left font-semibold border border-purple-700">
                    Concepto
                  </th>
                  <th className="px-3 py-2 text-center font-semibold border border-purple-700">
                    Código
                  </th>
                  <th className="px-3 py-2 text-right font-semibold border border-purple-700">
                    VALOR BRUTO
                  </th>
                  <th className="px-3 py-2 text-center font-semibold border border-purple-700">
                    Código
                  </th>
                  <th className="px-3 py-2 text-right font-semibold border border-purple-700">
                    VALOR NETO<br/>
                    <span className="text-xs font-normal">(VALOR BRUTO - N/C)</span>
                  </th>
                  <th className="px-3 py-2 text-center font-semibold border border-purple-700">
                    Código
                  </th>
                  <th className="px-3 py-2 text-right font-semibold border border-purple-700">
                    IMPUESTO<br/>GENERADO
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {/* Adquisiciones gravadas tarifa diferente de cero */}
                {(!hideZeroValues || (formData.compras.adquisiciones_tarifa_diferente_cero_bruto !== 0 || 
                  formData.compras.adquisiciones_tarifa_diferente_cero_neto !== 0 || 
                  formData.compras.impuesto_compras !== 0)) && (
                  <tr className="hover:bg-gray-50">
                    <td className="px-3 py-2 text-gray-900 border border-gray-200">
                      Adquisiciones y pagos (excluye activos fijos) gravados tarifa diferente de cero (con derecho a crédito tributario)
                    </td>
                    <td className="px-3 py-2 text-center text-xs text-gray-600 bg-purple-50 border border-gray-200">500</td>
                    {!hideBrutoValues ? (
                      <td className="px-3 py-2 text-right font-medium text-purple-700 border border-gray-200">
                        ${formData.compras.adquisiciones_tarifa_diferente_cero_bruto?.toLocaleString('en-US', { 
                          minimumFractionDigits: 2, maximumFractionDigits: 2 
                        }) || '0.00'}
                      </td>
                    ) : (
                      <td className="px-3 py-2 text-center text-xs text-gray-400 bg-gray-50 border border-gray-200">-</td>
                    )}
                    <td className="px-3 py-2 text-center text-xs text-gray-600 bg-purple-50 border border-gray-200">510</td>
                    <td className="px-3 py-2 text-right font-medium text-purple-700 border border-gray-200">
                      ${formData.compras.adquisiciones_tarifa_diferente_cero_neto?.toLocaleString('en-US', { 
                        minimumFractionDigits: 2, maximumFractionDigits: 2 
                      }) || '0.00'}
                    </td>
                    <td className="px-3 py-2 text-center text-xs text-gray-600 bg-purple-50 border border-gray-200">520</td>
                    <td className="px-3 py-2 text-right font-medium text-green-700 border border-gray-200">
                      ${formData.compras.impuesto_compras?.toLocaleString('en-US', { 
                        minimumFractionDigits: 2, maximumFractionDigits: 2 
                      }) || '0.00'}
                    </td>
                  </tr>
                )}

                {/* Other COMPRAS rows - dynamically show remaining fields */}
                {Object.entries(formData.compras)
                  .filter(([key]) => !['adquisiciones_tarifa_diferente_cero_bruto', 'adquisiciones_tarifa_diferente_cero_neto', 'impuesto_compras'].includes(key))
                  .filter(([key, value]) => {
                    if (hideZeroValues && typeof value === 'number' && value === 0) return false
                    if (hideBrutoValues && key.toLowerCase().includes('bruto')) return false
                    return true
                  })
                  .map(([key, value]) => (
                    <tr key={key} className="hover:bg-gray-50">
                      <td className="px-3 py-2 text-gray-900 border border-gray-200" colSpan={7}>
                        <div className="flex justify-between items-center">
                          <span>{formatFieldName(key)}</span>
                          <span className="font-medium text-purple-700">
                            ${typeof value === 'number' ? value.toLocaleString('en-US', { 
                              minimumFractionDigits: 2, maximumFractionDigits: 2 
                            }) : value}
                          </span>
                        </div>
                      </td>
                    </tr>
                  ))
                }
              </tbody>
            </table>
          </div>
          {(hideZeroValues || hideBrutoValues) && (
            <div className="mt-2 text-xs text-gray-500 text-right">
              {hideZeroValues && <span className="ml-1 text-purple-600">(ocultando ceros)</span>}
              {hideBrutoValues && <span className="ml-1 text-blue-600">(ocultando bruto)</span>}
            </div>
          )}
        </div>

        {/* RETENCIONES IVA - Original Format with Codes */}
        {formData.retenciones_iva && formData.retenciones_iva.length > 0 && (
          <div className="mb-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-3 bg-yellow-100 p-2 rounded">
              AGENTE DE RETENCIÓN DEL IMPUESTO AL VALOR AGREGADO
            </h3>
            <div className="overflow-x-auto">
              <table className="w-full border-collapse text-sm">
                <thead>
                  <tr className="bg-yellow-600 text-white">
                    <th className="px-3 py-2 text-left font-semibold border border-yellow-700">
                      Porcentaje de Retención
                    </th>
                    <th className="px-3 py-2 text-center font-semibold border border-yellow-700">
                      Código
                    </th>
                    <th className="px-3 py-2 text-right font-semibold border border-yellow-700">
                      Valor
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {filteredRetenciones.map((ret: any, index: number) => {
                    // Get field code based on percentage
                    const getRetentionCode = (percentage: number) => {
                      const codes: Record<number, string> = {
                        10: '721',
                        20: '723',
                        30: '725',
                        50: '727',
                        70: '729',
                        100: '731'
                      }
                      return codes[percentage] || ''
                    }

                    return (
                      <tr key={index} className="hover:bg-gray-50">
                        <td className="px-3 py-2 text-gray-900 border border-gray-200">
                          Retención del {ret.porcentaje}%
                        </td>
                        <td className="px-3 py-2 text-center text-xs text-gray-600 bg-yellow-50 border border-gray-200">
                          {getRetentionCode(ret.porcentaje)}
                        </td>
                        <td className="px-3 py-2 text-right font-medium text-yellow-700 border border-gray-200">
                          ${ret.valor.toLocaleString('en-US', { minimumFractionDigits: 2 })}
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
                <tfoot className="bg-yellow-50 border-t-2 border-yellow-600">
                  <tr>
                    <td className="px-3 py-3 text-sm font-semibold text-gray-900 border border-gray-200">
                      TOTAL IMPUESTO RETENIDO {hideZeroValues && `(${filteredRetenciones.length} de ${formData.retenciones_iva.length})`}
                    </td>
                    <td className="px-3 py-3 text-center text-xs text-gray-600 bg-yellow-100 border border-gray-200 font-semibold">
                      799
                    </td>
                    <td className="px-3 py-3 text-right font-bold text-yellow-900 border border-gray-200">
                      ${filteredRetenciones
                        .reduce((sum: number, ret: any) => sum + ret.valor, 0)
                        .toLocaleString('en-US', { minimumFractionDigits: 2 })}
                    </td>
                  </tr>
                </tfoot>
              </table>
            </div>
            {(hideZeroValues || hideBrutoValues) && formData.retenciones_iva && (
              <div className="mt-2 text-xs text-gray-500 text-right">
                {hideZeroValues && filteredRetenciones.length < formData.retenciones_iva.length && (
                  <span className="ml-1 text-purple-600">(ocultando ceros)</span>
                )}
              </div>
            )}
          </div>
        )}

        {/* TOTALS - Original Format with Codes */}
        <div className="mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-3 bg-green-100 p-2 rounded">
            RESUMEN IMPOSITIVO
          </h3>
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-sm">
              <thead>
                <tr className="bg-green-600 text-white">
                  <th className="px-3 py-2 text-left font-semibold border border-green-700">
                    Concepto
                  </th>
                  <th className="px-3 py-2 text-center font-semibold border border-green-700">
                    Código
                  </th>
                  <th className="px-3 py-2 text-right font-semibold border border-green-700">
                    Valor
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {Object.entries(formData.totals)
                  .filter(([key, value]) => {
                    if (hideZeroValues && typeof value === 'number' && value === 0) return false
                    if (hideBrutoValues && key.toLowerCase().includes('bruto')) return false
                    return true
                  })
                  .map(([key, value]) => {
                    // Highlight important totals
                    const isHighlight = [
                      'total_consolidado_iva',
                      'total_pagado',
                      'total_impuesto_a_pagar',
                      'total_impuesto_pagar_percepcion',
                      'impuesto_causado'
                    ].includes(key)
                    
                    // Get field code based on key name (you may need to map these properly)
                    const getFieldCode = (fieldKey: string) => {
                      const codes: Record<string, string> = {
                        'impuesto_causado': '601',
                        'credito_tributario_aplicable': '602',
                        'retenciones_efectuadas': '609',
                        'total_consolidado_iva': '859',
                        'total_pagado': '999',
                        'subtotal_a_pagar': '620',
                        'total_impuesto_pagar_percepcion': '699'
                      }
                      return codes[fieldKey] || ''
                    }
                    
                    return (
                      <tr 
                        key={key} 
                        className={isHighlight ? 'bg-green-50 hover:bg-green-100' : 'hover:bg-gray-50'}
                      >
                        <td className={`px-3 py-2 text-gray-900 border border-gray-200 ${isHighlight ? 'font-semibold' : ''}`}>
                          {formatFieldName(key)}
                        </td>
                        <td className="px-3 py-2 text-center text-xs text-gray-600 bg-green-50 border border-gray-200">
                          {getFieldCode(key)}
                        </td>
                        <td className={`px-3 py-2 text-right border border-gray-200 ${isHighlight ? 'font-bold text-green-900' : 'font-medium text-green-700'}`}>
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
          {(hideZeroValues || hideBrutoValues) && (
            <div className="mt-2 text-xs text-gray-500 text-right">
              {hideZeroValues && <span className="ml-1 text-purple-600">(ocultando ceros)</span>}
              {hideBrutoValues && <span className="ml-1 text-blue-600">(ocultando bruto)</span>}
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
