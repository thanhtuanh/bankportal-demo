-- Create accounts table if not exists
CREATE TABLE IF NOT EXISTS account (
    id BIGSERIAL PRIMARY KEY,
    owner VARCHAR(255) NOT NULL,
    balance DECIMAL(10,2) NOT NULL DEFAULT 0.00
);

-- Insert some test data if table is empty
INSERT INTO account (owner, balance) 
SELECT 'Max Mustermann', 1000.00 
WHERE NOT EXISTS (SELECT 1 FROM account WHERE owner = 'Max Mustermann');

INSERT INTO account (owner, balance) 
SELECT 'Anna Schmidt', 2500.50 
WHERE NOT EXISTS (SELECT 1 FROM account WHERE owner = 'Anna Schmidt');

INSERT INTO account (owner, balance) 
SELECT 'Peter Müller', 750.25 
WHERE NOT EXISTS (SELECT 1 FROM account WHERE owner = 'Peter Müller');