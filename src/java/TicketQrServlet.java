import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.security.MessageDigest;
import javax.imageio.ImageIO;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/TicketQr")
public class TicketQrServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String ticketIdParam = request.getParameter("ticketId");
        if (ticketIdParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ticketId required");
            return;
        }

        int ticketId;
        try {
            ticketId = Integer.parseInt(ticketIdParam);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "invalid ticketId");
            return;
        }

        TicketData data = fetchTicketData(userId, ticketId);
        if (data == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Ticket not found");
            return;
        }

        String payload = buildPayload(data);
        try {
            BufferedImage image = generateQr(payload);
            response.setContentType("image/png");
            response.setHeader("Cache-Control", "no-store");
            try (OutputStream os = response.getOutputStream()) {
                ImageIO.write(image, "PNG", os);
            }
        } catch (WriterException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "QR generation failed");
        }
    }

    private TicketData fetchTicketData(int userId, int ticketId) {
        TicketData data = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(
                         "SELECT t.ticket_id, t.event_id, t.seat_type, t.status, "
                         + "w.wallet_address, bc.ticket_state_hash "
                         + "FROM tickets t "
                         + "LEFT JOIN ( "
                         + "  SELECT w1.user_id, w1.wallet_address "
                         + "  FROM wallets w1 "
                         + "  WHERE w1.status = 'ACTIVE' "
                         + "    AND w1.wallet_id = (SELECT MAX(w2.wallet_id) FROM wallets w2 WHERE w2.user_id = w1.user_id AND w2.status = 'ACTIVE') "
                         + ") w ON w.user_id = t.user_id "
                         + "LEFT JOIN ( "
                         + "  SELECT b1.ticket_id, b1.ticket_state_hash "
                         + "  FROM blockchain b1 "
                         + "  INNER JOIN (SELECT ticket_id, MAX(block_id) AS max_block FROM blockchain GROUP BY ticket_id) b2 "
                         + "    ON b1.ticket_id = b2.ticket_id AND b1.block_id = b2.max_block "
                         + ") bc ON bc.ticket_id = t.ticket_id "
                         + "WHERE t.ticket_id = ? AND t.user_id = ?")) {

                ps.setInt(1, ticketId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        data = new TicketData();
                        data.ticketId = rs.getInt("ticket_id");
                        data.eventId = rs.getInt("event_id");
                        data.seatType = rs.getString("seat_type");
                        data.status = rs.getString("status");
                        data.walletAddress = rs.getString("wallet_address");
                        data.ticketStateHash = rs.getString("ticket_state_hash");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return data;
    }

    private String buildPayload(TicketData data) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"ticket_id\":").append(data.ticketId).append(",");
        sb.append("\"event_id\":").append(data.eventId).append(",");
        sb.append("\"seat_type\":").append(toJsonString(data.seatType)).append(",");
        sb.append("\"status\":").append(toJsonString(data.status)).append(",");
        sb.append("\"wallet_address\":").append(toJsonString(data.walletAddress)).append(",");
        sb.append("\"ticket_state_hash\":").append(toJsonString(data.ticketStateHash));
        sb.append("}");

        // Build signing JSON 
        String signingJson = "{\"ticket_id\":" + data.ticketId
                + ",\"event_id\":" + data.eventId
                + ",\"seat_type\":" + toJsonString(data.seatType)
                + ",\"wallet_address\":" + toJsonString(data.walletAddress)
                + ",\"ticket_state_hash\":" + toJsonString(data.ticketStateHash)
                + "}";

        String unsignedJson = sb.toString();
        String hash = sha256(signingJson);
        String signature = DigitalSignatureUtil.sign(hash);

        // attach signature and return full payload
        StringBuilder finalJson = new StringBuilder(unsignedJson.substring(0, unsignedJson.length() - 1));
        finalJson.append(",\"signature\":").append(toJsonString(signature)).append("}");
        return finalJson.toString();
    }

    private String toJsonString(String value) {
        if (value == null) {
            return "null";
        }
        String escaped = value.replace("\\", "\\\\").replace("\"", "\\\"");
        return "\"" + escaped + "\"";
    }

    private BufferedImage generateQr(String payload) throws WriterException {
        QRCodeWriter qrWriter = new QRCodeWriter();
        BitMatrix matrix = qrWriter.encode(payload, BarcodeFormat.QR_CODE, 260, 260);
        return MatrixToImageWriter.toBufferedImage(matrix);
    }

    private String sha256(String data) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(data.getBytes("UTF-8"));
            StringBuilder hex = new StringBuilder();
            for (byte b : hash) {
                String h = Integer.toHexString(0xff & b);
                if (h.length() == 1) hex.append('0');
                hex.append(h);
            }
            return hex.toString();
        } catch (Exception e) {
            throw new RuntimeException("Unable to hash payload", e);
        }
    }

    private static class TicketData {
        int ticketId;
        int eventId;
        String seatType;
        String status;
        String walletAddress;
        String ticketStateHash;
    }
}
