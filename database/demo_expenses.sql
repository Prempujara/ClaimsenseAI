-- =====================================================================
--  ClaimSense AI  ·  database/demo_expenses.sql
--  Realistic HISTORICAL expense data for the five demo employee accounts,
--  so the Isolation Forest has enough personal history to produce a genuine
--  anomaly verdict instead of "INSUFFICIENT DATA".
-- =====================================================================
--
--  WHY THIS FILE EXISTS
--  --------------------
--  The anomaly detector (ml/anomaly.py) needs at least MIN_HISTORY = 5 prior
--  amounts for the employee before an outlier model is meaningful; below that it
--  honestly reports "INSUFFICIENT DATA". The demo employees start with no
--  history, so every claim they submit shows that message. This file supplies
--  the missing *history* - the legitimate fix - rather than weakening the model.
--
--  Anomaly history is read per-user across ALL categories
--  (ExpenseDAO.listPriorAmounts: SELECT amount FROM expenses WHERE user_id = ?
--  AND expense_id <> ?), so the totals below give each employee a complete
--  personal spending baseline.
--
--  WHAT THIS FILE DOES *NOT* DO  (project spec §35 - never fake results)
--  ---------------------------------------------------------------------
--    * It does NOT insert any rows into ai_analysis.
--    * It does NOT store any anomaly_status / anomaly_score / prediction / label.
--    * It does NOT touch the ML model, the detector, or its thresholds.
--  Every anomaly verdict is still computed LIVE at submit time
--  (SubmitExpenseServlet -> ExpenseService -> AIService -> Flask /anomaly ->
--  IsolationForest) and written to ai_analysis by the application itself.
--  This file only provides the history the model reads; the model alone decides
--  normal vs. potential anomaly.
--
--  THE DATA
--  --------
--  16-18 ordinary business expenses per employee, spread over Feb-Aug 2026 and
--  never more than a couple per week. Amounts stay inside the documented
--  per-category bands (Food 150-2500, Travel 200-6000, Accommodation 1500-8000,
--  Office Supplies 200-3000, Entertainment 300-3500, Medical 200-5000,
--  Other 150-3000). Most cluster in a normal band and a few - a flight, a hotel
--  stay, a client dinner, an annual health check - are legitimately higher.
--  That natural spread is what makes the history informative. None of it is
--  fraudulent and none of it is labelled. Each employee has a deliberately
--  different spending pattern (Aarav: local travel and food; Riya: frequent
--  business travel; Arjun: office equipment; Ananya: client entertainment;
--  Kabir: mixed with higher medical).
--
--  All rows are APPROVED: they represent past, settled claims, so they act
--  purely as history and never appear in the manager's pending queue.
--
--  SAFETY
--  ------
--    * Run database/schema.sql first (creates the DB, the 7 categories and the
--      prem / manager accounts). This file then only appends.
--    * The five demo EMPLOYEE accounts are created here if missing, via
--      ON DUPLICATE KEY on the UNIQUE email - so re-running converges instead of
--      duplicating, and no other user row is read, changed or deleted.
--      The password column stores the same SHA-256 hash as the other demo
--      employees (plaintext is documented only in FINAL_REPORT.md).
--    * user_id and category_id are resolved by lookup, never hard-coded, so
--      nothing depends on auto-increment values and no existing id is reset.
--    * Idempotent: every seeded row is tagged '#demo-history' in its
--      description. Re-running deletes exactly those rows first (children first,
--      so foreign keys stay intact) and re-inserts them. Genuine expenses are
--      never touched, and neither are the '#demo' rows that
--      database/demo_data.sql seeds for prem@claimsense.com.
--    * NOT wired into application startup - load it manually.
--
--  LOAD COMMAND (run from the project root):
--      docker exec -i claimsense-mysql mysql -uroot -proot claimsense_ai < database/demo_expenses.sql
--
-- =====================================================================

USE claimsense_ai;

START TRANSACTION;

-- ---------------------------------------------------------------------
-- 1. Make sure the five demo EMPLOYEE accounts exist.
--    `email` is UNIQUE, so ON DUPLICATE KEY makes this converge rather than
--    duplicate. Only these five addresses are referenced; prem@claimsense.com
--    and manager@claimsense.com (and every other user) are left untouched.
--    Password = the shared demo password's SHA-256 hash (see FINAL_REPORT.md).
-- ---------------------------------------------------------------------
INSERT INTO users (name, email, password, role) VALUES
  ('Aarav Mehta',     'aarav@claimsense.com',  '455040035ae4f63d5f0708267f59a083a8ae01f120480f70f1229fae2ff3c4b2', 'EMPLOYEE'),
  ('Riya Sharma',     'riya@claimsense.com',   '455040035ae4f63d5f0708267f59a083a8ae01f120480f70f1229fae2ff3c4b2', 'EMPLOYEE'),
  ('Arjun Nair',      'arjun@claimsense.com',  '455040035ae4f63d5f0708267f59a083a8ae01f120480f70f1229fae2ff3c4b2', 'EMPLOYEE'),
  ('Ananya Iyer',     'ananya@claimsense.com', '455040035ae4f63d5f0708267f59a083a8ae01f120480f70f1229fae2ff3c4b2', 'EMPLOYEE'),
  ('Kabir Malhotra',  'kabir@claimsense.com',  '455040035ae4f63d5f0708267f59a083a8ae01f120480f70f1229fae2ff3c4b2', 'EMPLOYEE')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  role = VALUES(role);

-- ---------------------------------------------------------------------
-- 2. Resolve ids by lookup (never hard-coded).
-- ---------------------------------------------------------------------
SET @u_aarav  := (SELECT user_id FROM users WHERE email = 'aarav@claimsense.com');
SET @u_riya   := (SELECT user_id FROM users WHERE email = 'riya@claimsense.com');
SET @u_arjun  := (SELECT user_id FROM users WHERE email = 'arjun@claimsense.com');
SET @u_ananya := (SELECT user_id FROM users WHERE email = 'ananya@claimsense.com');
SET @u_kabir  := (SELECT user_id FROM users WHERE email = 'kabir@claimsense.com');

SET @c_food   := (SELECT category_id FROM expense_categories WHERE category_name = 'Food');
SET @c_travel := (SELECT category_id FROM expense_categories WHERE category_name = 'Travel');
SET @c_accom  := (SELECT category_id FROM expense_categories WHERE category_name = 'Accommodation');
SET @c_office := (SELECT category_id FROM expense_categories WHERE category_name = 'Office Supplies');
SET @c_enter  := (SELECT category_id FROM expense_categories WHERE category_name = 'Entertainment');
SET @c_med    := (SELECT category_id FROM expense_categories WHERE category_name = 'Medical');
SET @c_other  := (SELECT category_id FROM expense_categories WHERE category_name = 'Other');

-- ---------------------------------------------------------------------
-- 3. Idempotent cleanup: remove only previously-seeded '#demo-history' rows
--    for exactly these five employees. Children go first so foreign-key
--    constraints are never violated. (Seeded rows normally have no children;
--    this is defensive.)
-- ---------------------------------------------------------------------
SET @demo_users := CONCAT_WS(',', @u_aarav, @u_riya, @u_arjun, @u_ananya, @u_kabir);

DELETE FROM ai_analysis
      WHERE expense_id IN (SELECT expense_id FROM expenses
                            WHERE FIND_IN_SET(user_id, @demo_users)
                              AND description LIKE '%#demo-history%');
DELETE FROM approval_history
      WHERE expense_id IN (SELECT expense_id FROM expenses
                            WHERE FIND_IN_SET(user_id, @demo_users)
                              AND description LIKE '%#demo-history%');
DELETE FROM receipts
      WHERE expense_id IN (SELECT expense_id FROM expenses
                            WHERE FIND_IN_SET(user_id, @demo_users)
                              AND description LIKE '%#demo-history%');
DELETE FROM expenses
      WHERE FIND_IN_SET(user_id, @demo_users)
        AND description LIKE '%#demo-history%';

-- ---------------------------------------------------------------------
-- 4. Historical expenses.
--    Columns: user_id, category_id, title, amount, expense_date, description, status
--    Every row is APPROVED (a past, settled claim) and tagged '#demo-history'.
-- ---------------------------------------------------------------------

-- ===== Aarav Mehta - lots of local travel and everyday food; low ceiling =====
INSERT INTO expenses (user_id, category_id, title, amount, expense_date, description, status) VALUES
(@u_aarav, @c_food,   'Client Lunch',           620.00, '2026-03-04', 'Lunch with client during account review #demo-history', 'APPROVED'),
(@u_aarav, @c_travel, 'Local Taxi',             310.00, '2026-03-09', 'Taxi to the client office and back #demo-history',     'APPROVED'),
(@u_aarav, @c_food,   'Office Snacks',          240.00, '2026-03-18', 'Snacks for an afternoon team review #demo-history',    'APPROVED'),
(@u_aarav, @c_travel, 'Office Cab',             450.00, '2026-03-27', 'Late-evening cab home after release work #demo-history','APPROVED'),
(@u_aarav, @c_food,   'Team Dinner',           1450.00, '2026-04-02', 'Dinner with the delivery team after go-live #demo-history','APPROVED'),
(@u_aarav, @c_travel, 'Train Ticket',           890.00, '2026-04-15', 'Return train fare for a site visit #demo-history',     'APPROVED'),
(@u_aarav, @c_office, 'Stationery',             380.00, '2026-04-24', 'Notebooks and pens for the team #demo-history',        'APPROVED'),
(@u_aarav, @c_travel, 'Local Taxi',             275.00, '2026-05-06', 'Taxi to a vendor meeting #demo-history',               'APPROVED'),
(@u_aarav, @c_food,   'Business Lunch',         780.00, '2026-05-21', 'Lunch meeting with the partner team #demo-history',    'APPROVED'),
(@u_aarav, @c_enter,  'Team Outing',           1150.00, '2026-05-29', 'Quarterly team-building activity #demo-history',       'APPROVED'),
(@u_aarav, @c_travel, 'Flight Booking',        4200.00, '2026-06-11', 'Economy flight for a regional review meeting #demo-history','APPROVED'),
(@u_aarav, @c_accom,  'Hotel Stay',            2600.00, '2026-06-12', 'One night near the regional office #demo-history',     'APPROVED'),
(@u_aarav, @c_med,    'Medical Consultation',   700.00, '2026-06-25', 'Doctor consultation covered by policy #demo-history',  'APPROVED'),
(@u_aarav, @c_office, 'Printer Supplies',       950.00, '2026-07-02', 'Toner refill for the floor printer #demo-history',     'APPROVED'),
(@u_aarav, @c_other,  'Internet Expense',      1099.00, '2026-07-16', 'Monthly broadband reimbursement #demo-history',        'APPROVED'),
(@u_aarav, @c_other,  'Courier Charges',        260.00, '2026-08-05', 'Courier of signed documents to head office #demo-history','APPROVED'),
(@u_aarav, @c_food,   'Client Lunch',           540.00, '2026-08-14', 'Lunch during a requirements workshop #demo-history',   'APPROVED');

-- ===== Riya Sharma - frequent business traveller; higher travel/hotel spend =====
INSERT INTO expenses (user_id, category_id, title, amount, expense_date, description, status) VALUES
(@u_riya, @c_travel, 'Flight Booking',         5600.00, '2026-02-19', 'Flight for the annual client planning summit #demo-history','APPROVED'),
(@u_riya, @c_accom,  'Hotel Stay',             6900.00, '2026-02-21', 'Two nights during the client planning summit #demo-history','APPROVED'),
(@u_riya, @c_food,   'Business Lunch',          690.00, '2026-02-24', 'Working lunch on the last summit day #demo-history',   'APPROVED'),
(@u_riya, @c_travel, 'Local Taxi',              380.00, '2026-03-06', 'Airport transfer on return #demo-history',             'APPROVED'),
(@u_riya, @c_food,   'Client Lunch',           1250.00, '2026-03-19', 'Lunch with two client stakeholders #demo-history',     'APPROVED'),
(@u_riya, @c_accom,  'Hotel Stay',             4300.00, '2026-04-08', 'Overnight stay for an onsite workshop #demo-history',  'APPROVED'),
(@u_riya, @c_travel, 'Train Ticket',           1150.00, '2026-04-09', 'Intercity train to the workshop venue #demo-history',  'APPROVED'),
(@u_riya, @c_office, 'Stationery',              460.00, '2026-04-22', 'Workshop printouts and folders #demo-history',         'APPROVED'),
(@u_riya, @c_enter,  'Client Dinner',          2900.00, '2026-05-07', 'Dinner with the account team and client #demo-history','APPROVED'),
(@u_riya, @c_food,   'Office Snacks',           320.00, '2026-05-18', 'Refreshments for a design session #demo-history',      'APPROVED'),
(@u_riya, @c_travel, 'Office Cab',              540.00, '2026-06-02', 'Cab to the client site for a demo #demo-history',      'APPROVED'),
(@u_riya, @c_med,    'Medical Consultation',   1400.00, '2026-06-17', 'Specialist consultation under the health policy #demo-history','APPROVED'),
(@u_riya, @c_other,  'Internet Expense',       1099.00, '2026-07-01', 'Monthly broadband reimbursement #demo-history',        'APPROVED'),
(@u_riya, @c_travel, 'Flight Booking',         4750.00, '2026-07-14', 'Flight for a quarterly business review #demo-history', 'APPROVED'),
(@u_riya, @c_food,   'Team Dinner',            1850.00, '2026-07-23', 'Dinner with the regional team #demo-history',          'APPROVED'),
(@u_riya, @c_office, 'Printer Supplies',        720.00, '2026-08-04', 'Ink cartridges for the shared printer #demo-history',  'APPROVED'),
(@u_riya, @c_other,  'Conference Registration',2500.00, '2026-08-13', 'Registration for an industry conference #demo-history','APPROVED'),
(@u_riya, @c_food,   'Business Lunch',          610.00, '2026-08-21', 'Lunch during a vendor negotiation #demo-history',      'APPROVED');

-- ===== Arjun Nair - office equipment and supplies heavy; moderate amounts =====
INSERT INTO expenses (user_id, category_id, title, amount, expense_date, description, status) VALUES
(@u_arjun, @c_office, 'Stationery',             340.00, '2026-03-02', 'Whiteboard markers and sticky notes #demo-history',    'APPROVED'),
(@u_arjun, @c_food,   'Office Snacks',          280.00, '2026-03-11', 'Snacks for a sprint planning session #demo-history',   'APPROVED'),
(@u_arjun, @c_office, 'Printer Supplies',      1250.00, '2026-03-16', 'Replacement toner for the team printer #demo-history', 'APPROVED'),
(@u_arjun, @c_travel, 'Local Taxi',             240.00, '2026-03-25', 'Taxi to the vendor showroom #demo-history',            'APPROVED'),
(@u_arjun, @c_office, 'Stationery',             520.00, '2026-04-01', 'Files and folders for audit paperwork #demo-history',   'APPROVED'),
(@u_arjun, @c_food,   'Team Dinner',           1650.00, '2026-04-19', 'Dinner after the quarterly audit close #demo-history', 'APPROVED'),
(@u_arjun, @c_travel, 'Office Cab',             460.00, '2026-04-28', 'Cab for an offsite equipment pickup #demo-history',    'APPROVED'),
(@u_arjun, @c_office, 'Desk Accessories',      2400.00, '2026-05-12', 'Monitor stands and keyboard trays for two desks #demo-history','APPROVED'),
(@u_arjun, @c_travel, 'Train Ticket',          1350.00, '2026-05-22', 'Train to the branch office for an IT audit #demo-history','APPROVED'),
(@u_arjun, @c_accom,  'Hotel Stay',            3100.00, '2026-05-23', 'One night during the branch IT audit #demo-history',   'APPROVED'),
(@u_arjun, @c_food,   'Client Lunch',           720.00, '2026-06-03', 'Lunch with a hardware vendor #demo-history',           'APPROVED'),
(@u_arjun, @c_enter,  'Team Outing',            980.00, '2026-06-16', 'Team lunch outing after project delivery #demo-history','APPROVED'),
(@u_arjun, @c_med,    'Medical Consultation',   620.00, '2026-07-07', 'Routine consultation under the health policy #demo-history','APPROVED'),
(@u_arjun, @c_med,    'Pharmacy Bill',          380.00, '2026-07-21', 'Prescribed medication reimbursement #demo-history',    'APPROVED'),
(@u_arjun, @c_other,  'Internet Expense',       899.00, '2026-08-03', 'Monthly broadband reimbursement #demo-history',        'APPROVED'),
(@u_arjun, @c_other,  'Courier Charges',        190.00, '2026-08-12', 'Courier of asset transfer forms #demo-history',        'APPROVED'),
(@u_arjun, @c_office, 'Printer Supplies',       660.00, '2026-08-20', 'A4 paper and label rolls #demo-history',               'APPROVED');

-- ===== Ananya Iyer - client-facing food and entertainment; some medical =====
INSERT INTO expenses (user_id, category_id, title, amount, expense_date, description, status) VALUES
(@u_ananya, @c_food,   'Client Lunch',           850.00, '2026-02-27', 'Lunch with a prospective client #demo-history',        'APPROVED'),
(@u_ananya, @c_travel, 'Local Taxi',             290.00, '2026-03-05', 'Taxi to a client pitch #demo-history',                 'APPROVED'),
(@u_ananya, @c_food,   'Business Lunch',        1180.00, '2026-03-13', 'Lunch during contract discussions #demo-history',      'APPROVED'),
(@u_ananya, @c_food,   'Office Snacks',          350.00, '2026-03-30', 'Refreshments for a client walkthrough #demo-history',  'APPROVED'),
(@u_ananya, @c_travel, 'Office Cab',             610.00, '2026-04-06', 'Cab to the client office for onboarding #demo-history','APPROVED'),
(@u_ananya, @c_office, 'Stationery',             260.00, '2026-04-10', 'Presentation folders and name cards #demo-history',    'APPROVED'),
(@u_ananya, @c_food,   'Team Dinner',           2200.00, '2026-04-17', 'Dinner celebrating the account win #demo-history',     'APPROVED'),
(@u_ananya, @c_enter,  'Client Dinner',         3200.00, '2026-05-08', 'Dinner with senior client stakeholders #demo-history', 'APPROVED'),
(@u_ananya, @c_travel, 'Flight Booking',        3900.00, '2026-05-26', 'Flight for a client kickoff meeting #demo-history',    'APPROVED'),
(@u_ananya, @c_accom,  'Hotel Stay',            2850.00, '2026-05-27', 'One night for the client kickoff #demo-history',       'APPROVED'),
(@u_ananya, @c_enter,  'Team Outing',           1400.00, '2026-06-09', 'Team outing after the kickoff milestone #demo-history','APPROVED'),
(@u_ananya, @c_med,    'Medical Consultation',  1600.00, '2026-06-22', 'Consultation and diagnostics under policy #demo-history','APPROVED'),
(@u_ananya, @c_enter,  'Client Entertainment',   780.00, '2026-07-10', 'Coffee and refreshments during a client visit #demo-history','APPROVED'),
(@u_ananya, @c_med,    'Pharmacy Bill',          430.00, '2026-07-19', 'Prescribed medication reimbursement #demo-history',    'APPROVED'),
(@u_ananya, @c_office, 'Printer Supplies',      1050.00, '2026-08-06', 'Colour toner for client presentation decks #demo-history','APPROVED'),
(@u_ananya, @c_other,  'Internet Expense',      1099.00, '2026-08-11', 'Monthly broadband reimbursement #demo-history',        'APPROVED'),
(@u_ananya, @c_other,  'Courier Charges',        175.00, '2026-08-19', 'Courier of signed client contract #demo-history',      'APPROVED');

-- ===== Kabir Malhotra - mixed spend; higher medical and accommodation =====
INSERT INTO expenses (user_id, category_id, title, amount, expense_date, description, status) VALUES
(@u_kabir, @c_travel, 'Train Ticket',            780.00, '2026-02-23', 'Train to the regional office for a review #demo-history','APPROVED'),
(@u_kabir, @c_travel, 'Local Taxi',              260.00, '2026-03-08', 'Taxi to a supplier meeting #demo-history',             'APPROVED'),
(@u_kabir, @c_food,   'Client Lunch',            690.00, '2026-03-17', 'Lunch with a supplier representative #demo-history',   'APPROVED'),
(@u_kabir, @c_travel, 'Office Cab',              520.00, '2026-03-24', 'Cab for an evening deployment window #demo-history',   'APPROVED'),
(@u_kabir, @c_food,   'Office Snacks',           310.00, '2026-04-21', 'Snacks during a weekend release #demo-history',        'APPROVED'),
(@u_kabir, @c_accom,  'Hotel Stay',             2300.00, '2026-04-14', 'One night for a supplier site inspection #demo-history','APPROVED'),
(@u_kabir, @c_office, 'Stationery',              410.00, '2026-04-30', 'Log books and printer paper #demo-history',            'APPROVED'),
(@u_kabir, @c_food,   'Business Lunch',         1320.00, '2026-05-13', 'Lunch during a contract renewal discussion #demo-history','APPROVED'),
(@u_kabir, @c_med,    'Medical Consultation',   2100.00, '2026-05-25', 'Consultation and lab tests under policy #demo-history','APPROVED'),
(@u_kabir, @c_travel, 'Flight Booking',         5100.00, '2026-06-05', 'Flight for an onsite supplier audit #demo-history',    'APPROVED'),
(@u_kabir, @c_accom,  'Hotel Stay',             5800.00, '2026-06-06', 'Two nights during the supplier audit #demo-history',   'APPROVED'),
(@u_kabir, @c_office, 'Printer Supplies',       1150.00, '2026-06-29', 'Toner and binding covers for audit reports #demo-history','APPROVED'),
(@u_kabir, @c_med,    'Pharmacy Bill',           480.00, '2026-07-08', 'Prescribed medication reimbursement #demo-history',    'APPROVED'),
(@u_kabir, @c_enter,  'Team Dinner',            1750.00, '2026-07-15', 'Dinner with the operations team #demo-history',        'APPROVED'),
(@u_kabir, @c_med,    'Health Check-up',        3400.00, '2026-07-27', 'Annual company-mandated health screening #demo-history','APPROVED'),
(@u_kabir, @c_other,  'Internet Expense',        999.00, '2026-08-07', 'Monthly broadband reimbursement #demo-history',        'APPROVED'),
(@u_kabir, @c_other,  'Conference Registration',2650.00, '2026-08-18', 'Registration for a supply-chain conference #demo-history','APPROVED');

COMMIT;

-- ---------------------------------------------------------------------
-- 5. Verification (runs automatically; safe read-only queries).
-- ---------------------------------------------------------------------
SELECT u.email,
       COUNT(*)                                    AS history_rows,
       SUM(e.status = 'APPROVED')                  AS approved_rows,
       MIN(e.amount)                               AS min_amount,
       MAX(e.amount)                               AS max_amount,
       MIN(e.expense_date)                         AS first_date,
       MAX(e.expense_date)                         AS last_date
  FROM expenses e
  JOIN users u ON u.user_id = e.user_id
 WHERE e.description LIKE '%#demo-history%'
 GROUP BY u.email
 ORDER BY u.email;

-- Must be 0: this seed never fabricates AI analysis rows.
SELECT COUNT(*) AS fake_ai_rows_must_be_zero
  FROM ai_analysis a
  JOIN expenses e ON e.expense_id = a.expense_id
 WHERE e.description LIKE '%#demo-history%';
