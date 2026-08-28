package controller;

import dao.ExpenseCategoryDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.ExpenseCategory;
import model.User;
import service.ExpenseService;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * Submit-expense controller.
 * <ul>
 *   <li>GET  -> loads categories and shows {@code employee/submitExpense.jsp}.</li>
 *   <li>POST -> parses the multipart form, runs the full submit pipeline
 *       (persist -> OCR -> ML -> anomaly) via {@link ExpenseService}, then
 *       redirects to the new expense's detail page.</li>
 * </ul>
 */
@WebServlet("/SubmitExpenseServlet")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,       // 1 MB in memory before spooling
        maxFileSize       = 6L * 1024 * 1024,  // 6 MB per file
        maxRequestSize    = 10L * 1024 * 1024  // 10 MB total
)
public class SubmitExpenseServlet extends HttpServlet {

    private final ExpenseService expenseService = new ExpenseService();
    private final ExpenseCategoryDAO categoryDAO = new ExpenseCategoryDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        showForm(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User user = (User) req.getSession().getAttribute("user");
        String ctx = req.getContextPath();

        String title = req.getParameter("title");
        String description = req.getParameter("description");
        String categoryStr = req.getParameter("category");
        String amountStr = req.getParameter("amount");
        String dateStr = req.getParameter("expenseDate");

        // ---- parse the simple fields (parse failures are validation errors) ----
        int categoryId;
        BigDecimal amount;
        LocalDate expenseDate;
        try {
            categoryId = Integer.parseInt(categoryStr);
        } catch (Exception e) {
            failBack(req, resp, "Please select a valid category.");
            return;
        }
        try {
            amount = new BigDecimal(amountStr.trim());
        } catch (Exception e) {
            failBack(req, resp, "Please enter a valid amount.");
            return;
        }
        try {
            expenseDate = LocalDate.parse(dateStr.trim());
        } catch (Exception e) {
            failBack(req, resp, "Please select a valid expense date.");
            return;
        }

        // ---- read the uploaded receipt ----
        byte[] fileBytes = null;
        String fileName = null;
        String contentType = null;
        try {
            Part part = req.getPart("receipt");
            if (part != null && part.getSubmittedFileName() != null
                    && !part.getSubmittedFileName().isBlank()) {
                fileName = part.getSubmittedFileName();
                contentType = part.getContentType();
                try (InputStream in = part.getInputStream()) {
                    fileBytes = in.readAllBytes();
                }
            }
        } catch (Exception e) {
            failBack(req, resp, "The receipt upload could not be read. Please try again.");
            return;
        }

        ExpenseService.SubmitResult result = expenseService.submitExpense(
                user.getUserId(), title, categoryId, amount, expenseDate, description,
                fileBytes, fileName, contentType);

        if (!result.success) {
            failBack(req, resp, result.error);
            return;
        }

        // Success -> show the detail page (with OCR / ML / anomaly outcome).
        resp.sendRedirect(ctx + "/expense-details?id=" + result.expenseId + "&submitted=1");
    }

    /* -------- helpers -------- */

    private void showForm(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            List<ExpenseCategory> categories = categoryDAO.findAll();
            req.setAttribute("categories", categories);
        } catch (Exception e) {
            req.setAttribute("error", "Unable to load categories right now.");
        }
        req.getRequestDispatcher("/employee/submitExpense.jsp").forward(req, resp);
    }

    /** Re-render the form with an error message at the top. */
    private void failBack(HttpServletRequest req, HttpServletResponse resp, String message)
            throws ServletException, IOException {
        req.setAttribute("error", message);
        showForm(req, resp);
    }
}
