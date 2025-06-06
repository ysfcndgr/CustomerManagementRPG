-- Customer Information Update System - PostgreSQL Database Schema
-- Initialize database for Docker environment

-- Create customers table
CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    address VARCHAR(255) NOT NULL,
    tax_id CHAR(11) NOT NULL UNIQUE,
    status VARCHAR(20) DEFAULT 'Active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_customers_tax_id ON customers(tax_id);
CREATE INDEX IF NOT EXISTS idx_customers_name ON customers(name);
CREATE INDEX IF NOT EXISTS idx_customers_status ON customers(status);

-- Create audit log table
CREATE TABLE IF NOT EXISTS customer_audit_log (
    log_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(customer_id),
    action VARCHAR(50) NOT NULL,
    old_values JSONB,
    new_values JSONB,
    user_id VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO customers (name, phone, email, address, tax_id, status) VALUES
('Ahmet Yılmaz', '(555) 123-4567', 'ahmet.yilmaz@example.com', 'Atatürk Caddesi No:123 Ankara', '12345678901', 'Active'),
('Fatma Kaya', '(555) 234-5678', 'fatma.kaya@example.com', 'İstiklal Caddesi No:456 İstanbul', '98765432109', 'Active'),
('Mehmet Demir', '(555) 345-6789', 'mehmet.demir@example.com', 'Cumhuriyet Bulvarı No:789 İzmir', '11111111111', 'Inactive')
ON CONFLICT (tax_id) DO NOTHING;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updated_at
DROP TRIGGER IF EXISTS update_customers_updated_at ON customers;
CREATE TRIGGER update_customers_updated_at
    BEFORE UPDATE ON customers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin; 