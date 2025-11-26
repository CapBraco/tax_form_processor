-- ========================================
-- FIX NULL PERIODO_ANIO DATA
-- This script will update documents that have period info in parsed_data but not in columns
-- ========================================

-- Step 1: See the problem
SELECT 
    id,
    razon_social,
    filename,
    periodo_anio,
    periodo_mes,
    periodo_fiscal_completo,
    parsed_data->'header'->>'periodo_anio' as anio_in_json,
    parsed_data->'header'->>'periodo_mes' as mes_in_json
FROM documents
WHERE razon_social = 'GAMA EDITORES REYES MEDINA CIA. LTDA.'
ORDER BY id;

-- Step 2: Check if parsed_data has the information
SELECT 
    id,
    filename,
    periodo_anio as current_anio,
    periodo_mes as current_mes,
    parsed_data->'header'->>'periodo_anio' as json_anio,
    parsed_data->'header'->>'periodo_mes' as json_mes,
    CASE 
        WHEN parsed_data->'header'->>'periodo_anio' IS NOT NULL THEN 'Can be fixed from JSON'
        WHEN extracted_text LIKE '%2025%' THEN 'Check text manually'
        ELSE 'No period data found'
    END as status
FROM documents
WHERE razon_social = 'GAMA EDITORES REYES MEDINA CIA. LTDA.';

-- Step 3: Sample the extracted text to see if period info is there
SELECT 
    id,
    filename,
    SUBSTRING(extracted_text, 1, 1000) as text_sample
FROM documents
WHERE razon_social = 'GAMA EDITORES REYES MEDINA CIA. LTDA.'
LIMIT 1;

-- ========================================
-- OPTION 1: If parsed_data has the info, copy it to columns
-- ========================================

-- Preview what would be updated
SELECT 
    id,
    filename,
    'UPDATE' as action,
    parsed_data->'header'->>'periodo_anio' as new_periodo_anio,
    parsed_data->'header'->>'periodo_mes' as new_periodo_mes
FROM documents
WHERE razon_social = 'GAMA EDITORES REYES MEDINA CIA. LTDA.'
  AND parsed_data->'header'->>'periodo_anio' IS NOT NULL;

-- UNCOMMENT TO EXECUTE:
/*
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
        ELSE NULL
    END
WHERE razon_social = 'GAMA EDITORES REYES MEDINA CIA. LTDA.'
  AND parsed_data->'header'->>'periodo_anio' IS NOT NULL;
*/

-- ========================================
-- OPTION 2: If parsed_data doesn't have it, extract from text
-- ========================================

-- Try to find period patterns in extracted_text
SELECT 
    id,
    filename,
    extracted_text ~ 'ABRIL\s+2025' as has_abril_2025,
    extracted_text ~ 'ENERO\s+2025' as has_enero_2025,
    extracted_text ~ 'FEBRERO\s+2025' as has_febrero_2025,
    extracted_text ~ 'MARZO\s+2025' as has_marzo_2025,
    extracted_text ~ '2024' as has_2024,
    extracted_text ~ '2025' as has_2025
FROM documents
WHERE razon_social = 'GAMA EDITORES REYES MEDINA CIA. LTDA.';

-- ========================================
-- OPTION 3: Manual update (if you know the correct values)
-- ========================================

-- EXAMPLE: If you know document ID 1 is from ABRIL 2025:
/*
UPDATE documents
SET 
    periodo_anio = '2025',
    periodo_mes = 'ABRIL',
    periodo_fiscal_completo = 'ABRIL 2025',
    periodo_mes_numero = 4
WHERE id = 1;
*/

-- ========================================
-- VERIFICATION: Check after update
-- ========================================

SELECT 
    id,
    filename,
    periodo_anio,
    periodo_mes,
    periodo_mes_numero,
    periodo_fiscal_completo
FROM documents
WHERE razon_social = 'GAMA EDITORES REYES MEDINA CIA. LTDA.'
ORDER BY periodo_anio, periodo_mes_numero;

-- Count documents by year
SELECT 
    periodo_anio,
    COUNT(*) as document_count
FROM documents
WHERE razon_social = 'GAMA EDITORES REYES MEDINA CIA. LTDA.'
GROUP BY periodo_anio
ORDER BY periodo_anio;
