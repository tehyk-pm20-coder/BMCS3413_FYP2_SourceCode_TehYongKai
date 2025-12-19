import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import model.BlockAuditRecord;

@WebServlet("/AdminViewBlockServlet")
public class AdminViewBlockServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";
    private static final String STATUS_REJECTED = "REJECT";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<BlockAuditRecord> records = new ArrayList<>();
        String message = null;

        String sql = "SELECT b.block_id, b.ticket_id, b.previous_hash, b.block_hash, b.ticket_state_hash, "
                + "t.user_id, t.event_id, NULL AS signature, t.status, u.fullname, t.event_name, t.seat_type, "
                + "t.price, t.purchase_time "
                + "FROM blockchain b "
                + "JOIN tickets t ON b.ticket_id = t.ticket_id "
                + "LEFT JOIN users u ON t.user_id = u.id "
                + "ORDER BY b.block_id DESC";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(sql);
                 PreparedStatement rejectStmt = conn.prepareStatement(
                         "UPDATE tickets SET status = ? WHERE ticket_id = ? AND status <> ?");
                 ResultSet rs = ps.executeQuery()) {

                java.util.Set<Integer> latestTicketSeen = new java.util.HashSet<>();

                while (rs.next()) {
                    BlockAuditRecord record = new BlockAuditRecord();
                    record.setBlockId(rs.getInt("block_id"));
                    record.setTicketId(rs.getInt("ticket_id"));
                    record.setPreviousHash(rs.getString("previous_hash"));
                    record.setBlockHash(rs.getString("block_hash"));
                    record.setUserId(rs.getInt("user_id"));
                    record.setEventId(rs.getInt("event_id"));
                    record.setSignature(rs.getString("signature"));
                    record.setFullName(rs.getString("fullname"));
                    record.setEventName(rs.getString("event_name"));
                    record.setSeatType(rs.getString("seat_type"));
                    record.setPrice(rs.getDouble("price"));
                    record.setPurchaseTime(rs.getTimestamp("purchase_time"));
                    String ticketStateHash = rs.getString("ticket_state_hash");
                    record.setTicketStateHash(ticketStateHash);

                    boolean tampered = (ticketStateHash == null || ticketStateHash.isEmpty());

                    // Recompute the current block data into block hash to find mismatch
                    if (!tampered) {
                        String blockData = BlockchainUtil.buildBlockDataFromStateHash(
                                record.getTicketId(),
                                ticketStateHash,
                                record.getPreviousHash());
                        String recomputed = BlockchainUtil.sha256(blockData);
                        record.setRecomputedHash(recomputed);
                        tampered = !recomputed.equals(record.getBlockHash());
                    } else {
                        record.setRecomputedHash(null);
                    }


                    // Recompute the current ticket data into Hashed State data to find mismatch
                    String currentStateData = BlockchainUtil.buildTicketStateData(
                            record.getTicketId(),
                            record.getUserId(),
                            record.getEventId(),
                            record.getSeatType(),
                            record.getPrice()
                            
                    );
                    String currentStateHash = BlockchainUtil.sha256(currentStateData);
                    record.setCurrentStateHash(currentStateHash);

                    // Only compare latest block's snapshot to current ticket row to determine tampering
                    if (!latestTicketSeen.contains(record.getTicketId())) {
                        latestTicketSeen.add(record.getTicketId());
                        if (ticketStateHash != null && !ticketStateHash.isEmpty()) {
                            tampered = tampered || !ticketStateHash.equals(currentStateHash);
                        }
                    }

                    // If the global chain is broken, treat corresponding records as tampered
                    if (!TicketBlockchain.isChainValid()) {
                        tampered = true;
                    }

                    record.setTampered(tampered);

                    if (tampered) {
                        try {
                            rejectStmt.setString(1, STATUS_REJECTED);
                            rejectStmt.setInt(2, record.getTicketId());
                            rejectStmt.setString(3, STATUS_REJECTED);
                            rejectStmt.executeUpdate();
                        } catch (SQLException updateEx) {
                            updateEx.printStackTrace();
                        }
                    }

                    records.add(record);
                }
            }

            if (records.isEmpty()) {
                message = "No blockchain entries yet. Ticket purchases will populate this view.";
            }
        } catch (ClassNotFoundException | SQLException ex) {
            ex.printStackTrace();
            message = "Unable to load blockchain audit trail.";
        } catch (Exception hashEx) {
            hashEx.printStackTrace();
            message = "Blockchain verification failed. Please try again.";
        }

        List<BlockAuditRecord> tamperedRecords = new ArrayList<>();
        for (BlockAuditRecord record : records) {
            if (record.isTampered()) {
                tamperedRecords.add(record);
            }
        }

        request.setAttribute("records", records);
        request.setAttribute("message", message);
        request.setAttribute("tamperedRecords", tamperedRecords);
        request.getRequestDispatcher("AdminViewBlock.jsp").forward(request, response);
    }
}
