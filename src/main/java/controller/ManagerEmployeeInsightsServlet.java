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
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Page 14: Employee Insights for Managers (/manager/employee-insights)
 * Manager-facing employee spending metrics strictly related to expenses.
 */
@WebServlet("/manager/employee-insights")
public class ManagerEmployeeInsightsServlet extends HttpServlet {

    private final ExpenseService expenseService = new ExpenseService();

    /**
     * Per-employee roll-up rendered by {@code manager/employeeInsights.jsp}.
     *
     * <p>The getters are required: JSP EL reads bean properties, not public
     * fields, so {@code ${m.name}} needs {@link #getName()}.</p>
     */
    public static class EmployeeMetric {
        public String name;
        public int totalClaims;
        public BigDecimal totalAmount = BigDecimal.ZERO;
        public int pendingCount;
        public int approvedCount;
        public int rejectedCount;

        public String getName()          { return name; }
        public int getTotalClaims()      { return totalClaims; }
        public BigDecimal getTotalAmount() { return totalAmount; }
        public int getPendingCount()     { return pendingCount; }
        public int getApprovedCount()    { return approvedCount; }
        public int getRejectedCount()    { return rejectedCount; }
    }

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
            Map<String, EmployeeMetric> metricsMap = new LinkedHashMap<>();

            for (Expense e : all) {
                String empName = e.getEmployeeName() != null ? e.getEmployeeName() : "Employee";
                EmployeeMetric m = metricsMap.computeIfAbsent(empName, k -> {
                    EmployeeMetric newM = new EmployeeMetric();
                    newM.name = k;
                    return newM;
                });

                m.totalClaims++;
                if (e.getAmount() != null) {
                    m.totalAmount = m.totalAmount.add(e.getAmount());
                }
                if ("PENDING".equalsIgnoreCase(e.getStatus())) m.pendingCount++;
                else if ("APPROVED".equalsIgnoreCase(e.getStatus())) m.approvedCount++;
                else if ("REJECTED".equalsIgnoreCase(e.getStatus())) m.rejectedCount++;
            }

            List<EmployeeMetric> employeeMetrics = new ArrayList<>(metricsMap.values());
            employeeMetrics.sort((a, b) -> b.totalAmount.compareTo(a.totalAmount));

            req.setAttribute("employeeMetrics", employeeMetrics);

        } catch (Exception e) {
            req.setAttribute("error", "Unable to load employee expense insights.");
        }

        req.getRequestDispatcher("/manager/employeeInsights.jsp").forward(req, resp);
    }
}
