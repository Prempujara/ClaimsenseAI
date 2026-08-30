package controller;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import service.AvatarService;

import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.logging.Logger;

/**
 * Serves profile photos that live on disk (never in the database).
 *
 * <p>{@code GET /avatar?id={userId}} - the file name is looked up from
 * {@code users.avatar_path} for that id, so the browser never supplies a path
 * and cannot address anything outside the avatar directory. Reachable only with
 * an authenticated session ({@code AuthenticationFilter} guards {@code /avatar}
 * because it is not in the public path list).</p>
 */
@WebServlet("/avatar")
public class AvatarServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(AvatarServlet.class.getName());

    private final UserDAO userDAO = new UserDAO();
    private final AvatarService avatarService = new AvatarService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isBlank()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int userId;
        try {
            userId = Integer.parseInt(idParam.trim());
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        String fileName;
        try {
            User owner = userDAO.findById(userId);
            fileName = (owner != null) ? owner.getAvatarPath() : null;
        } catch (Exception e) {
            LOG.warning("Avatar lookup failed for user " + userId + ": " + e.getMessage());
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        if (fileName == null || fileName.isBlank()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        Path file = avatarService.resolveExisting(fileName);
        if (file == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = contentTypeFor(file.getFileName().toString());

        resp.setContentType(contentType);
        resp.setContentLengthLong(Files.size(file));
        // Photos are replaced in place under a new name; never serve a stale one.
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

        try (OutputStream out = resp.getOutputStream()) {
            Files.copy(file, out);
        }
    }

    /**
     * Map the stored extension to an image type. Done explicitly rather than via
     * the container MIME table so WEBP is always served correctly.
     */
    private String contentTypeFor(String fileName) {
        String lower = fileName.toLowerCase();
        if (lower.endsWith(".png"))  return "image/png";
        if (lower.endsWith(".webp")) return "image/webp";
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
        return "application/octet-stream";
    }
}
