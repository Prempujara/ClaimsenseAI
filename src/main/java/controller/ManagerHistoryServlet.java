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
import java.util.ArrayList;
import java.util.List;

/**
 * Page 15: Manager Approval History (/manager/history)
 * Dedicated manager history page showing previously processed claims across the organization.
 */
@WebServlet("/manager/history")
public class ManagerHistoryServlet extends HttpServlet {

    private final ExpenseService expenseService = new ExpenseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null || !user.isManager()) {
            resp.sendRedirect(req.getContextPath() + "/auth/login.jsp");
            return;
        }

        try {
            List<Expense> all = expenseService.listAll();
            List<Expense> processed = new ArrayList<>();

            for (Expense e : all) {
                if ("APPROVED".equalsIgnoreCase(e.getStatus()) || "REJECTED".equalsIgnoreCase(e.getStatus())) {
                    processed.add(e);
                }
            }

            req.setAttribute("processed", processed);

        } catch (Exception e) {
            req.setAttribute("error", "Unable to load approval history log.");
        }

        req.getRequestDispatcher("/manager/approvalHistory.jsp").forward(req, resp);
    }
}
