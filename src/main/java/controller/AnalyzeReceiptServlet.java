package controller;

import dao.ExpenseCategoryDAO;
import model.ExpenseCategory;
import model.User;
import service.AIService;
import utils.JsonUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.logging.Logger;

/**
 * Controller for instant receipt analysis & expense autofill.
 * Receives receipt upload asynchronously, runs OCR + Category Prediction via AIService,
 * maps suggested category name to categoryId, and returns structured JSON.
 */
@WebServlet("/AnalyzeReceiptServlet")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024)
public class AnalyzeReceiptServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(AnalyzeReceiptServlet.class.getName());
    private final AIService aiService = new AIService();
    private final ExpenseCategoryDAO categoryDAO = new ExpenseCategoryDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User user = session != null ? (User) session.getAttribute("user") : null;

        Map<String, Object> out = new LinkedHashMap<>();

        if (user == null) {
            out.put("success", false);
            out.put("message", "Session expired. Please log in again.");
            resp.getWriter().write(JsonUtil.write(out));
            return;
        }

        try {
            Part filePart = req.getPart("receipt");
            if (filePart == null || filePart.getSize() == 0) {
                out.put("success", false);
                out.put("message", "No file uploaded.");
                resp.getWriter().write(JsonUtil.write(out));
                return;
            }

            String fileName = filePart.getSubmittedFileName();
            byte[] fileBytes;
            try (InputStream is = filePart.getInputStream()) {
                fileBytes = is.readAllBytes();
            }

            // 1. Run OCR extraction (Merchant, Amount, Date, Raw Text)
            AIService.OcrResult ocrRes = aiService.runOcr(fileBytes, fileName);

            // 2. Run ML Category Prediction (TF-IDF + Logistic Regression)
            AIService.PredictionResult predRes = aiService.predictCategory(
                    ocrRes.merchant,
                    ocrRes.rawText,
                    ocrRes.amount
            );

            // 3. Map category name to categoryId
            Integer categoryId = null;
            if (predRes.hasCategory()) {
                ExpenseCategory cat = categoryDAO.findByName(predRes.category);
                if (cat != null) {
                    categoryId = cat.getCategoryId();
                }
            }

            boolean isAvailable = ocrRes.available || predRes.available;
            boolean hasFields = (ocrRes.merchant != null && !ocrRes.merchant.isBlank()) ||
                                ocrRes.amount != null ||
                                (ocrRes.date != null && !ocrRes.date.isBlank()) ||
                                predRes.hasCategory();

            out.put("success", isAvailable && hasFields);
            out.put("available", isAvailable);
            out.put("merchant", ocrRes.merchant);
            out.put("amount", ocrRes.amount != null ? ocrRes.amount.doubleValue() : null);
            out.put("date", ocrRes.date);
            out.put("category", predRes.category);
            out.put("categoryId", categoryId);
            out.put("confidence", predRes.confidence != null ? predRes.confidence : 0.0);
            out.put("ocrEngine", ocrRes.engine);
            out.put("rawText", ocrRes.rawText);

            if (!isAvailable) {
                out.put("message", "AI microservice is offline. Enter expense details manually.");
            } else if (!hasFields) {
                out.put("message", "No readable fields extracted. Please fill form manually.");
            }

        } catch (Exception e) {
            LOG.warning("AnalyzeReceiptServlet error: " + e.getMessage());
            out.put("success", false);
            out.put("message", "Analysis error: " + e.getMessage());
        }

        resp.getWriter().write(JsonUtil.write(out));
    }
}
