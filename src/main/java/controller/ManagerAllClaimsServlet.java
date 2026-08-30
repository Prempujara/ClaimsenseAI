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
 * Page 11: Manager All Claims Workspace (/manager/all-claims)
 * Shows all organizational claims with search, status, category, and AI risk filters.
 */
@WebServlet("/manager/all-claims")
public class ManagerAllClaimsServlet extends HttpServlet {

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

            for (Expense e : all) {
                AiAnalysis a = expenseService.getAnalysis(e.getExpenseId());
                analysisMap.put(e.getExpenseId(), a);
            }

            req.setAttribute("all", all);
            req.setAttribute("analysisMap", analysisMap);

        } catch (Exception e) {
            req.setAttribute("error", "Unable to load all claims records.");
        }

        req.getRequestDispatcher("/manager/allClaims.jsp").forward(req, resp);
    }
}
