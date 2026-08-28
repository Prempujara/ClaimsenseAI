package dao;

import model.Expense;
import utils.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Data access for {@code expenses}, including dashboard aggregates. */
public class ExpenseDAO {

    /** Common projection with category + employee names joined in. */
    private static final String BASE =
            "SELECT e.expense_id, e.user_id, e.category_id, e.title, e.amount, e.expense_date, "
          + "       e.description, e.status, e.rejection_reason, e.created_at, "
          + "       c.category_name, u.name AS employee_name "
          + "FROM expenses e "
          + "JOIN expense_categories c ON e.category_id = c.category_id "
          + "JOIN users u              ON e.user_id     = u.user_id ";

    /** Insert a new PENDING expense; returns the generated expense_id. */
    public int createExpense(Expense e) throws SQLException {
        String sql = "INSERT INTO expenses "
                   + "(user_id, category_id, title, amount, expense_date, description, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, e.getUserId());
            ps.setInt(2, e.getCategoryId());
            ps.setString(3, e.getTitle());
            ps.setBigDecimal(4, e.getAmount());
            ps.setDate(5, java.sql.Date.valueOf(e.getExpenseDate()));
            ps.setString(6, e.getDescription());
            ps.setString(7, e.getStatus() == null ? "PENDING" : e.getStatus());
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    int id = keys.getInt(1);
                    e.setExpenseId(id);
                    return id;
                }
            }
        }
        return -1;
    }

    public Expense findById(int expenseId) throws SQLException {
        String sql = BASE + "WHERE e.expense_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, expenseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    /** All expenses for one employee, newest first. */
    public List<Expense> findByEmployee(int userId) throws SQLException {
        String sql = BASE + "WHERE e.user_id = ? ORDER BY e.created_at DESC, e.expense_id DESC";
        return query(sql, ps -> ps.setInt(1, userId));
    }

    /** Every expense in the system, newest first (manager view). */
    public List<Expense> findAll() throws SQLException {
        String sql = BASE + "ORDER BY e.created_at DESC, e.expense_id DESC";
        return query(sql, ps -> { });
    }

    /** Expenses in a given status (e.g. PENDING), newest first. */
    public List<Expense> findByStatus(String status) throws SQLException {
        String sql = BASE + "WHERE e.status = ? ORDER BY e.created_at DESC, e.expense_id DESC";
        return query(sql, ps -> ps.setString(1, status));
    }

    /** Convenience for the manager dashboard. */
    public List<Expense> findPendingExpenses() throws SQLException {
        return findByStatus("PENDING");
    }

    public List<Expense> findRecentByEmployee(int userId, int limit) throws SQLException {
        String sql = BASE + "WHERE e.user_id = ? ORDER BY e.created_at DESC, e.expense_id DESC LIMIT ?";
        return query(sql, ps -> { ps.setInt(1, userId); ps.setInt(2, limit); });
    }

    public boolean updateStatus(int expenseId, String status) throws SQLException {
        String sql = "UPDATE expenses SET status = ? WHERE expense_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, expenseId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateRejectionReason(int expenseId, String reason) throws SQLException {
        String sql = "UPDATE expenses SET rejection_reason = ? WHERE expense_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, reason);
            ps.setInt(2, expenseId);
            return ps.executeUpdate() > 0;
        }
    }

    /* ===================== aggregates ===================== */

    /**
     * Count expenses by status.
     * @param userId null = across all users (manager); otherwise one employee.
     * @param status null = any status.
     */
    public int countByStatus(Integer userId, String status) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM expenses WHERE 1=1");
        if (userId != null) sql.append(" AND user_id = ?");
        if (status != null) sql.append(" AND status = ?");
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (userId != null) ps.setInt(idx++, userId);
            if (status != null) ps.setString(idx, status);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    /**
     * Sum of expense amounts.
     * @param userId null = all users; otherwise one employee.
     * @param status null = any status.
     */
    public BigDecimal sumAmount(Integer userId, String status) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COALESCE(SUM(amount),0) FROM expenses WHERE 1=1");
        if (userId != null) sql.append(" AND user_id = ?");
        if (status != null) sql.append(" AND status = ?");
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            int idx = 1;
            if (userId != null) ps.setInt(idx++, userId);
            if (status != null) ps.setString(idx, status);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            }
        }
    }

    /** Category -> total amount, for the employee's breakdown chart. */
    public Map<String, BigDecimal> categoryBreakdown(int userId) throws SQLException {
        String sql = "SELECT c.category_name, COALESCE(SUM(e.amount),0) AS total "
                   + "FROM expenses e JOIN expense_categories c ON e.category_id = c.category_id "
                   + "WHERE e.user_id = ? GROUP BY c.category_name HAVING total > 0 ORDER BY total DESC";
        Map<String, BigDecimal> out = new LinkedHashMap<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.put(rs.getString("category_name"), rs.getBigDecimal("total"));
            }
        }
        return out;
    }

    /**
     * Prior expense amounts for an employee (used for anomaly context),
     * excluding one expense id.
     */
    public List<Double> listPriorAmounts(int userId, int excludeExpenseId) throws SQLException {
        String sql = "SELECT amount FROM expenses WHERE user_id = ? AND expense_id <> ? ORDER BY created_at";
        List<Double> amounts = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, excludeExpenseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) amounts.add(rs.getDouble(1));
            }
        }
        return amounts;
    }

    /* ===================== helpers ===================== */

    /** Simple functional binder so list queries share one code path. */
    private interface Binder { void bind(PreparedStatement ps) throws SQLException; }

    private List<Expense> query(String sql, Binder binder) throws SQLException {
        List<Expense> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            binder.bind(ps);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        }
        return list;
    }

    private Expense map(ResultSet rs) throws SQLException {
        Expense e = new Expense();
        e.setExpenseId(rs.getInt("expense_id"));
        e.setUserId(rs.getInt("user_id"));
        e.setCategoryId(rs.getInt("category_id"));
        e.setTitle(rs.getString("title"));
        e.setAmount(rs.getBigDecimal("amount"));
        if (rs.getDate("expense_date") != null) {
            e.setExpenseDate(rs.getDate("expense_date").toLocalDate());
        }
        e.setDescription(rs.getString("description"));
        e.setStatus(rs.getString("status"));
        e.setRejectionReason(rs.getString("rejection_reason"));
        if (rs.getTimestamp("created_at") != null) {
            e.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        e.setCategoryName(rs.getString("category_name"));
        e.setEmployeeName(rs.getString("employee_name"));
        return e;
    }
}
