-- =====================================================================
--  ClaimSense AI  ·  database/demo_users.sql
--  Adds 5 demo EMPLOYEE accounts (for classmates to log in and create
--  their own real expenses during the demo).
-- =====================================================================
--
--  PASSWORD STORAGE  (matches the existing app exactly — spec: never plaintext)
--  ----------------------------------------------------------------------------
--  Authentication uses utils/PasswordUtil.hash(): a lowercase-hex SHA-256 digest
--  of the UTF-8 password bytes (no salt, no pepper). Login compares
--  PasswordUtil.hash(entered) to the stored value. The existing prem/manager
--  rows in database/schema.sql store exactly this digest, and this file uses the
--  identical scheme.
--
--  Every account below shares the demo password documented in FINAL_REPORT.md.
--  The plaintext is intentionally NOT written here; the column stores only its
--  SHA-256 hash, e.g. verifiable with:  SELECT SHA2('<password>', 256);
--
--  SAFETY / SCOPE
--  --------------
--    * Only inserts 5 NEW e-mail addresses. It does NOT touch the existing
--      employee (prem@claimsense.com) or manager (manager@claimsense.com) rows,
--      the table structure, auth logic, or hashing.
--    * Idempotent: `email` is UNIQUE. Re-running does not create duplicates;
--      ON DUPLICATE KEY UPDATE only re-applies name/password/role to these 5
--      addresses (converges to the intended state, never spawns extra rows).
--    * Safe on a fresh database: run database/schema.sql first (creates the DB
--      and the users table). This file only appends users.
--    * Not wired into application startup — load it manually, once, when needed.
--
--  NOTE: the first account's name ("Prem Pujara") matches the existing employee
--  by name only; it is a DISTINCT account (different e-mail, own user_id).
--
--  LOAD COMMAND (run from the project root):
--      docker exec -i claimsense-mysql mysql -uroot -proot claimsense_ai < database/demo_users.sql
--
-- =====================================================================

USE claimsense_ai;

START TRANSACTION;

-- SHA-256 lowercase-hex of the shared demo password (see FINAL_REPORT.md).
-- Columns: name, email, password (hash), role. user_id is AUTO_INCREMENT; created_at defaults.
INSERT INTO users (name, email, password, role) VALUES
  ('Prem Pujara', 'prempujara@claimsense.com', '455040035ae4f63d5f0708267f59a083a8ae01f120480f70f1229fae2ff3c4b2', 'EMPLOYEE'),
  ('Yashvi Shah', 'yashvi@claimsense.com',     '455040035ae4f63d5f0708267f59a083a8ae01f120480f70f1229fae2ff3c4b2', 'EMPLOYEE'),
  ('Mannan Shah', 'mannan@claimsense.com',     '455040035ae4f63d5f0708267f59a083a8ae01f120480f70f1229fae2ff3c4b2', 'EMPLOYEE'),
  ('Deev Savani', 'deev@claimsense.com',       '455040035ae4f63d5f0708267f59a083a8ae01f120480f70f1229fae2ff3c4b2', 'EMPLOYEE'),
  ('Jay Rathod',  'jay@claimsense.com',        '455040035ae4f63d5f0708267f59a083a8ae01f120480f70f1229fae2ff3c4b2', 'EMPLOYEE')
ON DUPLICATE KEY UPDATE
  name     = VALUES(name),
  password = VALUES(password),
  role     = VALUES(role);

COMMIT;

-- ---------------------------------------------------------------------
-- Quick verification (optional — run manually):
--   SELECT user_id, name, email, role FROM users
--    WHERE email IN ('prempujara@claimsense.com','yashvi@claimsense.com',
--                    'mannan@claimsense.com','deev@claimsense.com','jay@claimsense.com')
--    ORDER BY user_id;
-- ---------------------------------------------------------------------
