'use client'

import { useState, useEffect } from 'react'
import { Download, FileSpreadsheet, AlertTriangle, Settings } from 'lucide-react'
import { getYearlySummary, exportYearlyExcel, exportYearlyPDF } from '@/lib/api'
import type { YearlySummary as YearlySummaryType, PDFBranding } from '@/types'

interface YearlySummaryProps {
  razonSocial: string
  year: string
}

const MONTH_NAMES = [
  '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
]

export default function YearlySummary({ razonSocial, year }: YearlySummaryProps) {
  const [summaryData, setSummaryData] = useState<YearlySummaryType | null>(null)
  const [loading, setLoading] = useState(true)
  const [excludedMonths, setExcludedMonths] = useState<Set<number>>(new Set())
  const [showBrandingForm, setShowBrandingForm] = useState(false)
  const [branding, setBranding] = useState<PDFBranding>({
    company_name: '',
    logo_url: '',
    primary_color: '#1a73e8',
    secondary_color: '#34a853',
    footer_text: ''
  })
  const [exporting, setExporting] = useState(false)

  useEffect(() => {
    loadSummary()
  }, [razonSocial, year, excludedMonths])

  const loadSummary = async () => {
    try {
      setLoading(true)
      const excludeArray = Array.from(excludedMonths)
      const data = await getYearlySummary(razonSocial, year, excludeArray.length > 0 ? excludeArray : undefined)
      console.log('📊 Yearly Summary Data:', data)
      setSummaryData(data)
    } catch (err) {
      console.error('Error loading summary:', err)
    } finally {
      setLoading(false)
    }
  }

  const toggleMonth = (month: number) => {
    const newExcluded = new Set(excludedMonths)
    if (newExcluded.has(month)) {
      newExcluded.delete(month)
    } else {
      newExcluded.add(month)
    }
    setExcludedMonths(newExcluded)
  }

  const handleExportExcel = async () => {
    try {
      setExporting(true)
      const excludeArray = Array.from(excludedMonths)
      await exportYearlyExcel(razonSocial, year, excludeArray.length > 0 ? excludeArray : undefined)
    } catch (err) {
      console.error('Error exporting Excel:', err)
      alert('Error al exportar a Excel')
    } finally {
      setExporting(false)
    }
  }

  const handleExportPDF = async () => {
    if (!branding.company_name || !branding.footer_text) {
      alert('Por favor completa el nombre de tu empresa y el pie de página')
      setShowBrandingForm(true)
      return
    }

    try {
      setExporting(true)
      const excludeArray = Array.from(excludedMonths)
      await exportYearlyPDF(razonSocial, year, branding, excludeArray.length > 0 ? excludeArray : undefined)
      setShowBrandingForm(false)
    } catch (err) {
      console.error('Error exporting PDF:', err)
      alert('Error al exportar a PDF')
    } finally {
      setExporting(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 dark:border-blue-400"></div>
      </div>
    )
  }

  if (!summaryData) {
    return <div className="p-6 text-center text-gray-500 dark:text-gray-400">No hay datos disponibles</div>
  }

  const hasMissingMonths = 
    summaryData.missing_months.form_103.length > 0 || 
    summaryData.missing_months.form_104.length > 0

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
            Resumen Anual {year}
          </h1>
          <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">{razonSocial}</p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={handleExportExcel}
            disabled={exporting}
            className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50 transition-colors"
          >
            <FileSpreadsheet className="w-4 h-4" />
            {exporting ? 'Exportando...' : 'Exportar Excel'}
          </button>
          <button
            onClick={() => setShowBrandingForm(!showBrandingForm)}
            disabled={exporting}
            className="flex items-center gap-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 transition-colors"
          >
            <Download className="w-4 h-4" />
            Exportar PDF
          </button>
        </div>
      </div>

      {/* Branding Form */}
      {showBrandingForm && (
        <div className="bg-white dark:bg-gray-800 border-2 border-gray-300 dark:border-gray-600 rounded-lg p-6 space-y-4 shadow-lg">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <Settings className="w-5 h-5 text-gray-600 dark:text-gray-300" />
              <h3 className="font-semibold text-gray-900 dark:text-gray-100">Personalizar PDF</h3>
            </div>
            <button
              onClick={() => setShowBrandingForm(false)}
              className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
            >
              ✕
            </button>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Nombre de tu empresa *
              </label>
              <input
                type="text"
                placeholder="Ej: Mi Empresa S.A."
                value={branding.company_name}
                onChange={(e) => setBranding({ ...branding, company_name: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-sm text-gray-900 dark:text-gray-100 bg-white dark:bg-gray-700 placeholder-gray-400 dark:placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                URL del logo (opcional)
              </label>
              <input
                type="text"
                placeholder="https://ejemplo.com/logo.png"
                value={branding.logo_url}
                onChange={(e) => setBranding({ ...branding, logo_url: e.target.value })}
                className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-sm text-gray-900 dark:text-gray-100 bg-white dark:bg-gray-700 placeholder-gray-400 dark:placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Color primario
              </label>
              <div className="flex gap-2 items-center">
                <input
                  type="color"
                  value={branding.primary_color}
                  onChange={(e) => setBranding({ ...branding, primary_color: e.target.value })}
                  className="h-10 w-20 rounded border border-gray-300 dark:border-gray-600 cursor-pointer"
                />
                <input
                  type="text"
                  value={branding.primary_color}
                  onChange={(e) => setBranding({ ...branding, primary_color: e.target.value })}
                  className="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-sm text-gray-900 dark:text-gray-100 bg-white dark:bg-gray-700 font-mono focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="#1a73e8"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                Color secundario
              </label>
              <div className="flex gap-2 items-center">
                <input
                  type="color"
                  value={branding.secondary_color}
                  onChange={(e) => setBranding({ ...branding, secondary_color: e.target.value })}
                  className="h-10 w-20 rounded border border-gray-300 dark:border-gray-600 cursor-pointer"
                />
                <input
                  type="text"
                  value={branding.secondary_color}
                  onChange={(e) => setBranding({ ...branding, secondary_color: e.target.value })}
                  className="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-sm text-gray-900 dark:text-gray-100 bg-white dark:bg-gray-700 font-mono focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="#34a853"
                />
              </div>
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Texto del pie de página *
            </label>
            <input
              type="text"
              placeholder="Ej: © 2025 Mi Empresa - Todos los derechos reservados"
              value={branding.footer_text}
              onChange={(e) => setBranding({ ...branding, footer_text: e.target.value })}
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg text-sm text-gray-900 dark:text-gray-100 bg-white dark:bg-gray-700 placeholder-gray-400 dark:placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
              required
            />
          </div>
          
          <button
            onClick={handleExportPDF}
            disabled={exporting || !branding.company_name || !branding.footer_text}
            className="w-full px-4 py-3 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors font-medium"
          >
            {exporting ? '🔄 Generando PDF...' : '📄 Generar PDF Personalizado'}
          </button>

          <p className="text-xs text-gray-500 dark:text-gray-400 text-center">
            * Campos obligatorios
          </p>
        </div>
      )}

      {/* Missing Months Warning */}
      {hasMissingMonths && (
        <div className="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-300 dark:border-yellow-600 rounded-lg p-4">
          <div className="flex items-start gap-3">
            <AlertTriangle className="w-5 h-5 text-yellow-600 dark:text-yellow-400 mt-0.5" />
            <div className="flex-1">
              <h3 className="font-semibold text-yellow-900 dark:text-yellow-200 mb-2">Meses Faltantes</h3>
              {summaryData.missing_months.form_103.length > 0 && (
                <p className="text-sm text-yellow-800 dark:text-yellow-300 mb-1">
                  <span className="font-medium">Form 103:</span>{' '}
                  {summaryData.missing_months.form_103.map(m => MONTH_NAMES[m]).join(', ')}
                </p>
              )}
              {summaryData.missing_months.form_104.length > 0 && (
                <p className="text-sm text-yellow-800 dark:text-yellow-300">
                  <span className="font-medium">Form 104:</span>{' '}
                  {summaryData.missing_months.form_104.map(m => MONTH_NAMES[m]).join(', ')}
                </p>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Month Selector */}
      <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-4">
        <h3 className="font-semibold text-gray-900 dark:text-gray-100 mb-3">Seleccionar Meses a Incluir</h3>
        <div className="grid grid-cols-6 gap-2">
          {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12].map(month => (
            <button
              key={month}
              onClick={() => toggleMonth(month)}
              className={`px-3 py-2 rounded-lg text-sm font-medium transition-colors ${
                excludedMonths.has(month)
                  ? 'bg-gray-200 dark:bg-gray-700 text-gray-500 dark:text-gray-400 line-through'
                  : 'bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 hover:bg-blue-200 dark:hover:bg-blue-800/40'
              }`}
            >
              {MONTH_NAMES[month]}
            </button>
          ))}
        </div>
        <p className="text-xs text-gray-500 dark:text-gray-400 mt-2">
          Click en un mes para excluirlo del resumen
        </p>
      </div>

      {/* Form 103 Summary - ✅ SORTED BY MONTH */}
      <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-6">
        <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100 mb-4">
          📊 Formulario 103 - Resumen Anual
        </h2>
        
        <div className="overflow-x-auto">
          <table className="w-full text-sm border-collapse">
            <thead>
              <tr className="bg-blue-600 text-white">
                <th className="px-4 py-3 text-left font-semibold border-r border-blue-500">Mes</th>
                <th className="px-4 py-3 text-left font-semibold border-r border-blue-500">Período</th>
                <th className="px-4 py-3 text-right font-semibold border-r border-blue-500">Subtotal País</th>
                <th className="px-4 py-3 text-right font-semibold border-r border-blue-500">Total Retención</th>
                <th className="px-4 py-3 text-right font-semibold border-r border-blue-500">Total Impuesto</th>
                <th className="px-4 py-3 text-right font-semibold">Total Pagado</th>
              </tr>
            </thead>
            <tbody className="bg-white dark:bg-gray-800">
              {summaryData.form_103_summary.monthly_details
                .sort((a, b) => a.month - b.month)
                .map((detail, idx) => (
                <tr key={idx} className={`border-b border-gray-200 dark:border-gray-700 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors ${
                  excludedMonths.has(detail.month) ? 'opacity-30 line-through' : ''
                }`}>
                  <td className="px-4 py-3 font-medium text-gray-900 dark:text-gray-100">{MONTH_NAMES[detail.month]}</td>
                  <td className="px-4 py-3 text-gray-700 dark:text-gray-300">{detail.periodo_fiscal}</td>
                  <td className="px-4 py-3 text-right font-medium text-blue-700 dark:text-blue-400">
                    ${detail.subtotal_operaciones_pais.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                  </td>
                  <td className="px-4 py-3 text-right font-medium text-purple-700 dark:text-purple-400">
                    ${detail.total_retencion.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                  </td>
                  <td className="px-4 py-3 text-right font-medium text-orange-700 dark:text-orange-400">
                    ${detail.total_impuesto_pagar.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                  </td>
                  <td className="px-4 py-3 text-right font-bold text-green-700 dark:text-green-400">
                    ${detail.total_pagado.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                  </td>
                </tr>
              ))}
              <tr className="bg-gradient-to-r from-gray-800 to-gray-700 dark:from-gray-700 dark:to-gray-600 text-white font-bold">
                <td className="px-4 py-4 text-lg" colSpan={2}>TOTAL ANUAL</td>
                <td className="px-4 py-4 text-right text-lg">
                  ${summaryData.form_103_summary.subtotal_operaciones_pais.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                </td>
                <td className="px-4 py-4 text-right text-lg">
                  ${summaryData.form_103_summary.total_retencion.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                </td>
                <td className="px-4 py-4 text-right text-lg">
                  ${summaryData.form_103_summary.total_impuesto_pagar.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                </td>
                <td className="px-4 py-4 text-right text-lg">
                  ${summaryData.form_103_summary.total_pagado.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      {/* Form 104 Summary - ✅ SORTED + ENHANCED WITH ALL KEY FIELDS */}
      <div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-6">
        <h2 className="text-lg font-bold text-gray-900 dark:text-gray-100 mb-4">
          📈 Formulario 104 - Resumen Anual Completo
        </h2>
        
        {/* Row 1: Basic Sales & Purchases */}
        <div className="mb-4">
          <h3 className="text-sm font-semibold text-gray-600 dark:text-gray-400 mb-2">VENTAS Y COMPRAS</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            <div className="p-4 rounded-lg border-2 bg-gradient-to-br from-blue-50 to-blue-100 dark:from-blue-900/20 dark:to-blue-800/20 border-blue-300 dark:border-blue-700">
              <div className="text-xs font-semibold uppercase mb-1 text-blue-800 dark:text-blue-300">Ventas Neto</div>
              <div className="text-xl font-bold text-blue-700 dark:text-blue-400">
                ${summaryData.form_104_summary.total_ventas_neto?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
              </div>
            </div>

            <div className="p-4 rounded-lg border-2 bg-gradient-to-br from-purple-50 to-purple-100 dark:from-purple-900/20 dark:to-purple-800/20 border-purple-300 dark:border-purple-700">
              <div className="text-xs font-semibold uppercase mb-1 text-purple-800 dark:text-purple-300">Impuesto Generado</div>
              <div className="text-xl font-bold text-purple-700 dark:text-purple-400">
                ${summaryData.form_104_summary.total_impuesto_generado?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
              </div>
            </div>

            <div className="p-4 rounded-lg border-2 bg-gradient-to-br from-indigo-50 to-indigo-100 dark:from-indigo-900/20 dark:to-indigo-800/20 border-indigo-300 dark:border-indigo-700">
              <div className="text-xs font-semibold uppercase mb-1 text-indigo-800 dark:text-indigo-300">Adquisiciones</div>
              <div className="text-xl font-bold text-indigo-700 dark:text-indigo-400">
                ${summaryData.form_104_summary.total_adquisiciones?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
              </div>
            </div>

            <div className="p-4 rounded-lg border-2 bg-gradient-to-br from-amber-50 to-amber-100 dark:from-amber-900/20 dark:to-amber-800/20 border-amber-300 dark:border-amber-700">
              <div className="text-xs font-semibold uppercase mb-1 text-amber-800 dark:text-amber-300">Crédito Tributario</div>
              <div className="text-xl font-bold text-amber-700 dark:text-amber-400">
                ${summaryData.form_104_summary.credito_tributario_aplicable?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
              </div>
            </div>
          </div>
        </div>

        {/* Row 2: Key Financial Fields */}
        <div className="mb-4">
          <h3 className="text-sm font-semibold text-gray-600 dark:text-gray-400 mb-2">CÁLCULOS FISCALES PRINCIPALES</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            <div className="p-4 rounded-lg border-2 bg-gradient-to-br from-cyan-50 to-cyan-100 dark:from-cyan-900/20 dark:to-cyan-800/20 border-cyan-300 dark:border-cyan-700">
              <div className="text-xs font-semibold uppercase mb-1 text-cyan-800 dark:text-cyan-300">Impuesto Causado</div>
              <div className="text-xl font-bold text-cyan-700 dark:text-cyan-400">
                ${summaryData.form_104_summary.impuesto_causado?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
              </div>
            </div>

            <div className="p-4 rounded-lg border-2 bg-gradient-to-br from-yellow-50 to-yellow-100 dark:from-yellow-900/20 dark:to-yellow-800/20 border-yellow-300 dark:border-yellow-700">
              <div className="text-xs font-semibold uppercase mb-1 text-yellow-800 dark:text-yellow-300">Retenciones Efectuadas</div>
              <div className="text-xl font-bold text-yellow-700 dark:text-yellow-400">
                ${summaryData.form_104_summary.retenciones_efectuadas?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
              </div>
            </div>

            <div className="p-4 rounded-lg border-2 bg-gradient-to-br from-lime-50 to-lime-100 dark:from-lime-900/20 dark:to-lime-800/20 border-lime-300 dark:border-lime-700">
              <div className="text-xs font-semibold uppercase mb-1 text-lime-800 dark:text-lime-300">Subtotal a Pagar</div>
              <div className="text-xl font-bold text-lime-700 dark:text-lime-400">
                ${summaryData.form_104_summary.subtotal_a_pagar?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
              </div>
            </div>

            <div className="p-4 rounded-lg border-2 bg-gradient-to-br from-orange-50 to-orange-100 dark:from-orange-900/20 dark:to-orange-800/20 border-orange-300 dark:border-orange-700">
              <div className="text-xs font-semibold uppercase mb-1 text-orange-800 dark:text-orange-300">Impuesto Retenido</div>
              <div className="text-xl font-bold text-orange-700 dark:text-orange-400">
                ${summaryData.form_104_summary.total_impuesto_retenido?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
              </div>
            </div>
          </div>
        </div>

        {/* Row 3: Final Totals */}
        <div>
          <h3 className="text-sm font-semibold text-gray-600 dark:text-gray-400 mb-2">TOTALES FINALES</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
            <div className="p-4 rounded-lg border-2 bg-gradient-to-br from-violet-50 to-violet-100 dark:from-violet-900/20 dark:to-violet-800/20 border-violet-300 dark:border-violet-700">
              <div className="text-xs font-semibold uppercase mb-1 text-violet-800 dark:text-violet-300">Total Pagar (Percepción)</div>
              <div className="text-xl font-bold text-violet-700 dark:text-violet-400">
                ${summaryData.form_104_summary.total_impuesto_pagar_percepcion?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
              </div>
            </div>

            <div className="p-4 rounded-lg border-2 bg-gradient-to-br from-pink-50 to-pink-100 dark:from-pink-900/20 dark:to-pink-800/20 border-pink-300 dark:border-pink-700">
              <div className="text-xs font-semibold uppercase mb-1 text-pink-800 dark:text-pink-300">Total Pagar (Retención)</div>
              <div className="text-xl font-bold text-pink-700 dark:text-pink-400">
                ${summaryData.form_104_summary.total_impuesto_pagar_retencion?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
              </div>
            </div>

            <div className="p-4 rounded-lg border-2 bg-gradient-to-br from-purple-50 to-purple-100 dark:from-purple-900/20 dark:to-purple-800/20 border-purple-400 dark:border-purple-600">
              <div className="text-xs font-semibold uppercase mb-1 text-purple-800 dark:text-purple-300">Total Consolidado IVA</div>
              <div className="text-xl font-bold text-purple-700 dark:text-purple-400">
                ${summaryData.form_104_summary.total_consolidado_iva?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
              </div>
            </div>

            <div className="p-4 rounded-lg border-2 bg-gradient-to-br from-green-50 to-emerald-50 dark:from-green-900/30 dark:to-emerald-900/30 border-green-500 dark:border-green-600 shadow-md">
              <div className="text-xs font-semibold uppercase mb-1 text-green-800 dark:text-green-300">✅ TOTAL PAGADO</div>
              <div className="text-2xl font-bold text-green-700 dark:text-green-400">
                ${summaryData.form_104_summary.total_pagado?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
              </div>
            </div>
          </div>
        </div>

        {/* Additional Fields Section */}
        {(summaryData.form_104_summary.interes_mora > 0 || 
          summaryData.form_104_summary.multa > 0 || 
          summaryData.form_104_summary.total_impuesto_a_pagar) && (
          <div className="mt-4 pt-4 border-t border-gray-200 dark:border-gray-700">
            <h3 className="text-sm font-semibold text-gray-600 dark:text-gray-400 mb-2">INFORMACIÓN ADICIONAL</h3>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
              {summaryData.form_104_summary.total_impuesto_a_pagar !== undefined && (
                <div className="p-3 rounded-lg bg-gray-50 dark:bg-gray-700/50 border border-gray-200 dark:border-gray-600">
                  <div className="text-xs text-gray-600 dark:text-gray-400 mb-1">Total Impuesto a Pagar</div>
                  <div className="text-lg font-bold text-gray-900 dark:text-gray-100">
                    ${summaryData.form_104_summary.total_impuesto_a_pagar?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
                  </div>
                </div>
              )}
              
              {summaryData.form_104_summary.interes_mora !== undefined && (
                <div className="p-3 rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-700">
                  <div className="text-xs text-red-600 dark:text-red-400 mb-1">Interés Mora</div>
                  <div className="text-lg font-bold text-red-700 dark:text-red-400">
                    ${summaryData.form_104_summary.interes_mora?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
                  </div>
                </div>
              )}
              
              {summaryData.form_104_summary.multa !== undefined && (
                <div className="p-3 rounded-lg bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-700">
                  <div className="text-xs text-red-600 dark:text-red-400 mb-1">Multa</div>
                  <div className="text-lg font-bold text-red-700 dark:text-red-400">
                    ${summaryData.form_104_summary.multa?.toLocaleString('en-US', { minimumFractionDigits: 2 }) || '0.00'}
                  </div>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
