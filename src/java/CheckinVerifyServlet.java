import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/CheckinVerify")
public class CheckinVerifyServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        // Prefer form parameter (scanner posts x-www-form-urlencoded)
        String qrPayload = request.getParameter("qrPayload");
        if (qrPayload == null || qrPayload.isEmpty()) {
            qrPayload = readBody(request);
        }
        if (qrPayload == null || qrPayload.isEmpty()) {
            writeError(response, "Missing qrPayload");
            return;
        }

        qrPayload = qrPayload.trim();

        // Handle urlencoded body "qrPayload=...".
        if (qrPayload.startsWith("qrPayload=")) {
            qrPayload = qrPayload.substring("qrPayload=".length());
            try {
                qrPayload = java.net.URLDecoder.decode(qrPayload, "UTF-8");
            } catch (Exception ignored) {}
        }

        // Extract payload from JSON wrapper if sent as { "qrPayload": "..." }
        if (qrPayload.startsWith("{") && qrPayload.contains("qrPayload")) {
            String extracted = extractStringField(qrPayload, "qrPayload");
            if (extracted != null) {
                qrPayload = extracted;
            }
        }

        ParsedPayload parsed = parseQrJson(qrPayload);
        if (!parsed.valid) {
            writeError(response, parsed.error != null ? parsed.error : "Invalid QR payload");
            return;
        }

        boolean signatureOk = verifySignature(parsed);
        if (!signatureOk) {
            writeError(response, "Signature verification failed");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            writeError(response, "MySQL driver not found");
            return;
        }

        VerificationResult check = verifyAgainstDatabase(parsed);
        if (!check.success) {
            writeError(response, check.message);
            return;
        }

        writeSuccess(response, parsed, check);
    }

    private String readBody(HttpServletRequest request) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }

    private ParsedPayload parseQrJson(String json) {
        ParsedPayload p = new ParsedPayload();
        try {
            p.ticketId = extractIntField(json, "ticket_id");
            p.eventId = extractIntField(json, "event_id");
            p.seatType = extractStringField(json, "seat_type");
            p.status = extractStringField(json, "status");
            p.walletAddress = extractStringField(json, "wallet_address");
            p.ticketStateHash = extractStringField(json, "ticket_state_hash");
            p.signature = extractStringField(json, "signature");

            if (p.ticketId == null || p.eventId == null || p.seatType == null
                    || p.status == null || p.walletAddress == null || p.ticketStateHash == null || p.signature == null) {
                p.valid = false;
                p.error = "Invalid QR code. Missing required fields in QR payload";
                return p;
            }

            String unsignedJson = "{\"ticket_id\":" + p.ticketId
                    + ",\"event_id\":" + p.eventId
                    + ",\"seat_type\":" + toJsonString(p.seatType)
                    + ",\"status\":" + toJsonString(p.status)
                    + ",\"wallet_address\":" + toJsonString(p.walletAddress)
                    + ",\"ticket_state_hash\":" + toJsonString(p.ticketStateHash)
                    + "}";

            // Signing JSON excludes status to match TicketQrServlet
            String signingJson = "{\"ticket_id\":" + p.ticketId
                    + ",\"event_id\":" + p.eventId
                    + ",\"seat_type\":" + toJsonString(p.seatType)
                    + ",\"wallet_address\":" + toJsonString(p.walletAddress)
                    + ",\"ticket_state_hash\":" + toJsonString(p.ticketStateHash)
                    + "}";

            p.unsignedJson = unsignedJson;
            p.signingJson = signingJson;
            p.valid = true;
        } catch (Exception e) {
            p.valid = false;
            p.error = "Failed to parse QR payload";
        }
        return p;
    }

    private boolean verifySignature(ParsedPayload p) {
        try {
            String hash = sha256(p.signingJson);
            return DigitalSignatureUtil.verify(hash, p.signature);
        } catch (Exception e) {
            return false;
        }
    }

    private VerificationResult verifyAgainstDatabase(ParsedPayload p) {
        VerificationResult result = new VerificationResult();
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD)) {
            // fetch ticket info
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT t.ticket_id, t.user_id, t.event_id, t.seat_type, t.status "
                    + "FROM tickets t WHERE t.ticket_id = ?")) {
                ps.setInt(1, p.ticketId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        result.success = false;
                        result.message = "Ticket not found";
                        return result;
                    }
                    result.ticketId = rs.getInt("ticket_id");
                    result.userId = rs.getInt("user_id");
                    int dbEventId = rs.getInt("event_id");
                    String dbSeatType = rs.getString("seat_type");
                    String dbStatus = rs.getString("status");
                    // Status verification
                    if ("USED".equalsIgnoreCase(dbStatus) || "REJECT".equalsIgnoreCase(dbStatus)) {
                        result.success = false;
                        result.message = "Ticket is not valid for entry (status: " + dbStatus + ")";
                        return result;
                    }
                    if (!"ACTIVE".equalsIgnoreCase(dbStatus) && !"LISTED".equalsIgnoreCase(dbStatus)) {
                        result.success = false;
                        result.message = "Ticket status is not valid for entry";
                        return result;
                    }
                    if (dbEventId != p.eventId || !safeEquals(dbSeatType, p.seatType)) {
                        result.success = false;
                        result.message = "Ticket data mismatch";
                        return result;
                    }
                    result.dbStatus = dbStatus;
                }
            }

            // wallet
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT wallet_address FROM wallets WHERE user_id = ? AND status = 'ACTIVE' "
                    + "ORDER BY wallet_id DESC LIMIT 1")) {
                ps.setInt(1, result.userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        result.walletAddress = rs.getString("wallet_address");
                    }
                }
            }

            // blockchain latest state hash
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT ticket_state_hash FROM blockchain WHERE ticket_id = ? ORDER BY block_id DESC LIMIT 1")) {
                ps.setInt(1, p.ticketId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        result.ticketStateHash = rs.getString("ticket_state_hash");
                    }
                }
            }

            // compare
            if (!safeEquals(result.walletAddress, p.walletAddress)) {
                result.success = false;
                result.message = "Wallet address mismatch";
                return result;
            }
            if (!safeEquals(result.ticketStateHash, p.ticketStateHash)) {
                result.success = false;
                result.message = "Ticket state hash mismatch";
                return result;
            }
            result.success = true;
            return result;
        } catch (SQLException e) {
            e.printStackTrace();
            result.success = false;
            result.message = "Database error during verification";
            return result;
        }
    }

    private void writeError(HttpServletResponse response, String message) throws IOException {
        response.getWriter().write("{\"status\":\"ERROR\",\"message\":\"" + escapeJson(message) + "\"}");
    }

    private void writeSuccess(HttpServletResponse response, ParsedPayload p, VerificationResult db) throws IOException {
        Map<String, String> out = new HashMap<>();
        out.put("status", "SUCCESS");
        out.put("ticket_id", String.valueOf(p.ticketId));
        out.put("event_id", String.valueOf(p.eventId));
        out.put("seat_type", p.seatType);
        out.put("status_value", p.status);
        out.put("wallet_address", p.walletAddress);
        out.put("ticket_state_hash", p.ticketStateHash);
        out.put("message", "Ticket verified. Proceed to face verification.");
        StringBuilder sb = new StringBuilder("{");
        boolean first = true;
        for (Map.Entry<String, String> entry : out.entrySet()) {
            if (!first) sb.append(",");
            first = false;
            sb.append("\"").append(entry.getKey()).append("\":\"").append(escapeJson(entry.getValue())).append("\"");
        }
        sb.append("}");
        response.getWriter().write(sb.toString());
    }

    private Integer extractIntField(String json, String key) {
        Pattern p = Pattern.compile("\"" + key + "\"\\s*:\\s*(\\d+)");
        Matcher m = p.matcher(json);
        if (m.find()) {
            return Integer.parseInt(m.group(1));
        }
        return null;
    }

    private String extractStringField(String json, String key) {
        Pattern p = Pattern.compile("\"" + key + "\"\\s*:\\s*\"([^\"]*)\"");
        Matcher m = p.matcher(json);
        if (m.find()) {
            return m.group(1);
        }
        return null;
    }

    private String toJsonString(String value) {
        if (value == null) return "null";
        String escaped = value.replace("\\", "\\\\").replace("\"", "\\\"");
        return "\"" + escaped + "\"";
    }

    private String sha256(String data) throws Exception {
        return BlockchainUtil.sha256(data);
    }

    private boolean safeEquals(String a, String b) {
        if (a == null && b == null) return true;
        if (a == null || b == null) return false;
        return a.equals(b);
    }

    private String escapeJson(String s) {
        return s == null ? "" : s.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private static class ParsedPayload {
        boolean valid;
        String error;
        Integer ticketId;
        Integer eventId;
        String seatType;
        String status;
        String walletAddress;
        String ticketStateHash;
        String signature;
        String unsignedJson;
        String signingJson;
    }

    private static class VerificationResult {
        boolean success;
        String message;
        int ticketId;
        int userId;
        String dbStatus;
        String walletAddress;
        String ticketStateHash;
    }
}
