package model;

import java.math.BigDecimal;

/**
 * The AI/ML analysis attached to an expense: OCR extraction, ML category
 * prediction and anomaly-detection result. One row per expense.
 */
public class AiAnalysis {

    private int analysisId;
    private int expenseId;

    // OCR extraction
    private String ocrMerchant;
    private BigDecimal ocrAmount;
    private String ocrDate;

    // ML category prediction
    private String predictedCategory;
    private Double predictionConfidence;   // 0.0 - 1.0

    // Anomaly detection
    private String anomalyStatus;          // NORMAL | POTENTIAL ANOMALY | INSUFFICIENT DATA | UNAVAILABLE
    private Double anomalyScore;

    public AiAnalysis() { }

    public int getAnalysisId() { return analysisId; }
    public void setAnalysisId(int analysisId) { this.analysisId = analysisId; }

    public int getExpenseId() { return expenseId; }
    public void setExpenseId(int expenseId) { this.expenseId = expenseId; }

    public String getOcrMerchant() { return ocrMerchant; }
    public void setOcrMerchant(String ocrMerchant) { this.ocrMerchant = ocrMerchant; }

    public BigDecimal getOcrAmount() { return ocrAmount; }
    public void setOcrAmount(BigDecimal ocrAmount) { this.ocrAmount = ocrAmount; }

    public String getOcrDate() { return ocrDate; }
    public void setOcrDate(String ocrDate) { this.ocrDate = ocrDate; }

    public String getPredictedCategory() { return predictedCategory; }
    public void setPredictedCategory(String predictedCategory) { this.predictedCategory = predictedCategory; }

    public Double getPredictionConfidence() { return predictionConfidence; }
    public void setPredictionConfidence(Double predictionConfidence) { this.predictionConfidence = predictionConfidence; }

    public String getAnomalyStatus() { return anomalyStatus; }
    public void setAnomalyStatus(String anomalyStatus) { this.anomalyStatus = anomalyStatus; }

    public Double getAnomalyScore() { return anomalyScore; }
    public void setAnomalyScore(Double anomalyScore) { this.anomalyScore = anomalyScore; }

    /* ---- display helpers ---- */

    public boolean isHasPrediction() {
        return predictedCategory != null && !predictedCategory.isBlank();
    }

    /** Confidence as a whole-number percentage, e.g. "94%". */
    public String getConfidencePercent() {
        if (predictionConfidence == null) return "-";
        return Math.round(predictionConfidence * 100) + "%";
    }

    public String getOcrAmountDisplay() {
        return ocrAmount == null ? null : String.format("%,.2f", ocrAmount);
    }

    public boolean isAnomaly() {
        return anomalyStatus != null && anomalyStatus.toUpperCase().contains("ANOMALY");
    }
}
