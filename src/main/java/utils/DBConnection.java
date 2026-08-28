package utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Logger;

/**
 * Single, centralised JDBC connection factory for the {@code claimsense_ai}
 * MySQL database.
 *
 * <p>Every DAO obtains connections from here and uses try-with-resources so
 * connections are always closed. Credentials live in {@link Config}
 * (config.properties) - never in JSP or in source.</p>
 */
public final class DBConnection {

    private static final Logger LOG = Logger.getLogger(DBConnection.class.getName());
    private static boolean driverLoaded = false;

    private DBConnection() { }

    private static synchronized void ensureDriver() {
        if (driverLoaded) return;
        try {
            Class.forName(Config.dbDriver());
            driverLoaded = true;
        } catch (ClassNotFoundException e) {
            // Not fatal at class-load time; surfaced clearly when a connection is requested.
            LOG.severe("MySQL JDBC driver not found on classpath: " + Config.dbDriver()
                    + " - add mysql-connector-j to WEB-INF/lib");
        }
    }

    /**
     * @return a live connection to claimsense_ai.
     * @throws SQLException if the database is unreachable or misconfigured.
     */
    public static Connection getConnection() throws SQLException {
        ensureDriver();
        return DriverManager.getConnection(Config.dbUrl(), Config.dbUser(), Config.dbPass());
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
