package utils;

import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;
import java.util.logging.Logger;

/**
 * Central, read-once application configuration.
 *
 * Values come from {@code config.properties} on the classpath
 * (compiled to WEB-INF/classes). Everything has a sane default so the
 * application still starts if the file is missing.
 */
public final class Config {

    private static final Logger LOG = Logger.getLogger(Config.class.getName());
    private static final Properties PROPS = new Properties();

    static {
        try (InputStream in = Config.class.getResourceAsStream("/config.properties")) {
            if (in != null) {
                PROPS.load(in);
                LOG.info("Loaded config.properties");
            } else {
                LOG.warning("config.properties not found on classpath - using defaults");
            }
        } catch (Exception e) {
            LOG.warning("Failed to load config.properties: " + e.getMessage());
        }
    }

    private Config() { }

    public static String get(String key, String def) {
        String v = PROPS.getProperty(key);
        return (v == null || v.isBlank()) ? def : v.trim();
    }

    public static int getInt(String key, int def) {
        try {
            return Integer.parseInt(get(key, String.valueOf(def)));
        } catch (NumberFormatException e) {
            return def;
        }
    }

    // ---- Database ----
    public static String dbUrl()    { return get("db.url",
            "jdbc:mysql://localhost:3306/claimsense_ai?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&characterEncoding=utf8"); }
    public static String dbUser()   { return get("db.user", "root"); }
    public static String dbPass()   { return get("db.password", "root"); }
    public static String dbDriver() { return get("db.driver", "com.mysql.cj.jdbc.Driver"); }

    // ---- ML service ----
    public static String mlBaseUrl()    { return get("ml.service.url", "http://localhost:5000"); }
    public static int    mlTimeoutMs()  { return getInt("ml.service.timeoutMs", 8000); }

    /**
     * Directory where receipt files are stored. Defaults to
     * {@code <user.home>/claimsense-uploads}. Created if missing.
     */
    public static Path uploadDir() {
        String configured = get("upload.dir", "");
        Path dir = configured.isBlank()
                ? Paths.get(System.getProperty("user.home"), "claimsense-uploads")
                : Paths.get(configured);
        try {
            Files.createDirectories(dir);
        } catch (Exception e) {
            LOG.warning("Could not create upload dir " + dir + ": " + e.getMessage());
        }
        return dir;
    }

    /**
     * Dedicated directory for profile photos, kept separate from receipts.
     * Defaults to {@code <user.home>/.claimsense/avatars}. Created if missing.
     */
    public static Path avatarDir() {
        String configured = get("avatar.dir", "");
        Path dir = configured.isBlank()
                ? Paths.get(System.getProperty("user.home"), ".claimsense", "avatars")
                : Paths.get(configured);
        try {
            Files.createDirectories(dir);
        } catch (Exception e) {
            LOG.warning("Could not create avatar dir " + dir + ": " + e.getMessage());
        }
        return dir;
    }
}
