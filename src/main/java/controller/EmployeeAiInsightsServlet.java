package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.AiAnalysis;
import model.Expense;
import model.User;
import service.ExpenseService;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Page 7: Employee AI Insights (/employee/ai-insights)
 * Explains AI predictions, confidence ratings, and non-confrontational risk statuses for employee claims.
 */
@WebServlet("/employee/ai-insights")
public class EmployeeAiInsightsServlet extends HttpServlet {

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
            List<Expense> expenses = expenseService.listByEmployee(user.getUserId());
            Map<Integer, AiAnalysis> analysisMap = new LinkedHashMap<>();

            int anomalyCount = 0;
            int normalCount = 0;
            int insufficientCount = 0;

            for (Expense e : expenses) {
                AiAnalysis a = expenseService.getAnalysis(e.getExpenseId());
                analysisMap.put(e.getExpenseId(), a);
                if (a != null) {
                    if (a.isAnomaly()) {
                        anomalyCount++;
                    } else if ("NORMAL".equalsIgnoreCase(a.getAnomalyStatus())) {
                        normalCount++;
                    } else {
                        insufficientCount++;
                    }
                } else {
                    insufficientCount++;
                }
            }

            req.setAttribute("expenses", expenses);
            req.setAttribute("analysisMap", analysisMap);
            req.setAttribute("anomalyCount", anomalyCount);
            req.setAttribute("normalCount", normalCount);
            req.setAttribute("insufficientCount", insufficientCount);

        } catch (Exception e) {
            req.setAttribute("error", "Unable to load AI insights at this time.");
        }

        req.getRequestDispatcher("/employee/aiInsights.jsp").forward(req, resp);
    }
}
