package controller;

import dao.ApprovalHistoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.AiAnalysis;
import model.ApprovalHistory;
import model.Expense;
import model.Receipt;
import model.User;
import service.ExpenseService;

import java.io.IOException;
import java.util.List;

/**
 * Shows one claim in full: expense fields, AI/OCR analysis, the attached
 * receipt and the approval timeline. An employee may only open their own
 * claims; a manager may open any. Forwards to {@code employee/expenseDetails.jsp}.
 */
@WebServlet("/expense-details")
public class ExpenseDetailsServlet extends HttpServlet {

    private final ExpenseService expenseService = new ExpenseService();
    private final ApprovalHistoryDAO historyDAO = new ApprovalHistoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String ctx = req.getContextPath();
        User user = (User) req.getSession().getAttribute("user");

        int id;
        try {
            id = Integer.parseInt(req.getParameter("id"));
        } catch (Exception e) {
            resp.sendRedirect(ctx + (user.isManager() ? "/manager/dashboard" : "/employee/expenses"));
            return;
        }

        try {
            Expense expense = expenseService.findById(id);
            if (expense == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Expense not found.");
                return;
            }
            // Ownership: employees are restricted to their own claims.
            if (user.isEmployee() && expense.getUserId() != user.getUserId()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You cannot view this claim.");
                return;
            }

            Receipt receipt = expenseService.getReceipt(id);
            AiAnalysis analysis = expenseService.getAnalysis(id);
            List<ApprovalHistory> history = historyDAO.findByExpenseId(id);

            req.setAttribute("expense", expense);
            req.setAttribute("receipt", receipt);
            req.setAttribute("analysis", analysis);
            req.setAttribute("history", history);
            // Managers get action buttons only while the claim is still pending.
            req.setAttribute("canDecide",
                    user.isManager() && "PENDING".equalsIgnoreCase(expense.getStatus()));

            req.getRequestDispatcher("/employee/expenseDetails.jsp").forward(req, resp);
        } catch (IOException | ServletException e) {
            throw e;
        } catch (Exception e) {
            req.setAttribute("error", "Unable to load this claim right now.");
            req.getRequestDispatcher("/employee/expenseDetails.jsp").forward(req, resp);
        }
    }
}
