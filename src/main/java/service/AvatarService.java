package service;

import utils.Config;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.security.SecureRandom;
import java.util.Set;

/**
 * Profile-photo (avatar) handling: validation + safe storage on disk.
 *
 * <p>Mirrors {@link ReceiptService}: the image bytes are written to a dedicated
 * upload directory on the filesystem and the database stores only the generated
 * file <em>name</em> - never the binary, never a client-supplied path.</p>
 *
 * <p>Nothing from the browser is trusted for naming. The stored name is built
 * entirely from the authenticated user id, random bytes and the extension
 * derived from the file's own magic bytes.</p>
 */
public class AvatarService {

    /** Profile photos are small; 5 MB matches the receipt upload limit. */
    public static final long MAX_BYTES = 5L * 1024 * 1024;

    /** The only formats accepted, as required by the spec. */
    private static final Set<String> ALLOWED_EXT = Set.of("jpg", "jpeg", "png", "webp");

    /** Declared content types a browser may legitimately send for those formats. */
    private static final Set<String> ALLOWED_MIME = Set.of(
            "image/jpeg", "image/jpg", "image/png", "image/webp",
            "application/octet-stream");   // some browsers send this for uploads

    /** Generated names look like: avatar_5_9f3c1a7b.png */
    private static final String NAME_PATTERN = "avatar_\\d+_[0-9a-f]{8}\\.(jpg|jpeg|png|webp)";

    private static final SecureRandom RANDOM = new SecureRandom();

    /* ===================== validation ===================== */

    /**
     * Validate an uploaded profile photo.
     *
     * <p>The submitted file name and the declared content type are only ever
     * used to reject obvious junk early. The authoritative check is
     * {@link #detectFormat(byte[])}, which reads the file's own signature, so a
     * renamed executable or script cannot pass as an image.</p>
     *
     * @return {@code null} if valid, otherwise a user-facing error message.
     */
    public String validate(byte[] bytes, String submittedName, String contentType) {
        if (bytes == null || bytes.length == 0) {
            return "The selected image file is empty.";
        }
        if (bytes.length > MAX_BYTES) {
            return "Image is too large. Maximum size is 5MB.";
        }
        if (contentType != null && !ALLOWED_MIME.contains(contentType.toLowerCase())) {
            return "Unsupported file content type: " + contentType;
        }
        // Reject a mismatched / disallowed extension before looking at content.
        String claimedExt = extensionOf(submittedName);
        if (!claimedExt.isEmpty() && !ALLOWED_EXT.contains(claimedExt)) {
            return "Invalid file type. Allowed: JPG, JPEG, PNG, WEBP.";
        }

        String format = detectFormat(bytes);
        if (format == null) {
            return "That file is not a valid JPG, PNG or WEBP image.";
        }
        // For the formats the JDK can decode, prove the pixels really parse.
        if (("png".equals(format) || "jpg".equals(format)) && !decodes(bytes)) {
            return "The image file appears to be corrupted and could not be read.";
        }
        return null;
    }

    /**
     * Identify the real image format from the file's magic bytes.
     *
     * @return {@code "png"}, {@code "jpg"}, {@code "webp"}, or {@code null} when
     *         the bytes are not one of the allowed image formats.
     */
    public String detectFormat(byte[] b) {
        if (b == null || b.length < 12) return null;

        // PNG: 89 50 4E 47 0D 0A 1A 0A
        if ((b[0] & 0xFF) == 0x89 && b[1] == 'P' && b[2] == 'N' && b[3] == 'G'
                && (b[4] & 0xFF) == 0x0D && (b[5] & 0xFF) == 0x0A
                && (b[6] & 0xFF) == 0x1A && (b[7] & 0xFF) == 0x0A) {
            return "png";
        }

        // JPEG: FF D8 FF
        if ((b[0] & 0xFF) == 0xFF && (b[1] & 0xFF) == 0xD8 && (b[2] & 0xFF) == 0xFF) {
            return "jpg";
        }

        // WEBP: "RIFF" <4-byte size> "WEBP" then a VP8 / VP8L / VP8X chunk.
        // The JDK has no WEBP ImageIO reader, so the container itself is checked.
        if (ascii(b, 0, 4).equals("RIFF") && ascii(b, 8, 4).equals("WEBP")) {
            String chunk = b.length >= 16 ? ascii(b, 12, 4) : "";
            if (chunk.equals("VP8 ") || chunk.equals("VP8L") || chunk.equals("VP8X")) {
                return "webp";
            }
        }
        return null;
    }

    /** @return {@code true} if the JDK can actually decode the bytes into pixels. */
    private boolean decodes(byte[] bytes) {
        try (ByteArrayInputStream in = new ByteArrayInputStream(bytes)) {
            BufferedImage img = ImageIO.read(in);
            return img != null && img.getWidth() > 0 && img.getHeight() > 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static String ascii(byte[] b, int off, int len) {
        if (b.length < off + len) return "";
        return new String(b, off, len, StandardCharsets.US_ASCII);
    }

    /* ===================== storage ===================== */

    /**
     * Write the image under the avatar directory using a generated, collision-safe
     * name that contains no client-supplied text at all.
     *
     * @param format the value returned by {@link #detectFormat(byte[])}
     * @return the generated file name to persist in {@code users.avatar_path}
     */
    public String store(byte[] bytes, int userId, String format) throws Exception {
        String ext = "jpg".equals(format) ? "jpg" : format;      // jpeg normalised to jpg
        byte[] rnd = new byte[4];
        RANDOM.nextBytes(rnd);
        StringBuilder suffix = new StringBuilder(8);
        for (byte x : rnd) suffix.append(String.format("%02x", x));

        String fileName = "avatar_" + userId + "_" + suffix + "." + ext;
        Path target = Config.avatarDir().resolve(fileName);
        Files.write(target, bytes);
        return fileName;
    }

    /**
     * Resolve a stored avatar file name to a readable file inside the avatar
     * directory.
     *
     * <p>Returns {@code null} unless the name matches the generated-name pattern
     * and the resolved path really sits inside the avatar directory, so a crafted
     * value can never escape it or reach an unrelated file.</p>
     */
    public Path resolveExisting(String fileName) {
        if (!isGeneratedName(fileName)) return null;
        try {
            Path dir = Config.avatarDir().toAbsolutePath().normalize();
            Path file = dir.resolve(fileName).toAbsolutePath().normalize();
            if (!file.startsWith(dir)) return null;                 // traversal guard
            return Files.isRegularFile(file) ? file : null;
        } catch (Exception e) {
            return null;
        }
    }

    /** Delete a previously stored avatar file. Missing files are ignored. */
    public void delete(String fileName) {
        Path file = resolveExisting(fileName);
        if (file == null) return;
        try {
            Files.deleteIfExists(file);
        } catch (Exception ignored) {
            // A locked/undeletable old photo must not fail the profile update.
        }
    }

    /** @return {@code true} if this is a name this class generated. */
    public boolean isGeneratedName(String fileName) {
        return fileName != null && fileName.matches(NAME_PATTERN);
    }

    static String extensionOf(String fileName) {
        if (fileName == null) return "";
        String base = fileName.replace('\\', '/');
        int slash = base.lastIndexOf('/');
        if (slash >= 0) base = base.substring(slash + 1);
        int dot = base.lastIndexOf('.');
        return dot < 0 ? "" : base.substring(dot + 1).toLowerCase();
    }
}
