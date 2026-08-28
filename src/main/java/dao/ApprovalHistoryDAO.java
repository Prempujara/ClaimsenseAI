package dao;

import model.ApprovalHistory;
import utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Data access for {@code approval_history}. */
public class ApprovalHistoryDAO {

    public int saveHistory(ApprovalHistory h) throws SQLException {
        String sql = "INSERT INTO approval_history (expense_id, manager_id, action, remarks) "
                   + "VALUES (?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, h.getExpenseId());
            ps.setInt(2, h.getManagerId());
            ps.setString(3, h.getAction());
            ps.setString(4, h.getRemarks());
            return ps.executeUpdate();
        }
    }

    /** History entries for an expense (with manager name), oldest first. */
    public List<ApprovalHistory> findByExpenseId(int expenseId) throws SQLException {
        String sql = "SELECT h.history_id, h.expense_id, h.manager_id, h.action, h.remarks, h.action_date, "
                   + "       u.name AS manager_name "
                   + "FROM approval_history h JOIN users u ON h.manager_id = u.user_id "
                   + "WHERE h.expense_id = ? ORDER BY h.action_date ASC, h.history_id ASC";
        List<ApprovalHistory> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, expenseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    private ApprovalHistory map(ResultSet rs) throws SQLException {
        ApprovalHistory h = new ApprovalHistory();
        h.setHistoryId(rs.getInt("history_id"));
        h.setExpenseId(rs.getInt("expense_id"));
        h.setManagerId(rs.getInt("manager_id"));
        h.setAction(rs.getString("action"));
        h.setRemarks(rs.getString("remarks"));
        if (rs.getTimestamp("action_date") != null) {
            h.setActionDate(rs.getTimestamp("action_date").toLocalDateTime());
        }
        h.setManagerName(rs.getString("manager_name"));
        return h;
    }
}
