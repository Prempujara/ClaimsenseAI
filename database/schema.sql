-- ============================================================
--  ClaimSense AI  -  Complete Database Schema + Seed Data
--  Engine : MySQL 8
--  Charset: utf8mb4 (full unicode, supports the Rupee sign)
--
--  Reproducible: safe to run multiple times (drops & recreates).
--  Run with:  mysql -u root -p < database/schema.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS claimsense_ai
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE claimsense_ai;

-- Drop in dependency order (children first) so re-running is clean.
DROP TABLE IF EXISTS ai_analysis;
DROP TABLE IF EXISTS approval_history;
DROP TABLE IF EXISTS receipts;
DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS expense_categories;
DROP TABLE IF EXISTS users;

-- ------------------------------------------------------------
-- USERS
-- ------------------------------------------------------------
CREATE TABLE users (
    user_id      INT           NOT NULL AUTO_INCREMENT,
    name         VARCHAR(100)  NOT NULL,
    email        VARCHAR(150)  NOT NULL,
    password     VARCHAR(64)   NOT NULL,           -- SHA-256 hex digest
    role         ENUM('EMPLOYEE','MANAGER') NOT NULL DEFAULT 'EMPLOYEE',
    created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id),
    UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- EXPENSE CATEGORIES
-- ------------------------------------------------------------
CREATE TABLE expense_categories (
    category_id    INT          NOT NULL AUTO_INCREMENT,
    category_name  VARCHAR(60)  NOT NULL,
    PRIMARY KEY (category_id),
    UNIQUE KEY uq_category_name (category_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- EXPENSES
--   NOTE: `title` is added because the existing frontend
--         (submitExpense.jsp / tables) uses an Expense Title
--         field distinct from the longer description.
-- ------------------------------------------------------------
CREATE TABLE expenses (
    expense_id        INT            NOT NULL AUTO_INCREMENT,
    user_id           INT            NOT NULL,
    category_id       INT            NOT NULL,
    title             VARCHAR(150)   NOT NULL,
    amount            DECIMAL(12,2)  NOT NULL,
    expense_date      DATE           NOT NULL,
    description       TEXT           NULL,
    status            ENUM('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
    rejection_reason  TEXT           NULL,
    created_at        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (expense_id),
    KEY idx_expenses_user   (user_id),
    KEY idx_expenses_status (status),
    KEY idx_expenses_cat    (category_id),
    CONSTRAINT fk_expenses_user
        FOREIGN KEY (user_id)     REFERENCES users(user_id)              ON DELETE CASCADE,
    CONSTRAINT fk_expenses_cat
        FOREIGN KEY (category_id) REFERENCES expense_categories(category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- RECEIPTS   (metadata only - binary stays on disk)
-- ------------------------------------------------------------
CREATE TABLE receipts (
    receipt_id   INT           NOT NULL AUTO_INCREMENT,
    expense_id   INT           NOT NULL,
    file_name    VARCHAR(255)  NOT NULL,
    file_path    VARCHAR(500)  NOT NULL,
    ocr_text     LONGTEXT      NULL,
    uploaded_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (receipt_id),
    KEY idx_receipts_expense (expense_id),
    CONSTRAINT fk_receipts_expense
        FOREIGN KEY (expense_id) REFERENCES expenses(expense_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- APPROVAL HISTORY  (audit trail of every manager decision)
-- ------------------------------------------------------------
CREATE TABLE approval_history (
    history_id   INT           NOT NULL AUTO_INCREMENT,
    expense_id   INT           NOT NULL,
    manager_id   INT           NOT NULL,
    action       ENUM('APPROVED','REJECTED') NOT NULL,
    remarks      TEXT          NULL,
    action_date  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (history_id),
    KEY idx_history_expense (expense_id),
    CONSTRAINT fk_history_expense
        FOREIGN KEY (expense_id) REFERENCES expenses(expense_id) ON DELETE CASCADE,
    CONSTRAINT fk_history_manager
        FOREIGN KEY (manager_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- AI ANALYSIS  (OCR extraction + ML prediction + anomaly result)
--   One row per expense, written when the expense is submitted.
-- ------------------------------------------------------------
CREATE TABLE ai_analysis (
    analysis_id            INT            NOT NULL AUTO_INCREMENT,
    expense_id             INT            NOT NULL,
    ocr_merchant           VARCHAR(255)   NULL,
    ocr_amount             DECIMAL(12,2)  NULL,
    ocr_date               VARCHAR(40)    NULL,
    predicted_category     VARCHAR(60)    NULL,
    prediction_confidence  DECIMAL(5,4)   NULL,   -- 0.0000 - 1.0000
    anomaly_status         VARCHAR(60)    NULL,   -- NORMAL / POTENTIAL ANOMALY / INSUFFICIENT DATA
    anomaly_score          DOUBLE         NULL,
    created_at             TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (analysis_id),
    UNIQUE KEY uq_ai_expense (expense_id),
    CONSTRAINT fk_ai_expense
        FOREIGN KEY (expense_id) REFERENCES expenses(expense_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
--  SEED DATA
-- ============================================================

-- Categories (exactly the 7 required)
INSERT INTO expense_categories (category_name) VALUES
    ('Food'),
    ('Travel'),
    ('Accommodation'),
    ('Office Supplies'),
    ('Entertainment'),
    ('Medical'),
    ('Other');

-- Demo users.
-- Password for BOTH demo accounts is:  123456
-- Stored as SHA-256 hex:
--   sha256("123456") = 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92
INSERT INTO users (name, email, password, role) VALUES
    ('Prem Pujara',  'prem@claimsense.com',
        '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'EMPLOYEE'),
    ('Rajesh Kumar', 'manager@claimsense.com',
        '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92', 'MANAGER');

-- (Expenses are created live through the application - no fake seed rows,
--  so every claim you see in the UI is a genuine record.)

SELECT 'claimsense_ai schema created successfully' AS status;
