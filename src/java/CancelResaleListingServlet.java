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

@WebServlet("/CancelResaleListing")
public class CancelResaleListingServlet extends HttpServlet {

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
        try {
            ticketId = Integer.parseInt(request.getParameter("ticketId"));
        } catch (NumberFormatException e) {
            setFlash(session, "error", "Invalid ticket id.");
            response.sendRedirect("MyTickets");
            return;
        }

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            conn.setAutoCommit(false);

            Integer listingId = null;
            int ownerId = -1;
            String status = null;
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT t.user_id, t.status, rl.listing_id "
                    + "FROM tickets t "
                    + "LEFT JOIN ticket_resale_listings rl ON rl.ticket_id = t.ticket_id AND rl.status = 'LISTED' "
                    + "WHERE t.ticket_id = ? FOR UPDATE")) {
                ps.setInt(1, ticketId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        setFlash(session, "error", "Ticket not found.");
                        response.sendRedirect("MyTickets");
                        return;
                    }
                    ownerId = rs.getInt("user_id");
                    status = rs.getString("status");
                    listingId = (Integer) rs.getObject("listing_id");
                }
            }

            if (ownerId != userId) {
                conn.rollback();
                setFlash(session, "error", "You can only cancel your own ticket listing.");
                response.sendRedirect("MyTickets");
                return;
            }
            if (!"LISTED".equalsIgnoreCase(status)) {
                conn.rollback();
                setFlash(session, "error", "Only listed tickets can be cancelled.");
                response.sendRedirect("MyTickets");
                return;
            }
            if (listingId == null) {
                conn.rollback();
                setFlash(session, "error", "No active listing found for this ticket.");
                response.sendRedirect("MyTickets");
                return;
            }

            try (PreparedStatement cancelListing = conn.prepareStatement(
                    "UPDATE ticket_resale_listings SET status='CANCELLED' WHERE listing_id=?")) {
                cancelListing.setInt(1, listingId);
                cancelListing.executeUpdate();
            }

            try (PreparedStatement updateTicket = conn.prepareStatement(
                    "UPDATE tickets SET status='ACTIVE' WHERE ticket_id=?")) {
                updateTicket.setInt(1, ticketId);
                updateTicket.executeUpdate();
            }

            conn.commit();
            setFlash(session, "success", "Listing cancelled and ticket reverted to ACTIVE.");
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            setFlash(session, "error", "Unable to cancel listing. Please try again.");
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
        if (session == null) return;
        session.setAttribute("ticketsStatus", status);
        session.setAttribute("ticketsMessage", message);
    }
}
