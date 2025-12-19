import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/identity_image")
public class IdentityImageServlet extends HttpServlet {

    private static final Path STORAGE_ROOT = Paths.get("C:", "FYPUploads", "user_identity");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String fileName = request.getParameter("file");
        if (!isValidFileName(fileName)) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        if (!isAuthorized(request.getSession(false), fileName)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        Path imagePath = STORAGE_ROOT.resolve(fileName);
        if (!Files.exists(imagePath)) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        String mimeType = Files.probeContentType(imagePath);
        response.setContentType(mimeType != null ? mimeType : "application/octet-stream");
        response.setHeader("Cache-Control", "private, max-age=604800");
        try (OutputStream os = response.getOutputStream()) {
            Files.copy(imagePath, os);
        }
    }

    private boolean isValidFileName(String fileName) {
        if (fileName == null) {
            return false;
        }
        return !fileName.contains("..") && !fileName.contains("/") && !fileName.contains("\\");
    }

    private boolean isAuthorized(HttpSession session, String fileName) {
        if (session == null) {
            return false;
        }
        String role = (String) session.getAttribute("userRole");
        if (role != null && "admin".equalsIgnoreCase(role)) {
            return true;
        }
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            return false;
        }
        Integer ownerId = UserIdentityDAO.findUserIdByFileName(fileName);
        return ownerId != null && ownerId.equals(userId);
    }
}
