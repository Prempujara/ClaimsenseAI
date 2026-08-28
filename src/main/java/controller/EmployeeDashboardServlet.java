package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Expense;
import model.User;
import service.DashboardStats;
import service.ExpenseService;
import utils.JsonUtil;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Loads the employee dashboard: KPI counters, recent claims and the
 * category-breakdown data that feeds the doughnut chart. Forwards to
 * {@code employee/dashboard.jsp}.
 */
@WebServlet("/employee/dashboard")
public class EmployeeDashboardServlet extends HttpServlet {

    private final ExpenseService expenseService = new ExpenseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        int userId = user.getUserId();

        try {
            DashboardStats stats = expenseService.employeeStats(userId);
            List<Expense> recent = expenseService.recentByEmployee(userId, 5);
            Map<String, BigDecimal> breakdown = expenseService.categoryBreakdown(userId);

            List<String> labels = new ArrayList<>(breakdown.keySet());
            List<Object> data = new ArrayList<>();
            for (BigDecimal v : breakdown.values()) data.add(v.doubleValue());

            req.setAttribute("stats", stats);
            req.setAttribute("recent", recent);
            req.setAttribute("chartLabels", JsonUtil.write(labels));
            req.setAttribute("chartData", JsonUtil.write(data));
            req.setAttribute("chartHasData", !labels.isEmpty());
        } catch (Exception e) {
            req.setAttribute("error", "Unable to load dashboard data right now.");
        }

        req.getRequestDispatcher("/employee/dashboard.jsp").forward(req, resp);
    }
}
