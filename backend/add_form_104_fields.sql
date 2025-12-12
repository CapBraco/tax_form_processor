-- =====================================================
-- Form 104 Complete Fields Migration - SQL Script
-- =====================================================
-- Adds 105 new columns to form_104_data table
-- Run this directly in your PostgreSQL database
-- =====================================================

BEGIN;

-- ===== VENTAS SECTION (28 new fields) =====
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ventas_activos_fijos_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ventas_activos_fijos_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS impuesto_generado_activos_fijos FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ventas_tarifa_5_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ventas_tarifa_5_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS impuesto_generado_tarifa_5 FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS iva_ajuste_pagar FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS iva_ajuste_favor FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ventas_0_sin_derecho_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ventas_0_sin_derecho_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS activos_fijos_0_sin_derecho_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS activos_fijos_0_sin_derecho_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ventas_0_con_derecho_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ventas_0_con_derecho_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS activos_fijos_0_con_derecho_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS activos_fijos_0_con_derecho_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS exportaciones_bienes_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS exportaciones_bienes_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS exportaciones_servicios_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS exportaciones_servicios_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS transferencias_no_objeto_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS transferencias_no_objeto_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS notas_credito_0_compensar FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS notas_credito_diferente_0_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS notas_credito_diferente_0_impuesto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ingresos_reembolso_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ingresos_reembolso_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ingresos_reembolso_impuesto FLOAT DEFAULT 0.0;

-- ===== LIQUIDACIÓN SECTION (8 new fields) =====
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS transferencias_contado_mes FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS transferencias_credito_mes FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS impuesto_liquidar_mes_anterior FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS impuesto_liquidar_este_mes FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS impuesto_liquidar_proximo_mes FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS mes_pagar_iva_credito INTEGER DEFAULT 0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS tamano_copci VARCHAR(50) DEFAULT 'No aplica';
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS total_impuesto_liquidar_mes FLOAT DEFAULT 0.0;

-- ===== COMPRAS SECTION (48 new fields) =====
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS activos_fijos_diferente_0_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS activos_fijos_diferente_0_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS impuesto_activos_fijos_diferente_0 FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS adquisiciones_tarifa_5_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS adquisiciones_tarifa_5_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS impuesto_adquisiciones_tarifa_5 FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS adquisiciones_sin_derecho_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS adquisiciones_sin_derecho_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS impuesto_adquisiciones_sin_derecho FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS importaciones_servicios_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS importaciones_servicios_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS impuesto_importaciones_servicios FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS importaciones_bienes_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS importaciones_bienes_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS impuesto_importaciones_bienes FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS importaciones_activos_fijos_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS importaciones_activos_fijos_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS impuesto_importaciones_activos_fijos FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS importaciones_0_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS importaciones_0_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS adquisiciones_0_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS adquisiciones_0_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS adquisiciones_rise_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS adquisiciones_rise_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS total_adquisiciones_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS total_impuesto_adquisiciones FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS adquisiciones_no_objeto_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS adquisiciones_no_objeto_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS adquisiciones_exentas_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS adquisiciones_exentas_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS notas_credito_compras_0_compensar FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS notas_credito_compras_diferente_0_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS notas_credito_compras_diferente_0_impuesto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS pagos_reembolso_bruto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS pagos_reembolso_neto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS pagos_reembolso_impuesto FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS factor_proporcionalidad FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS iva_no_considerado_credito FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ajuste_positivo_credito FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ajuste_negativo_credito FLOAT DEFAULT 0.0;

-- ===== EXPORTACIONES SECTION (3 new fields) =====
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS importaciones_materias_primas_valor FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS importaciones_materias_primas_isd_pagado FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS proporcion_ingreso_neto_divisas FLOAT DEFAULT 0.0;

-- ===== TOTALS SECTION (26 new fields) =====
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS compensacion_iva_medio_electronico FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS saldo_credito_anterior_adquisiciones FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS saldo_credito_anterior_retenciones FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS saldo_credito_anterior_compensacion_electronico FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS saldo_credito_anterior_zonas_afectadas FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS iva_devuelto_adultos_mayores FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ajuste_iva_devuelto_electronico FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ajuste_iva_devuelto_adquisiciones FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ajuste_iva_devuelto_retenciones FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ajuste_iva_otras_instituciones FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS saldo_credito_proximo_adquisiciones FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS saldo_credito_proximo_retenciones FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS saldo_credito_proximo_compensacion_electronico FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS saldo_credito_proximo_zonas_afectadas FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS iva_pagado_no_compensado FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ajuste_credito_superior_5_anos FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ajuste_reduccion_impuesto_tarifa_5 FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ajuste_reduccion_impuesto_iva_diferencial FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS ajuste_credito_compensacion_zonas_afectadas FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS saldo_credito_anterior_iva_medio_electronico FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS saldo_credito_proximo_iva_electronico FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS total_impuesto_pagar_percepcion FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS total_impuesto_a_pagar FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS interes_mora FLOAT DEFAULT 0.0;
ALTER TABLE form_104_data ADD COLUMN IF NOT EXISTS multa FLOAT DEFAULT 0.0;

-- Verify columns were added
SELECT COUNT(*) as total_columns 
FROM information_schema.columns 
WHERE table_name = 'form_104_data';

COMMIT;

-- =====================================================
-- Migration Complete!
-- Expected total columns: ~130 (22 original + 105 new + 3 system columns)
-- =====================================================
