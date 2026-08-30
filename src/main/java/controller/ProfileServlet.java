package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.User;
import service.AvatarService;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.logging.Logger;

/**
 * Controller for User Profile &amp; Account Settings (/profile).
 *
 * <p>Actions: view profile (GET), update own details, upload a profile photo,
 * remove the profile photo (POST).</p>
 *
 * <p><b>Authorization.</b> The user id operated on is always taken from the
 * authenticated session ({@code session.getAttribute("user")}). No user id is
 * ever read from a request parameter, so a signed-in employee or manager can
 * only ever read and write their <em>own</em> row - there is no request shape
 * that addresses another user's profile.</p>
 *
 * <p>Email is deliberately read-only: it is the login identity, so it is never
 * taken from the form. Passwords are neither displayed nor editable here.</p>
 */
@WebServlet("/profile")
@MultipartConfig(
    fileSizeThreshold = 512 * 1024,        // 512 KB, then spool to disk
    maxFileSize = 5 * 1024 * 1024,         // 5 MB per file  (see AvatarService.MAX_BYTES)
    maxRequestSize = 6 * 1024 * 1024       // 6 MB whole request
)
public class ProfileServlet extends HttpServlet {

    /** Must match {@code maxRequestSize} above; used for the early size check. */
    private static final long MAX_REQUEST_BYTES = 6L * 1024 * 1024;

    private static final Logger LOG = Logger.getLogger(ProfileServlet.class.getName());

    private final UserDAO userDAO = new UserDAO();
    private final AvatarService avatarService = new AvatarService();

    /* ===================== GET: show own profile ===================== */

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = sessionUser(session);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login.jsp");
            return;
        }

        // Re-read from the DB so the page always shows persisted values.
        try {
            User fresh = userDAO.findById(user.getUserId());
            if (fresh != null) session.setAttribute("user", fresh);
        } catch (Exception e) {
            LOG.warning("Could not refresh user profile: " + e.getMessage());
        }

        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    /* ===================== POST: update / upload / remove ===================== */

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = sessionUser(session);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login.jsp");
            return;
        }

        // An over-sized request makes the container abort multipart parsing, after
        // which every getParameter() returns null. Check the declared length first
        // so the user sees the real reason instead of "Full Name is required".
        if (req.getContentLengthLong() > MAX_REQUEST_BYTES) {
            fail(req, resp, "Image is too large. Maximum size is 5MB.");
            return;
        }

        String action = req.getParameter("action");
        if ("removeAvatar".equalsIgnoreCase(action)) {
            removePhoto(req, resp, session, user);
            return;
        }
        updateProfile(req, resp, session, user);
    }

    /* ---------- remove profile photo ---------- */

    private void removePhoto(HttpServletRequest req, HttpServletResponse resp,
                             HttpSession session, User user) throws IOException {

        String existing = user.getAvatarPath();
        try {
            // Clear the DB reference first; only then delete the bytes, so a
            // failed delete can never leave a row pointing at a missing file.
            User toSave = copyOf(user);
            toSave.setAvatarPath(null);

            if (!userDAO.updateProfile(toSave)) {
                redirect(req, resp, "err", "Unable to remove profile photo.");
                return;
            }
            avatarService.delete(existing);
            session.setAttribute("user", toSave);
            redirect(req, resp, "ok", "Profile photo removed successfully.");
        } catch (Exception e) {
            LOG.severe("Avatar removal failed for user " + user.getUserId() + ": " + e.getMessage());
            redirect(req, resp, "err", "Unable to remove profile photo.");
        }
    }

    /* ---------- update details (+ optional new photo) ---------- */

    private void updateProfile(HttpServletRequest req, HttpServletResponse resp,
                               HttpSession session, User user)
            throws ServletException, IOException {

        String name       = trimTo(req.getParameter("name"), 100);
        String phone      = trimTo(req.getParameter("phone"), 50);
        String department = trimTo(req.getParameter("department"), 100);
        String jobTitle   = trimTo(req.getParameter("jobTitle"), 100);

        if (name.isBlank()) {
            fail(req, resp, "Full Name is required.");
            return;
        }
        if (!phone.isEmpty() && !phone.matches("[0-9+()\\-\\s]{6,50}")) {
            fail(req, resp, "Phone number may contain only digits, spaces and + - ( ) characters.");
            return;
        }

        // Work on a copy: the session user is replaced only after the DB commits.
        User toSave = copyOf(user);
        toSave.setName(name);
        toSave.setPhone(phone);
        toSave.setDepartment(department);
        toSave.setJobTitle(jobTitle);

        // ---- optional photo upload ----
        String newPhoto = null;
        try {
            Part part = req.getPart("avatarFile");
            if (part != null && part.getSize() > 0) {
                byte[] bytes = readPart(part);

                String error = avatarService.validate(bytes, part.getSubmittedFileName(),
                                                      part.getContentType());
                if (error != null) {
                    fail(req, resp, error);
                    return;
                }

                String format = avatarService.detectFormat(bytes);
                newPhoto = avatarService.store(bytes, user.getUserId(), format);
                toSave.setAvatarPath(newPhoto);
            }
        } catch (IllegalStateException e) {
            // Thrown by the container when the request exceeds maxRequestSize.
            fail(req, resp, "Image is too large. Maximum size is 5MB.");
            return;
        } catch (Exception e) {
            LOG.warning("Avatar upload failed for user " + user.getUserId() + ": " + e.getMessage());
            fail(req, resp, "Profile photo could not be saved. Please try another image.");
            return;
        }

        // ---- persist ----
        try {
            if (!userDAO.updateProfile(toSave)) {
                if (newPhoto != null) avatarService.delete(newPhoto);   // don't orphan the file
                fail(req, resp, "Unable to update profile. Please try again.");
                return;
            }
        } catch (Exception e) {
            LOG.severe("Profile update DB error for user " + user.getUserId() + ": " + e.getMessage());
            if (newPhoto != null) avatarService.delete(newPhoto);
            fail(req, resp, "Unable to update profile. Please try again.");
            return;
        }

        // Saved: swap in the new state and drop the replaced photo from disk.
        if (newPhoto != null && user.getAvatarPath() != null
                && !newPhoto.equals(user.getAvatarPath())) {
            avatarService.delete(user.getAvatarPath());
        }
        session.setAttribute("user", toSave);
        redirect(req, resp, "ok", "Profile updated successfully.");
    }

    /* ===================== helpers ===================== */

    private User sessionUser(HttpSession session) {
        return (session != null) ? (User) session.getAttribute("user") : null;
    }

    /**
     * Shallow copy used so a failed save never leaves edited values in the
     * session. Email / role / password are carried over untouched - this page
     * cannot change them.
     */
    private User copyOf(User u) {
        User c = new User();
        c.setUserId(u.getUserId());
        c.setName(u.getName());
        c.setEmail(u.getEmail());
        c.setPassword(u.getPassword());
        c.setRole(u.getRole());
        c.setPhone(u.getPhone());
        c.setDepartment(u.getDepartment());
        c.setJobTitle(u.getJobTitle());
        c.setAvatarPath(u.getAvatarPath());
        c.setCreatedAt(u.getCreatedAt());
        return c;
    }

    private byte[] readPart(Part part) throws IOException {
        try (InputStream in = part.getInputStream()) {
            return in.readAllBytes();
        }
    }

    private String trimTo(String value, int max) {
        if (value == null) return "";
        String v = value.trim();
        return v.length() > max ? v.substring(0, max) : v;
    }

    /** Re-render the form with an error message (no redirect, nothing persisted). */
    private void fail(HttpServletRequest req, HttpServletResponse resp, String message)
            throws ServletException, IOException {
        req.setAttribute("error", message);
        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    private void redirect(HttpServletRequest req, HttpServletResponse resp,
                          String key, String message) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/profile?" + key + "="
                + URLEncoder.encode(message, StandardCharsets.UTF_8));
    }
}
