package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import service.ApprovalService;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Processes a manager's decision on a claim (APPROVE / REJECT), recording an
 * approval-history entry, then redirects back to the manager dashboard with a
 * status message. Only MANAGER sessions reach here (enforced by the filter).
 */
@WebServlet("/ApproveRejectServlet")
public class ApproveRejectServlet extends HttpServlet {

    private final ApprovalService approvalService = new ApprovalService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        String ctx = req.getContextPath();
        String dashboard = ctx + "/manager/dashboard";
        User manager = (User) req.getSession().getAttribute("user");

        String action = req.getParameter("action");
        String remarks = req.getParameter("remarks");

        int expenseId;
        try {
            expenseId = Integer.parseInt(req.getParameter("expenseId"));
        } catch (Exception e) {
            redirect(resp, dashboard, false, "Invalid claim reference.");
            return;
        }

        ApprovalService.Result result;
        if ("APPROVE".equalsIgnoreCase(action)) {
            result = approvalService.approve(expenseId, manager.getUserId(), remarks);
        } else if ("REJECT".equalsIgnoreCase(action)) {
            result = approvalService.reject(expenseId, manager.getUserId(), remarks);
        } else {
            redirect(resp, dashboard, false, "Unknown action.");
            return;
        }

        redirect(resp, dashboard, result.success, result.message);
    }

    private void redirect(HttpServletResponse resp, String dashboard, boolean ok, String message)
            throws IOException {
        String enc = URLEncoder.encode(message == null ? "" : message, StandardCharsets.UTF_8);
        resp.sendRedirect(dashboard + "?" + (ok ? "ok" : "err") + "=" + enc);
    }
}
