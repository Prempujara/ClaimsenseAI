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

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Manager review dashboard: org-wide KPI counters plus every PENDING claim
 * awaiting a decision, each with its AI analysis (for the risk column).
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

            // AI analysis per pending claim, for the risk-assessment column.
            Map<Integer, AiAnalysis> analysisMap = new LinkedHashMap<>();
            for (Expense e : pending) {
                analysisMap.put(e.getExpenseId(), expenseService.getAnalysis(e.getExpenseId()));
            }

            req.setAttribute("stats", stats);
            req.setAttribute("pending", pending);
            req.setAttribute("analysisMap", analysisMap);
        } catch (Exception e) {
            req.setAttribute("error", "Unable to load claims for review right now.");
        }

        req.getRequestDispatcher("/manager/dashboard.jsp").forward(req, resp);
    }
}
