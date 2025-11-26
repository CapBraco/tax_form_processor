-- ========================================
-- FIX ALL 5 DOCUMENTS - Based on Diagnostic Results
-- ========================================

-- Step 1: Fix the 2 documents that have data in parsed_data JSON
UPDATE documents
SET 
    periodo_anio = parsed_data->'header'->>'periodo_anio',
    periodo_mes = parsed_data->'header'->>'periodo_mes',
    periodo_fiscal_completo = CONCAT(parsed_data->'header'->>'periodo_mes', ' ', parsed_data->'header'->>'periodo_anio'),
    periodo_mes_numero = CASE parsed_data->'header'->>'periodo_mes'
        WHEN 'ENERO' THEN 1
        WHEN 'FEBRERO' THEN 2
        WHEN 'MARZO' THEN 3
        WHEN 'ABRIL' THEN 4
        WHEN 'MAYO' THEN 5
        WHEN 'JUNIO' THEN 6
        WHEN 'JULIO' THEN 7
        WHEN 'AGOSTO' THEN 8
        WHEN 'SEPTIEMBRE' THEN 9
        WHEN 'OCTUBRE' THEN 10
        WHEN 'NOVIEMBRE' THEN 11
        WHEN 'DICIEMBRE' THEN 12
    END
WHERE id IN (148, 149)  -- These have data in JSON
  AND parsed_data->'header'->>'periodo_anio' IS NOT NULL;

-- Step 2: Fix document 152 (ENERO 2025 - from text sample)
UPDATE documents
SET 
    periodo_anio = '2025',
    periodo_mes = 'ENERO',
    periodo_fiscal_completo = 'ENERO 2025',
    periodo_mes_numero = 1
WHERE id = 152;

-- Step 3: Fix document 150 (ABRIL 2025 - from text pattern)
UPDATE documents
SET 
    periodo_anio = '2025',
    periodo_mes = 'ABRIL',
    periodo_fiscal_completo = 'ABRIL 2025',
    periodo_mes_numero = 4
WHERE id = 150;

-- Step 4: Fix document 151 (ENERO 2025 - from text pattern)
UPDATE documents
SET 
    periodo_anio = '2025',
    periodo_mes = 'ENERO',
    periodo_fiscal_completo = 'ENERO 2025',
    periodo_mes_numero = 1
WHERE id = 151;

-- ========================================
-- VERIFICATION: Check the results
-- ========================================

SELECT 
    id,
    filename,
    periodo_anio,
    periodo_mes,
    periodo_mes_numero,
    periodo_fiscal_completo,
    form_type
FROM documents
WHERE razon_social = 'GAMA EDITORES REYES MEDINA CIA. LTDA.'
ORDER BY periodo_anio, periodo_mes_numero;

-- Count documents by year
SELECT 
    periodo_anio,
    COUNT(*) as document_count,
    ARRAY_AGG(DISTINCT periodo_mes ORDER BY periodo_mes) as months
FROM documents
WHERE razon_social = 'GAMA EDITORES REYES MEDINA CIA. LTDA.'
GROUP BY periodo_anio
ORDER BY periodo_anio;

-- Final check: Should see 5 documents with valid years
SELECT 
    COUNT(*) as total_documents,
    COUNT(periodo_anio) as documents_with_year,
    COUNT(*) - COUNT(periodo_anio) as documents_without_year
FROM documents
WHERE razon_social = 'GAMA EDITORES REYES MEDINA CIA. LTDA.';
