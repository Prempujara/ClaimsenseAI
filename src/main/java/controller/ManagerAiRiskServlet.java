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
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Page 12: Manager AI Risk Center (/manager/ai-risk)
 * Focused view of AI-detected anomalies, normal low-risk claims, and insufficient data cases.
 */
@WebServlet("/manager/ai-risk")
public class ManagerAiRiskServlet extends HttpServlet {

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
            Map<Integer, AiAnalysis> analysisMap = new LinkedHashMap<>();

            List<Expense> anomalyClaims = new ArrayList<>();
            List<Expense> normalClaims = new ArrayList<>();
            List<Expense> insufficientClaims = new ArrayList<>();

            for (Expense e : all) {
                AiAnalysis a = expenseService.getAnalysis(e.getExpenseId());
                analysisMap.put(e.getExpenseId(), a);
                if (a != null) {
                    if (a.isAnomaly()) {
                        anomalyClaims.add(e);
                    } else if ("NORMAL".equalsIgnoreCase(a.getAnomalyStatus())) {
                        normalClaims.add(e);
                    } else {
                        insufficientClaims.add(e);
                    }
                } else {
                    insufficientClaims.add(e);
                }
            }

            req.setAttribute("analysisMap", analysisMap);
            req.setAttribute("anomalyClaims", anomalyClaims);
            req.setAttribute("normalClaims", normalClaims);
            req.setAttribute("insufficientClaims", insufficientClaims);

        } catch (Exception e) {
            req.setAttribute("error", "Unable to load AI Risk Center data.");
        }

        req.getRequestDispatcher("/manager/aiRiskCenter.jsp").forward(req, resp);
    }
}
