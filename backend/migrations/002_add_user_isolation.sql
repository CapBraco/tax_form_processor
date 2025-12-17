-- ============================================================================
-- 002_add_user_isolation.sql
-- Add user_id to all tables for complete user data isolation
-- (Run this only if your tables don't already have user_id columns)
-- ============================================================================

-- Check if migrations are needed
DO $$ 
BEGIN
    -- Add user_id to documents if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'documents' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE documents ADD COLUMN user_id INTEGER REFERENCES users(id) ON DELETE CASCADE;
        CREATE INDEX idx_documents_user_id ON documents(user_id);
    END IF;

    -- Add user_id to form_103_data if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'form_103_data' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE form_103_data ADD COLUMN user_id INTEGER REFERENCES users(id) ON DELETE CASCADE;
        CREATE INDEX idx_form_103_user_id ON form_103_data(user_id);
    END IF;

    -- Add user_id to form_104_data if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'form_104_data' AND column_name = 'user_id'
    ) THEN
        ALTER TABLE form_104_data ADD COLUMN user_id INTEGER REFERENCES users(id) ON DELETE CASCADE;
        CREATE INDEX idx_form_104_user_id ON form_104_data(user_id);
    END IF;

    -- Add session_id to documents if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'documents' AND column_name = 'session_id'
    ) THEN
        ALTER TABLE documents ADD COLUMN session_id VARCHAR(255);
        CREATE INDEX idx_documents_session_id ON documents(session_id);
    END IF;

    -- Add session_id to form_103_data if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'form_103_data' AND column_name = 'session_id'
    ) THEN
        ALTER TABLE form_103_data ADD COLUMN session_id VARCHAR(255);
        CREATE INDEX idx_form_103_session_id ON form_103_data(session_id);
    END IF;

    -- Add session_id to form_104_data if not exists
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'form_104_data' AND column_name = 'session_id'
    ) THEN
        ALTER TABLE form_104_data ADD COLUMN session_id VARCHAR(255);
        CREATE INDEX idx_form_104_session_id ON form_104_data(session_id);
    END IF;

END $$;

-- ============================================================================
-- Add comments
-- ============================================================================
COMMENT ON COLUMN documents.user_id IS 'User ID for registered users, NULL for guests';
COMMENT ON COLUMN documents.session_id IS 'Session ID for guest users, NULL for registered';
COMMENT ON COLUMN form_103_data.user_id IS 'User ID for complete data isolation';
COMMENT ON COLUMN form_103_data.session_id IS 'Guest session ID for temporary data';
COMMENT ON COLUMN form_104_data.user_id IS 'User ID for complete data isolation';
COMMENT ON COLUMN form_104_data.session_id IS 'Guest session ID for temporary data';

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- This migration is idempotent - safe to run multiple times
