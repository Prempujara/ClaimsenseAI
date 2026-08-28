package model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/** One recorded manager decision (APPROVED / REJECTED) on an expense. */
public class ApprovalHistory {

    private static final DateTimeFormatter DT = DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a");

    private int historyId;
    private int expenseId;
    private int managerId;
    private String action;        // APPROVED | REJECTED
    private String remarks;
    private LocalDateTime actionDate;

    // join / display-only
    private String managerName;

    public ApprovalHistory() { }

    public int getHistoryId() { return historyId; }
    public void setHistoryId(int historyId) { this.historyId = historyId; }

    public int getExpenseId() { return expenseId; }
    public void setExpenseId(int expenseId) { this.expenseId = expenseId; }

    public int getManagerId() { return managerId; }
    public void setManagerId(int managerId) { this.managerId = managerId; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getRemarks() { return remarks; }
    public void setRemarks(String remarks) { this.remarks = remarks; }

    public LocalDateTime getActionDate() { return actionDate; }
    public void setActionDate(LocalDateTime actionDate) { this.actionDate = actionDate; }

    public String getManagerName() { return managerName; }
    public void setManagerName(String managerName) { this.managerName = managerName; }

    public String getActionDateDisplay() {
        return actionDate == null ? "" : actionDate.format(DT);
    }

    public boolean isApproved() { return "APPROVED".equalsIgnoreCase(action); }
}
