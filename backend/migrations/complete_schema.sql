--
-- Tax Forms Processor - Complete Database Schema
-- This is the PRODUCTION-READY schema that should be used for ALL new deployments
--
-- Created: December 2025
-- Version: 1.0
--
-- INSTRUCTIONS:
-- 1. Create database: CREATE DATABASE pdf_extractor_db;
-- 2. Run this file: psql -U postgres -d pdf_extractor_db -f complete_schema.sql
-- 3. Verify: \dt (should show 9 tables)
--

-- PostgreSQL settings
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- ============================================================================
-- ENUM TYPES
-- ============================================================================

-- Form type enum
CREATE TYPE formtypeenum AS ENUM (
    'FORM_103',
    'FORM_104',
    'UNKNOWN'
);

-- Processing status enum
CREATE TYPE processingstatusenum AS ENUM (
    'PENDING',
    'PROCESSING',
    'COMPLETED',
    'FAILED'
);

-- ============================================================================
-- TABLES
-- ============================================================================

-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    hashed_password VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_superuser BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    reset_token VARCHAR(500),
    reset_token_expires TIMESTAMP WITH TIME ZONE,
    google_id VARCHAR(255)
);

-- Guest sessions table
CREATE TABLE guest_sessions (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) NOT NULL UNIQUE,
    ip_address VARCHAR(50),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Documents table (main)
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(255) NOT NULL,
    original_filename VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size INTEGER NOT NULL,
    form_type formtypeenum,
    extracted_text TEXT,
    total_pages INTEGER,
    total_characters INTEGER,
    parsed_data JSON,
    codigo_verificador VARCHAR(100),
    numero_serial VARCHAR(100),
    fecha_recaudacion TIMESTAMP WITH TIME ZONE,
    identificacion_ruc VARCHAR(50),
    razon_social VARCHAR(500),
    periodo_mes VARCHAR(20),
    periodo_anio VARCHAR(10),
    processing_status processingstatusenum DEFAULT 'PENDING',
    processing_error TEXT,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE,
    periodo_fiscal_completo VARCHAR(50),
    periodo_mes_numero INTEGER,
    user_id INTEGER,
    session_id VARCHAR,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Form 103 line items (detailed data)
CREATE TABLE form_103_line_items (
    id SERIAL PRIMARY KEY,
    document_id INTEGER NOT NULL,
    concepto VARCHAR(500) NOT NULL,
    codigo_base VARCHAR(10) NOT NULL,
    base_imponible DOUBLE PRECISION NOT NULL,
    codigo_retencion VARCHAR(10) NOT NULL,
    valor_retenido DOUBLE PRECISION NOT NULL,
    order_index INTEGER NOT NULL,
    user_id INTEGER,
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Form 103 totals
CREATE TABLE form_103_totals (
    id SERIAL PRIMARY KEY,
    document_id INTEGER NOT NULL UNIQUE,
    subtotal_operaciones_pais DOUBLE PRECISION,
    total_retencion DOUBLE PRECISION,
    total_impuesto_pagar DOUBLE PRECISION,
    total_pagado DOUBLE PRECISION,
    subtotal_retencion DOUBLE PRECISION DEFAULT 0.0,
    interes_mora DOUBLE PRECISION DEFAULT 0.0,
    multa DOUBLE PRECISION DEFAULT 0.0,
    pagos_no_sujetos DOUBLE PRECISION DEFAULT 0.0,
    otras_retenciones_base DOUBLE PRECISION DEFAULT 0.0,
    otras_retenciones_retenido DOUBLE PRECISION DEFAULT 0.0,
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
);

-- Form 104 data (complete with all 133 fields)
-- NOTE: This table is large! It contains all fields from the 7-page Form 104
CREATE TABLE form_104_data (
    id SERIAL PRIMARY KEY,
    document_id INTEGER NOT NULL,
    user_id INTEGER,
    
    -- Section 1: Ventas (Sales)
    ventas_tarifa_diferente_cero_bruto DOUBLE PRECISION DEFAULT 0.0,
    ventas_tarifa_diferente_cero_neto DOUBLE PRECISION DEFAULT 0.0,
    impuesto_generado DOUBLE PRECISION DEFAULT 0.0,
    ventas_activos_fijos_bruto DOUBLE PRECISION DEFAULT 0.0,
    ventas_activos_fijos_neto DOUBLE PRECISION DEFAULT 0.0,
    impuesto_generado_activos_fijos DOUBLE PRECISION DEFAULT 0.0,
    ventas_tarifa_5_bruto DOUBLE PRECISION DEFAULT 0.0,
    ventas_tarifa_5_neto DOUBLE PRECISION DEFAULT 0.0,
    impuesto_generado_tarifa_5 DOUBLE PRECISION DEFAULT 0.0,
    activos_fijos_diferente_0_bruto DOUBLE PRECISION DEFAULT 0.0,
    activos_fijos_diferente_0_neto DOUBLE PRECISION DEFAULT 0.0,
    impuesto_activos_fijos_diferente_0 DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 2: Ventas tarifa 0%
    ventas_0_sin_derecho_bruto DOUBLE PRECISION DEFAULT 0.0,
    ventas_0_sin_derecho_neto DOUBLE PRECISION DEFAULT 0.0,
    activos_fijos_0_sin_derecho_bruto DOUBLE PRECISION DEFAULT 0.0,
    activos_fijos_0_sin_derecho_neto DOUBLE PRECISION DEFAULT 0.0,
    ventas_0_con_derecho_bruto DOUBLE PRECISION DEFAULT 0.0,
    ventas_0_con_derecho_neto DOUBLE PRECISION DEFAULT 0.0,
    activos_fijos_0_con_derecho_bruto DOUBLE PRECISION DEFAULT 0.0,
    activos_fijos_0_con_derecho_neto DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 3: Exportaciones
    exportaciones_bienes_bruto DOUBLE PRECISION DEFAULT 0.0,
    exportaciones_bienes_neto DOUBLE PRECISION DEFAULT 0.0,
    exportaciones_servicios_bruto DOUBLE PRECISION DEFAULT 0.0,
    exportaciones_servicios_neto DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 4: Otras transacciones
    transferencias_no_objeto_bruto DOUBLE PRECISION DEFAULT 0.0,
    transferencias_no_objeto_neto DOUBLE PRECISION DEFAULT 0.0,
    notas_credito_0_compensar DOUBLE PRECISION DEFAULT 0.0,
    notas_credito_diferente_0_bruto DOUBLE PRECISION DEFAULT 0.0,
    notas_credito_diferente_0_impuesto DOUBLE PRECISION DEFAULT 0.0,
    ingresos_reembolso_bruto DOUBLE PRECISION DEFAULT 0.0,
    ingresos_reembolso_neto DOUBLE PRECISION DEFAULT 0.0,
    ingresos_reembolso_impuesto DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 5: Totales de ventas
    total_ventas_bruto DOUBLE PRECISION DEFAULT 0.0,
    total_ventas_neto DOUBLE PRECISION DEFAULT 0.0,
    total_impuesto_generado DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 6: Liquidación por transferencias
    transferencias_contado_mes DOUBLE PRECISION DEFAULT 0.0,
    transferencias_credito_mes DOUBLE PRECISION DEFAULT 0.0,
    impuesto_liquidar_mes_anterior DOUBLE PRECISION DEFAULT 0.0,
    impuesto_liquidar_este_mes DOUBLE PRECISION DEFAULT 0.0,
    impuesto_liquidar_proximo_mes DOUBLE PRECISION DEFAULT 0.0,
    mes_pagar_iva_credito INTEGER DEFAULT 0,
    tamano_copci VARCHAR(50) DEFAULT 'No aplica',
    total_impuesto_liquidar_mes DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 7: Adquisiciones tarifa diferente de 0%
    adquisiciones_tarifa_diferente_cero_bruto DOUBLE PRECISION DEFAULT 0.0,
    adquisiciones_tarifa_diferente_cero_neto DOUBLE PRECISION DEFAULT 0.0,
    impuesto_compras DOUBLE PRECISION DEFAULT 0.0,
    adquisiciones_tarifa_5_bruto DOUBLE PRECISION DEFAULT 0.0,
    adquisiciones_tarifa_5_neto DOUBLE PRECISION DEFAULT 0.0,
    impuesto_adquisiciones_tarifa_5 DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 8: Adquisiciones sin derecho a crédito
    adquisiciones_sin_derecho_bruto DOUBLE PRECISION DEFAULT 0.0,
    adquisiciones_sin_derecho_neto DOUBLE PRECISION DEFAULT 0.0,
    impuesto_adquisiciones_sin_derecho DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 9: Importaciones
    importaciones_servicios_bruto DOUBLE PRECISION DEFAULT 0.0,
    importaciones_servicios_neto DOUBLE PRECISION DEFAULT 0.0,
    impuesto_importaciones_servicios DOUBLE PRECISION DEFAULT 0.0,
    importaciones_bienes_bruto DOUBLE PRECISION DEFAULT 0.0,
    importaciones_bienes_neto DOUBLE PRECISION DEFAULT 0.0,
    impuesto_importaciones_bienes DOUBLE PRECISION DEFAULT 0.0,
    importaciones_activos_fijos_bruto DOUBLE PRECISION DEFAULT 0.0,
    importaciones_activos_fijos_neto DOUBLE PRECISION DEFAULT 0.0,
    impuesto_importaciones_activos_fijos DOUBLE PRECISION DEFAULT 0.0,
    importaciones_0_bruto DOUBLE PRECISION DEFAULT 0.0,
    importaciones_0_neto DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 10: Adquisiciones tarifa 0%
    adquisiciones_tarifa_cero DOUBLE PRECISION DEFAULT 0.0,
    adquisiciones_0_bruto DOUBLE PRECISION DEFAULT 0.0,
    adquisiciones_0_neto DOUBLE PRECISION DEFAULT 0.0,
    adquisiciones_rise_bruto DOUBLE PRECISION DEFAULT 0.0,
    adquisiciones_rise_neto DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 11: Totales adquisiciones
    total_adquisiciones DOUBLE PRECISION DEFAULT 0.0,
    total_adquisiciones_neto DOUBLE PRECISION DEFAULT 0.0,
    total_impuesto_adquisiciones DOUBLE PRECISION DEFAULT 0.0,
    adquisiciones_no_objeto_bruto DOUBLE PRECISION DEFAULT 0.0,
    adquisiciones_no_objeto_neto DOUBLE PRECISION DEFAULT 0.0,
    adquisiciones_exentas_bruto DOUBLE PRECISION DEFAULT 0.0,
    adquisiciones_exentas_neto DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 12: Notas de crédito en compras
    notas_credito_compras_0_compensar DOUBLE PRECISION DEFAULT 0.0,
    notas_credito_compras_diferente_0_bruto DOUBLE PRECISION DEFAULT 0.0,
    notas_credito_compras_diferente_0_impuesto DOUBLE PRECISION DEFAULT 0.0,
    pagos_reembolso_bruto DOUBLE PRECISION DEFAULT 0.0,
    pagos_reembolso_neto DOUBLE PRECISION DEFAULT 0.0,
    pagos_reembolso_impuesto DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 13: Crédito tributario
    credito_tributario_aplicable DOUBLE PRECISION DEFAULT 0.0,
    factor_proporcionalidad DOUBLE PRECISION DEFAULT 0.0,
    iva_no_considerado_credito DOUBLE PRECISION DEFAULT 0.0,
    ajuste_positivo_credito DOUBLE PRECISION DEFAULT 0.0,
    ajuste_negativo_credito DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 14: Importaciones de materias primas
    importaciones_materias_primas_valor DOUBLE PRECISION DEFAULT 0.0,
    importaciones_materias_primas_isd_pagado DOUBLE PRECISION DEFAULT 0.0,
    proporcion_ingreso_neto_divisas DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 15: Saldos y ajustes
    compensacion_iva_medio_electronico DOUBLE PRECISION DEFAULT 0.0,
    saldo_credito_anterior_adquisiciones DOUBLE PRECISION DEFAULT 0.0,
    saldo_credito_anterior_retenciones DOUBLE PRECISION DEFAULT 0.0,
    saldo_credito_anterior_electronico DOUBLE PRECISION DEFAULT 0.0,
    saldo_credito_anterior_zonas_afectadas DOUBLE PRECISION DEFAULT 0.0,
    iva_devuelto_adultos_mayores DOUBLE PRECISION DEFAULT 0.0,
    ajuste_iva_devuelto_electronico DOUBLE PRECISION DEFAULT 0.0,
    ajuste_iva_devuelto_adquisiciones DOUBLE PRECISION DEFAULT 0.0,
    ajuste_iva_devuelto_retenciones DOUBLE PRECISION DEFAULT 0.0,
    ajuste_iva_otras_instituciones DOUBLE PRECISION DEFAULT 0.0,
    saldo_credito_proximo_adquisiciones DOUBLE PRECISION DEFAULT 0.0,
    saldo_credito_proximo_retenciones DOUBLE PRECISION DEFAULT 0.0,
    saldo_credito_proximo_electronico DOUBLE PRECISION DEFAULT 0.0,
    saldo_credito_proximo_zonas_afectadas DOUBLE PRECISION DEFAULT 0.0,
    iva_pagado_no_compensado DOUBLE PRECISION DEFAULT 0.0,
    ajuste_credito_superior_5_anos DOUBLE PRECISION DEFAULT 0.0,
    devolucion_provisional_iva DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 16: Additional fields
    field_887 DOUBLE PRECISION DEFAULT 0.0,
    saldo_credito_anterior_compensacion_electronico DOUBLE PRECISION DEFAULT 0.0,
    saldo_credito_proximo_compensacion_electronico DOUBLE PRECISION DEFAULT 0.0,
    ajuste_reduccion_impuesto_tarifa_5 DOUBLE PRECISION DEFAULT 0.0,
    ajuste_reduccion_impuesto_iva_diferencial DOUBLE PRECISION DEFAULT 0.0,
    ajuste_credito_compensacion_zonas_afectadas DOUBLE PRECISION DEFAULT 0.0,
    saldo_credito_anterior_iva_medio_electronico DOUBLE PRECISION DEFAULT 0.0,
    saldo_credito_proximo_iva_electronico DOUBLE PRECISION DEFAULT 0.0,
    
    -- Section 17: Retenciones
    retenciones_iva JSON,
    
    -- Section 18: Totales finales
    impuesto_causado DOUBLE PRECISION DEFAULT 0.0,
    retenciones_efectuadas DOUBLE PRECISION DEFAULT 0.0,
    subtotal_a_pagar DOUBLE PRECISION DEFAULT 0.0,
    total_impuesto_retenido DOUBLE PRECISION DEFAULT 0.0,
    total_impuesto_pagar_retencion DOUBLE PRECISION DEFAULT 0.0,
    total_impuesto_pagar_percepcion DOUBLE PRECISION DEFAULT 0.0,
    total_consolidado_iva DOUBLE PRECISION DEFAULT 0.0,
    total_impuesto_a_pagar DOUBLE PRECISION DEFAULT 0.0,
    interes_mora DOUBLE PRECISION DEFAULT 0.0,
    multa DOUBLE PRECISION DEFAULT 0.0,
    total_pagado DOUBLE PRECISION DEFAULT 0.0,
    iva_ajuste_pagar DOUBLE PRECISION DEFAULT 0.0,
    iva_ajuste_favor DOUBLE PRECISION DEFAULT 0.0,
    
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Temporary files tracking
CREATE TABLE temporary_files (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITHOUT TIME ZONE NOT NULL
);

-- Usage analytics
CREATE TABLE usage_analytics (
    id SERIAL PRIMARY KEY,
    event_type VARCHAR(50) NOT NULL,
    user_id INTEGER,
    session_id VARCHAR(255),
    event_data JSONB,
    created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Users indexes
CREATE INDEX ix_users_id ON users(id);
CREATE UNIQUE INDEX ix_users_username ON users(username);
CREATE UNIQUE INDEX ix_users_email ON users(email);
CREATE INDEX ix_users_google_id ON users(google_id);

-- Guest sessions indexes
CREATE INDEX idx_guest_sessions_session_id ON guest_sessions(session_id);
CREATE INDEX idx_guest_sessions_created_at ON guest_sessions(created_at);

-- Documents indexes
CREATE INDEX ix_documents_id ON documents(id);
CREATE INDEX ix_documents_form_type ON documents(form_type);
CREATE INDEX ix_documents_processing_status ON documents(processing_status);
CREATE INDEX ix_documents_identificacion_ruc ON documents(identificacion_ruc);
CREATE INDEX ix_documents_codigo_verificador ON documents(codigo_verificador);
CREATE INDEX ix_documents_periodo_anio ON documents(periodo_anio);
CREATE INDEX ix_documents_session_id ON documents(session_id);
CREATE INDEX idx_documents_user_id ON documents(user_id);
CREATE INDEX idx_documents_razon_social ON documents(razon_social);
CREATE INDEX idx_documents_periodo_mes ON documents(periodo_mes);
CREATE INDEX idx_documents_periodo_mes_numero ON documents(periodo_mes_numero);

-- Form 103 line items indexes
CREATE INDEX ix_form_103_line_items_id ON form_103_line_items(id);
CREATE INDEX ix_form_103_line_items_document_id ON form_103_line_items(document_id);
CREATE INDEX idx_form_103_user_id ON form_103_line_items(user_id);

-- Form 103 totals indexes
CREATE INDEX ix_form_103_totals_id ON form_103_totals(id);
CREATE UNIQUE INDEX ix_form_103_totals_document_id ON form_103_totals(document_id);

-- Form 104 data indexes
CREATE INDEX ix_form_104_data_id ON form_104_data(id);
CREATE INDEX ix_form_104_data_document_id ON form_104_data(document_id);
CREATE INDEX idx_form_104_data_user_id ON form_104_data(user_id);

-- Temporary files indexes
CREATE INDEX idx_temp_files_session_id ON temporary_files(session_id);
CREATE INDEX idx_temp_files_expires_at ON temporary_files(expires_at);

-- Usage analytics indexes
CREATE INDEX idx_analytics_user_id ON usage_analytics(user_id);
CREATE INDEX idx_analytics_event_type ON usage_analytics(event_type);

-- ============================================================================
-- VERIFICATION QUERY
-- ============================================================================

-- Run this to verify all tables were created:
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;

-- Expected output (9 tables):
-- documents
-- form_103_line_items
-- form_103_totals
-- form_104_data
-- guest_sessions
-- temporary_files
-- usage_analytics
-- users

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================
