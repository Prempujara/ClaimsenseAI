package service;

import dao.AiAnalysisDAO;
import dao.ExpenseCategoryDAO;
import dao.ExpenseDAO;
import dao.ReceiptDAO;
import model.AiAnalysis;
import model.Expense;
import model.ExpenseCategory;
import model.Receipt;

import java.math.BigDecimal;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

/**
 * Core expense business logic. {@link #submitExpense} coordinates the full
 * pipeline: validate -> persist expense -> store receipt -> OCR -> ML category
 * prediction -> anomaly detection -> persist AI analysis.
 *
 * <p>AI/ML steps are best-effort: if the Python service is down the expense is
 * still saved (status PENDING) and the analysis fields are left null with a
 * clear status - submission never fails because of AI.</p>
 */
public class ExpenseService {

    private static final Logger LOG = Logger.getLogger(ExpenseService.class.getName());

    private final ExpenseDAO expenseDAO = new ExpenseDAO();
    private final ReceiptDAO receiptDAO = new ReceiptDAO();
    private final AiAnalysisDAO aiDAO = new AiAnalysisDAO();
    private final ExpenseCategoryDAO categoryDAO = new ExpenseCategoryDAO();
    private final ReceiptService receiptService = new ReceiptService();
    private final AIService aiService = new AIService();

    /* ===================== submission ===================== */

    /** Immutable-ish result returned to the servlet. */
    public static class SubmitResult {
        public boolean success;
        public int expenseId = -1;
        public String error;              // validation / system error (submission failed)
        // best-effort AI outcomes (for optional UI feedback)
        public boolean ocrSuccess;
        public String predictedCategory;
        public Double confidence;
        public String anomalyStatus;

        static SubmitResult fail(String msg) {
            SubmitResult r = new SubmitResult();
            r.success = false;
            r.error = msg;
            return r;
        }
    }

    public SubmitResult submitExpense(int userId, String title, int categoryId, BigDecimal amount,
                                      LocalDate expenseDate, String description,
                                      byte[] fileBytes, String fileName, String contentType) {
        // ---- validation ----
        if (title == null || title.isBlank())      return SubmitResult.fail("Expense title is required.");
        if (amount == null || amount.signum() <= 0) return SubmitResult.fail("Amount must be a positive number.");
        if (expenseDate == null)                    return SubmitResult.fail("A valid expense date is required.");
        if (expenseDate.isAfter(LocalDate.now()))   return SubmitResult.fail("Expense date cannot be in the future.");

        ExpenseCategory category;
        try {
            category = categoryDAO.findById(categoryId);
        } catch (Exception e) {
            LOG.severe("Category lookup failed: " + e.getMessage());
            return SubmitResult.fail("Could not validate the selected category. Please try again.");
        }
        if (category == null) return SubmitResult.fail("Please select a valid category.");

        String fileError = receiptService.validate(fileName,
                fileBytes == null ? 0 : fileBytes.length, contentType);
        if (fileError != null) return SubmitResult.fail(fileError);

        // ---- persist the expense (PENDING) ----
        Expense e = new Expense();
        e.setUserId(userId);
        e.setCategoryId(categoryId);
        e.setTitle(title.trim());
        e.setAmount(amount);
        e.setExpenseDate(expenseDate);
        e.setDescription(description == null ? "" : description.trim());
        e.setStatus("PENDING");

        int expenseId;
        try {
            expenseId = expenseDAO.createExpense(e);
        } catch (Exception ex) {
            LOG.severe("Failed to insert expense: " + ex.getMessage());
            return SubmitResult.fail("Could not save the expense. Please try again.");
        }
        if (expenseId <= 0) return SubmitResult.fail("Could not save the expense. Please try again.");

        SubmitResult result = new SubmitResult();
        result.success = true;
        result.expenseId = expenseId;

        // ---- store the receipt file on disk ----
        String storedPath = null;
        try {
            Path p = receiptService.store(fileBytes, fileName, expenseId);
            storedPath = p.toString();
        } catch (Exception ex) {
            LOG.warning("Receipt storage failed: " + ex.getMessage());
        }

        // ---- OCR (best-effort) ----
        AIService.OcrResult ocr = aiService.runOcr(fileBytes, fileName);
        String ocrText = (ocr.available && ocr.success && ocr.hasText())
                ? ocr.rawText
                : (ocr.available ? null : "OCR processing failed");
        result.ocrSuccess = ocr.available && ocr.success;

        // ---- save receipt metadata + OCR text ----
        try {
            Receipt r = new Receipt();
            r.setExpenseId(expenseId);
            r.setFileName(fileName);
            r.setFilePath(storedPath == null ? "" : storedPath);
            r.setOcrText(ocrText);
            receiptDAO.saveReceipt(r);
        } catch (Exception ex) {
            LOG.warning("Receipt row save failed: " + ex.getMessage());
        }

        // ---- ML category prediction (best-effort) ----
        String merchantForMl = (ocr.merchant != null && !ocr.merchant.isBlank()) ? ocr.merchant : title;
        AIService.PredictionResult pred =
                aiService.predictCategory(merchantForMl, description, amount);
        if (pred.available && pred.hasCategory()) {
            result.predictedCategory = pred.category;
            result.confidence = pred.confidence;
        }

        // ---- anomaly detection (best-effort) ----
        AIService.AnomalyResult anomaly;
        try {
            List<Double> history = expenseDAO.listPriorAmounts(userId, expenseId);
            anomaly = aiService.detectAnomaly(amount, category.getCategoryName(), history);
        } catch (Exception ex) {
            anomaly = new AIService.AnomalyResult();
            anomaly.available = false;
            anomaly.status = "UNAVAILABLE";
        }
        result.anomalyStatus = anomaly.status;

        // ---- persist AI analysis ----
        try {
            AiAnalysis a = new AiAnalysis();
            a.setExpenseId(expenseId);
            a.setOcrMerchant(ocr.merchant);
            a.setOcrAmount(ocr.amount);
            a.setOcrDate(ocr.date);
            a.setPredictedCategory(result.predictedCategory);
            a.setPredictionConfidence(result.confidence);
            a.setAnomalyStatus(anomaly.status);
            a.setAnomalyScore(anomaly.score);
            aiDAO.save(a);
        } catch (Exception ex) {
            LOG.warning("AI analysis save failed: " + ex.getMessage());
        }

        return result;
    }

    /* ===================== queries used by controllers ===================== */

    public Expense findById(int id) throws Exception { return expenseDAO.findById(id); }
    public List<Expense> listByEmployee(int userId) throws Exception { return expenseDAO.findByEmployee(userId); }
    public List<Expense> listAll() throws Exception { return expenseDAO.findAll(); }
    public List<Expense> listPending() throws Exception { return expenseDAO.findPendingExpenses(); }
    public List<Expense> recentByEmployee(int userId, int n) throws Exception { return expenseDAO.findRecentByEmployee(userId, n); }
    public Map<String, BigDecimal> categoryBreakdown(int userId) throws Exception { return expenseDAO.categoryBreakdown(userId); }
    public Receipt getReceipt(int expenseId) throws Exception { return receiptDAO.findByExpenseId(expenseId); }
    public AiAnalysis getAnalysis(int expenseId) throws Exception { return aiDAO.findByExpenseId(expenseId); }

    /* ===================== dashboards ===================== */

    public DashboardStats employeeStats(int userId) throws Exception {
        DashboardStats s = new DashboardStats();
        s.setTotalAmount(expenseDAO.sumAmount(userId, null));
        s.setTotalCount(expenseDAO.countByStatus(userId, null));
        s.setPendingCount(expenseDAO.countByStatus(userId, "PENDING"));
        s.setApprovedCount(expenseDAO.countByStatus(userId, "APPROVED"));
        s.setRejectedCount(expenseDAO.countByStatus(userId, "REJECTED"));
        return s;
    }

    public DashboardStats managerStats() throws Exception {
        DashboardStats s = new DashboardStats();
        s.setTotalAmount(expenseDAO.sumAmount(null, null));
        s.setTotalCount(expenseDAO.countByStatus(null, null));
        s.setPendingCount(expenseDAO.countByStatus(null, "PENDING"));
        s.setApprovedCount(expenseDAO.countByStatus(null, "APPROVED"));
        s.setRejectedCount(expenseDAO.countByStatus(null, "REJECTED"));
        return s;
    }
}
