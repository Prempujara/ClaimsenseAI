package model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * An expense claim. Includes a few read-only "join" fields (categoryName,
 * employeeName) populated by the DAO for convenient display in JSP.
 */
public class Expense {

    private static final DateTimeFormatter D  = DateTimeFormatter.ofPattern("dd MMM yyyy");
    private static final DateTimeFormatter DT = DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a");

    private int expenseId;
    private int userId;
    private int categoryId;
    private String title;
    private BigDecimal amount;
    private LocalDate expenseDate;
    private String description;
    private String status;            // PENDING | APPROVED | REJECTED
    private String rejectionReason;
    private LocalDateTime createdAt;

    // join / display-only fields
    private String categoryName;
    private String employeeName;

    public Expense() { }

    public int getExpenseId() { return expenseId; }
    public void setExpenseId(int expenseId) { this.expenseId = expenseId; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public LocalDate getExpenseDate() { return expenseDate; }
    public void setExpenseDate(LocalDate expenseDate) { this.expenseDate = expenseDate; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getRejectionReason() { return rejectionReason; }
    public void setRejectionReason(String rejectionReason) { this.rejectionReason = rejectionReason; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getEmployeeName() { return employeeName; }
    public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }

    /* ---- display helpers used by the JSPs ---- */

    /** e.g. "#EX-1091" */
    public String getClaimCode() { return String.format("#EX-%04d", expenseId); }

    /** e.g. "450.00" with thousands separators. */
    public String getAmountDisplay() {
        return amount == null ? "0.00" : String.format("%,.2f", amount);
    }

    public String getExpenseDateDisplay() {
        return expenseDate == null ? "" : expenseDate.format(D);
    }

    public String getCreatedAtDisplay() {
        return createdAt == null ? "" : createdAt.format(DT);
    }
}
