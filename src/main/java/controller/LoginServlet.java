package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import service.UserService;

import java.io.IOException;

/**
 * Handles the login form POST from {@code auth/login.jsp}.
 * On success stores the {@link User} in the session and redirects to the
 * role-appropriate dashboard; on failure bounces back to the login page.
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        // Nothing to GET here - send users to the login page.
        resp.sendRedirect(req.getContextPath() + "/auth/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {

        String ctx = req.getContextPath();
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        User user;
        try {
            user = userService.authenticate(email, password);
        } catch (Exception e) {
            // DB unreachable, etc. - do not leak details to the user.
            resp.sendRedirect(ctx + "/auth/login.jsp?error=system");
            return;
        }

        if (user == null) {
            resp.sendRedirect(ctx + "/auth/login.jsp?error=1");
            return;
        }

        // Fresh session to avoid fixation; store the authenticated user.
        HttpSession old = req.getSession(false);
        if (old != null) old.invalidate();
        HttpSession session = req.getSession(true);
        session.setAttribute("user", user);
        session.setMaxInactiveInterval(30 * 60); // 30 minutes

        resp.sendRedirect(ctx + (user.isManager() ? "/manager/dashboard" : "/employee/dashboard"));
    }
}
