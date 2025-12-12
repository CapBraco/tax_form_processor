'use client'

import { useState } from 'react'
import { Download, ArrowLeft, Eye, EyeOff, ChevronDown, ChevronUp } from 'lucide-react'

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
  
  // Accordion states
  const [openSections, setOpenSections] = useState<Record<string, boolean>>({
    ventas: true,
    liquidacion: false,
    compras: true,
    resumen: false,
    exportaciones: false,
    retenciones: true,
    totales: true
  })

  const toggleSection = (section: string) => {
    setOpenSections(prev => ({ ...prev, [section]: !prev[section] }))
  }

  const filteredRetenciones = formData?.retenciones_iva?.filter((ret: any) => {
    if (!hideZeroValues) return true
    return ret.valor !== 0
  }) || []

  const exportToCSV = () => {
    if (!formData) return
    const lines = [
      '=== FORM 104 COMPLETE DATA ===',
      'Section,Field,Value',
      ...Object.entries(formData.ventas || {}).map(([key, value]) => 
        `VENTAS,${key},${typeof value === 'number' ? value.toFixed(2) : value}`
      ),
      ...Object.entries(formData.compras || {}).map(([key, value]) => 
        `COMPRAS,${key},${typeof value === 'number' ? value.toFixed(2) : value}`
      ),
      ...Object.entries(formData.totals || {}).map(([key, value]) => 
        `TOTALS,${key},${typeof value === 'number' ? value.toFixed(2) : value}`
      ),
    ]
    const csv = lines.join('\n')
    const blob = new Blob([csv], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `form_104_complete_${formData.document?.filename || 'export'}.csv`
    a.click()
  }

  if (!formData) {
    return (
      <div className="text-center py-12 text-gray-500 dark:text-gray-400">
        Error loading form data
      </div>
    )
  }

  const isRowZero = (bruto?: number, neto?: number, impuesto?: number) => {
    if (!hideZeroValues) return false
    return (bruto === 0 || bruto === undefined) && 
           (neto === 0 || neto === undefined) && 
           (impuesto === 0 || impuesto === undefined)
  }

  const shouldHideSingleValue = (value?: number) => {
    if (!hideZeroValues) return false
    return value === 0 || value === undefined
  }

  const formatValue = (value: any) => {
    if (typeof value === 'number') {
      return value.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
    }
    return value || '0.00'
  }

  const ventas = formData.ventas || {}
  const compras = formData.compras || {}
  const totals = formData.totals || {}

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

  return (
    <div className="space-y-6">
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-4 md:p-6">
        {showBackButton && onBack && (
          <button
            onClick={onBack}
            className="flex items-center text-blue-600 dark:text-blue-400 hover:text-blue-800 dark:hover:text-blue-300 mb-4"
          >
            <ArrowLeft size={20} className="mr-2" />
            Volver a la vista general
          </button>
        )}

        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-6 gap-4">
          <div className="min-w-0">
            <h2 className="text-xl md:text-2xl font-bold text-gray-900 dark:text-gray-100 truncate">
              {formData.document?.filename || formData.filename || 'Form 104'}
            </h2>
            <p className="text-gray-600 dark:text-gray-400 truncate">
              {formData.document?.razon_social || formData.razon_social || 'N/A'}
            </p>
            <p className="text-xs md:text-sm text-gray-500">
              {formData.document?.periodo || formData.periodo || 'N/A'}
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
              onClick={() => setHideBrutoValues(!hideBrutoValues)}
              className={`flex items-center justify-center gap-2 px-3 py-2 rounded-lg border-2 transition-all text-xs md:text-sm ${
                hideBrutoValues 
                  ? 'bg-blue-600 text-white border-blue-600' 
                  : 'bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-200 border-gray-300 dark:border-gray-600'
              }`}
            >
              {hideBrutoValues ? <EyeOff size={16} /> : <Eye size={16} />}
              <span className="font-medium whitespace-nowrap">
                {hideBrutoValues ? 'Mostrar Bruto' : 'Ocultar Bruto'}
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

        {/* SECTION 1: VENTAS */}
        <AccordionSection 
          id="ventas" 
          title="RESUMEN DE VENTAS Y OTRAS OPERACIONES (401-454)" 
          bgColor="bg-blue-600"
        >
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-xs">
              <thead>
                <tr className="bg-blue-600 text-white">
                  <th className="px-2 py-2 text-left border border-blue-700">Concepto</th>
                  <th className="px-2 py-2 text-center border border-blue-700 w-12">Cód</th>
                  <th className="px-2 py-2 text-right border border-blue-700 min-w-[80px]">VALOR BRUTO</th>
                  <th className="px-2 py-2 text-center border border-blue-700 w-12">Cód</th>
                  <th className="px-2 py-2 text-right border border-blue-700 min-w-[80px]">VALOR NETO</th>
                  <th className="px-2 py-2 text-center border border-blue-700 w-12">Cód</th>
                  <th className="px-2 py-2 text-right border border-blue-700 min-w-[80px]">IMPUESTO</th>
                </tr>
              </thead>
              <tbody>
                {/* Row 401-411-421 */}
                {!isRowZero(ventas.ventas_tarifa_diferente_cero_bruto, ventas.ventas_tarifa_diferente_cero_neto, ventas.impuesto_generado) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100">Ventas locales (excluye activos fijos) gravadas tarifa diferente de cero</td>
                    <td className="px-2 py-1 text-center border bg-blue-50 dark:bg-blue-900/20 text-gray-600 dark:text-gray-400">401</td>
                    {!hideBrutoValues ? (
                      <td className="px-2 py-1 text-right border font-medium text-blue-700 dark:text-blue-400">${formatValue(ventas.ventas_tarifa_diferente_cero_bruto)}</td>
                    ) : (
                      <td className="px-2 py-1 text-center border text-gray-400">-</td>
                    )}
                    <td className="px-2 py-1 text-center border bg-blue-50 dark:bg-blue-900/20 text-gray-600 dark:text-gray-400">411</td>
                    <td className="px-2 py-1 text-right border font-medium text-blue-700 dark:text-blue-400">${formatValue(ventas.ventas_tarifa_diferente_cero_neto)}</td>
                    <td className="px-2 py-1 text-center border bg-blue-50 dark:bg-blue-900/20 text-gray-600 dark:text-gray-400">421</td>
                    <td className="px-2 py-1 text-right border font-medium text-green-700 dark:text-green-400">${formatValue(ventas.impuesto_generado)}</td>
                  </tr>
                )}

                {/* Row 402-412-422 */}
                {!isRowZero(ventas.ventas_activos_fijos_bruto, ventas.ventas_activos_fijos_neto, ventas.impuesto_generado_activos_fijos) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100">Ventas de activos fijos gravadas tarifa diferente de cero</td>
                    <td className="px-2 py-1 text-center border bg-blue-50 dark:bg-blue-900/20 text-gray-600 dark:text-gray-400">402</td>
                    {!hideBrutoValues ? (
                      <td className="px-2 py-1 text-right border font-medium text-blue-700 dark:text-blue-400">${formatValue(ventas.ventas_activos_fijos_bruto)}</td>
                    ) : (
                      <td className="px-2 py-1 text-center border text-gray-400">-</td>
                    )}
                    <td className="px-2 py-1 text-center border bg-blue-50 dark:bg-blue-900/20 text-gray-600 dark:text-gray-400">412</td>
                    <td className="px-2 py-1 text-right border font-medium text-blue-700 dark:text-blue-400">${formatValue(ventas.ventas_activos_fijos_neto)}</td>
                    <td className="px-2 py-1 text-center border bg-blue-50 dark:bg-blue-900/20 text-gray-600 dark:text-gray-400">422</td>
                    <td className="px-2 py-1 text-right border font-medium text-green-700 dark:text-green-400">${formatValue(ventas.impuesto_generado_activos_fijos)}</td>
                  </tr>
                )}

                {/* Row 425-435-445 */}
                {!isRowZero(ventas.ventas_tarifa_5_bruto, ventas.ventas_tarifa_5_neto, ventas.impuesto_generado_tarifa_5) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100">Ventas locales (excluye activos fijos) gravadas tarifa 5%</td>
                    <td className="px-2 py-1 text-center border bg-blue-50 dark:bg-blue-900/20 text-gray-600 dark:text-gray-400">425</td>
                    {!hideBrutoValues ? (
                      <td className="px-2 py-1 text-right border font-medium text-blue-700 dark:text-blue-400">${formatValue(ventas.ventas_tarifa_5_bruto)}</td>
                    ) : (
                      <td className="px-2 py-1 text-center border text-gray-400">-</td>
                    )}
                    <td className="px-2 py-1 text-center border bg-blue-50 dark:bg-blue-900/20 text-gray-600 dark:text-gray-400">435</td>
                    <td className="px-2 py-1 text-right border font-medium text-blue-700 dark:text-blue-400">${formatValue(ventas.ventas_tarifa_5_neto)}</td>
                    <td className="px-2 py-1 text-center border bg-blue-50 dark:bg-blue-900/20 text-gray-600 dark:text-gray-400">445</td>
                    <td className="px-2 py-1 text-right border font-medium text-green-700 dark:text-green-400">${formatValue(ventas.impuesto_generado_tarifa_5)}</td>
                  </tr>
                )}

                {/* Row 423 (adjustment pagar) */}
                {!shouldHideSingleValue(ventas.iva_ajuste_pagar) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100" colSpan={5}>IVA generado en la diferencia entre ventas y notas de crédito con distinta tarifa (ajuste a pagar)</td>
                    <td className="px-2 py-1 text-center border bg-blue-50 dark:bg-blue-900/20 text-gray-600 dark:text-gray-400">423</td>
                    <td className="px-2 py-1 text-right border font-medium text-blue-700 dark:text-blue-400">${formatValue(ventas.iva_ajuste_pagar)}</td>
                  </tr>
                )}

                {/* Row 424 (adjustment favor) */}
                {!shouldHideSingleValue(ventas.iva_ajuste_favor) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100" colSpan={5}>IVA generado en la diferencia entre ventas y notas de crédito con distinta tarifa (ajuste a favor)</td>
                    <td className="px-2 py-1 text-center border bg-blue-50 dark:bg-blue-900/20 text-gray-600 dark:text-gray-400">424</td>
                    <td className="px-2 py-1 text-right border font-medium text-blue-700 dark:text-blue-400">${formatValue(ventas.iva_ajuste_favor)}</td>
                  </tr>
                )}

                {/* TOTAL ROW */}
                <tr className="bg-yellow-50 dark:bg-yellow-900/20 font-bold">
                  <td className="px-2 py-2 border dark:text-gray-100">TOTAL VENTAS Y OTRAS OPERACIONES</td>
                  <td className="px-2 py-2 text-center border bg-yellow-100 dark:bg-yellow-900/30">409</td>
                  {!hideBrutoValues ? (
                    <td className="px-2 py-2 text-right border text-blue-900 dark:text-blue-300">${formatValue(ventas.total_ventas_bruto)}</td>
                  ) : (
                    <td className="px-2 py-2 text-center border text-gray-400">-</td>
                  )}
                  <td className="px-2 py-2 text-center border bg-yellow-100 dark:bg-yellow-900/30">419</td>
                  <td className="px-2 py-2 text-right border text-blue-900 dark:text-blue-300">${formatValue(ventas.total_ventas_neto)}</td>
                  <td className="px-2 py-2 text-center border bg-yellow-100 dark:bg-yellow-900/30">429</td>
                  <td className="px-2 py-2 text-right border text-green-900 dark:text-green-300">${formatValue(ventas.total_impuesto_generado)}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </AccordionSection>

        {/* SECTION 2: LIQUIDACIÓN */}
        <AccordionSection 
          id="liquidacion" 
          title="LIQUIDACIÓN DEL IVA EN EL MES (480-499)" 
          bgColor="bg-indigo-600"
        >
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-xs">
              <tbody>
                {!shouldHideSingleValue(ventas.transferencias_contado) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100">Total transferencias gravadas tarifa diferente de cero a contado este mes</td>
                    <td className="px-2 py-1 text-center border bg-indigo-50 dark:bg-indigo-900/20 w-12">480</td>
                    <td className="px-2 py-1 text-right border font-medium text-indigo-700 dark:text-indigo-400 min-w-[100px]">${formatValue(ventas.transferencias_contado)}</td>
                  </tr>
                )}

                {!shouldHideSingleValue(ventas.transferencias_credito) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100">Total transferencias gravadas tarifa diferente de cero a crédito este mes</td>
                    <td className="px-2 py-1 text-center border bg-indigo-50 dark:bg-indigo-900/20 w-12">481</td>
                    <td className="px-2 py-1 text-right border font-medium text-indigo-700 dark:text-indigo-400 min-w-[100px]">${formatValue(ventas.transferencias_credito)}</td>
                  </tr>
                )}

                {!shouldHideSingleValue(ventas.impuesto_liquidar_mes_anterior) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100">Impuesto a liquidar del mes anterior</td>
                    <td className="px-2 py-1 text-center border bg-indigo-50 dark:bg-indigo-900/20 w-12">483</td>
                    <td className="px-2 py-1 text-right border font-medium text-indigo-700 dark:text-indigo-400 min-w-[100px]">${formatValue(ventas.impuesto_liquidar_mes_anterior)}</td>
                  </tr>
                )}

                {!shouldHideSingleValue(ventas.impuesto_liquidar_este_mes) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100">Impuesto a liquidar en este mes</td>
                    <td className="px-2 py-1 text-center border bg-indigo-50 dark:bg-indigo-900/20 w-12">484</td>
                    <td className="px-2 py-1 text-right border font-medium text-indigo-700 dark:text-indigo-400 min-w-[100px]">${formatValue(ventas.impuesto_liquidar_este_mes)}</td>
                  </tr>
                )}

                {!shouldHideSingleValue(ventas.impuesto_liquidar_proximo_mes) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100">Impuesto a liquidar en el próximo mes</td>
                    <td className="px-2 py-1 text-center border bg-indigo-50 dark:bg-indigo-900/20 w-12">485</td>
                    <td className="px-2 py-1 text-right border font-medium text-indigo-700 dark:text-indigo-400 min-w-[100px]">${formatValue(ventas.impuesto_liquidar_proximo_mes)}</td>
                  </tr>
                )}

                <tr className="bg-yellow-50 dark:bg-yellow-900/20 font-bold">
                  <td className="px-2 py-2 border dark:text-gray-100">TOTAL IMPUESTO A LIQUIDAR EN ESTE MES</td>
                  <td className="px-2 py-2 text-center border bg-yellow-100 dark:bg-yellow-900/30 w-12">499</td>
                  <td className="px-2 py-2 text-right border text-indigo-900 dark:text-indigo-300 min-w-[100px]">${formatValue(ventas.total_impuesto_liquidar || ventas.impuesto_liquidar_este_mes)}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </AccordionSection>

        {/* SECTION 3: COMPRAS */}
        <AccordionSection 
          id="compras" 
          title="RESUMEN DE ADQUISICIONES Y PAGOS (500-565)" 
          bgColor="bg-purple-600"
        >
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-xs">
              <thead>
                <tr className="bg-purple-600 text-white">
                  <th className="px-2 py-2 text-left border border-purple-700">Concepto</th>
                  <th className="px-2 py-2 text-center border border-purple-700 w-12">Cód</th>
                  <th className="px-2 py-2 text-right border border-purple-700 min-w-[80px]">VALOR BRUTO</th>
                  <th className="px-2 py-2 text-center border border-purple-700 w-12">Cód</th>
                  <th className="px-2 py-2 text-right border border-purple-700 min-w-[80px]">VALOR NETO</th>
                  <th className="px-2 py-2 text-center border border-purple-700 w-12">Cód</th>
                  <th className="px-2 py-2 text-right border border-purple-700 min-w-[80px]">IMPUESTO</th>
                </tr>
              </thead>
              <tbody>
                {/* Row 500-510-520 */}
                {!isRowZero(compras.adquisiciones_tarifa_diferente_cero_bruto, compras.adquisiciones_tarifa_diferente_cero_neto, compras.impuesto_compras) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100">Adquisiciones y pagos (excluye activos fijos) gravados tarifa diferente de cero (con derecho a crédito tributario)</td>
                    <td className="px-2 py-1 text-center border bg-purple-50 dark:bg-purple-900/20">500</td>
                    {!hideBrutoValues ? (
                      <td className="px-2 py-1 text-right border font-medium text-purple-700 dark:text-purple-400">${formatValue(compras.adquisiciones_tarifa_diferente_cero_bruto)}</td>
                    ) : (
                      <td className="px-2 py-1 text-center border text-gray-400">-</td>
                    )}
                    <td className="px-2 py-1 text-center border bg-purple-50 dark:bg-purple-900/20">510</td>
                    <td className="px-2 py-1 text-right border font-medium text-purple-700 dark:text-purple-400">${formatValue(compras.adquisiciones_tarifa_diferente_cero_neto)}</td>
                    <td className="px-2 py-1 text-center border bg-purple-50 dark:bg-purple-900/20">520</td>
                    <td className="px-2 py-1 text-right border font-medium text-green-700 dark:text-green-400">${formatValue(compras.impuesto_compras)}</td>
                  </tr>
                )}

                {/* TOTAL ROW */}
                <tr className="bg-yellow-50 dark:bg-yellow-900/20 font-bold">
                  <td className="px-2 py-2 border dark:text-gray-100">TOTAL ADQUISICIONES Y PAGOS</td>
                  <td className="px-2 py-2 text-center border bg-yellow-100 dark:bg-yellow-900/30">509</td>
                  {!hideBrutoValues ? (
                    <td className="px-2 py-2 text-right border text-purple-900 dark:text-purple-300">${formatValue(compras.total_adquisiciones)}</td>
                  ) : (
                    <td className="px-2 py-2 text-center border text-gray-400">-</td>
                  )}
                  <td className="px-2 py-2 text-center border bg-yellow-100 dark:bg-yellow-900/30">519</td>
                  <td className="px-2 py-2 text-right border text-purple-900 dark:text-purple-300">${formatValue(compras.total_adquisiciones_neto || compras.total_adquisiciones)}</td>
                  <td className="px-2 py-2 text-center border bg-yellow-100 dark:bg-yellow-900/30">529</td>
                  <td className="px-2 py-2 text-right border text-green-900 dark:text-green-300">${formatValue(compras.total_impuesto_compras || compras.impuesto_compras)}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </AccordionSection>

        {/* SECTION 4: RESUMEN IMPOSITIVO */}
        <AccordionSection 
          id="resumen" 
          title="RESUMEN IMPOSITIVO (601-699)" 
          bgColor="bg-teal-600"
        >
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-xs">
              <tbody>
                {!shouldHideSingleValue(totals.impuesto_causado) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100">Impuesto causado</td>
                    <td className="px-2 py-1 text-center border bg-teal-50 dark:bg-teal-900/20 w-12">601</td>
                    <td className="px-2 py-1 text-right border font-medium text-teal-700 dark:text-teal-400 min-w-[100px]">${formatValue(totals.impuesto_causado)}</td>
                  </tr>
                )}

                {!shouldHideSingleValue(totals.credito_tributario_aplicable) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100">Crédito tributario aplicable en este periodo</td>
                    <td className="px-2 py-1 text-center border bg-teal-50 dark:bg-teal-900/20 w-12">602</td>
                    <td className="px-2 py-1 text-right border font-medium text-teal-700 dark:text-teal-400 min-w-[100px]">${formatValue(totals.credito_tributario_aplicable)}</td>
                  </tr>
                )}

                {!shouldHideSingleValue(totals.retenciones_efectuadas) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100">(-) Retenciones en la fuente de IVA que le han sido efectuadas en este período</td>
                    <td className="px-2 py-1 text-center border bg-teal-50 dark:bg-teal-900/20 w-12">609</td>
                    <td className="px-2 py-1 text-right border font-medium text-teal-700 dark:text-teal-400 min-w-[100px]">${formatValue(totals.retenciones_efectuadas)}</td>
                  </tr>
                )}

                {!shouldHideSingleValue(totals.subtotal_a_pagar) && (
                  <tr className="bg-gray-200 dark:bg-gray-600 font-semibold">
                    <td className="px-2 py-2 border dark:text-gray-100">SUBTOTAL A PAGAR</td>
                    <td className="px-2 py-2 text-center border bg-gray-300 dark:bg-gray-500 w-12">620</td>
                    <td className="px-2 py-2 text-right border text-teal-900 dark:text-teal-300 min-w-[100px]">${formatValue(totals.subtotal_a_pagar)}</td>
                  </tr>
                )}

                <tr className="bg-yellow-50 dark:bg-yellow-900/20 font-bold">
                  <td className="px-2 py-2 border dark:text-gray-100">TOTAL IMPUESTO A PAGAR POR PERCEPCIÓN Y RETENCIONES</td>
                  <td className="px-2 py-2 text-center border bg-yellow-100 dark:bg-yellow-900/30 w-12">699</td>
                  <td className="px-2 py-2 text-right border text-teal-900 dark:text-teal-300 min-w-[100px]">${formatValue(totals.total_impuesto_pagar_percepcion)}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </AccordionSection>

        {/* SECTION 5: EXPORTACIONES */}
        <AccordionSection 
          id="exportaciones" 
          title="EXPORTACIONES - ISD (700-702)" 
          bgColor="bg-cyan-600"
        >
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-xs">
              <tbody>
                <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                  <td className="px-2 py-1 border dark:text-gray-100">Importaciones de materias primas (Valor)</td>
                  <td className="px-2 py-1 text-center border bg-cyan-50 dark:bg-cyan-900/20 w-12">700</td>
                  <td className="px-2 py-1 text-right border font-medium text-cyan-700 dark:text-cyan-400 min-w-[100px]">${formatValue(formData.exportaciones?.importaciones_materias_primas_valor || 0)}</td>
                </tr>
                <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                  <td className="px-2 py-1 border dark:text-gray-100">ISD Pagado</td>
                  <td className="px-2 py-1 text-center border bg-cyan-50 dark:bg-cyan-900/20 w-12">701</td>
                  <td className="px-2 py-1 text-right border font-medium text-cyan-700 dark:text-cyan-400 min-w-[100px]">${formatValue(formData.exportaciones?.isd_pagado || 0)}</td>
                </tr>
                <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                  <td className="px-2 py-1 border dark:text-gray-100">Proporción del ingreso neto de divisas</td>
                  <td className="px-2 py-1 text-center border bg-cyan-50 dark:bg-cyan-900/20 w-12">702</td>
                  <td className="px-2 py-1 text-right border font-medium text-cyan-700 dark:text-cyan-400 min-w-[100px]">{formatValue(formData.exportaciones?.proporcion_ingreso_neto_divisas || 0)}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </AccordionSection>

        {/* SECTION 6: RETENCIONES */}
        <AccordionSection 
          id="retenciones" 
          title="AGENTE DE RETENCIÓN DEL IVA (721-801)" 
          bgColor="bg-yellow-600"
        >
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-xs">
              <thead>
                <tr className="bg-yellow-600 text-white">
                  <th className="px-2 py-2 text-left border border-yellow-700">Porcentaje de Retención</th>
                  <th className="px-2 py-2 text-center border border-yellow-700 w-12">Código</th>
                  <th className="px-2 py-2 text-right border border-yellow-700 min-w-[120px]">Valor</th>
                </tr>
              </thead>
              <tbody>
                {filteredRetenciones.map((ret: any, index: number) => {
                  const getRetentionCode = (percentage: number) => {
                    const codes: Record<number, string> = {
                      10: '721', 20: '723', 30: '725', 50: '727', 70: '729', 100: '731'
                    }
                    return codes[percentage] || ''
                  }

                  return (
                    <tr key={index} className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                      <td className="px-2 py-1 border dark:text-gray-100">Retención del {ret.porcentaje}%</td>
                      <td className="px-2 py-1 text-center border bg-yellow-50 dark:bg-yellow-900/20">{getRetentionCode(ret.porcentaje)}</td>
                      <td className="px-2 py-1 text-right border font-medium text-yellow-700 dark:text-yellow-400">${ret.valor.toLocaleString('en-US', { minimumFractionDigits: 2 })}</td>
                    </tr>
                  )
                })}
              </tbody>
              <tfoot className="bg-yellow-50 dark:bg-yellow-900/20 border-t-2 border-yellow-600">
                <tr>
                  <td className="px-2 py-3 font-semibold border dark:text-gray-100">TOTAL IMPUESTO RETENIDO</td>
                  <td className="px-2 py-3 text-center border bg-yellow-100 dark:bg-yellow-900/30 font-semibold">799</td>
                  <td className="px-2 py-3 text-right border font-bold text-yellow-900 dark:text-yellow-300">
                    ${filteredRetenciones.reduce((sum: number, ret: any) => sum + ret.valor, 0).toLocaleString('en-US', { minimumFractionDigits: 2 })}
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>
        </AccordionSection>

        {/* SECTION 7: TOTALES FINALES */}
        <AccordionSection 
          id="totales" 
          title="TOTALES FINALES (859, 902-999)" 
          bgColor="bg-green-600"
        >
          <div className="overflow-x-auto">
            <table className="w-full border-collapse text-xs">
              <tbody>
                <tr className="bg-blue-100 dark:bg-blue-900/30 font-bold">
                  <td className="px-2 py-2 border dark:text-gray-100">TOTAL CONSOLIDADO DE IMPUESTO AL VALOR AGREGADO</td>
                  <td className="px-2 py-2 text-center border bg-blue-200 dark:bg-blue-900/40 w-12">859</td>
                  <td className="px-2 py-2 text-right border text-blue-900 dark:text-blue-300 min-w-[100px]">${formatValue(totals.total_consolidado_iva)}</td>
                </tr>

                <tr className="bg-yellow-100 dark:bg-yellow-900/30 font-bold text-base">
                  <td className="px-2 py-3 border dark:text-gray-100">TOTAL IMPUESTO A PAGAR</td>
                  <td className="px-2 py-3 text-center border bg-yellow-200 dark:bg-yellow-900/40 w-12">902</td>
                  <td className="px-2 py-3 text-right border text-yellow-900 dark:text-yellow-300 min-w-[100px]">${formatValue(totals.total_impuesto_a_pagar)}</td>
                </tr>

                {!shouldHideSingleValue(totals.interes_mora) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100">Interés por mora</td>
                    <td className="px-2 py-1 text-center border bg-gray-50 dark:bg-gray-800 w-12">903</td>
                    <td className="px-2 py-1 text-right border font-medium text-gray-700 dark:text-gray-400 min-w-[100px]">${formatValue(totals.interes_mora)}</td>
                  </tr>
                )}

                {!shouldHideSingleValue(totals.multa) && (
                  <tr className="hover:bg-gray-50 dark:hover:bg-gray-700/50">
                    <td className="px-2 py-1 border dark:text-gray-100">Multa</td>
                    <td className="px-2 py-1 text-center border bg-gray-50 dark:bg-gray-800 w-12">904</td>
                    <td className="px-2 py-1 text-right border font-medium text-gray-700 dark:text-gray-400 min-w-[100px]">${formatValue(totals.multa)}</td>
                  </tr>
                )}

                <tr className="bg-green-100 dark:bg-green-900/30 font-bold text-lg">
                  <td className="px-3 py-4 border dark:text-gray-100">TOTAL PAGADO</td>
                  <td className="px-3 py-4 text-center border bg-green-200 dark:bg-green-900/40 w-12 text-base">999</td>
                  <td className="px-3 py-4 text-right border text-green-900 dark:text-green-300 min-w-[100px] text-2xl">${formatValue(totals.total_pagado)}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </AccordionSection>

        {/* Summary Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 md:gap-4 mt-6">
          <div className="border-2 rounded-lg p-3 md:p-4 bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800">
            <p className="text-xs md:text-sm text-gray-600 dark:text-gray-400 font-medium">Impuesto Causado</p>
            <p className="text-lg md:text-2xl font-bold text-blue-700 dark:text-blue-400">
              ${formatValue(totals.impuesto_causado)}
            </p>
          </div>
          <div className="border-2 rounded-lg p-3 md:p-4 bg-yellow-50 dark:bg-yellow-900/20 border-yellow-200 dark:border-yellow-800">
            <p className="text-xs md:text-sm text-gray-600 dark:text-gray-400 font-medium">Retenciones</p>
            <p className="text-lg md:text-2xl font-bold text-yellow-700 dark:text-yellow-400">
              ${formatValue(totals.retenciones_efectuadas)}
            </p>
          </div>
          <div className="border-2 rounded-lg p-3 md:p-4 bg-purple-50 dark:bg-purple-900/20 border-purple-200 dark:border-purple-800">
            <p className="text-xs md:text-sm text-gray-600 dark:text-gray-400 font-medium">Consolidado IVA</p>
            <p className="text-lg md:text-2xl font-bold text-purple-700 dark:text-purple-400">
              ${formatValue(totals.total_consolidado_iva)}
            </p>
          </div>
          <div className="border-2 rounded-lg p-3 md:p-4 bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800">
            <p className="text-xs md:text-sm text-gray-600 dark:text-gray-400 font-medium">Total Pagado</p>
            <p className="text-xl md:text-3xl font-bold text-green-700 dark:text-green-400">
              ${formatValue(totals.total_pagado)}
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
