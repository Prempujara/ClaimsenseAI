package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Expense;
import model.User;
import service.ExpenseService;

import java.io.IOException;
import java.util.List;

/**
 * Controller for the Approval History timeline view (/history).
 * Shows org-wide claim decisions for managers, or personal claim history for employees.
 */
@WebServlet("/history")
public class HistoryServlet extends HttpServlet {

    private final ExpenseService expenseService = new ExpenseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login.jsp");
            return;
        }

        try {
            List<Expense> expenses;
            if (user.isManager()) {
                expenses = expenseService.listAll();
            } else {
                expenses = expenseService.listByEmployee(user.getUserId());
            }
            req.setAttribute("expenses", expenses);
        } catch (Exception e) {
            req.setAttribute("error", "Unable to load approval history at this time.");
        }

        req.getRequestDispatcher("/history.jsp").forward(req, resp);
    }
}
