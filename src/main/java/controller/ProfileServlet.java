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

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.logging.Logger;

/**
 * Controller for User Profile & Account Settings (/profile).
 * Handles GET (view profile) and POST (update details, upload profile photo, remove profile photo).
 */
@WebServlet("/profile")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize = 10 * 1024 * 1024,        // 10 MB
    maxRequestSize = 15 * 1024 * 1024      // 15 MB
)
public class ProfileServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(ProfileServlet.class.getName());
    private static final String UPLOAD_DIR = System.getProperty("user.home")
            + File.separator + ".claimsense" + File.separator + "avatars";

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login.jsp");
            return;
        }

        try {
            User updated = userDAO.findById(user.getUserId());
            if (updated != null) {
                session.setAttribute("user", updated);
            }
        } catch (Exception e) {
            LOG.warning("Could not refresh user profile: " + e.getMessage());
        }

        req.getRequestDispatcher("/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        if ("removeAvatar".equalsIgnoreCase(action)) {
            removeUserAvatar(user);
            try {
                user.setAvatarPath(null);
                userDAO.updateProfile(user);
                session.setAttribute("user", user);
                resp.sendRedirect(req.getContextPath() + "/profile?ok=Profile photo removed successfully");
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/profile?err=Unable to remove profile photo");
            }
            return;
        }

        String name = req.getParameter("name");
        String phone = req.getParameter("phone");
        String department = req.getParameter("department");
        String jobTitle = req.getParameter("jobTitle");

        if (name == null || name.isBlank()) {
            req.setAttribute("error", "Full Name is required.");
            req.getRequestDispatcher("/profile.jsp").forward(req, resp);
            return;
        }

        user.setName(name.trim());
        user.setPhone(phone != null ? phone.trim() : "");
        user.setDepartment(department != null ? department.trim() : "");
        user.setJobTitle(jobTitle != null ? jobTitle.trim() : "");

        // Handle Avatar File Upload if provided
        try {
            Part part = req.getPart("avatarFile");
            if (part != null && part.getSize() > 0) {
                String contentType = part.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    req.setAttribute("error", "Please select a valid image file (JPEG, PNG, WEBP, GIF).");
                    req.getRequestDispatcher("/profile.jsp").forward(req, resp);
                    return;
                }

                String ext = getExtension(part.getSubmittedFileName());
                if (ext.isEmpty()) ext = ".png";

                File folder = new File(UPLOAD_DIR);
                if (!folder.exists()) folder.mkdirs();

                // Clear any existing avatar extensions first
                removeUserAvatar(user);

                File targetFile = new File(folder, "avatar_" + user.getUserId() + ext);
                try (InputStream in = part.getInputStream()) {
                    Files.copy(in, targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }

                String avatarUrl = req.getContextPath() + "/avatar?id=" + user.getUserId() + "&t=" + System.currentTimeMillis();
                user.setAvatarPath(avatarUrl);
            }
        } catch (Exception e) {
            LOG.warning("Avatar upload failed: " + e.getMessage());
        }

        try {
            boolean success = userDAO.updateProfile(user);
            if (success) {
                session.setAttribute("user", user);
                resp.sendRedirect(req.getContextPath() + "/profile?ok=Profile updated successfully");
            } else {
                req.setAttribute("error", "Unable to update profile. Please try again.");
                req.getRequestDispatcher("/profile.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            LOG.severe("Profile update DB error: " + e.getMessage());
            req.setAttribute("error", "Unable to update profile: " + e.getMessage());
            req.getRequestDispatcher("/profile.jsp").forward(req, resp);
        }
    }

    private void removeUserAvatar(User user) {
        try {
            File folder = new File(UPLOAD_DIR);
            if (folder.exists()) {
                String[] exts = {".png", ".jpg", ".jpeg", ".webp", ".gif"};
                for (String ext : exts) {
                    File f = new File(folder, "avatar_" + user.getUserId() + ext);
                    if (f.exists()) f.delete();
                }
            }
        } catch (Exception e) {
            LOG.warning("Could not delete avatar file: " + e.getMessage());
        }
    }

    private String getExtension(String fileName) {
        if (fileName == null) return "";
        int dot = fileName.lastIndexOf('.');
        return dot >= 0 ? fileName.substring(dot).toLowerCase() : "";
    }
}
