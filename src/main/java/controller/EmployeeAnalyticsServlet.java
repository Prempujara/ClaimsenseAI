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
 * Page 6: Employee Spending Analytics (/employee/analytics)
 * Gives employees a personal analytics view of their spending.
 */
@WebServlet("/employee/analytics")
public class EmployeeAnalyticsServlet extends HttpServlet {

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
            DashboardStats stats = expenseService.employeeStats(user.getUserId());
            List<Expense> expenses = expenseService.listByEmployee(user.getUserId());
            Map<String, BigDecimal> categoryTotals = expenseService.categoryBreakdown(user.getUserId());

            List<String> catLabels = new ArrayList<>(categoryTotals.keySet());
            List<Double> catData = new ArrayList<>();
            for (BigDecimal val : categoryTotals.values()) {
                catData.add(val.doubleValue());
            }

            req.setAttribute("stats", stats);
            req.setAttribute("expenses", expenses);
            req.setAttribute("categoryTotals", categoryTotals);
            req.setAttribute("chartLabels", JsonUtil.write(catLabels));
            req.setAttribute("chartData", JsonUtil.write(catData));
            req.setAttribute("chartHasData", !catLabels.isEmpty());

        } catch (Exception e) {
            req.setAttribute("error", "Unable to load spending analytics.");
        }

        req.getRequestDispatcher("/employee/analytics.jsp").forward(req, resp);
    }
}
