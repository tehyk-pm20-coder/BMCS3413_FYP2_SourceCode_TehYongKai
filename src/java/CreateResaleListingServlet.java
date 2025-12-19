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

@WebServlet("/CreateResaleListing")
public class CreateResaleListingServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        int ticketId;
        double listingPrice;
        try {
            ticketId = Integer.parseInt(request.getParameter("ticketId"));
            listingPrice = Double.parseDouble(request.getParameter("listingPrice"));
        } catch (NumberFormatException e) {
            setFlash(session, "error", "Invalid listing request. Please check the form and try again.");
            response.sendRedirect("MyTickets");
            return;
        }

        if (listingPrice <= 0) {
            setFlash(session, "error", "Listing price must be greater than zero.");
            response.sendRedirect("MyTickets");
            return;
        }

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            conn.setAutoCommit(false);

            String ticketSql = "SELECT t.ticket_id, t.user_id, t.event_id, t.price, t.status, t.seat_type, "
                    + "e.event_date, "
                    + "(SELECT buyer_id FROM ticket_resale_listings rl "
                    + "   WHERE rl.ticket_id = t.ticket_id AND rl.status = 'SOLD' "
                    + "   ORDER BY rl.sold_at DESC, rl.listing_id DESC LIMIT 1) AS last_buyer_id, "
                    + "(SELECT sold_at FROM ticket_resale_listings rl "
                    + "   WHERE rl.ticket_id = t.ticket_id AND rl.status = 'SOLD' "
                    + "   ORDER BY rl.sold_at DESC, rl.listing_id DESC LIMIT 1) AS last_sold_at "
                    + "FROM tickets t JOIN events e ON t.event_id = e.event_id "
                    + "WHERE t.ticket_id = ? FOR UPDATE";

            int ownerId;
            String ticketStatus;
            double originalPrice;
            int eventId;
            String seatType;
            java.sql.Timestamp eventDate;
            Integer lastBuyerId;
            java.sql.Timestamp lastSoldAt;

            try (PreparedStatement ticketStmt = conn.prepareStatement(ticketSql)) {
                ticketStmt.setInt(1, ticketId);
                try (ResultSet rs = ticketStmt.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        setFlash(session, "error", "Ticket not found.");
                        response.sendRedirect("MyTickets");
                        return;
                    }
                    ownerId = rs.getInt("user_id");
                    ticketStatus = rs.getString("status");
                    originalPrice = rs.getDouble("price");
                    eventId = rs.getInt("event_id");
                    seatType = rs.getString("seat_type");
                    eventDate = rs.getTimestamp("event_date");
                    lastBuyerId = (Integer) rs.getObject("last_buyer_id");
                    lastSoldAt = rs.getTimestamp("last_sold_at");
                }
            }

            if (ownerId != userId) {
                conn.rollback();
                setFlash(session, "error", "You can only list tickets that belong to your account.");
                response.sendRedirect("MyTickets");
                return;
            }

            if ("REJECT".equalsIgnoreCase(ticketStatus)) {
                conn.rollback();
                setFlash(session, "error", "This ticket has been rejected due to tampering and cannot be listed.");
                response.sendRedirect("MyTickets");
                return;
            }

            if (!"ACTIVE".equalsIgnoreCase(ticketStatus)) {
                conn.rollback();
                setFlash(session, "error", "Only active tickets can be listed for resale.");
                response.sendRedirect("MyTickets");
                return;
            }

            java.util.Date eventDateValue = eventDate != null ? new java.util.Date(eventDate.getTime()) : null;
            if (eventDateValue != null && !SmartContractRules.canTicketBeListed(ticketStatus, eventDateValue)) {
                conn.rollback();
                setFlash(session, "error", "This event is no longer available for resale.");
                response.sendRedirect("MyTickets");
                return;
            }

            boolean acquiredFromMarketplace = lastBuyerId != null && lastBuyerId == ownerId;
            java.util.Date lastResaleDate = lastSoldAt != null ? new java.util.Date(lastSoldAt.getTime()) : null;
            if (acquiredFromMarketplace && lastResaleDate != null && !SmartContractRules.hasCooldownElapsed(lastResaleDate)) {
                conn.rollback();
                java.util.Date relistAt = SmartContractRules.getCooldownExpiry(lastResaleDate);
                String readableDate = relistAt != null
                        ? new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a").format(relistAt)
                        : "after the cooling-off period";
                setFlash(session, "error", "Resale purchases require a 7-day cooling-off period. You can list this ticket on or after " + readableDate + ".");
                response.sendRedirect("MyTickets");
                return;
            }

            if (!SmartContractRules.canResellAtPrice(originalPrice, listingPrice)) {
                conn.rollback();
                setFlash(session, "error", "Listing price cannot exceed the original ticket price (RM "
                        + String.format("%.2f", originalPrice) + ").");
                response.sendRedirect("MyTickets");
                return;
            }

            try (PreparedStatement checkListing = conn.prepareStatement(
                    "SELECT listing_id FROM ticket_resale_listings WHERE ticket_id = ? AND status = 'LISTED' LIMIT 1")) {
                checkListing.setInt(1, ticketId);
                try (ResultSet rs = checkListing.executeQuery()) {
                    if (rs.next()) {
                        conn.rollback();
                        setFlash(session, "error", "This ticket is already listed on the marketplace.");
                        response.sendRedirect("MyTickets");
                        return;
                    }
                }
            }

            try (PreparedStatement insertListing = conn.prepareStatement(
                    "INSERT INTO ticket_resale_listings "
                    + "(ticket_id, seller_id, event_id, seat_type, original_price, listing_price, status) "
                    + "VALUES (?, ?, ?, ?, ?, ?, 'LISTED')")) {
                insertListing.setInt(1, ticketId);
                insertListing.setInt(2, userId);
                insertListing.setInt(3, eventId);
                insertListing.setString(4, seatType);
                insertListing.setDouble(5, originalPrice);
                insertListing.setDouble(6, listingPrice);
                insertListing.executeUpdate();
            }

            try (PreparedStatement updateTicket = conn.prepareStatement(
                    "UPDATE tickets SET status = 'LISTED' WHERE ticket_id = ?")) {
                updateTicket.setInt(1, ticketId);
                updateTicket.executeUpdate();
            }

            conn.commit();
            setFlash(session, "success", "Ticket listed successfully at RM "
                    + String.format("%.2f", listingPrice) + ".");
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            setFlash(session, "error", "Unable to list ticket. Please try again.");
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        response.sendRedirect("MyTickets");
    }

    private void setFlash(HttpSession session, String status, String message) {
        if (session == null) {
            return;
        }
        session.setAttribute("ticketsStatus", status);
        session.setAttribute("ticketsMessage", message);
    }
}
