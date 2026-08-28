package service;

import utils.Config;
import utils.JsonUtil;

import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

/**
 * Java -> Python bridge for all AI/ML capabilities: OCR extraction, ML
 * category prediction and anomaly detection. Talks to the Flask service over
 * plain HTTP using the JDK's built-in {@link HttpClient} (no extra frameworks).
 *
 * <p>Every method degrades gracefully: if the Python service is unavailable or
 * errors, a result with {@code available=false} and a human-readable message is
 * returned instead of throwing, so expense submission never breaks.</p>
 *
 * <p>This class is the concrete "MLPredictionService" / AI-service abstraction
 * referenced by the architecture.</p>
 */
public class AIService {

    private static final Logger LOG = Logger.getLogger(AIService.class.getName());

    private final String baseUrl = Config.mlBaseUrl();
    private final HttpClient http = HttpClient.newBuilder()
            .connectTimeout(Duration.ofMillis(Math.min(4000, Config.mlTimeoutMs())))
            .build();

    /* ===================== health ===================== */

    public boolean isAvailable() {
        try {
            HttpResponse<String> resp = send("/health", null, 3000);
            return resp != null && resp.statusCode() == 200;
        } catch (Exception e) {
            return false;
        }
    }

    /* ===================== OCR ===================== */

    /** Runs OCR on receipt bytes via the Python service. */
    public OcrResult runOcr(byte[] fileBytes, String fileName) {
        OcrResult r = new OcrResult();
        try {
            Map<String, Object> body = new LinkedHashMap<>();
            body.put("filename", fileName);
            body.put("content_base64", Base64.getEncoder().encodeToString(fileBytes));
            HttpResponse<String> resp = send("/ocr", JsonUtil.write(body), 30000);
            if (resp == null || resp.statusCode() != 200) {
                r.available = false;
                r.message = "OCR processing failed";
                return r;
            }
            Map<String, Object> m = JsonUtil.parseObject(resp.body());
            boolean ok = JsonUtil.getBool(m, "success", false);
            r.available = true;
            r.success = ok;
            r.rawText = JsonUtil.getString(m, "text");
            r.merchant = JsonUtil.getString(m, "merchant");
            Double amt = JsonUtil.getDouble(m, "amount");
            if (amt != null) r.amount = BigDecimal.valueOf(amt);
            r.date = JsonUtil.getString(m, "date");
            r.engine = JsonUtil.getString(m, "engine");
            if (!ok) r.message = JsonUtil.getString(m, "error");
            return r;
        } catch (Exception e) {
            LOG.warning("OCR call failed: " + e.getMessage());
            r.available = false;
            r.message = "OCR processing failed";
            return r;
        }
    }

    /* ===================== category prediction ===================== */

    public PredictionResult predictCategory(String merchant, String description, BigDecimal amount) {
        PredictionResult r = new PredictionResult();
        try {
            Map<String, Object> body = new LinkedHashMap<>();
            body.put("merchant", merchant == null ? "" : merchant);
            body.put("description", description == null ? "" : description);
            body.put("amount", amount == null ? 0 : amount.doubleValue());
            HttpResponse<String> resp = send("/predict", JsonUtil.write(body), Config.mlTimeoutMs());
            if (resp == null || resp.statusCode() != 200) {
                r.available = false;
                r.message = "AI category suggestion unavailable";
                return r;
            }
            Map<String, Object> m = JsonUtil.parseObject(resp.body());
            r.available = true;
            r.category = JsonUtil.getString(m, "category");
            r.confidence = JsonUtil.getDouble(m, "confidence");
            return r;
        } catch (Exception e) {
            LOG.warning("Predict call failed: " + e.getMessage());
            r.available = false;
            r.message = "AI category suggestion unavailable";
            return r;
        }
    }

    /* ===================== anomaly detection ===================== */

    public AnomalyResult detectAnomaly(BigDecimal amount, String category, List<Double> history) {
        AnomalyResult r = new AnomalyResult();
        try {
            Map<String, Object> body = new LinkedHashMap<>();
            body.put("amount", amount == null ? 0 : amount.doubleValue());
            body.put("category", category == null ? "" : category);
            body.put("history", history == null ? List.of() : history);
            HttpResponse<String> resp = send("/anomaly", JsonUtil.write(body), Config.mlTimeoutMs());
            if (resp == null || resp.statusCode() != 200) {
                r.available = false;
                r.status = "UNAVAILABLE";
                return r;
            }
            Map<String, Object> m = JsonUtil.parseObject(resp.body());
            r.available = true;
            r.status = JsonUtil.getString(m, "status");
            r.score = JsonUtil.getDouble(m, "score");
            r.message = JsonUtil.getString(m, "message");
            return r;
        } catch (Exception e) {
            LOG.warning("Anomaly call failed: " + e.getMessage());
            r.available = false;
            r.status = "UNAVAILABLE";
            return r;
        }
    }

    /* ===================== transport ===================== */

    private HttpResponse<String> send(String path, String jsonBody, int timeoutMs) throws Exception {
        HttpRequest.Builder b = HttpRequest.newBuilder()
                .uri(URI.create(baseUrl + path))
                .timeout(Duration.ofMillis(timeoutMs))
                .header("Content-Type", "application/json");
        if (jsonBody == null) {
            b.GET();
        } else {
            b.POST(HttpRequest.BodyPublishers.ofString(jsonBody, StandardCharsets.UTF_8));
        }
        return http.send(b.build(), HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));
    }

    /* ===================== result value objects ===================== */

    public static class OcrResult {
        public boolean available = true;   // was the service reachable?
        public boolean success = false;    // did OCR actually extract text?
        public String rawText;
        public String merchant;
        public BigDecimal amount;
        public String date;
        public String engine;
        public String message;

        public boolean hasText() { return rawText != null && !rawText.isBlank(); }
    }

    public static class PredictionResult {
        public boolean available = true;
        public String category;
        public Double confidence;
        public String message;

        public boolean hasCategory() { return category != null && !category.isBlank(); }
    }

    public static class AnomalyResult {
        public boolean available = true;
        public String status = "INSUFFICIENT DATA";
        public Double score;
        public String message;
    }
}
