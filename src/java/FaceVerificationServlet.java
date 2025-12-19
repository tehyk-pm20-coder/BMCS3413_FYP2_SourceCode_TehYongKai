
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Base64;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/FaceVerification")
public class FaceVerificationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String API_URL
            = System.getenv("DEEPFACE_API_URL") != null
            ? System.getenv("DEEPFACE_API_URL")
            : "http://localhost:8000/verify";
    private static final Path STORAGE_ROOT = Paths.get("C:", "FYPUploads", "user_identity");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");

        String walletAddress = defaultString(request.getParameter("wallet_address")).trim();
        String ticketIdStr = request.getParameter("ticket_id");
        Integer ticketId = null;
        if (ticketIdStr != null && !ticketIdStr.isEmpty()) {
            try {
                ticketId = Integer.parseInt(ticketIdStr);
            } catch (NumberFormatException ex) {
                writeJson(response, HttpServletResponse.SC_BAD_REQUEST,
                        "FAIL", null, null, "Invalid ticket_id", null);
                return;
            }
        }
        if (ticketId == null) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    "FAIL", null, null, "Missing ticket_id", null);
            return;
        }
        if (walletAddress.isEmpty()) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    "FAIL", null, null, "Missing wallet address", null);
            return;
        }

        IdentityInfo identity;
        try {
            identity = findIdentityByWallet(walletAddress);
        } catch (SQLException ex) {
            writeJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "FAIL", null, null, "Database lookup failed: " + ex.getMessage(), null);
            return;
        }

        if (identity == null || identity.facePhotoPath == null || identity.facePhotoPath.isEmpty()) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    "FAIL", null, null, "No reference face photo found for this wallet.", null);
            return;
        }

        Path referencePath = STORAGE_ROOT.resolve(identity.facePhotoPath);
        if (!Files.exists(referencePath)) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    "FAIL", null, null, "Reference photo missing on server: " + identity.facePhotoPath, null);
            return;
        }

        String imageData = request.getParameter("imageData");
        if (imageData == null || imageData.isEmpty()) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    "FAIL", null, null, "Missing image data", null);
            return;
        }

        String cleanBase64 = stripDataUrlPrefix(imageData.trim());
        byte[] imageBytes;
        try {
            imageBytes = Base64.getDecoder().decode(cleanBase64);
        } catch (IllegalArgumentException ex) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST,
                    "FAIL", null, null, "Invalid image encoding", null);
            return;
        }

        Path saved = saveTemp(imageBytes);

        String referenceBase64;
        try {
            referenceBase64 = Base64.getEncoder().encodeToString(Files.readAllBytes(referencePath));
        } catch (IOException ex) {
            writeJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "FAIL", null, null, "Unable to read reference photo.", null);
            return;
        }

        PythonResult result;
        try {
            result = callPythonApi(cleanBase64, walletAddress, referenceBase64, identity.facePhotoPath);
        } catch (IOException ex) {
            writeJson(response, HttpServletResponse.SC_BAD_GATEWAY,
                    "FAIL", null, null, "DeepFace service error: " + ex.getMessage(), null);
            return;
        }

        Double distance = result.distance;
        Double similarity = distance != null
                ? clamp(1.0 - distance, 0.0, 1.0)
                : null;

        //  threshold: 60%
        boolean verified = similarity != null && similarity >= 0.60;


        String message = verified
                ? "Face match successful."
                : "Face match not verified.";

        if (verified) {
            boolean updated;
            try {
                updated = updateTicketStatusToUsed(ticketId);
            } catch (SQLException ex) {
                writeJson(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "FAIL", distance, similarity, "Face verified but ticket update failed: " + ex.getMessage(), identity.facePhotoPath);
                return;
            }
            if (!updated) {
                writeJson(response, HttpServletResponse.SC_BAD_REQUEST,
                        "FAIL", distance, similarity, "Face verified but ticket status could not be updated.", identity.facePhotoPath);
                return;
            }
        }

        writeJson(response, HttpServletResponse.SC_OK,
                verified ? "PASS" : "FAIL",
                distance, similarity,
                message,
                identity.facePhotoPath);

        // Optional: log file path for diagnostics
        System.out.println("Saved face capture to: " + saved);
    }

    private IdentityInfo findIdentityByWallet(String walletAddress) throws SQLException {
        String sql = "SELECT w.user_id, ui.face_photo_path "
                + "FROM wallets w "
                + "LEFT JOIN user_identity ui ON ui.user_id = w.user_id AND ui.status = 'APPROVED' "
                + "WHERE w.wallet_address = ? "
                + "LIMIT 1";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, walletAddress);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    IdentityInfo info = new IdentityInfo();
                    info.userId = rs.getInt("user_id");
                    info.facePhotoPath = rs.getString("face_photo_path");
                    return info;
                }
            }
        }
        return null;
    }

    private PythonResult callPythonApi(String base64Image,
            String walletAddress,
            String referenceBase64,
            String referenceFileName) throws IOException {
        URL url = new URL(API_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        String payload = "{"
                + "\"wallet_address\":\"" + escapeJson(walletAddress) + "\","
                + "\"image_base64\":\"" + escapeJson(base64Image) + "\","
                + "\"reference_base64\":\"" + escapeJson(referenceBase64) + "\","
                + "\"reference_filename\":\"" + escapeJson(referenceFileName) + "\""
                + "}";

        try (OutputStream os = conn.getOutputStream()) {
            os.write(payload.getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();
        InputStream stream = status >= 200 && status < 300
                ? conn.getInputStream()
                : conn.getErrorStream();
        String responseBody = readStream(stream);

        Boolean verified = parseBoolean(responseBody, "verified");
        Double distance = parseDouble(responseBody, "distance");
        return new PythonResult(verified, distance, status, responseBody);
    }

    private Path saveTemp(byte[] data) throws IOException {
        Path tempFile = Files.createTempFile("face-capture-", ".jpg");
        Files.write(tempFile, data);
        return tempFile;
    }

    private void writeJson(HttpServletResponse response,
            int statusCode,
            String status,
            Double distance,
            Double similarity,
            String message,
            String referenceFile) throws IOException {
        response.setStatus(statusCode);
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"status\":\"").append(escapeJson(status)).append("\"");
        if (distance != null) {
            sb.append(",\"distance\":").append(distance);
        }
        if (similarity != null) {
            sb.append(",\"similarity\":").append(similarity);
        }
        if (message != null) {
            sb.append(",\"message\":\"").append(escapeJson(message)).append("\"");
        }
        if (referenceFile != null) {
            sb.append(",\"reference_file\":\"").append(escapeJson(referenceFile)).append("\"");
        }
        sb.append("}");
        response.getWriter().write(sb.toString());
    }

    private String stripDataUrlPrefix(String data) {
        int commaIndex = data.indexOf(',');
        if (data.startsWith("data:") && commaIndex != -1) {
            return data.substring(commaIndex + 1);
        }
        return data;
    }

    private String readStream(InputStream stream) throws IOException {
        if (stream == null) {
            return "";
        }
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(stream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }

    private Boolean parseBoolean(String json, String key) {
        Pattern p = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*(true|false)", Pattern.CASE_INSENSITIVE);
        Matcher m = p.matcher(json);
        if (m.find()) {
            return Boolean.parseBoolean(m.group(1));
        }
        return null;
    }

    private Double parseDouble(String json, String key) {
        Pattern p = Pattern.compile("\"" + Pattern.quote(key) + "\"\\s*:\\s*([-+]?[0-9]*\\.?[0-9]+)");
        Matcher m = p.matcher(json);
        if (m.find()) {
            try {
                return Double.parseDouble(m.group(1));
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value
                .replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    private double clamp(double value, double min, double max) {
        return Math.max(min, Math.min(max, value));
    }

    private String defaultString(String value) {
        return value == null ? "" : value;
    }

    private static class PythonResult {

        final Boolean verified;
        final Double distance;
        final int statusCode;
        final String raw;

        PythonResult(Boolean verified, Double distance, int statusCode, String raw) {
            this.verified = verified;
            this.distance = distance;
            this.statusCode = statusCode;
            this.raw = raw;
        }
    }

    private static class IdentityInfo {

        int userId;
        String facePhotoPath;
    }

    private boolean updateTicketStatusToUsed(int ticketId) throws SQLException {
        Connection conn = DBConnection.getConnection();
        if (conn == null) {
            throw new SQLException("Unable to acquire database connection.");
        }
        try (Connection c = conn;
                PreparedStatement ps = c.prepareStatement(
                        "UPDATE tickets SET status = 'USED' WHERE ticket_id = ? AND status <> 'USED'")) {
            ps.setInt(1, ticketId);
            return ps.executeUpdate() > 0;
        }
    }
}
