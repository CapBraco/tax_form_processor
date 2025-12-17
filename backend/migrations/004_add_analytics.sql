-- ============================================================================
-- ANALYTICS TRACKING DATABASE MIGRATION
-- Add analytics_events table for visitor and usage tracking
-- ============================================================================

-- Create analytics_events table
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

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_analytics_event_type ON analytics_events(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_session_id ON analytics_events(session_id);
CREATE INDEX IF NOT EXISTS idx_analytics_user_id ON analytics_events(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_created_at ON analytics_events(created_at);
CREATE INDEX IF NOT EXISTS idx_analytics_event_data ON analytics_events USING GIN(event_data);

-- Add relationship to users table (if not exists)
-- This should already exist in your User model
-- ALTER TABLE users ADD COLUMN IF NOT EXISTS analytics_events_relation VARCHAR(50);

COMMENT ON TABLE analytics_events IS 'Tracks all analytics events including page views, uploads, exports, etc.';
COMMENT ON COLUMN analytics_events.event_type IS 'Type of event: page_view, upload, export, etc.';
COMMENT ON COLUMN analytics_events.event_data IS 'JSON data with additional event details (page path, metadata, etc.)';
COMMENT ON COLUMN analytics_events.session_id IS 'Session ID for tracking guest users';
COMMENT ON COLUMN analytics_events.user_id IS 'User ID for registered users (NULL for guests)';
COMMENT ON COLUMN analytics_events.ip_address IS 'IP address of the visitor (optional)';
COMMENT ON COLUMN analytics_events.user_agent IS 'Browser user agent string (optional)';
