import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import model.UserIdentity;

@WebServlet("/UserIdentityUpload")
@MultipartConfig
public class UserIdentityUploadServlet extends HttpServlet {

    private static final Path STORAGE_ROOT = Paths.get("C:", "FYPUploads", "user_identity");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            response.sendRedirect("Login.jsp");
            return;
        }
        moveFlash(session, request);
        request.setAttribute("userIdentity", UserIdentityDAO.findByUserId(userId));
        request.getRequestDispatcher("UserIdentityUpload.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        UserIdentity existingIdentity = UserIdentityDAO.findByUserId(userId);
        if (existingIdentity != null && "APPROVED".equalsIgnoreCase(existingIdentity.getStatus())) {
            session.setAttribute("identityStatus", "success");
            session.setAttribute("identityMessage", "Your identity is already verified. No further uploads are needed.");
            response.sendRedirect("UserIdentityUpload");
            return;
        }

        Part idPhoto = request.getPart("idPhoto");
        Part facePhoto = request.getPart("facePhoto");
        String croppedFaceData = request.getParameter("croppedFaceData");

        List<String> validationErrors = new ArrayList<>();
        validatePart(idPhoto, "ID/IC photo", validationErrors);
        validateFaceInput(facePhoto, croppedFaceData, validationErrors);

        if (!validationErrors.isEmpty()) {
            request.setAttribute("validationErrors", validationErrors);
            request.setAttribute("userIdentity", existingIdentity);
            request.getRequestDispatcher("UserIdentityUpload.jsp").forward(request, response);
            return;
        }

        try {
            Files.createDirectories(STORAGE_ROOT);
            String idFileName = storeFile(idPhoto, userId, "id");
            String faceFileName;
            if (croppedFaceData != null && !croppedFaceData.isEmpty()) {
                faceFileName = storeBase64Image(croppedFaceData, userId, "face");
            } else {
                faceFileName = storeFile(facePhoto, userId, "face");
            }
            UserIdentityDAO.saveOrUpdate(userId, idFileName, faceFileName);
            session.setAttribute("identityStatus", "success");
            session.setAttribute("identityMessage", "Documents uploaded successfully. Please wait for admin review.");
            response.sendRedirect("UserIdentityUpload");
        } catch (SQLException e) {
            e.printStackTrace();
            validationErrors.add("Unable to save your documents. Please try again.");
            request.setAttribute("validationErrors", validationErrors);
            request.setAttribute("userIdentity", existingIdentity);
            request.getRequestDispatcher("UserIdentityUpload.jsp").forward(request, response);
        } catch (IOException e) {
            e.printStackTrace();
            validationErrors.add("We could not store your files. Please retry or use smaller images.");
            request.setAttribute("validationErrors", validationErrors);
            request.setAttribute("userIdentity", existingIdentity);
            request.getRequestDispatcher("UserIdentityUpload.jsp").forward(request, response);
        }
    }

    private void moveFlash(HttpSession session, HttpServletRequest request) {
        if (session == null) {
            return;
        }
        Object status = session.getAttribute("identityStatus");
        Object message = session.getAttribute("identityMessage");
        if (message != null) {
            request.setAttribute("identityStatus", status);
            request.setAttribute("identityMessage", message);
            session.removeAttribute("identityStatus");
            session.removeAttribute("identityMessage");
        }
    }

    private void validatePart(Part part, String label, List<String> errors) {
        if (part == null || part.getSize() == 0) {
            errors.add(label + " is required.");
            return;
        }
        String contentType = part.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            errors.add(label + " must be an image.");
            return;
        }
        if (!hasAllowedExtension(part.getSubmittedFileName())) {
            errors.add(label + " must be a JPG or PNG file.");
        }
    }

    private String storeFile(Part filePart, int userId, String prefix) throws IOException {
        String submittedName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String extension = "";
        int dot = submittedName.lastIndexOf('.');
        if (dot != -1 && dot < submittedName.length() - 1) {
            extension = submittedName.substring(dot);
        }
        String storedFileName = userId + "_" + prefix + "_" + System.currentTimeMillis() + extension;
        Path destination = STORAGE_ROOT.resolve(storedFileName);
        try (InputStream inputStream = filePart.getInputStream()) {
            Files.copy(inputStream, destination, StandardCopyOption.REPLACE_EXISTING);
        }
        return storedFileName;
    }

    private String storeBase64Image(String dataUrl, int userId, String prefix) throws IOException {
        if (dataUrl == null || !dataUrl.contains(",")) {
            throw new IOException("Invalid image data.");
        }
        String[] pieces = dataUrl.split(",", 2);
        String metadata = pieces[0];
        String base64Data = pieces[1];
        String extension = ".jpg";
        if (metadata.contains("png")) {
            extension = ".png";
        } else if (metadata.contains("jpeg")) {
            extension = ".jpg";
        }
        byte[] bytes = Base64.getDecoder().decode(base64Data);
        String storedFileName = userId + "_" + prefix + "_" + System.currentTimeMillis() + extension;
        Path destination = STORAGE_ROOT.resolve(storedFileName);
        Files.write(destination, bytes);
        return storedFileName;
    }

    private void validateFaceInput(Part facePart, String croppedData, List<String> errors) {
        boolean hasCropped = croppedData != null && !croppedData.isEmpty();
        boolean hasPart = facePart != null && facePart.getSize() > 0;
        if (!hasCropped && !hasPart) {
            errors.add("Face photo is required.");
            return;
        }
        if (hasCropped) {
            if (!croppedData.startsWith("data:image/jpg")
                    && !croppedData.startsWith("data:image/jpeg")
                    && !croppedData.startsWith("data:image/png")) {
                errors.add("Cropped face data must be a JPG or PNG image.");
            }
            return;
        }
        validateImagePart(facePart, "Face photo", errors);
    }

    private void validateImagePart(Part part, String label, List<String> errors) {
        if (part == null || part.getSize() == 0) {
            errors.add(label + " is required.");
            return;
        }
        String contentType = part.getContentType();
        if (contentType == null || !(contentType.equalsIgnoreCase("image/jpeg")
                || contentType.equalsIgnoreCase("image/jpg")
                || contentType.equalsIgnoreCase("image/png"))) {
            errors.add(label + " must be a JPG or PNG image.");
            return;
        }
        if (!hasAllowedExtension(part.getSubmittedFileName())) {
            errors.add(label + " file extension must be .jpg, .jpeg, or .png.");
        }
    }

    private boolean hasAllowedExtension(String fileName) {
        if (fileName == null) {
            return false;
        }
        String lower = fileName.toLowerCase();
        return lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png");
    }
}
