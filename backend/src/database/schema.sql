-- Cop Stopper Database Schema
-- PostgreSQL database schema for the Cop Stopper application

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table for authentication
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    last_login TIMESTAMP
);

-- User settings table
CREATE TABLE user_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    video_quality VARCHAR(10) DEFAULT '1080p',
    audio_bitrate INTEGER DEFAULT 128,
    auto_save BOOLEAN DEFAULT true,
    cloud_backup BOOLEAN DEFAULT true,
    data_sharing BOOLEAN DEFAULT false,
    jurisdiction VARCHAR(100),
    consent_recording BOOLEAN DEFAULT true,
    notifications_enabled BOOLEAN DEFAULT true,
    voice_commands BOOLEAN DEFAULT false,
    high_contrast BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Emergency contacts table
CREATE TABLE emergency_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    relationship VARCHAR(50),
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Recording sessions table
CREATE TABLE recording_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255),
    description TEXT,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    duration INTEGER, -- in seconds
    file_path VARCHAR(500),
    file_size BIGINT,
    video_quality VARCHAR(10),
    audio_bitrate INTEGER,
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_address TEXT,
    jurisdiction VARCHAR(100),
    is_emergency BOOLEAN DEFAULT false,
    is_encrypted BOOLEAN DEFAULT true,
    encryption_key_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Transcription data table
CREATE TABLE transcriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES recording_sessions(id) ON DELETE CASCADE,
    text_content TEXT NOT NULL,
    timestamp_start INTEGER NOT NULL, -- milliseconds from session start
    timestamp_end INTEGER NOT NULL,
    speaker_id VARCHAR(50),
    confidence_score DECIMAL(3, 2),
    language VARCHAR(10) DEFAULT 'en',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Legal guidance and fact-checking results
CREATE TABLE fact_check_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES recording_sessions(id) ON DELETE CASCADE,
    claim TEXT NOT NULL,
    status VARCHAR(20) NOT NULL, -- 'true', 'false', 'disputed', 'unverified'
    confidence DECIMAL(3, 2),
    explanation TEXT,
    sources TEXT[], -- Array of source URLs/references
    timestamp_ms INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Legal alerts during sessions
CREATE TABLE legal_alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES recording_sessions(id) ON DELETE CASCADE,
    alert_type VARCHAR(50) NOT NULL, -- 'rights_violation', 'procedural_error', etc.
    severity VARCHAR(20) NOT NULL, -- 'low', 'medium', 'high', 'critical'
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    suggested_response TEXT,
    relevant_laws TEXT[],
    timestamp_ms INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Officer records and public information
CREATE TABLE officer_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    badge_number VARCHAR(50) UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    department VARCHAR(200),
    rank VARCHAR(100),
    years_of_service INTEGER,
    photo_url VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Officer complaint records
CREATE TABLE officer_complaints (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    officer_id UUID REFERENCES officer_profiles(id) ON DELETE CASCADE,
    complaint_number VARCHAR(100),
    date_filed DATE,
    category VARCHAR(100),
    description TEXT,
    status VARCHAR(50), -- 'pending', 'sustained', 'not_sustained', 'dismissed'
    resolution TEXT,
    is_public BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Collaborative monitoring sessions
CREATE TABLE collaborative_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    session_type VARCHAR(20) NOT NULL, -- 'private_group', 'spectator_mode'
    title VARCHAR(255),
    description TEXT,
    max_participants INTEGER DEFAULT 10,
    privacy_level VARCHAR(20) DEFAULT 'private', -- 'private', 'friends', 'public'
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    radius_meters INTEGER DEFAULT 1000,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Collaborative session participants
CREATE TABLE session_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES collaborative_sessions(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'observer', -- 'host', 'observer', 'assistant'
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    UNIQUE(session_id, user_id)
);

-- Document storage metadata
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    session_id UUID REFERENCES recording_sessions(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    file_type VARCHAR(50),
    file_path VARCHAR(500),
    file_size BIGINT,
    is_encrypted BOOLEAN DEFAULT true,
    encryption_key_id VARCHAR(100),
    tags TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit log for security and compliance
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    details JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_recording_sessions_user_id ON recording_sessions(user_id);
CREATE INDEX idx_recording_sessions_start_time ON recording_sessions(start_time);
CREATE INDEX idx_transcriptions_session_id ON transcriptions(session_id);
CREATE INDEX idx_fact_check_results_session_id ON fact_check_results(session_id);
CREATE INDEX idx_legal_alerts_session_id ON legal_alerts(session_id);
CREATE INDEX idx_officer_profiles_badge_number ON officer_profiles(badge_number);
CREATE INDEX idx_officer_complaints_officer_id ON officer_complaints(officer_id);
CREATE INDEX idx_collaborative_sessions_host_user_id ON collaborative_sessions(host_user_id);
CREATE INDEX idx_session_participants_session_id ON session_participants(session_id);
CREATE INDEX idx_documents_user_id ON documents(user_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- Functions for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_settings_updated_at BEFORE UPDATE ON user_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_recording_sessions_updated_at BEFORE UPDATE ON recording_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_officer_profiles_updated_at BEFORE UPDATE ON officer_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_documents_updated_at BEFORE UPDATE ON documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();