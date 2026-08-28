package dao;

import model.Receipt;
import utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/** Data access for {@code receipts}. */
public class ReceiptDAO {

    public int saveReceipt(Receipt r) throws SQLException {
        String sql = "INSERT INTO receipts (expense_id, file_name, file_path, ocr_text) VALUES (?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, r.getExpenseId());
            ps.setString(2, r.getFileName());
            ps.setString(3, r.getFilePath());
            ps.setString(4, r.getOcrText());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int id = keys.getInt(1);
                    r.setReceiptId(id);
                    return id;
                }
            }
        }
        return -1;
    }

    public Receipt findByExpenseId(int expenseId) throws SQLException {
        String sql = "SELECT receipt_id, expense_id, file_name, file_path, ocr_text, uploaded_at "
                   + "FROM receipts WHERE expense_id = ? ORDER BY receipt_id DESC LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, expenseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    private Receipt map(ResultSet rs) throws SQLException {
        Receipt r = new Receipt();
        r.setReceiptId(rs.getInt("receipt_id"));
        r.setExpenseId(rs.getInt("expense_id"));
        r.setFileName(rs.getString("file_name"));
        r.setFilePath(rs.getString("file_path"));
        r.setOcrText(rs.getString("ocr_text"));
        if (rs.getTimestamp("uploaded_at") != null) {
            r.setUploadedAt(rs.getTimestamp("uploaded_at").toLocalDateTime());
        }
        return r;
    }
}
