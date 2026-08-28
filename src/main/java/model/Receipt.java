package model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/** Metadata for an uploaded receipt file (the binary lives on disk). */
public class Receipt {

    private static final DateTimeFormatter DT = DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a");

    private int receiptId;
    private int expenseId;
    private String fileName;
    private String filePath;
    private String ocrText;
    private LocalDateTime uploadedAt;

    public Receipt() { }

    public int getReceiptId() { return receiptId; }
    public void setReceiptId(int receiptId) { this.receiptId = receiptId; }

    public int getExpenseId() { return expenseId; }
    public void setExpenseId(int expenseId) { this.expenseId = expenseId; }

    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }

    public String getFilePath() { return filePath; }
    public void setFilePath(String filePath) { this.filePath = filePath; }

    public String getOcrText() { return ocrText; }
    public void setOcrText(String ocrText) { this.ocrText = ocrText; }

    public LocalDateTime getUploadedAt() { return uploadedAt; }
    public void setUploadedAt(LocalDateTime uploadedAt) { this.uploadedAt = uploadedAt; }

    /* ---- display helpers ---- */

    public String getUploadedAtDisplay() {
        return uploadedAt == null ? "" : uploadedAt.format(DT);
    }

    public boolean isPdf() {
        return fileName != null && fileName.toLowerCase().endsWith(".pdf");
    }

    public boolean isHasOcr() {
        return ocrText != null && !ocrText.isBlank();
    }

    /** Lower-cased file extension without the dot (e.g. "png"), or "" if none. */
    public String getExtension() {
        if (fileName == null) return "";
        int dot = fileName.lastIndexOf('.');
        return dot < 0 ? "" : fileName.substring(dot + 1).toLowerCase();
    }
}
