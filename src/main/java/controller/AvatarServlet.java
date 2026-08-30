package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Serves profile avatar images stored on disk.
 * GET /avatar?id={userId}
 */
@WebServlet("/avatar")
public class AvatarServlet extends HttpServlet {

    private static final String UPLOAD_DIR = System.getProperty("user.home")
            + File.separator + ".claimsense" + File.separator + "avatars";

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

        File folder = new File(UPLOAD_DIR);
        if (!folder.exists()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        File avatarFile = null;
        String[] exts = {".png", ".jpg", ".jpeg", ".webp", ".gif"};
        for (String ext : exts) {
            File f = new File(folder, "avatar_" + userId + ext);
            if (f.exists() && f.isFile()) {
                avatarFile = f;
                break;
            }
        }

        if (avatarFile == null || !avatarFile.exists()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = getServletContext().getMimeType(avatarFile.getName());
        if (contentType == null) contentType = "image/png";

        resp.setContentType(contentType);
        resp.setContentLengthLong(avatarFile.length());
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

        try (FileInputStream in = new FileInputStream(avatarFile);
             OutputStream out = resp.getOutputStream()) {
            in.transferTo(out);
        }
    }
}
