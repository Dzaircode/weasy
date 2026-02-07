-- ============================================================================
-- MULTI-SERVICE PLATFORM - POSTGRESQL DATABASE SCHEMA
-- ============================================================================
-- This schema supports: Food Delivery, Marketplace, Package Delivery, 
-- Digital Services with Wallet-First Payment System (Algeria-Ready)
-- ============================================================================

-- ============================================================================
-- DATABASE SETUP
-- ============================================================================

-- Create separate databases for each microservice
CREATE DATABASE auth_service_db;
CREATE DATABASE wallet_service_db;
CREATE DATABASE order_service_db;
CREATE DATABASE merchant_service_db;
CREATE DATABASE dispatch_service_db;

-- ============================================================================
-- AUTH SERVICE DATABASE
-- ============================================================================

\c auth_service_db;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- User roles enumeration
CREATE TYPE user_role AS ENUM ('CLIENT', 'DRIVER', 'MERCHANT', 'ADMIN', 'SUPPORT');

-- KYC status enumeration
CREATE TYPE kyc_status AS ENUM ('PENDING', 'VERIFIED', 'REJECTED', 'EXPIRED');

-- Users table (core identity)
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role user_role NOT NULL DEFAULT 'CLIENT',
    kyc_status kyc_status DEFAULT 'PENDING',
    kyc_verified_at TIMESTAMP,
    profile_image_url TEXT,
    date_of_birth DATE,
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100) DEFAULT 'Algeria',
    is_active BOOLEAN DEFAULT TRUE,
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_phone_verified BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sessions table
CREATE TABLE sessions (
    session_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    refresh_token_hash VARCHAR(255),
    device_info JSONB,
    ip_address INET,
    user_agent TEXT,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Roles table (for RBAC)
CREATE TABLE roles (
    role_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    permissions JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User roles mapping (many-to-many)
CREATE TABLE user_roles (
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    role_id UUID REFERENCES roles(role_id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by UUID REFERENCES users(user_id),
    PRIMARY KEY (user_id, role_id)
);

-- OTP verification table
CREATE TABLE otp_verifications (
    otp_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(user_id) ON DELETE CASCADE,
    phone VARCHAR(20) NOT NULL,
    otp_code VARCHAR(6) NOT NULL,
    purpose VARCHAR(50) NOT NULL, -- 'REGISTRATION', 'LOGIN', 'PASSWORD_RESET'
    expires_at TIMESTAMP NOT NULL,
    verified_at TIMESTAMP,
    attempts INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for Auth Service
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_token_hash ON sessions(token_hash);
CREATE INDEX idx_sessions_expires_at ON sessions(expires_at);
CREATE INDEX idx_otp_phone ON otp_verifications(phone);
CREATE INDEX idx_otp_expires_at ON otp_verifications(expires_at);

-- ============================================================================
-- WALLET SERVICE DATABASE
-- ============================================================================

\c wallet_service_db;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Wallet types
CREATE TYPE wallet_type AS ENUM ('CLIENT', 'DRIVER', 'MERCHANT', 'PLATFORM');

-- Wallet status
CREATE TYPE wallet_status AS ENUM ('ACTIVE', 'SUSPENDED', 'FROZEN', 'CLOSED');

-- Transaction types
CREATE TYPE transaction_type AS ENUM (
    'DEPOSIT', 
    'WITHDRAWAL', 
    'ORDER_PAYMENT', 
    'ORDER_REFUND',
    'DRIVER_EARNING',
    'MERCHANT_REVENUE',
    'COMMISSION',
    'ADJUSTMENT',
    'TRANSFER'
);

-- Transaction status
CREATE TYPE transaction_status AS ENUM (
    'PENDING', 
    'RESERVED', 
    'COMPLETED', 
    'FAILED', 
    'REVERSED',
    'CANCELLED'
);

-- Deposit/Withdrawal request status
CREATE TYPE request_status AS ENUM (
    'PENDING', 
    'APPROVED', 
    'REJECTED', 
    'COMPLETED', 
    'CANCELLED'
);

-- Wallets table
CREATE TABLE wallets (
    wallet_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE, -- References users from auth_service_db
    wallet_type wallet_type NOT NULL,
    current_balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00 CHECK (current_balance >= 0),
    reserved_balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00 CHECK (reserved_balance >= 0),
    available_balance DECIMAL(15, 2) GENERATED ALWAYS AS (current_balance - reserved_balance) STORED,
    currency VARCHAR(3) DEFAULT 'DZD',
    status wallet_status DEFAULT 'ACTIVE',
    daily_withdrawal_limit DECIMAL(15, 2),
    monthly_withdrawal_limit DECIMAL(15, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_balance_non_negative CHECK (current_balance >= reserved_balance)
);

-- Transactions table (all wallet movements)
CREATE TABLE transactions (
    transaction_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_type transaction_type NOT NULL,
    source_wallet_id UUID REFERENCES wallets(wallet_id),
    destination_wallet_id UUID REFERENCES wallets(wallet_id),
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    status transaction_status DEFAULT 'PENDING',
    reference_id UUID, -- order_id, request_id, etc.
    reference_type VARCHAR(50), -- 'ORDER', 'DEPOSIT_REQUEST', etc.
    idempotency_key VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    created_by UUID, -- admin or system
    CONSTRAINT check_wallets_different CHECK (
        source_wallet_id IS NULL OR 
        destination_wallet_id IS NULL OR 
        source_wallet_id != destination_wallet_id
    )
);

-- Ledger entries (double-entry bookkeeping)
CREATE TABLE ledger_entries (
    entry_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_id UUID NOT NULL REFERENCES transactions(transaction_id),
    wallet_id UUID NOT NULL REFERENCES wallets(wallet_id),
    entry_type VARCHAR(10) NOT NULL CHECK (entry_type IN ('DEBIT', 'CREDIT')),
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    balance_before DECIMAL(15, 2) NOT NULL,
    balance_after DECIMAL(15, 2) NOT NULL,
    description TEXT,
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by VARCHAR(100) DEFAULT 'SYSTEM'
);

-- Deposit requests
CREATE TABLE deposit_requests (
    request_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_id UUID NOT NULL REFERENCES wallets(wallet_id),
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    status request_status DEFAULT 'PENDING',
    agent_id UUID, -- driver or admin who collects cash
    collection_point VARCHAR(255),
    receipt_number VARCHAR(100),
    notes TEXT,
    verification_data JSONB,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP,
    confirmed_by UUID,
    transaction_id UUID REFERENCES transactions(transaction_id)
);

-- Withdrawal requests
CREATE TABLE withdrawal_requests (
    request_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_id UUID NOT NULL REFERENCES wallets(wallet_id),
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    status request_status DEFAULT 'PENDING',
    agent_id UUID, -- who processes withdrawal
    collection_point VARCHAR(255),
    recipient_name VARCHAR(255),
    recipient_phone VARCHAR(20),
    verification_data JSONB,
    notes TEXT,
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    approved_by UUID,
    rejected_at TIMESTAMP,
    rejected_by UUID,
    rejection_reason TEXT,
    completed_at TIMESTAMP,
    transaction_id UUID REFERENCES transactions(transaction_id)
);

-- Balance snapshots (for reconciliation)
CREATE TABLE balance_snapshots (
    snapshot_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    wallet_id UUID NOT NULL REFERENCES wallets(wallet_id),
    balance DECIMAL(15, 2) NOT NULL,
    reserved_balance DECIMAL(15, 2) NOT NULL,
    snapshot_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    snapshot_type VARCHAR(20) DEFAULT 'SCHEDULED' -- 'SCHEDULED', 'ON_DEMAND', 'RECONCILIATION'
);

-- Indexes for Wallet Service
CREATE INDEX idx_wallets_user_id ON wallets(user_id);
CREATE INDEX idx_wallets_status ON wallets(status);
CREATE INDEX idx_transactions_source ON transactions(source_wallet_id);
CREATE INDEX idx_transactions_destination ON transactions(destination_wallet_id);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_reference ON transactions(reference_id, reference_type);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
CREATE INDEX idx_ledger_transaction_id ON ledger_entries(transaction_id);
CREATE INDEX idx_ledger_wallet_id ON ledger_entries(wallet_id);
CREATE INDEX idx_ledger_created_at ON ledger_entries(created_at);
CREATE INDEX idx_deposit_wallet_id ON deposit_requests(wallet_id);
CREATE INDEX idx_deposit_status ON deposit_requests(status);
CREATE INDEX idx_withdrawal_wallet_id ON withdrawal_requests(wallet_id);
CREATE INDEX idx_withdrawal_status ON withdrawal_requests(status);

-- ============================================================================
-- ORDER SERVICE DATABASE
-- ============================================================================

\c order_service_db;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User roles enumeration (needed for order_status_history)
CREATE TYPE user_role AS ENUM ('CLIENT', 'DRIVER', 'MERCHANT', 'ADMIN', 'SUPPORT');

-- Order types
CREATE TYPE order_type AS ENUM ('FOOD', 'MARKET', 'PACKAGE', 'DIGITAL_MOBILE', 'DIGITAL_FLIGHT');

-- Order status
CREATE TYPE order_status AS ENUM (
    'CREATED',
    'PAYMENT_PENDING',
    'PAYMENT_RESERVED',
    'ACCEPTED',
    'PREPARING',
    'READY_FOR_PICKUP',
    'DRIVER_ASSIGNED',
    'PICKED_UP',
    'IN_TRANSIT',
    'ARRIVED',
    'DELIVERED',
    'PAYMENT_SETTLED',
    'COMPLETED',
    'CANCELLED',
    'REFUND_PROCESSING',
    'REFUND_COMPLETED',
    'DISPUTED',
    'RESOLVED'
);

-- Orders table
CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(20) UNIQUE NOT NULL,
    user_id UUID NOT NULL, -- References users from auth_service_db
    merchant_id UUID, -- References merchants from merchant_service_db
    order_type order_type NOT NULL,
    status order_status DEFAULT 'CREATED',
    
    -- Addresses
    pickup_address TEXT,
    delivery_address TEXT NOT NULL,
    delivery_latitude DECIMAL(10, 8),
    delivery_longitude DECIMAL(11, 8),
    
    -- Pricing
    subtotal DECIMAL(10, 2) NOT NULL CHECK (subtotal >= 0),
    delivery_fee DECIMAL(10, 2) DEFAULT 0.00 CHECK (delivery_fee >= 0),
    service_fee DECIMAL(10, 2) DEFAULT 0.00,
    tax DECIMAL(10, 2) DEFAULT 0.00,
    discount DECIMAL(10, 2) DEFAULT 0.00 CHECK (discount >= 0),
    total DECIMAL(10, 2) NOT NULL CHECK (total >= 0),
    commission DECIMAL(10, 2) DEFAULT 0.00,
    
    -- Special instructions
    notes TEXT,
    special_instructions TEXT,
    
    -- Tracking
    estimated_delivery_time TIMESTAMP,
    accepted_at TIMESTAMP,
    ready_at TIMESTAMP,
    picked_up_at TIMESTAMP,
    delivered_at TIMESTAMP,
    completed_at TIMESTAMP,
    cancelled_at TIMESTAMP,
    cancellation_reason TEXT,
    
    -- Metadata
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order items (for food and marketplace orders)
CREATE TABLE order_items (
    item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id UUID NOT NULL, -- References products from merchant_service_db
    product_name VARCHAR(255) NOT NULL,
    product_description TEXT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    total_price DECIMAL(10, 2) NOT NULL CHECK (total_price >= 0),
    customizations JSONB, -- size, extras, modifications
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Order status history (audit trail)
CREATE TABLE order_status_history (
    history_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    from_status order_status,
    to_status order_status NOT NULL,
    changed_by UUID, -- user_id who made the change
    changed_by_role user_role,
    notes TEXT,
    metadata JSONB,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Package delivery details (for package orders)
CREATE TABLE package_deliveries (
    package_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
    sender_name VARCHAR(255) NOT NULL,
    sender_phone VARCHAR(20) NOT NULL,
    receiver_name VARCHAR(255) NOT NULL,
    receiver_phone VARCHAR(20) NOT NULL,
    package_type VARCHAR(50), -- 'DOCUMENT', 'PARCEL', 'FRAGILE'
    package_weight DECIMAL(5, 2), -- in kg
    package_dimensions JSONB, -- length, width, height
    distance_km DECIMAL(10, 2),
    pickup_time_preference TIMESTAMP,
    delivery_time_preference TIMESTAMP,
    requires_signature BOOLEAN DEFAULT FALSE,
    insurance_value DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Digital service orders (mobile recharge, flight tickets)
CREATE TABLE digital_service_orders (
    digital_order_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
    service_type VARCHAR(50) NOT NULL, -- 'MOBILE_RECHARGE', 'FLIGHT_BOOKING'
    provider VARCHAR(100), -- telecom operator or airline
    service_details JSONB NOT NULL, -- phone number, flight details, etc.
    confirmation_code VARCHAR(100),
    provider_transaction_id VARCHAR(255),
    status VARCHAR(50) DEFAULT 'PENDING', -- 'PENDING', 'PROCESSING', 'CONFIRMED', 'FAILED'
    provider_response JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    confirmed_at TIMESTAMP,
    failed_at TIMESTAMP,
    failure_reason TEXT
);

-- Indexes for Order Service
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_merchant_id ON orders(merchant_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_type ON orders(order_type);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_order_history_order_id ON order_status_history(order_id);
CREATE INDEX idx_package_deliveries_order_id ON package_deliveries(order_id);
CREATE INDEX idx_digital_orders_order_id ON digital_service_orders(order_id);

-- ============================================================================
-- MERCHANT SERVICE DATABASE
-- ============================================================================

\c merchant_service_db;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Merchant category
CREATE TYPE merchant_category AS ENUM (
    'RESTAURANT',
    'CAFE',
    'FAST_FOOD',
    'GROCERY',
    'PHARMACY',
    'ELECTRONICS',
    'FASHION',
    'OTHER'
);

-- Merchant status
CREATE TYPE merchant_status AS ENUM ('PENDING', 'ACTIVE', 'SUSPENDED', 'CLOSED');

-- Merchants table
CREATE TABLE merchants (
    merchant_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE, -- References users from auth_service_db
    business_name VARCHAR(255) NOT NULL,
    business_name_ar VARCHAR(255), -- Arabic name
    category merchant_category NOT NULL,
    description TEXT,
    address TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    business_registration_number VARCHAR(100),
    tax_id VARCHAR(100),
    
    -- Status and ratings
    status merchant_status DEFAULT 'PENDING',
    rating DECIMAL(3, 2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
    total_ratings INT DEFAULT 0,
    
    -- Business hours
    is_open BOOLEAN DEFAULT TRUE,
    
    -- Financial
    commission_rate DECIMAL(5, 2) DEFAULT 15.00, -- percentage
    
    -- Media
    logo_url TEXT,
    cover_image_url TEXT,
    
    -- Metadata
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Merchant hours (operating hours)
CREATE TABLE merchant_hours (
    hours_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID NOT NULL REFERENCES merchants(merchant_id) ON DELETE CASCADE,
    day_of_week INT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0 = Sunday
    open_time TIME NOT NULL,
    close_time TIME NOT NULL,
    is_closed BOOLEAN DEFAULT FALSE,
    UNIQUE (merchant_id, day_of_week)
);

-- Product categories
CREATE TABLE product_categories (
    category_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID NOT NULL REFERENCES merchants(merchant_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100),
    display_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products table
CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID NOT NULL REFERENCES merchants(merchant_id) ON DELETE CASCADE,
    category_id UUID REFERENCES product_categories(category_id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    name_ar VARCHAR(255),
    description TEXT,
    description_ar TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    compare_at_price DECIMAL(10, 2), -- original price if discounted
    
    -- Availability
    is_available BOOLEAN DEFAULT TRUE,
    stock_managed BOOLEAN DEFAULT FALSE,
    
    -- Media
    image_url TEXT,
    additional_images JSONB,
    
    -- Attributes
    tags TEXT[],
    attributes JSONB, -- size options, customizations, etc.
    
    -- Metrics
    view_count INT DEFAULT 0,
    order_count INT DEFAULT 0,
    rating DECIMAL(3, 2) DEFAULT 0.00,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inventory management
CREATE TABLE inventory (
    inventory_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL UNIQUE REFERENCES products(product_id) ON DELETE CASCADE,
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    reserved_quantity INT NOT NULL DEFAULT 0 CHECK (reserved_quantity >= 0),
    available_quantity INT GENERATED ALWAYS AS (stock_quantity - reserved_quantity) STORED,
    reorder_level INT DEFAULT 10,
    reorder_quantity INT DEFAULT 50,
    last_restocked_at TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_reserved_not_exceed_stock CHECK (reserved_quantity <= stock_quantity)
);

-- Merchant reviews and ratings
CREATE TABLE merchant_reviews (
    review_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    merchant_id UUID NOT NULL REFERENCES merchants(merchant_id) ON DELETE CASCADE,
    order_id UUID NOT NULL, -- References orders from order_service_db
    user_id UUID NOT NULL, -- References users from auth_service_db
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    response_text TEXT, -- merchant response
    response_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for Merchant Service
CREATE INDEX idx_merchants_user_id ON merchants(user_id);
CREATE INDEX idx_merchants_category ON merchants(category);
CREATE INDEX idx_merchants_status ON merchants(status);
CREATE INDEX idx_merchants_location ON merchants(latitude, longitude);
CREATE INDEX idx_merchant_hours_merchant_id ON merchant_hours(merchant_id);
CREATE INDEX idx_products_merchant_id ON products(merchant_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_available ON products(is_available);
CREATE INDEX idx_inventory_product_id ON inventory(product_id);
CREATE INDEX idx_merchant_reviews_merchant_id ON merchant_reviews(merchant_id);
CREATE INDEX idx_merchant_reviews_user_id ON merchant_reviews(user_id);

-- ============================================================================
-- DISPATCH SERVICE DATABASE
-- ============================================================================

\c dispatch_service_db;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- PostGIS extension requires postgis/postgis image. Using regular postgres image.
-- For geospatial operations, use postgis/postgis:15 image in docker-compose.yml

-- Driver status
CREATE TYPE driver_status AS ENUM ('OFFLINE', 'AVAILABLE', 'BUSY', 'ON_BREAK');

-- Vehicle types
CREATE TYPE vehicle_type AS ENUM ('BIKE', 'MOTORCYCLE', 'CAR', 'VAN');

-- Delivery status
CREATE TYPE delivery_status AS ENUM (
    'ASSIGNED',
    'ACCEPTED',
    'REJECTED',
    'ARRIVED_AT_PICKUP',
    'PICKED_UP',
    'IN_TRANSIT',
    'ARRIVED_AT_DELIVERY',
    'DELIVERED',
    'FAILED',
    'CANCELLED'
);

-- Drivers table
CREATE TABLE drivers (
    driver_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL UNIQUE, -- References users from auth_service_db
    vehicle_type vehicle_type NOT NULL,
    license_number VARCHAR(50) NOT NULL UNIQUE,
    license_expiry DATE NOT NULL,
    vehicle_registration VARCHAR(50) NOT NULL,
    vehicle_model VARCHAR(100),
    vehicle_color VARCHAR(50),
    
    -- Status
    status driver_status DEFAULT 'OFFLINE',
    is_verified BOOLEAN DEFAULT FALSE,
    verification_date TIMESTAMP,
    
    -- Performance metrics
    rating DECIMAL(3, 2) DEFAULT 0.00 CHECK (rating >= 0 AND rating <= 5),
    total_ratings INT DEFAULT 0,
    total_deliveries INT DEFAULT 0,
    completed_deliveries INT DEFAULT 0,
    cancelled_deliveries INT DEFAULT 0,
    acceptance_rate DECIMAL(5, 2) DEFAULT 100.00,
    
    -- Documents
    license_image_url TEXT,
    vehicle_image_url TEXT,
    insurance_certificate_url TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Driver availability zones
CREATE TABLE driver_zones (
    zone_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    driver_id UUID NOT NULL REFERENCES drivers(driver_id) ON DELETE CASCADE,
    zone_name VARCHAR(100) NOT NULL,
    zone_polygon JSONB NOT NULL, -- GeoJSON polygon format: {"type": "Polygon", "coordinates": [[[lon, lat], ...]]}
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Deliveries table
CREATE TABLE deliveries (
    delivery_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL UNIQUE, -- References orders from order_service_db
    driver_id UUID REFERENCES drivers(driver_id),
    
    -- Locations
    pickup_address TEXT NOT NULL,
    pickup_latitude DECIMAL(10, 8) NOT NULL,
    pickup_longitude DECIMAL(11, 8) NOT NULL,
    delivery_address TEXT NOT NULL,
    delivery_latitude DECIMAL(10, 8) NOT NULL,
    delivery_longitude DECIMAL(11, 8) NOT NULL,
    
    -- Status
    status delivery_status DEFAULT 'ASSIGNED',
    
    -- Timing
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP,
    rejected_at TIMESTAMP,
    picked_up_at TIMESTAMP,
    delivered_at TIMESTAMP,
    
    -- Distance and ETA
    estimated_distance_km DECIMAL(10, 2),
    actual_distance_km DECIMAL(10, 2),
    estimated_duration_minutes INT,
    actual_duration_minutes INT,
    
    -- Delivery proof
    delivery_photo_url TEXT,
    signature_image_url TEXT,
    delivery_notes TEXT,
    
    -- Issues
    rejection_reason TEXT,
    failure_reason TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Driver locations (real-time tracking)
CREATE TABLE driver_locations (
    location_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    driver_id UUID NOT NULL REFERENCES drivers(driver_id) ON DELETE CASCADE,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    accuracy DECIMAL(8, 2), -- in meters
    heading DECIMAL(5, 2), -- direction in degrees
    speed DECIMAL(5, 2), -- in km/h
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    delivery_id UUID REFERENCES deliveries(delivery_id)
);

-- Driver earnings (per delivery)
CREATE TABLE driver_earnings (
    earning_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    driver_id UUID NOT NULL REFERENCES drivers(driver_id) ON DELETE CASCADE,
    delivery_id UUID NOT NULL REFERENCES deliveries(delivery_id) ON DELETE CASCADE,
    base_fee DECIMAL(10, 2) NOT NULL,
    distance_fee DECIMAL(10, 2) DEFAULT 0.00,
    time_bonus DECIMAL(10, 2) DEFAULT 0.00,
    tip DECIMAL(10, 2) DEFAULT 0.00,
    total_earning DECIMAL(10, 2) NOT NULL,
    paid BOOLEAN DEFAULT FALSE,
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Driver reviews
CREATE TABLE driver_reviews (
    review_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    driver_id UUID NOT NULL REFERENCES drivers(driver_id) ON DELETE CASCADE,
    order_id UUID NOT NULL, -- References orders from order_service_db
    user_id UUID NOT NULL, -- References users from auth_service_db
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for Dispatch Service
CREATE INDEX idx_drivers_user_id ON drivers(user_id);
CREATE INDEX idx_drivers_status ON drivers(status);
CREATE INDEX idx_deliveries_order_id ON deliveries(order_id);
CREATE INDEX idx_deliveries_driver_id ON deliveries(driver_id);
CREATE INDEX idx_deliveries_status ON deliveries(status);
CREATE INDEX idx_driver_locations_driver_id ON driver_locations(driver_id);
CREATE INDEX idx_driver_locations_timestamp ON driver_locations(timestamp);
CREATE INDEX idx_driver_locations_delivery_id ON driver_locations(delivery_id);
CREATE INDEX idx_driver_earnings_driver_id ON driver_earnings(driver_id);
CREATE INDEX idx_driver_earnings_paid ON driver_earnings(paid);
CREATE INDEX idx_driver_reviews_driver_id ON driver_reviews(driver_id);

-- Composite index for location queries (using lat/lon for range queries)
CREATE INDEX idx_driver_locations_coords ON driver_locations(latitude, longitude);

-- ============================================================================
-- TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- ============================================================================

-- Function to update updated_at timestamp (must be created in each database)
-- Auth Service
\c auth_service_db;
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_roles_updated_at BEFORE UPDATE ON roles 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Wallet Service
\c wallet_service_db;
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_wallets_updated_at BEFORE UPDATE ON wallets 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Order Service
\c order_service_db;
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Merchant Service
\c merchant_service_db;
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_merchants_updated_at BEFORE UPDATE ON merchants 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Dispatch Service
\c dispatch_service_db;
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_drivers_updated_at BEFORE UPDATE ON drivers 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_deliveries_updated_at BEFORE UPDATE ON deliveries 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();