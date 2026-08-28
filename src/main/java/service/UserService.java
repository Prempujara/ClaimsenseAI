package service;

import dao.UserDAO;
import model.User;
import utils.PasswordUtil;

import java.sql.SQLException;

/** Authentication / user business logic. */
public class UserService {

    private final UserDAO userDAO = new UserDAO();

    /**
     * Authenticate by email + plaintext password (hashed and compared).
     * @return the {@link User} on success, or {@code null} on bad credentials.
     */
    public User authenticate(String email, String password) throws SQLException {
        if (email == null || password == null) return null;
        User u = userDAO.findByEmail(email.trim().toLowerCase());
        if (u == null) {
            // Try as-entered too (in case emails were seeded with mixed case).
            u = userDAO.findByEmail(email.trim());
        }
        if (u == null) return null;
        return PasswordUtil.matches(password, u.getPassword()) ? u : null;
    }

    public User findById(int userId) throws SQLException {
        return userDAO.findById(userId);
    }
}
