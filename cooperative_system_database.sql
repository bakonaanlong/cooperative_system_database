CREATE DATABASE Cooperative_System;
USE Cooperative_System;

-- SELECT * FROM cooperative;

CREATE TABLE cooperative (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,               
    reg_number VARCHAR(50) UNIQUE,           
    address TEXT,
    phone VARCHAR(15),
    email VARCHAR(100),
    established_date DATE,
    status ENUM('active', 'suspended', 'dissolved') DEFAULT 'active',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE members (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coop_id INT,
    member_no VARCHAR(20) UNIQUE,
    first_name VARCHAR(100), 
    last_name VARCHAR(100),
    gender ENUM('male', 'female'),
    date_of_birth DATE,
    phone VARCHAR(15), 
    email VARCHAR(50),
    address VARCHAR(100),
    id_type ENUM('NIN','BVN','TIN'),
    id_num VARCHAR(50),
    photo_url VARCHAR(255),
    join_date DATE,
    status ENUM('active','inactive','suspended') DEFAULT 'active',
    FOREIGN KEY (coop_id) REFERENCES cooperative(id)
);

CREATE TABLE member_next_of_kin (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    relationship ENUM('spouse', 'child', 'parent', 'sibling', 'cousin', 'friend', 'guardian', 'other') NOT NULL,
    phone VARCHAR(15) NOT NULL,
    email VARCHAR(100) NULL,
    address VARCHAR(100),
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE 
	);
    
CREATE TABLE contribution_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coop_id INT,
    name VARCHAR(100),
    amount DECIMAL(12,2),
    frequency ENUM('monthly','quarterly','annual','one-off'),
    FOREIGN KEY (coop_id) REFERENCES cooperative(id)
);

CREATE TABLE contributions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    contrib_type_id INT,
    amount DECIMAL(12,2),
    payment_date DATE,
    payment_channel ENUM('cash','bank transfer','crypto','remita', 'bank cheque'),
    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (contrib_type_id) REFERENCES contribution_types(id)
);

CREATE TABLE share_types (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coop_id INT,
    name VARCHAR(100),
    unit_price DECIMAL(12,2),
    min_units DECIMAL(6,2),
    max_units DECIMAL(6,2),
    FOREIGN KEY (coop_id) REFERENCES cooperative(id)
);

CREATE TABLE member_shares (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    share_type_id INT,
    units DECIMAL(8, 2),
    purchase_date DATE, 
    certificate_no INT,
    FOREIGN KEY (share_type_id) REFERENCES share_types(id),
    FOREIGN KEY (member_id) REFERENCES members(id)
);

CREATE TABLE loan_products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coop_id INT,
    name VARCHAR(100),
    max_amount DECIMAL(12,2),
    interest_rate DECIMAL(5,2),
    tenor_months INT,
    guarantors_required ENUM('no','yes'),
    collateral_required ENUM('no','yes'),
    FOREIGN KEY (coop_id) REFERENCES cooperative(id)
);

CREATE TABLE loans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT,
    product_id INT,
    principal DECIMAL(12,2),
    interest_rate DECIMAL(6,2),
    tenor_months INT,
    disburse_date DATE,
    status ENUM('pending','approved','active','closed','defaulted'),
    FOREIGN KEY (member_id) REFERENCES members(id),
    FOREIGN KEY (product_id) REFERENCES loan_products(id)
);

CREATE TABLE loan_repayments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT,
    due_date DATE,
    due_amount DECIMAL(12,2),
    paid_amount DECIMAL(12,2) DEFAULT 0,
    paid_date DATE ,
    FOREIGN KEY (loan_id) REFERENCES loans(id)
);

CREATE TABLE guarantors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    loan_id INT,
    member_id INT,
    accepted_date DATE ,
    FOREIGN KEY (loan_id) REFERENCES loans(id),
    FOREIGN KEY (member_id) REFERENCES members(id)
);

CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coop_id INT,
    member_id INT NULL,
    type ENUM('contribution','loan_disburse','loan_repay','fee','dividend'),
    amount DECIMAL(12,2),
    trans_date DATE,
    FOREIGN KEY (coop_id) REFERENCES cooperative(id),
    FOREIGN KEY (member_id) REFERENCES members(id)
);

CREATE TABLE accounts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coop_id INT NOT NULL,
    code VARCHAR(20) NOT NULL,                  
    name VARCHAR(255) NOT NULL,                 
    type ENUM('asset', 'liability', 'equity', 'income', 'expense') NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (coop_id) REFERENCES cooperative(id) ON DELETE CASCADE
);

CREATE TABLE journal_entries (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coop_id INT NOT NULL,
    transaction_id INT NULL,
    entry_date DATE NOT NULL,
    description VARCHAR(500) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (coop_id) REFERENCES cooperative(id) ON DELETE CASCADE,
    FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE SET NULL
);

CREATE TABLE meetings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coop_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,                  
    meeting_date DATETIME NOT NULL,
    venue VARCHAR(255) NULL,
    agenda TEXT NULL,
    minutes_url VARCHAR(255) NULL,
    status ENUM('scheduled', 'held', 'cancelled') DEFAULT 'scheduled',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (coop_id) REFERENCES cooperative(id) ON DELETE CASCADE
);

CREATE TABLE meeting_attendance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    meeting_id INT NOT NULL,
    member_id INT NOT NULL,
    remarks VARCHAR(255),
    signed_in_at DATETIME NULL,
    FOREIGN KEY (meeting_id) REFERENCES meetings(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
);

CREATE TABLE fees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coop_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,                   
    amount DECIMAL(12,2) NOT NULL,
    applicable_to ENUM('new_member', 'exit', 'late_payment', 'loan_processing', 'other') NOT NULL,
    description TEXT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (coop_id) REFERENCES cooperative(id) ON DELETE CASCADE
);

CREATE TABLE fee_payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    member_id INT NOT NULL,
    fee_id INT NOT NULL,
    amount_paid DECIMAL(12,2) NOT NULL,
    payment_date DATE NOT NULL,
    receipt_no VARCHAR(50) NULL,
    channel ENUM('cash', 'bank_transfer', 'mobile_money', 'pos') NOT NULL,
    reference VARCHAR(100) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE,
    FOREIGN KEY (fee_id) REFERENCES fees(id) ON DELETE RESTRICT
);

CREATE TABLE dividends (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coop_id INT NOT NULL,
    fiscal_year YEAR NOT NULL,                    
    rate_percent DECIMAL(5,2) NOT NULL,           
    total_amount DECIMAL(15,2) NOT NULL,
    tax_rate DECIMAL(5,2) DEFAULT 0.00, 
    approval_date DATE NULL,
    status ENUM('draft', 'approved', 'paid', 'cancelled') DEFAULT 'draft',
    notes TEXT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (coop_id) REFERENCES cooperative(id) ON DELETE CASCADE
);

CREATE TABLE dividend_distributions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    dividend_id INT NOT NULL,
    member_id INT NOT NULL,
    gross_amount DECIMAL(12,2) NOT NULL,
    tax_deducted DECIMAL(12,2) DEFAULT 0.00,
    net_amount DECIMAL(12,2) NOT NULL,
    paid_date DATE NULL,
    payment_method ENUM('bank_transfer', 'cash', 'mobile_money') NULL,
    reference VARCHAR(100) NULL,
    status ENUM('pending', 'paid', 'failed') DEFAULT 'pending',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dividend_id) REFERENCES dividends(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
);

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    coop_id INT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('super_admin', 'admin', 'teller', 'auditor', 'secretary') NOT NULL,
    member_id INT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(15) NULL,
    email VARCHAR(100) NULL,
    last_login DATETIME NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (coop_id) REFERENCES cooperative(id) ON DELETE SET NULL,
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE SET NULL
);

CREATE TABLE audit_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    table_name VARCHAR(100) NOT NULL,
    record_id INT NOT NULL,
    action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    old_values JSON NULL,
    new_values JSON NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);