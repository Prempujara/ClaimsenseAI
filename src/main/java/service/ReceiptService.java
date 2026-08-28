package service;

import utils.Config;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Set;

/**
 * Receipt file handling: validation + safe storage on disk.
 * (Binaries are never stored in the database - only their path/metadata.)
 */
public class ReceiptService {

    public static final long MAX_BYTES = 5L * 1024 * 1024;               // 5 MB
    private static final Set<String> ALLOWED_EXT = Set.of("jpg", "jpeg", "png", "pdf");
    private static final Set<String> ALLOWED_MIME = Set.of(
            "image/jpeg", "image/jpg", "image/png", "application/pdf",
            "application/octet-stream");   // some browsers send this for uploads

    /**
     * Validate an uploaded receipt.
     * @return {@code null} if valid, otherwise a user-facing error message.
     */
    public String validate(String fileName, long size, String contentType) {
        if (fileName == null || fileName.isBlank()) return "A receipt file is required.";
        String ext = extensionOf(fileName);
        if (!ALLOWED_EXT.contains(ext)) {
            return "Invalid file type. Allowed: JPG, JPEG, PNG, PDF.";
        }
        if (contentType != null && !ALLOWED_MIME.contains(contentType.toLowerCase())) {
            return "Unsupported file content type: " + contentType;
        }
        if (size <= 0) return "The uploaded receipt is empty.";
        if (size > MAX_BYTES) return "File size exceeds the 5MB limit.";
        return null;
    }

    /**
     * Store the receipt bytes under the configured upload directory using a
     * collision-safe name, and return the absolute path.
     */
    public Path store(byte[] bytes, String originalName, int expenseId) throws Exception {
        Path dir = Config.uploadDir();
        String safe = sanitize(originalName);
        Path target = dir.resolve("exp" + expenseId + "_" + safe);
        Files.write(target, bytes);
        return target;
    }

    public static String extensionOf(String fileName) {
        int dot = fileName.lastIndexOf('.');
        return dot < 0 ? "" : fileName.substring(dot + 1).toLowerCase();
    }

    /** Strip any path components and keep a filesystem-safe basename. */
    private String sanitize(String name) {
        String base = name.replace('\\', '/');
        int slash = base.lastIndexOf('/');
        if (slash >= 0) base = base.substring(slash + 1);
        base = base.replaceAll("[^A-Za-z0-9._-]", "_");
        if (base.isBlank()) base = "receipt";
        return base;
    }
}
