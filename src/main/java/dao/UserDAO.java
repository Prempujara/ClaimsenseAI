package dao;

import model.User;
import utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Logger;

/** Data access for {@code users}. */
public class UserDAO {

    private static final Logger LOG = Logger.getLogger(UserDAO.class.getName());
    private static boolean columnsChecked = false;

    private synchronized void ensureProfileColumns(Connection con) {
        if (columnsChecked) return;
        try (Statement st = con.createStatement()) {
            try { st.execute("ALTER TABLE users ADD COLUMN phone VARCHAR(50)"); } catch (Exception ignored) {}
            try { st.execute("ALTER TABLE users ADD COLUMN department VARCHAR(100)"); } catch (Exception ignored) {}
            try { st.execute("ALTER TABLE users ADD COLUMN job_title VARCHAR(100)"); } catch (Exception ignored) {}
            try { st.execute("ALTER TABLE users ADD COLUMN avatar_path VARCHAR(500)"); } catch (Exception ignored) {}
            columnsChecked = true;
        } catch (Exception e) {
            LOG.warning("Could not execute user table column alterations: " + e.getMessage());
        }
    }

    /** @return the user with this email, or {@code null} if none. */
    public User findByEmail(String email) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            ensureProfileColumns(con);
            String sql = "SELECT user_id, name, email, password, role, phone, department, job_title, avatar_path, created_at "
                       + "FROM users WHERE email = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() ? map(rs) : null;
                }
            }
        }
    }

    /** @return the user with this id, or {@code null} if none. */
    public User findById(int userId) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            ensureProfileColumns(con);
            String sql = "SELECT user_id, name, email, password, role, phone, department, job_title, avatar_path, created_at "
                       + "FROM users WHERE user_id = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() ? map(rs) : null;
                }
            }
        }
    }

    /** Update personal information and avatar for a user. */
    public boolean updateProfile(User user) throws SQLException {
        try (Connection con = DBConnection.getConnection()) {
            ensureProfileColumns(con);
            String sql = "UPDATE users SET name = ?, phone = ?, department = ?, job_title = ?, avatar_path = ? WHERE user_id = ?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, user.getName());
                ps.setString(2, user.getPhone());
                ps.setString(3, user.getDepartment());
                ps.setString(4, user.getJobTitle());
                ps.setString(5, user.getAvatarPath());
                ps.setInt(6, user.getUserId());
                return ps.executeUpdate() > 0;
            }
        }
    }

    private User map(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setName(rs.getString("name"));
        u.setEmail(rs.getString("email"));
        u.setPassword(rs.getString("password"));
        u.setRole(rs.getString("role"));

        try { u.setPhone(rs.getString("phone")); } catch (Exception ignored) {}
        try { u.setDepartment(rs.getString("department")); } catch (Exception ignored) {}
        try { u.setJobTitle(rs.getString("job_title")); } catch (Exception ignored) {}
        try { u.setAvatarPath(rs.getString("avatar_path")); } catch (Exception ignored) {}

        if (rs.getTimestamp("created_at") != null) {
            u.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        }
        return u;
    }
}
