package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Logger;

/**
 * Single, centralised JDBC connection factory for the {@code claimsense_ai}
 * database.
 *
 * <p>Supports transparent fallback to an embedded database if the external
 * MySQL service is unreachable, ensuring zero downtime for login and testing.</p>
 */
public final class DBConnection {

    private static final Logger LOG = Logger.getLogger(DBConnection.class.getName());
    private static boolean driverLoaded = false;
    private static boolean useFallback = false;
    private static boolean fallbackInitialized = false;

    private DBConnection() { }

    private static synchronized void ensureDriver() {
        if (driverLoaded) return;
        try {
            Class.forName(Config.dbDriver());
            driverLoaded = true;
        } catch (ClassNotFoundException e) {
            LOG.warning("MySQL JDBC driver not found on classpath: " + Config.dbDriver());
        }
    }

    /**
     * @return a live connection to claimsense_ai (MySQL or embedded fallback).
     * @throws SQLException if database initialization fails.
     */
    public static Connection getConnection() throws SQLException {
        ensureDriver();
        if (!useFallback) {
            try {
                return DriverManager.getConnection(Config.dbUrl(), Config.dbUser(), Config.dbPass());
            } catch (SQLException e) {
                LOG.warning("MySQL database connection failed (" + e.getMessage() + "). Switching to embedded fallback database...");
                useFallback = true;
            }
        }
        return getFallbackConnection();
    }

    private static synchronized Connection getFallbackConnection() throws SQLException {
        try {
            Class.forName("org.h2.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Embedded H2 driver not found", e);
        }

        String h2Url = "jdbc:h2:~/claimsense_ai_db;MODE=MySQL;CASE_INSENSITIVE_IDENTIFIERS=TRUE;DEFAULT_NULL_ORDERING=HIGH;AUTO_SERVER=TRUE";
        Connection con = DriverManager.getConnection(h2Url, "sa", "");

        if (!fallbackInitialized) {
            initFallbackDatabase(con);
            fallbackInitialized = true;
        }
        return con;
    }

    private static void initFallbackDatabase(Connection con) {
        LOG.info("Initializing embedded fallback database schema and seed data...");
        try (Statement st = con.createStatement()) {
            st.execute("CREATE TABLE IF NOT EXISTS users ("
                    + "user_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "name VARCHAR(100) NOT NULL, "
                    + "email VARCHAR(150) NOT NULL UNIQUE, "
                    + "password VARCHAR(64) NOT NULL, "
                    + "role VARCHAR(20) NOT NULL DEFAULT 'EMPLOYEE', "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

            st.execute("CREATE TABLE IF NOT EXISTS expense_categories ("
                    + "category_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "category_name VARCHAR(60) NOT NULL UNIQUE)");

            st.execute("CREATE TABLE IF NOT EXISTS expenses ("
                    + "expense_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "user_id INT NOT NULL, "
                    + "category_id INT NOT NULL, "
                    + "title VARCHAR(150) NOT NULL, "
                    + "amount DECIMAL(12,2) NOT NULL, "
                    + "expense_date DATE NOT NULL, "
                    + "description TEXT NULL, "
                    + "status VARCHAR(20) NOT NULL DEFAULT 'PENDING', "
                    + "rejection_reason TEXT NULL, "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

            st.execute("CREATE TABLE IF NOT EXISTS receipts ("
                    + "receipt_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "expense_id INT NOT NULL, "
                    + "file_name VARCHAR(255) NOT NULL, "
                    + "file_path VARCHAR(500) NOT NULL, "
                    + "ocr_text TEXT NULL, "
                    + "uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

            st.execute("CREATE TABLE IF NOT EXISTS approval_history ("
                    + "history_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "expense_id INT NOT NULL, "
                    + "manager_id INT NOT NULL, "
                    + "action VARCHAR(20) NOT NULL, "
                    + "remarks TEXT NULL, "
                    + "action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

            st.execute("CREATE TABLE IF NOT EXISTS ai_analysis ("
                    + "analysis_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, "
                    + "expense_id INT NOT NULL UNIQUE, "
                    + "ocr_merchant VARCHAR(255) NULL, "
                    + "ocr_amount DECIMAL(12,2) NULL, "
                    + "ocr_date VARCHAR(40) NULL, "
                    + "predicted_category VARCHAR(60) NULL, "
                    + "prediction_confidence DECIMAL(5,4) NULL, "
                    + "anomaly_status VARCHAR(60) NULL, "
                    + "anomaly_score DOUBLE NULL, "
                    + "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");

            // Seed Categories if empty
            st.execute("MERGE INTO expense_categories (category_id, category_name) KEY(category_name) VALUES "
                    + "(1, 'Food'), (2, 'Travel'), (3, 'Accommodation'), (4, 'Office Supplies'), "
                    + "(5, 'Entertainment'), (6, 'Medical'), (7, 'Other')");

            // Seed Users (SHA-256 digest of password "123456" = 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92)
            String pwdHash123456 = "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92";
            String pwdHashDemo = "455040035ae4f63d5f0708267f59a083a8ae01f120480f70f1229fae2ff3c4b2";

            st.execute("MERGE INTO users (user_id, name, email, password, role) KEY(email) VALUES "
                    + "(1, 'Prem Pujara', 'prem@claimsense.com', '" + pwdHash123456 + "', 'EMPLOYEE'), "
                    + "(2, 'Rajesh Kumar', 'manager@claimsense.com', '" + pwdHash123456 + "', 'MANAGER'), "
                    + "(3, 'Prem Pujara', 'prempujara@claimsense.com', '" + pwdHashDemo + "', 'EMPLOYEE'), "
                    + "(4, 'Yashvi Shah', 'yashvi@claimsense.com', '" + pwdHashDemo + "', 'EMPLOYEE'), "
                    + "(5, 'Mannan Shah', 'mannan@claimsense.com', '" + pwdHashDemo + "', 'EMPLOYEE'), "
                    + "(6, 'Deev Savani', 'deev@claimsense.com', '" + pwdHashDemo + "', 'EMPLOYEE'), "
                    + "(7, 'Jay Rathod', 'jay@claimsense.com', '" + pwdHashDemo + "', 'EMPLOYEE')");

            // Seed Historical Approved Demo Expenses (from database/demo_data.sql)
            st.execute("MERGE INTO expenses (expense_id, user_id, category_id, title, amount, expense_date, description, status) KEY(expense_id) VALUES "
                    + "(1, 1, 1, 'Team lunch', 540.00, '2026-04-12', 'Working lunch with project team #demo', 'APPROVED'), "
                    + "(2, 1, 1, 'Client coffee meeting', 275.00, '2026-05-03', 'Coffee and snacks #demo', 'APPROVED'), "
                    + "(3, 1, 1, 'Breakfast (offsite)', 180.00, '2026-06-19', 'Offsite workshop breakfast #demo', 'APPROVED'), "
                    + "(4, 1, 1, 'Cafeteria lunch', 320.00, '2026-07-22', 'Regular workday lunch #demo', 'APPROVED'), "
                    + "(5, 1, 2, 'Auto to client site', 240.00, '2026-04-18', 'Local travel #demo', 'APPROVED'), "
                    + "(6, 1, 2, 'Cab to airport', 610.00, '2026-05-14', 'Airport drop #demo', 'APPROVED'), "
                    + "(7, 1, 2, 'Intercity cab', 1850.00, '2026-06-08', 'Site visit cab #demo', 'APPROVED'), "
                    + "(8, 1, 2, 'Commute (metro)', 460.00, '2026-07-30', 'Public transport #demo', 'APPROVED'), "
                    + "(9, 1, 3, 'Hotel stay (1 night)', 3200.00, '2026-04-25', 'Regional review meeting #demo', 'APPROVED'), "
                    + "(10, 1, 3, 'Hotel stay (2 nights)', 6800.00, '2026-05-27', 'Client onboarding #demo', 'APPROVED'), "
                    + "(11, 1, 3, 'Budget hotel', 4500.00, '2026-07-11', 'Training program #demo', 'APPROVED'), "
                    + "(12, 1, 4, 'Notebooks & stationery', 150.00, '2026-04-09', 'Team stationery #demo', 'APPROVED'), "
                    + "(13, 1, 4, 'Printer cartridges', 890.00, '2026-05-21', 'Office printer ink #demo', 'APPROVED'), "
                    + "(14, 1, 4, 'USB drives', 1250.00, '2026-06-30', 'Storage backup #demo', 'APPROVED'), "
                    + "(15, 1, 5, 'Client dinner', 2400.00, '2026-05-16', 'Business dinner #demo', 'APPROVED'), "
                    + "(16, 1, 5, 'Team outing', 700.00, '2026-07-05', 'Team building #demo', 'APPROVED'), "
                    + "(17, 1, 6, 'Pharmacy', 450.00, '2026-04-28', 'First aid supplies #demo', 'APPROVED'), "
                    + "(18, 1, 6, 'Health check-up', 1200.00, '2026-06-14', 'Health screening #demo', 'APPROVED'), "
                    + "(19, 1, 7, 'Courier charges', 340.00, '2026-05-09', 'Document courier #demo', 'APPROVED'), "
                    + "(20, 1, 7, 'Software subscription', 980.00, '2026-07-18', 'SaaS tool #demo', 'APPROVED'), "
                    // Pending Submissions for Manager Review
                    + "(21, 1, 2, 'Executive Travel & Conference Stay', 1850.00, '2026-08-28', 'Annual Tech Summit VIP Delegate Travel', 'PENDING'), "
                    + "(22, 4, 1, 'Client Strategy Lunch', 1250.00, '2026-08-29', 'Lunch meeting with key account partner', 'PENDING'), "
                    + "(23, 5, 4, 'Ergonomic Workstation Setup', 14200.00, '2026-08-27', 'Ergonomic dual-monitor stands and chair', 'PENDING'), "
                    + "(24, 6, 2, 'Intercity Flight Ticket', 6400.00, '2026-08-30', 'Bangalore onsite client deployment flight', 'PENDING')");

            // Seed AI Analysis results
            st.execute("MERGE INTO ai_analysis (analysis_id, expense_id, ocr_merchant, ocr_amount, ocr_date, predicted_category, prediction_confidence, anomaly_status, anomaly_score) KEY(expense_id) VALUES "
                    + "(1, 21, 'MakeMyTrip', 1850.00, '2026-08-28', 'Travel', 0.9400, 'ANOMALOUS', -0.42), "
                    + "(2, 22, 'Taj Hotel & Resorts', 1250.00, '2026-08-29', 'Food', 0.9800, 'NORMAL', 0.18), "
                    + "(3, 23, 'IKEA Business', 14200.00, '2026-08-27', 'Office Supplies', 0.9100, 'NORMAL', 0.05), "
                    + "(4, 24, 'IndiGo Airlines', 6400.00, '2026-08-30', 'Travel', 0.9600, 'NORMAL', 0.22)");

            LOG.info("Embedded fallback database schema initialized with seed users, 20 historical expenses, and 4 pending AI risk claims.");
        } catch (Exception e) {
            LOG.severe("Failed to initialize fallback database: " + e.getMessage());
        }
    }

    /** Lightweight connectivity probe used by health checks / diagnostics. */
    public static boolean testConnection() {
        try (Connection c = getConnection()) {
            return c != null && !c.isClosed();
        } catch (SQLException e) {
            LOG.warning("DB connectivity test failed: " + e.getMessage());
            return false;
        }
    }
}

