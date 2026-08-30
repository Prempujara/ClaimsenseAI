-- =====================================================================
--  ClaimSense AI  ·  database/migration_profile_fields.sql
--  Adds the optional user-profile columns to an EXISTING claimsense_ai
--  database (for databases created before the Profile & Settings page).
-- =====================================================================
--
--  WHAT THIS DOES
--  --------------
--  Adds four NULLable columns to `users`:
--      phone        VARCHAR(50)
--      department   VARCHAR(100)
--      job_title    VARCHAR(100)
--      avatar_path  VARCHAR(255)   -- generated file NAME only, not image bytes
--
--  WHAT THIS DOES *NOT* DO
--  -----------------------
--    * Does NOT rename, drop, retype or re-mean any existing column.
--    * Does NOT touch user_id / name / email / password / role / created_at,
--      so authentication and every existing query keep working unchanged.
--    * Does NOT restructure the table, add indexes, or alter foreign keys.
--    * Does NOT insert, update or delete a single row of data.
--
--  Fresh installs do not need this file - database/schema.sql already declares
--  these columns. This migration exists only to bring an older database up to
--  the same shape.
--
--  IDEMPOTENT
--  ----------
--  Each column is added only if it is not already present (checked against
--  information_schema), so running this file repeatedly is harmless and never
--  errors out. Safe to re-run after schema.sql, after demo seeds, any time.
--
--  LOAD COMMAND (run from the project root):
--      docker exec -i claimsense-mysql mysql -uroot -proot claimsense_ai < database/migration_profile_fields.sql
--
-- =====================================================================

USE claimsense_ai;

-- ---------------------------------------------------------------------
-- Helper: add a column only when it does not already exist.
-- MySQL 8 has no "ADD COLUMN IF NOT EXISTS", so each step is guarded by a
-- lookup in information_schema and executed through a prepared statement.
-- ---------------------------------------------------------------------

-- phone -----------------------------------------------------------------
SET @sql := (
    SELECT IF(COUNT(*) = 0,
              'ALTER TABLE users ADD COLUMN phone VARCHAR(50) NULL AFTER role',
              'SELECT ''users.phone already present - skipped'' AS migration')
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = 'claimsense_ai'
       AND TABLE_NAME   = 'users'
       AND COLUMN_NAME  = 'phone'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- department ------------------------------------------------------------
SET @sql := (
    SELECT IF(COUNT(*) = 0,
              'ALTER TABLE users ADD COLUMN department VARCHAR(100) NULL AFTER phone',
              'SELECT ''users.department already present - skipped'' AS migration')
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = 'claimsense_ai'
       AND TABLE_NAME   = 'users'
       AND COLUMN_NAME  = 'department'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- job_title -------------------------------------------------------------
SET @sql := (
    SELECT IF(COUNT(*) = 0,
              'ALTER TABLE users ADD COLUMN job_title VARCHAR(100) NULL AFTER department',
              'SELECT ''users.job_title already present - skipped'' AS migration')
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = 'claimsense_ai'
       AND TABLE_NAME   = 'users'
       AND COLUMN_NAME  = 'job_title'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- avatar_path -----------------------------------------------------------
SET @sql := (
    SELECT IF(COUNT(*) = 0,
              'ALTER TABLE users ADD COLUMN avatar_path VARCHAR(255) NULL AFTER job_title',
              'SELECT ''users.avatar_path already present - skipped'' AS migration')
      FROM information_schema.COLUMNS
     WHERE TABLE_SCHEMA = 'claimsense_ai'
       AND TABLE_NAME   = 'users'
       AND COLUMN_NAME  = 'avatar_path'
);
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------------
-- Result
-- ---------------------------------------------------------------------
SELECT 'profile columns present on users' AS status,
       COUNT(*) AS profile_column_count
  FROM information_schema.COLUMNS
 WHERE TABLE_SCHEMA = 'claimsense_ai'
   AND TABLE_NAME   = 'users'
   AND COLUMN_NAME IN ('phone', 'department', 'job_title', 'avatar_path');
