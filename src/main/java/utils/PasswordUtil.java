package utils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

/**
 * Password hashing helper.
 *
 * <p>Uses SHA-256 (hex) so the application never stores plaintext passwords.
 * The seed users in {@code database/schema.sql} store the SHA-256 digest of
 * their demo password, so {@link #hash(String)} of the entered password is
 * compared directly against the stored value.</p>
 */
public final class PasswordUtil {

    private PasswordUtil() { }

    /** @return lowercase hex SHA-256 digest of {@code raw}. */
    public static String hash(String raw) {
        if (raw == null) raw = "";
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(raw.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(digest.length * 2);
            for (byte b : digest) {
                sb.append(Character.forDigit((b >> 4) & 0xF, 16));
                sb.append(Character.forDigit(b & 0xF, 16));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException("SHA-256 not available", e);
        }
    }

    /** Constant-time-ish comparison of the hash of {@code raw} to a stored hash. */
    public static boolean matches(String raw, String storedHash) {
        if (storedHash == null) return false;
        return hash(raw).equalsIgnoreCase(storedHash.trim());
    }
}
