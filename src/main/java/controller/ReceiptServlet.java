package controller;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Expense;
import model.Receipt;
import model.User;
import service.ExpenseService;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Streams a stored receipt file back to the browser (inline preview / download).
 * Same ownership rule as the detail page: employees only their own, managers any.
 * The binary is read from disk (never stored in the DB).
 */
@WebServlet("/receipt")
public class ReceiptServlet extends HttpServlet {

    private final ExpenseService expenseService = new ExpenseService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {

        User user = (User) req.getSession().getAttribute("user");

        int expenseId;
        try {
            expenseId = Integer.parseInt(req.getParameter("expenseId"));
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing expense reference.");
            return;
        }

        try {
            Expense expense = expenseService.findById(expenseId);
            if (expense == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Expense not found.");
                return;
            }
            if (user.isEmployee() && expense.getUserId() != user.getUserId()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You cannot access this receipt.");
                return;
            }

            Receipt receipt = expenseService.getReceipt(expenseId);
            if (receipt == null || receipt.getFilePath() == null || receipt.getFilePath().isBlank()) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "No receipt on file.");
                return;
            }

            Path path = Path.of(receipt.getFilePath());
            if (!Files.exists(path)) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Receipt file is missing.");
                return;
            }

            resp.setContentType(contentTypeFor(receipt.getExtension()));
            resp.setContentLengthLong(Files.size(path));
            // "inline" so images/PDFs preview in-browser; filename for downloads.
            resp.setHeader("Content-Disposition",
                    "inline; filename=\"" + safeName(receipt.getFileName()) + "\"");

            try (OutputStream out = resp.getOutputStream()) {
                Files.copy(path, out);
            }
        } catch (IOException e) {
            throw e;
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not read receipt.");
        }
    }

    private String contentTypeFor(String ext) {
        return switch (ext == null ? "" : ext.toLowerCase()) {
            case "pdf" -> "application/pdf";
            case "png" -> "image/png";
            case "jpg", "jpeg" -> "image/jpeg";
            default -> "application/octet-stream";
        };
    }

    private String safeName(String name) {
        if (name == null || name.isBlank()) return "receipt";
        return name.replaceAll("[\\r\\n\"]", "_");
    }
}
