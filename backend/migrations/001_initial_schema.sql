-- ============================================================================
-- 001_initial_schema.sql
-- Complete initial database schema for Tax Forms Processor
-- ============================================================================

-- Enable UUID extension (if needed)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- USERS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    is_superuser BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_is_superuser ON users(is_superuser);

-- ============================================================================
-- GUEST SESSIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS guest_sessions (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) UNIQUE NOT NULL,
    document_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_guest_sessions_session_id ON guest_sessions(session_id);
CREATE INDEX IF NOT EXISTS idx_guest_sessions_expires_at ON guest_sessions(expires_at);

-- ============================================================================
-- DOCUMENTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS documents (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(500) NOT NULL,
    file_path VARCHAR(1000),
    file_size INTEGER,
    form_type VARCHAR(50),
    razon_social VARCHAR(500),
    ruc VARCHAR(50),
    period VARCHAR(20),
    status VARCHAR(50) DEFAULT 'pending',
    error_message TEXT,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    session_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_documents_user_id ON documents(user_id);
CREATE INDEX IF NOT EXISTS idx_documents_session_id ON documents(session_id);
CREATE INDEX IF NOT EXISTS idx_documents_form_type ON documents(form_type);
CREATE INDEX IF NOT EXISTS idx_documents_razon_social ON documents(razon_social);
CREATE INDEX IF NOT EXISTS idx_documents_ruc ON documents(ruc);
CREATE INDEX IF NOT EXISTS idx_documents_period ON documents(period);
CREATE INDEX IF NOT EXISTS idx_documents_status ON documents(status);
CREATE INDEX IF NOT EXISTS idx_documents_created_at ON documents(created_at);

-- ============================================================================
-- FORM 103 DATA TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS form_103_data (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES documents(id) ON DELETE CASCADE,
    razon_social VARCHAR(500),
    ruc VARCHAR(50),
    period VARCHAR(20),
    
    -- Form 103 specific fields
    base_imponible_total NUMERIC(15, 2),
    valor_retenido_total NUMERIC(15, 2),
    
    -- Store all extracted data as JSON for flexibility
    raw_data JSONB,
    
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    session_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_form_103_document_id ON form_103_data(document_id);
CREATE INDEX IF NOT EXISTS idx_form_103_user_id ON form_103_data(user_id);
CREATE INDEX IF NOT EXISTS idx_form_103_session_id ON form_103_data(session_id);
CREATE INDEX IF NOT EXISTS idx_form_103_razon_social ON form_103_data(razon_social);
CREATE INDEX IF NOT EXISTS idx_form_103_ruc ON form_103_data(ruc);
CREATE INDEX IF NOT EXISTS idx_form_103_period ON form_103_data(period);
CREATE INDEX IF NOT EXISTS idx_form_103_raw_data ON form_103_data USING GIN(raw_data);

-- ============================================================================
-- FORM 104 DATA TABLE (127 fields)
-- ============================================================================
CREATE TABLE IF NOT EXISTS form_104_data (
    id SERIAL PRIMARY KEY,
    document_id INTEGER REFERENCES documents(id) ON DELETE CASCADE,
    razon_social VARCHAR(500),
    ruc VARCHAR(50),
    period VARCHAR(20),
    
    -- IDENTIFICACIÓN (14 fields)
    periodo_fiscal VARCHAR(50),
    formulario_num VARCHAR(50),
    num_formulario_que_sustituye VARCHAR(50),
    
    -- VENTAS (24 fields)
    ventas_tarifa_0 NUMERIC(15, 2),
    ventas_tarifa_12 NUMERIC(15, 2),
    ventas_tarifa_15 NUMERIC(15, 2),
    ventas_no_objeto_iva NUMERIC(15, 2),
    ventas_exentas NUMERIC(15, 2),
    
    -- COMPRAS (42 fields)
    compras_tarifa_0 NUMERIC(15, 2),
    compras_tarifa_12 NUMERIC(15, 2),
    compras_tarifa_15 NUMERIC(15, 2),
    compras_no_objeto_iva NUMERIC(15, 2),
    
    -- LIQUIDACIÓN IVA (15 fields)
    impuesto_causado NUMERIC(15, 2),
    credito_tributario NUMERIC(15, 2),
    iva_a_pagar NUMERIC(15, 2),
    saldo_favor_contribuyente NUMERIC(15, 2),
    
    -- RESUMEN IMPOSITIVO (15 fields)
    total_ventas NUMERIC(15, 2),
    total_compras NUMERIC(15, 2),
    diferencia NUMERIC(15, 2),
    
    -- EXPORTACIONES (8 fields)
    exportaciones_bienes NUMERIC(15, 2),
    exportaciones_servicios NUMERIC(15, 2),
    
    -- TOTALES FINALES (9 fields)
    total_impuesto_generado NUMERIC(15, 2),
    total_impuesto_pagado NUMERIC(15, 2),
    saldo_total NUMERIC(15, 2),
    
    -- Store all extracted data as JSON for complete flexibility
    raw_data JSONB,
    
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    session_id VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_form_104_document_id ON form_104_data(document_id);
CREATE INDEX IF NOT EXISTS idx_form_104_user_id ON form_104_data(user_id);
CREATE INDEX IF NOT EXISTS idx_form_104_session_id ON form_104_data(session_id);
CREATE INDEX IF NOT EXISTS idx_form_104_razon_social ON form_104_data(razon_social);
CREATE INDEX IF NOT EXISTS idx_form_104_ruc ON form_104_data(ruc);
CREATE INDEX IF NOT EXISTS idx_form_104_period ON form_104_data(period);
CREATE INDEX IF NOT EXISTS idx_form_104_raw_data ON form_104_data USING GIN(raw_data);

-- ============================================================================
-- ANALYTICS EVENTS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS analytics_events (
    id SERIAL PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    session_id VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_analytics_event_type ON analytics_events(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_session_id ON analytics_events(session_id);
CREATE INDEX IF NOT EXISTS idx_analytics_user_id ON analytics_events(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_created_at ON analytics_events(created_at);
CREATE INDEX IF NOT EXISTS idx_analytics_event_data ON analytics_events USING GIN(event_data);

-- ============================================================================
-- TEMPORARY FILES TABLE (for guest uploads)
-- ============================================================================
CREATE TABLE IF NOT EXISTS temporary_files (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) NOT NULL,
    file_path VARCHAR(1000) NOT NULL,
    document_id INTEGER REFERENCES documents(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_temporary_files_session_id ON temporary_files(session_id);
CREATE INDEX IF NOT EXISTS idx_temporary_files_expires_at ON temporary_files(expires_at);
CREATE INDEX IF NOT EXISTS idx_temporary_files_document_id ON temporary_files(document_id);

-- ============================================================================
-- USAGE ANALYTICS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS usage_analytics (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    session_id VARCHAR(255),
    action VARCHAR(100) NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_usage_analytics_user_id ON usage_analytics(user_id);
CREATE INDEX IF NOT EXISTS idx_usage_analytics_session_id ON usage_analytics(session_id);
CREATE INDEX IF NOT EXISTS idx_usage_analytics_action ON usage_analytics(action);
CREATE INDEX IF NOT EXISTS idx_usage_analytics_created_at ON usage_analytics(created_at);

-- ============================================================================
-- COMMENTS
-- ============================================================================
COMMENT ON TABLE users IS 'Registered user accounts with authentication';
COMMENT ON TABLE guest_sessions IS 'Guest session tracking with document limits';
COMMENT ON TABLE documents IS 'Uploaded PDF documents metadata';
COMMENT ON TABLE form_103_data IS 'Extracted data from Form 103 (Retenciones)';
COMMENT ON TABLE form_104_data IS 'Extracted data from Form 104 (IVA) - 127 fields';
COMMENT ON TABLE analytics_events IS 'Analytics tracking for visitors and usage';
COMMENT ON TABLE temporary_files IS 'Temporary file storage for guest sessions';
COMMENT ON TABLE usage_analytics IS 'User action tracking and usage statistics';

-- ============================================================================
-- DEFAULT ADMIN USER (password: admin123 - CHANGE THIS!)
-- ============================================================================
-- Uncomment and modify after deployment
-- INSERT INTO users (username, email, hashed_password, is_superuser, created_at)
-- VALUES (
--     'admin',
--     'admin@pantributario.com',
--     '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyPvg7SqDL4u',
--     true,
--     NOW()
-- );

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- Run this to verify tables were created:
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;
