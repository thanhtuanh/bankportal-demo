-- src/main/resources/init.sql
-- Database initialization for Account Service

-- Create accounts table if it doesn't exist
CREATE TABLE IF NOT EXISTS account (
    id BIGSERIAL PRIMARY KEY,
    owner VARCHAR(255) NOT NULL,
    balance DOUBLE PRECISION NOT NULL DEFAULT 0.0
);

-- Insert some sample data for testing (optional)
INSERT INTO account (owner, balance) VALUES 
    ('Max Mustermann', 1000.0),
    ('Anna Schmidt', 2500.0),
    ('John Doe', 500.0)
ON CONFLICT DO NOTHING;