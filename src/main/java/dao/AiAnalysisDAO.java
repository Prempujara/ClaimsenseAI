package dao;

import model.AiAnalysis;
import utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

/** Data access for {@code ai_analysis} (OCR + ML prediction + anomaly). */
public class AiAnalysisDAO {

    /** Insert or replace the analysis row for an expense. */
    public void save(AiAnalysis a) throws SQLException {
        String sql = "INSERT INTO ai_analysis "
                + "(expense_id, ocr_merchant, ocr_amount, ocr_date, predicted_category, "
                + " prediction_confidence, anomaly_status, anomaly_score) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE "
                + " ocr_merchant=VALUES(ocr_merchant), ocr_amount=VALUES(ocr_amount), "
                + " ocr_date=VALUES(ocr_date), predicted_category=VALUES(predicted_category), "
                + " prediction_confidence=VALUES(prediction_confidence), "
                + " anomaly_status=VALUES(anomaly_status), anomaly_score=VALUES(anomaly_score)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, a.getExpenseId());
            ps.setString(2, a.getOcrMerchant());
            if (a.getOcrAmount() != null) ps.setBigDecimal(3, a.getOcrAmount());
            else ps.setNull(3, Types.DECIMAL);
            ps.setString(4, a.getOcrDate());
            ps.setString(5, a.getPredictedCategory());
            if (a.getPredictionConfidence() != null) ps.setDouble(6, a.getPredictionConfidence());
            else ps.setNull(6, Types.DECIMAL);
            ps.setString(7, a.getAnomalyStatus());
            if (a.getAnomalyScore() != null) ps.setDouble(8, a.getAnomalyScore());
            else ps.setNull(8, Types.DOUBLE);
            ps.executeUpdate();
        }
    }

    public AiAnalysis findByExpenseId(int expenseId) throws SQLException {
        String sql = "SELECT analysis_id, expense_id, ocr_merchant, ocr_amount, ocr_date, "
                   + "predicted_category, prediction_confidence, anomaly_status, anomaly_score "
                   + "FROM ai_analysis WHERE expense_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, expenseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    private AiAnalysis map(ResultSet rs) throws SQLException {
        AiAnalysis a = new AiAnalysis();
        a.setAnalysisId(rs.getInt("analysis_id"));
        a.setExpenseId(rs.getInt("expense_id"));
        a.setOcrMerchant(rs.getString("ocr_merchant"));
        a.setOcrAmount(rs.getBigDecimal("ocr_amount"));
        a.setOcrDate(rs.getString("ocr_date"));
        a.setPredictedCategory(rs.getString("predicted_category"));
        double conf = rs.getDouble("prediction_confidence");
        if (!rs.wasNull()) a.setPredictionConfidence(conf);
        a.setAnomalyStatus(rs.getString("anomaly_status"));
        double score = rs.getDouble("anomaly_score");
        if (!rs.wasNull()) a.setAnomalyScore(score);
        return a;
    }
}
