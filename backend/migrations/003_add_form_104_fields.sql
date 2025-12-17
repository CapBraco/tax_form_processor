-- ============================================================================
-- 003_add_form_104_fields.sql
-- Expand Form 104 to support all 127 fields from 5-page PDF
-- (Run this only if form_104_data table needs additional fields)
-- ============================================================================

-- This migration ensures form_104_data has all necessary columns
-- If running 001_initial_schema.sql, this migration may not be needed

DO $$ 
BEGIN
    -- Ensure raw_data JSONB column exists for complete flexibility
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'form_104_data' AND column_name = 'raw_data'
    ) THEN
        ALTER TABLE form_104_data ADD COLUMN raw_data JSONB;
        CREATE INDEX idx_form_104_raw_data ON form_104_data USING GIN(raw_data);
    END IF;

    -- Add IDENTIFICACIÓN fields if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'form_104_data' AND column_name = 'periodo_fiscal'
    ) THEN
        ALTER TABLE form_104_data ADD COLUMN periodo_fiscal VARCHAR(50);
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'form_104_data' AND column_name = 'formulario_num'
    ) THEN
        ALTER TABLE form_104_data ADD COLUMN formulario_num VARCHAR(50);
    END IF;

    -- Add VENTAS fields if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'form_104_data' AND column_name = 'ventas_tarifa_0'
    ) THEN
        ALTER TABLE form_104_data ADD COLUMN ventas_tarifa_0 NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN ventas_tarifa_12 NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN ventas_tarifa_15 NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN ventas_no_objeto_iva NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN ventas_exentas NUMERIC(15, 2);
    END IF;

    -- Add COMPRAS fields if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'form_104_data' AND column_name = 'compras_tarifa_0'
    ) THEN
        ALTER TABLE form_104_data ADD COLUMN compras_tarifa_0 NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN compras_tarifa_12 NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN compras_tarifa_15 NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN compras_no_objeto_iva NUMERIC(15, 2);
    END IF;

    -- Add LIQUIDACIÓN IVA fields if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'form_104_data' AND column_name = 'impuesto_causado'
    ) THEN
        ALTER TABLE form_104_data ADD COLUMN impuesto_causado NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN credito_tributario NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN iva_a_pagar NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN saldo_favor_contribuyente NUMERIC(15, 2);
    END IF;

    -- Add RESUMEN IMPOSITIVO fields if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'form_104_data' AND column_name = 'total_ventas'
    ) THEN
        ALTER TABLE form_104_data ADD COLUMN total_ventas NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN total_compras NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN diferencia NUMERIC(15, 2);
    END IF;

    -- Add EXPORTACIONES fields if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'form_104_data' AND column_name = 'exportaciones_bienes'
    ) THEN
        ALTER TABLE form_104_data ADD COLUMN exportaciones_bienes NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN exportaciones_servicios NUMERIC(15, 2);
    END IF;

    -- Add TOTALES FINALES fields if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'form_104_data' AND column_name = 'total_impuesto_generado'
    ) THEN
        ALTER TABLE form_104_data ADD COLUMN total_impuesto_generado NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN total_impuesto_pagado NUMERIC(15, 2);
        ALTER TABLE form_104_data ADD COLUMN saldo_total NUMERIC(15, 2);
    END IF;

END $$;

-- ============================================================================
-- Update comments
-- ============================================================================
COMMENT ON COLUMN form_104_data.raw_data IS 'Complete JSON storage of all 127 fields from Form 104';
COMMENT ON COLUMN form_104_data.ventas_tarifa_0 IS 'Sales at 0% VAT rate';
COMMENT ON COLUMN form_104_data.ventas_tarifa_12 IS 'Sales at 12% VAT rate';
COMMENT ON COLUMN form_104_data.ventas_tarifa_15 IS 'Sales at 15% VAT rate';
COMMENT ON COLUMN form_104_data.impuesto_causado IS 'VAT tax caused/generated';
COMMENT ON COLUMN form_104_data.credito_tributario IS 'Tax credit available';

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- This migration is idempotent - safe to run multiple times
-- All Form 104 fields are now available, with complete data in raw_data JSONB
