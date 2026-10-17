-- V1__initial_schema.sql
-- Flyway Database Migration for Expert Consultation Platform

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(30) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    avatar_url VARCHAR(500),
    role VARCHAR(30) NOT NULL DEFAULT 'CUSTOMER', -- CUSTOMER, CREATOR, ADMIN
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    fcm_token VARCHAR(500),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_email ON users(email);

-- 2. Categories Table
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(120) NOT NULL UNIQUE,
    description TEXT,
    icon_url VARCHAR(500),
    display_order INT DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Expert / Creator Profiles Table
CREATE TABLE expert_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    headline VARCHAR(255),
    bio TEXT,
    experience_years INT DEFAULT 0,
    audio_rate_per_min DECIMAL(10, 2) DEFAULT 0.00,
    video_rate_per_min DECIMAL(10, 2) DEFAULT 0.00,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,
    is_approved BOOLEAN NOT NULL DEFAULT FALSE,
    rating_average DECIMAL(3, 2) DEFAULT 5.00,
    total_reviews INT DEFAULT 0,
    total_consultations INT DEFAULT 0,
    agora_uid BIGINT,
    kyc_status VARCHAR(30) NOT NULL DEFAULT 'NOT_SUBMITTED', -- NOT_SUBMITTED, PENDING, APPROVED, REJECTED
    wallet_balance DECIMAL(12, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_expert_category ON expert_profiles(category_id);
CREATE INDEX idx_expert_rating ON expert_profiles(rating_average DESC);
CREATE INDEX idx_expert_kyc ON expert_profiles(kyc_status);

-- 4. KYC Verifications
CREATE TABLE kyc_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    expert_id UUID NOT NULL REFERENCES expert_profiles(id) ON DELETE CASCADE,
    id_type VARCHAR(50) NOT NULL, -- AADHAAR, PAN, PASSPORT, DRIVING_LICENSE
    id_number VARCHAR(100) NOT NULL,
    document_front_url VARCHAR(500) NOT NULL,
    document_back_url VARCHAR(500),
    selfie_url VARCHAR(500),
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING', -- PENDING, APPROVED, REJECTED
    rejection_reason TEXT,
    reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Call Sessions
CREATE TABLE call_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    call_id VARCHAR(100) NOT NULL UNIQUE,
    customer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    expert_id UUID NOT NULL REFERENCES expert_profiles(id) ON DELETE RESTRICT,
    call_type VARCHAR(20) NOT NULL DEFAULT 'VIDEO', -- AUDIO, VIDEO
    status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED', -- REQUESTED, RINGING, CONNECTED, ENDED, REJECTED, MISSED, CANCELLED
    agora_channel_name VARCHAR(120) NOT NULL,
    agora_token TEXT,
    start_time TIMESTAMP WITH TIME ZONE,
    end_time TIMESTAMP WITH TIME ZONE,
    duration_seconds INT DEFAULT 0,
    rate_per_minute DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(10, 2) DEFAULT 0.00,
    commission_amount DECIMAL(10, 2) DEFAULT 0.00,
    expert_earnings DECIMAL(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_call_customer ON call_sessions(customer_id);
CREATE INDEX idx_call_expert ON call_sessions(expert_id);
CREATE INDEX idx_call_status ON call_sessions(status);

-- 6. Transactions Table
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reference_id VARCHAR(100) NOT NULL UNIQUE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    call_session_id UUID REFERENCES call_sessions(id) ON DELETE SET NULL,
    amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    payment_gateway VARCHAR(30) NOT NULL DEFAULT 'RAZORPAY', -- RAZORPAY, CASHFREE
    gateway_order_id VARCHAR(150),
    gateway_payment_id VARCHAR(150),
    gateway_signature VARCHAR(255),
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING', -- PENDING, SUCCESS, FAILED, REFUNDED
    type VARCHAR(30) NOT NULL, -- WALLET_RECHARGE, CALL_PAYMENT, CREATOR_PAYOUT
    failure_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_tx_user ON transactions(user_id);
CREATE INDEX idx_tx_status ON transactions(status);
CREATE INDEX idx_tx_order_id ON transactions(gateway_order_id);

-- 7. Reviews Table
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    call_session_id UUID NOT NULL UNIQUE REFERENCES call_sessions(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    expert_id UUID NOT NULL REFERENCES expert_profiles(id) ON DELETE RESTRICT,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. Payout Requests Table
CREATE TABLE payout_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    expert_id UUID NOT NULL REFERENCES expert_profiles(id) ON DELETE CASCADE,
    amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'INR',
    status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED', -- REQUESTED, PROCESSING, COMPLETED, REJECTED
    bank_account_number VARCHAR(50),
    bank_ifsc VARCHAR(30),
    upi_id VARCHAR(100),
    processed_at TIMESTAMP WITH TIME ZONE,
    transaction_reference VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
