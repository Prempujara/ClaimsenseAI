package service;

import dao.ApprovalHistoryDAO;
import dao.ExpenseDAO;
import model.ApprovalHistory;
import model.Expense;

import java.util.logging.Logger;

/** Manager approval / rejection business logic (with audit history). */
public class ApprovalService {

    private static final Logger LOG = Logger.getLogger(ApprovalService.class.getName());

    private final ExpenseDAO expenseDAO = new ExpenseDAO();
    private final ApprovalHistoryDAO historyDAO = new ApprovalHistoryDAO();

    public static class Result {
        public boolean success;
        public String message;
        Result(boolean s, String m) { success = s; message = m; }
    }

    /** Approve a pending claim, recording an approval_history entry. */
    public Result approve(int expenseId, int managerId, String remarks) {
        return decide(expenseId, managerId, "APPROVED",
                (remarks == null || remarks.isBlank()) ? "Approved" : remarks.trim());
    }

    /** Reject a pending claim; remarks are mandatory. */
    public Result reject(int expenseId, int managerId, String remarks) {
        if (remarks == null || remarks.isBlank()) {
            return new Result(false, "Rejection remarks are required.");
        }
        return decide(expenseId, managerId, "REJECTED", remarks.trim());
    }

    private Result decide(int expenseId, int managerId, String action, String remarks) {
        try {
            Expense e = expenseDAO.findById(expenseId);
            if (e == null) return new Result(false, "Expense not found.");
            if (!"PENDING".equalsIgnoreCase(e.getStatus())) {
                return new Result(false, "This claim has already been " + e.getStatus().toLowerCase() + ".");
            }

            boolean updated = expenseDAO.updateStatus(expenseId, action);
            if (!updated) return new Result(false, "Could not update the claim status.");

            if ("REJECTED".equals(action)) {
                expenseDAO.updateRejectionReason(expenseId, remarks);
            } else {
                expenseDAO.updateRejectionReason(expenseId, null);
            }

            ApprovalHistory h = new ApprovalHistory();
            h.setExpenseId(expenseId);
            h.setManagerId(managerId);
            h.setAction(action);
            h.setRemarks(remarks);
            historyDAO.saveHistory(h);

            return new Result(true, "Claim " + action.toLowerCase() + " successfully.");
        } catch (Exception ex) {
            LOG.severe("Approval decision failed: " + ex.getMessage());
            return new Result(false, "A system error occurred while processing the decision.");
        }
    }
}
