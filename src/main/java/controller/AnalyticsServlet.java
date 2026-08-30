package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Expense;
import model.User;
import service.DashboardStats;
import service.ExpenseService;
import utils.JsonUtil;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller for Spending Analytics view (/analytics).
 * Computes category distributions and status metrics for visualization.
 */
@WebServlet("/analytics")
public class AnalyticsServlet extends HttpServlet {

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
            DashboardStats stats = user.isManager()
                    ? expenseService.managerStats()
                    : expenseService.employeeStats(user.getUserId());

            List<Expense> expenses = user.isManager()
                    ? expenseService.listAll()
                    : expenseService.listByEmployee(user.getUserId());

            // Category breakdown map
            Map<String, BigDecimal> categoryTotals = new LinkedHashMap<>();
            for (Expense e : expenses) {
                if (e.getCategoryName() != null && e.getAmount() != null) {
                    categoryTotals.merge(e.getCategoryName(), e.getAmount(), BigDecimal::add);
                }
            }

            List<String> catLabels = new ArrayList<>(categoryTotals.keySet());
            List<Double> catData = new ArrayList<>();
            for (BigDecimal v : categoryTotals.values()) {
                catData.add(v.doubleValue());
            }

            req.setAttribute("stats", stats);
            req.setAttribute("expenses", expenses);
            req.setAttribute("categoryTotals", categoryTotals);
            req.setAttribute("chartLabels", JsonUtil.write(catLabels));
            req.setAttribute("chartData", JsonUtil.write(catData));
            req.setAttribute("chartHasData", !catLabels.isEmpty());

        } catch (Exception e) {
            req.setAttribute("error", "Unable to load spending analytics at this time.");
        }

        req.getRequestDispatcher("/analytics.jsp").forward(req, resp);
    }
}
