package dao;

import model.ExpenseCategory;
import utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/** Data access for {@code expense_categories}. */
public class ExpenseCategoryDAO {

    public List<ExpenseCategory> findAll() throws SQLException {
        String sql = "SELECT category_id, category_name FROM expense_categories ORDER BY category_id";
        List<ExpenseCategory> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        }
        return list;
    }

    public ExpenseCategory findById(int categoryId) throws SQLException {
        String sql = "SELECT category_id, category_name FROM expense_categories WHERE category_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    /** Used when the ML service suggests a category by name. */
    public ExpenseCategory findByName(String name) throws SQLException {
        String sql = "SELECT category_id, category_name FROM expense_categories WHERE category_name = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    private ExpenseCategory map(ResultSet rs) throws SQLException {
        return new ExpenseCategory(rs.getInt("category_id"), rs.getString("category_name"));
    }
}
