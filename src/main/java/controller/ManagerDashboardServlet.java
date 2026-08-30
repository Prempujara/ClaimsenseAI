package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.AiAnalysis;
import model.Expense;
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
 * Manager review dashboard: org-wide KPI counters, priority queue, AI risk analysis,
 * category breakdown analytics, and recent activity.
 * Forwards to {@code manager/dashboard.jsp}.
 */
@WebServlet("/manager/dashboard")
public class ManagerDashboardServlet extends HttpServlet {

    private final ExpenseService expenseService = new ExpenseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        try {
            DashboardStats stats = expenseService.managerStats();
            List<Expense> pending = expenseService.listPending();
            List<Expense> all = expenseService.listAll();

            // AI analysis per claim (for all expenses)
            Map<Integer, AiAnalysis> analysisMap = new LinkedHashMap<>();
            int anomalyCount = 0;
            for (Expense e : all) {
                AiAnalysis a = expenseService.getAnalysis(e.getExpenseId());
                analysisMap.put(e.getExpenseId(), a);
                if (a != null && a.isAnomaly()) {
                    anomalyCount++;
                }
            }

            // Category breakdown across all expenses
            Map<String, BigDecimal> categoryTotals = new LinkedHashMap<>();
            for (Expense e : all) {
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
            req.setAttribute("pending", pending);
            req.setAttribute("all", all);
            req.setAttribute("analysisMap", analysisMap);
            req.setAttribute("anomalyCount", anomalyCount);

            req.setAttribute("chartLabels", JsonUtil.write(catLabels));
            req.setAttribute("chartData", JsonUtil.write(catData));
            req.setAttribute("chartHasData", !catLabels.isEmpty());

        } catch (Exception e) {
            req.setAttribute("error", "Unable to load claims for review right now.");
        }

        req.getRequestDispatcher("/manager/dashboard.jsp").forward(req, resp);
    }
}

