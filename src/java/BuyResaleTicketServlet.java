import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/BuyResaleTicket")
public class BuyResaleTicketServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer buyerId = session != null ? (Integer) session.getAttribute("userId") : null;
        if (buyerId == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        int listingId;
        try {
            listingId = Integer.parseInt(request.getParameter("listingId"));
        } catch (NumberFormatException e) {
            setFlash(session, "error", "Invalid listing selected.");
            response.sendRedirect("ResaleMarketplace");
            return;
        }

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            conn.setAutoCommit(false);

            String identityStatus = fetchIdentityStatus(buyerId);
            if (identityStatus == null || !"VERIFIED".equalsIgnoreCase(identityStatus)) {
                conn.rollback();
                setFlash(session, "error", "Please complete identity verification before purchasing resale tickets.");
                setIdentityRedirectFlash(session);
                response.sendRedirect("UserIdentityUpload");
                return;
            }

            if (!TicketBlockchain.isChainValid()) {
                conn.rollback();
                setFlash(session, "error", "Blockchain integrity check failed. Please try again.");
                response.sendRedirect("ResaleMarketplace");
                return;
            }

            String listingSql = "SELECT rl.*, "
                    + "t.status AS ticket_status, t.user_id AS ticket_owner, t.event_name, t.seat_type AS ticket_seat, "
                    + "e.event_date "
                    + "FROM ticket_resale_listings rl "
                    + "JOIN tickets t ON rl.ticket_id = t.ticket_id "
                    + "JOIN events e ON rl.event_id = e.event_id "
                    + "WHERE rl.listing_id = ? FOR UPDATE";

            int sellerId;
            int ticketId;
            int eventId;
            double originalPrice;
            double listingPrice;
            String ticketStatus;
            String seatLabel;
            java.sql.Timestamp eventDate;

            try (PreparedStatement listingStmt = conn.prepareStatement(listingSql)) {
                listingStmt.setInt(1, listingId);
                try (ResultSet rs = listingStmt.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        setFlash(session, "error", "Listing is no longer available.");
                        response.sendRedirect("ResaleMarketplace");
                        return;
                    }
                    String status = rs.getString("status");
                    if (!"LISTED".equalsIgnoreCase(status)) {
                        conn.rollback();
                        setFlash(session, "error", "Listing has already been processed.");
                        response.sendRedirect("ResaleMarketplace");
                        return;
                    }
                    ticketStatus = rs.getString("ticket_status");
                    ticketId = rs.getInt("ticket_id");
                    sellerId = rs.getInt("seller_id");
                    eventId = rs.getInt("event_id");
                    listingPrice = rs.getDouble("listing_price");
                    originalPrice = rs.getDouble("original_price");
                    seatLabel = rs.getString("ticket_seat");
                    eventDate = rs.getTimestamp("event_date");
                }
            }

            if ("REJECT".equalsIgnoreCase(ticketStatus)) {
                conn.rollback();
                setFlash(session, "error", "This ticket has been rejected for integrity reasons and cannot be sold.");
                response.sendRedirect("ResaleMarketplace");
                return;
            }

            if (sellerId == buyerId) {
                conn.rollback();
                setFlash(session, "error", "You cannot purchase your own listing.");
                response.sendRedirect("ResaleMarketplace");
                return;
            }

            java.util.Date eventDateValue = eventDate != null ? new java.util.Date(eventDate.getTime()) : null;
            if (eventDateValue != null && !SmartContractRules.canTicketBeListed("ACTIVE", eventDateValue)) {
                conn.rollback();
                setFlash(session, "error", "This event has already passed and can no longer be sold.");
                response.sendRedirect("ResaleMarketplace");
                return;
            }

            if (!SmartContractRules.canResellAtPrice(originalPrice, listingPrice)) {
                conn.rollback();
                setFlash(session, "error", "Listing violates the smart contract price rule.");
                response.sendRedirect("ResaleMarketplace");
                return;
            }

            // Treat ACTIVE as acceptable in case the ticket status was reset while the listing remained open.
            if (!"LISTED".equalsIgnoreCase(ticketStatus) && !"ACTIVE".equalsIgnoreCase(ticketStatus)) {
                conn.rollback();
                setFlash(session, "error", "Ticket is not available for resale anymore.");
                response.sendRedirect("ResaleMarketplace");
                return;
            }

            TicketBlockchain.ensureLatestSnapshotForTicket(conn, ticketId);

            int buyerWalletId;
            double buyerBalance;
            try (PreparedStatement buyerWallet = conn.prepareStatement(
                    "SELECT wallet_id, balance FROM wallets WHERE user_id = ? FOR UPDATE")) {
                buyerWallet.setInt(1, buyerId);
                try (ResultSet rs = buyerWallet.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        setFlash(session, "error", "Create a wallet before purchasing resale tickets.");
                        response.sendRedirect("ResaleMarketplace");
                        return;
                    }
                    buyerWalletId = rs.getInt("wallet_id");
                    buyerBalance = rs.getDouble("balance");
                }
            }

            if (buyerBalance < listingPrice) {
                conn.rollback();
                setFlash(session, "error", "Insufficient wallet balance to complete this purchase.");
                response.sendRedirect("ResaleMarketplace");
                return;
            }

            int sellerWalletId;
            try (PreparedStatement sellerWallet = conn.prepareStatement(
                    "SELECT wallet_id FROM wallets WHERE user_id = ? FOR UPDATE")) {
                sellerWallet.setInt(1, sellerId);
                try (ResultSet rs = sellerWallet.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        setFlash(session, "error", "Seller wallet is unavailable. Please try again later.");
                        response.sendRedirect("ResaleMarketplace");
                        return;
                    }
                    sellerWalletId = rs.getInt("wallet_id");
                }
            }

            try (PreparedStatement debitBuyer = conn.prepareStatement(
                    "UPDATE wallets SET balance = balance - ? WHERE wallet_id = ?")) {
                debitBuyer.setDouble(1, listingPrice);
                debitBuyer.setInt(2, buyerWalletId);
                debitBuyer.executeUpdate();
            }

            try (PreparedStatement creditSeller = conn.prepareStatement(
                    "UPDATE wallets SET balance = balance + ? WHERE wallet_id = ?")) {
                creditSeller.setDouble(1, listingPrice);
                creditSeller.setInt(2, sellerWalletId);
                creditSeller.executeUpdate();
            }

            try (PreparedStatement updateTicket = conn.prepareStatement(
                    "UPDATE tickets SET user_id = ?, status = 'ACTIVE', block_hash = 'pending-block', "
                    + "purchase_time = NOW() WHERE ticket_id = ?")) {
                updateTicket.setInt(1, buyerId);
                updateTicket.setInt(2, ticketId);
                updateTicket.executeUpdate();
            }

            try (PreparedStatement markSold = conn.prepareStatement(
                    "UPDATE ticket_resale_listings SET status='SOLD', buyer_id=?, sold_at=NOW() WHERE listing_id=?")) {
                markSold.setInt(1, buyerId);
                markSold.setInt(2, listingId);
                markSold.executeUpdate();
            }

            TicketBlock newBlock = TicketBlockchain.appendBlock(conn, ticketId);
            try (PreparedStatement updateHash = conn.prepareStatement(
                    "UPDATE tickets SET block_hash = ? WHERE ticket_id = ?")) {
                updateHash.setString(1, newBlock.getBlockHash());
                updateHash.setInt(2, ticketId);
                updateHash.executeUpdate();
            }

            conn.commit();
            setFlash(session, "success", "Resale ticket purchased successfully.");
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            setFlash(session, "error", "Unable to complete the purchase. Please try again.");
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        response.sendRedirect("ResaleMarketplace");
    }

    private void setFlash(HttpSession session, String status, String message) {
        if (session == null) {
            return;
        }
        session.setAttribute("marketStatus", status);
        session.setAttribute("marketMessage", message);
    }

    private void setIdentityRedirectFlash(HttpSession session) {
        if (session == null) {
            return;
        }
        session.setAttribute("identityStatus", "error");
        session.setAttribute("identityMessage", "Please complete identity verification to continue.");
    }

    private String fetchIdentityStatus(int userId) {
        String status = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement("SELECT identity_status FROM users WHERE id = ? LIMIT 1")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        status = rs.getString("identity_status");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return status;
    }
}
