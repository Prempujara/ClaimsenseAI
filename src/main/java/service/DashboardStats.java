package service;

import java.math.BigDecimal;

/** Aggregated counters for the employee / manager dashboards. */
public class DashboardStats {

    private BigDecimal totalAmount = BigDecimal.ZERO;
    private int totalCount;
    private int pendingCount;
    private int approvedCount;
    private int rejectedCount;

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public int getTotalCount() { return totalCount; }
    public void setTotalCount(int totalCount) { this.totalCount = totalCount; }

    public int getPendingCount() { return pendingCount; }
    public void setPendingCount(int pendingCount) { this.pendingCount = pendingCount; }

    public int getApprovedCount() { return approvedCount; }
    public void setApprovedCount(int approvedCount) { this.approvedCount = approvedCount; }

    public int getRejectedCount() { return rejectedCount; }
    public void setRejectedCount(int rejectedCount) { this.rejectedCount = rejectedCount; }

    /** Total amount formatted with thousands separators, e.g. "28,500.00". */
    public String getTotalAmountDisplay() {
        return totalAmount == null ? "0.00" : String.format("%,.2f", totalAmount);
    }
}
