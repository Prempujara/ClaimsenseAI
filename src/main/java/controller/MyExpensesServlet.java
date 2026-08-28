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

import java.io.IOException;
import java.util.List;

/**
 * Lists all of the logged-in employee's claims (plus status counters for the
 * filter chips). Forwards to {@code employee/myExpense.jsp}.
 */
@WebServlet("/employee/expenses")
public class MyExpensesServlet extends HttpServlet {

    private final ExpenseService expenseService = new ExpenseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        int userId = user.getUserId();

        try {
            List<Expense> expenses = expenseService.listByEmployee(userId);
            DashboardStats stats = expenseService.employeeStats(userId);
            req.setAttribute("expenses", expenses);
            req.setAttribute("stats", stats);
        } catch (Exception e) {
            req.setAttribute("error", "Unable to load your expenses right now.");
        }

        req.getRequestDispatcher("/employee/myExpense.jsp").forward(req, resp);
    }
}
