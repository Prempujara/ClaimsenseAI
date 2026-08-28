-- =====================================================================
--  ClaimSense AI  ·  database/demo_data.sql
--  Demo historical expense data for the anomaly-detection demonstration.
-- =====================================================================
--
--  WHY THIS FILE EXISTS
--  --------------------
--  The anomaly detector (Isolation Forest, ml/anomaly.py) needs at least
--  MIN_HISTORY = 5 prior amounts for the employee before it can score a new
--  expense; with fewer it honestly reports "INSUFFICIENT DATA". On a freshly
--  loaded database prem@claimsense.com has almost no history, so every new
--  claim shows "INSUFFICIENT DATA". This file seeds a realistic spending
--  history so the detector has enough data to produce a genuine verdict.
--
--  WHAT THIS FILE DOES *NOT* DO  (important — see project spec §35)
--  ---------------------------------------------------------------
--    * It does NOT insert any rows into ai_analysis.
--    * It does NOT store any anomaly_status / anomaly_score / label.
--    * It does NOT weaken, bypass or pre-compute the detector.
--  Every anomaly verdict is still produced live by the real Isolation Forest
--  at submit time (ExpenseService -> AIService -> Flask /anomaly) and stored
--  in ai_analysis by the application. This file only provides the *history*
--  the model reads; the model decides normal vs. potential-anomaly itself.
--
--  The amounts below are ordinary business expenses. Most cluster in a normal
--  band; a few (hotel stays, an intercity cab, a client dinner) are legitimately
--  higher. That natural spread is what gives the Isolation Forest meaningful
--  variation — none of it is fraudulent and none of it is labelled.
--
--  SAFETY
--  ------
--    * Safe on a fresh database: run database/schema.sql first (it creates the
--      DB, the 7 categories and users prem/manager). This script only inserts
--      expenses for the existing employee (user_id = 1) and existing categories.
--    * Idempotent / re-runnable: every seeded row is tagged with '#demo' in its
--      description. Re-running first removes the previous demo rows (children
--      first, so foreign keys stay intact) and re-inserts them. Your own real
--      expenses (which do not contain '#demo') are never touched.
--    * This file is NOT wired into application startup — load it manually when
--      you want demo history, exactly once, using the command below.
--
--  LOAD COMMAND (run from the project root):
--      docker exec -i claimsense-mysql mysql -uroot -proot claimsense_ai < database/demo_data.sql
--
-- =====================================================================

USE claimsense_ai;

START TRANSACTION;

-- ---------------------------------------------------------------------
-- Idempotent cleanup: drop any previously-seeded demo history for prem.
-- Children are deleted first so foreign-key constraints are never violated.
-- (These seeded rows normally have no children; this is defensive.)
-- ---------------------------------------------------------------------
DELETE FROM ai_analysis
      WHERE expense_id IN (SELECT expense_id FROM expenses
                            WHERE user_id = 1 AND description LIKE '%#demo%');
DELETE FROM approval_history
      WHERE expense_id IN (SELECT expense_id FROM expenses
                            WHERE user_id = 1 AND description LIKE '%#demo%');
DELETE FROM receipts
      WHERE expense_id IN (SELECT expense_id FROM expenses
                            WHERE user_id = 1 AND description LIKE '%#demo%');
DELETE FROM expenses
      WHERE user_id = 1 AND description LIKE '%#demo%';

-- ---------------------------------------------------------------------
-- Historical expenses for prem@claimsense.com (user_id = 1).
-- Columns: user_id, category_id, title, amount, expense_date, description, status
-- Categories: 1 Food · 2 Travel · 3 Accommodation · 4 Office Supplies
--             5 Entertainment · 6 Medical · 7 Other
-- All are APPROVED (they are past, settled claims) so they do not appear in
-- the manager's pending queue — they exist purely as spending history.
-- ---------------------------------------------------------------------
INSERT INTO expenses (user_id, category_id, title, amount, expense_date, description, status) VALUES
-- Food (1)
(1, 1, 'Team lunch',            540.00, '2026-04-12', 'Working lunch with the project team #demo',       'APPROVED'),
(1, 1, 'Client coffee meeting', 275.00, '2026-05-03', 'Coffee and snacks during a client sync #demo',    'APPROVED'),
(1, 1, 'Breakfast (offsite)',   180.00, '2026-06-19', 'Breakfast during an offsite workshop #demo',      'APPROVED'),
(1, 1, 'Cafeteria lunch',       320.00, '2026-07-22', 'Regular workday lunch #demo',                     'APPROVED'),
-- Travel (2)
(1, 2, 'Auto to client site',   240.00, '2026-04-18', 'Local travel to the client office #demo',         'APPROVED'),
(1, 2, 'Cab to airport',        610.00, '2026-05-14', 'Airport drop for a business trip #demo',          'APPROVED'),
(1, 2, 'Intercity cab',        1850.00, '2026-06-08', 'Cab between Ahmedabad and Vadodara, site visit #demo','APPROVED'),
(1, 2, 'Commute (metro + bus)', 460.00, '2026-07-30', 'Public transport for client meetings #demo',      'APPROVED'),
-- Accommodation (3) — legitimately higher; real business travel
(1, 3, 'Hotel stay (1 night)', 3200.00, '2026-04-25', 'One-night stay for a regional review meeting #demo','APPROVED'),
(1, 3, 'Hotel stay (2 nights)',6800.00, '2026-05-27', 'Two-night stay during client onboarding #demo',   'APPROVED'),
(1, 3, 'Budget hotel',         4500.00, '2026-07-11', 'Accommodation for a training program #demo',      'APPROVED'),
-- Office Supplies (4)
(1, 4, 'Notebooks & stationery',150.00, '2026-04-09', 'Stationery for the team #demo',                   'APPROVED'),
(1, 4, 'Printer cartridges',    890.00, '2026-05-21', 'Ink cartridges for the office printer #demo',     'APPROVED'),
(1, 4, 'USB drives',           1250.00, '2026-06-30', 'Storage devices for backups #demo',               'APPROVED'),
-- Entertainment (5)
(1, 5, 'Client dinner',        2400.00, '2026-05-16', 'Business dinner with client stakeholders #demo',  'APPROVED'),
(1, 5, 'Team outing',           700.00, '2026-07-05', 'Team-building activity #demo',                     'APPROVED'),
-- Medical (6)
(1, 6, 'Pharmacy',              450.00, '2026-04-28', 'First-aid supplies for the office #demo',         'APPROVED'),
(1, 6, 'Health check-up',      1200.00, '2026-06-14', 'Company-mandated health screening #demo',         'APPROVED'),
-- Other (7)
(1, 7, 'Courier charges',       340.00, '2026-05-09', 'Document courier to the head office #demo',       'APPROVED'),
(1, 7, 'Software subscription', 980.00, '2026-07-18', 'Monthly SaaS tool for the team #demo',            'APPROVED');

COMMIT;

-- ---------------------------------------------------------------------
-- Quick verification (optional — run manually):
--   SELECT COUNT(*) AS demo_rows FROM expenses WHERE user_id = 1 AND description LIKE '%#demo%';
--   SELECT category_id, COUNT(*), MIN(amount), MAX(amount)
--     FROM expenses WHERE user_id = 1 GROUP BY category_id ORDER BY category_id;
-- ---------------------------------------------------------------------
