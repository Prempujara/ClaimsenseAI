package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

/**
 * Gatekeeper for the whole app.
 *
 * <ul>
 *   <li>Public paths (login, static assets) pass through.</li>
 *   <li>Everything else requires an authenticated session.</li>
 *   <li>Role rules: only EMPLOYEE may hit /employee/* and the submit action;
 *       only MANAGER may hit /manager/* and the approve/reject action.</li>
 * </ul>
 *
 * Registered on {@code /*}; internal forwards to JSPs are not re-filtered
 * (default REQUEST dispatch only).
 */
@WebFilter("/*")
public class AuthenticationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        // Ensure UTF-8 for all form posts (rupee sign, unicode names, etc.)
        req.setCharacterEncoding("UTF-8");

        String ctx = req.getContextPath();
        String uri = req.getRequestURI();
        String path = uri.length() >= ctx.length() ? uri.substring(ctx.length()) : uri;

        // ---- public paths ----
        if (isPublic(path)) {
            chain.doFilter(request, response);
            return;
        }

        // ---- must be logged in ----
        HttpSession session = req.getSession(false);
        User user = (session == null) ? null : (User) session.getAttribute("user");
        if (user == null) {
            resp.sendRedirect(ctx + "/auth/login.jsp?timeout=1");
            return;
        }

        // ---- role-based authorization ----
        boolean employeeArea = path.startsWith("/employee/") || path.equals("/SubmitExpenseServlet") || path.equals("/AnalyzeReceiptServlet");
        boolean managerArea  = path.startsWith("/manager/")  || path.equals("/ApproveRejectServlet");

        if (employeeArea && !user.isEmployee()) {
            resp.sendRedirect(ctx + dashboardFor(user) + "?denied=1");
            return;
        }
        if (managerArea && !user.isManager()) {
            resp.sendRedirect(ctx + dashboardFor(user) + "?denied=1");
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean isPublic(String path) {
        if (path == null) return true;
        return path.equals("/")
                || path.equals("/index.jsp")
                || path.startsWith("/auth/")
                || path.startsWith("/assets/")
                || path.equals("/LoginServlet")
                || path.equals("/LogoutServlet")
                || path.equals("/favicon.ico");
    }

    private String dashboardFor(User user) {
        return user.isManager() ? "/manager/dashboard" : "/employee/dashboard";
    }
}
