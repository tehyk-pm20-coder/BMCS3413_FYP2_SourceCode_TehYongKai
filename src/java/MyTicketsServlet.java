import java.io.IOException;
import java.math.BigDecimal;
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
import javax.servlet.http.HttpSession;
import model.UserTicketView;

@WebServlet("/MyTickets")
public class MyTicketsServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        List<UserTicketView> tickets = new ArrayList<>();
        String fallbackMessage = null;
        Double walletBalance = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(
                         "SELECT t.ticket_id, t.event_id, t.event_name, t.seat_type, t.price, t.status, "
                         + "t.purchase_time, NULL AS signature, "
                         + "e.event_date, e.venue, "
                         + "rl.listing_id, rl.listing_price, rl.status AS listing_status, rl.created_at, "
                         + "w.wallet_address, bc.ticket_state_hash, "
                         + "(SELECT rs.sold_at FROM ticket_resale_listings rs "
                         + "   WHERE rs.ticket_id = t.ticket_id AND rs.status = 'SOLD' AND rs.buyer_id = t.user_id "
                         + "   ORDER BY rs.sold_at DESC, rs.listing_id DESC LIMIT 1) AS last_resale_sold_at, "
                         + "(SELECT rs.buyer_id FROM ticket_resale_listings rs "
                         + "   WHERE rs.ticket_id = t.ticket_id AND rs.status = 'SOLD' AND rs.buyer_id = t.user_id "
                         + "   ORDER BY rs.sold_at DESC, rs.listing_id DESC LIMIT 1) AS last_resale_buyer_id "
                         + "FROM tickets t "
                         + "LEFT JOIN events e ON t.event_id = e.event_id "
                         + "LEFT JOIN ticket_resale_listings rl "
                         + "  ON rl.ticket_id = t.ticket_id AND rl.status = 'LISTED' "
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
                         + "WHERE t.user_id = ? "
                         + "ORDER BY e.event_date IS NULL, e.event_date ASC, t.ticket_id ASC")) {

                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        UserTicketView view = new UserTicketView();
                        view.setTicketId(rs.getInt("ticket_id"));
                        view.setEventId(rs.getInt("event_id"));
                        view.setEventName(rs.getString("event_name"));
                        view.setSeatType(rs.getString("seat_type"));
                        view.setPrice(rs.getDouble("price"));
                        view.setTicketStatus(rs.getString("status"));
                        view.setSignature(rs.getString("signature"));
                        view.setEventDate(rs.getTimestamp("event_date"));
                        view.setVenue(rs.getString("venue"));
                        Integer listingId = (Integer) rs.getObject("listing_id");
                        view.setListingId(listingId);
                        BigDecimal listingPrice = rs.getBigDecimal("listing_price");
                        view.setListingPrice(listingPrice != null ? listingPrice.doubleValue() : null);
                        view.setListingStatus(rs.getString("listing_status"));
                        view.setListingCreatedAt(rs.getTimestamp("created_at"));
                        view.setWalletAddress(rs.getString("wallet_address"));
                        view.setTicketStateHash(rs.getString("ticket_state_hash"));
                        view.setPurchaseTime(rs.getTimestamp("purchase_time"));
                        view.setLastResaleSoldAt(rs.getTimestamp("last_resale_sold_at"));
                        Integer lastBuyer = (Integer) rs.getObject("last_resale_buyer_id");
                        view.setLastResaleBuyerId(lastBuyer);
                        tickets.add(view);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            fallbackMessage = "Unable to load your tickets at the moment. Please try again shortly.";
        }

        walletBalance = fetchWalletBalance(userId);

        moveFlashAttribute(session, request, "ticketsStatus");
        moveFlashAttribute(session, request, "ticketsMessage");

        if (fallbackMessage != null) {
            request.setAttribute("fallbackMessage", fallbackMessage);
        }

        request.setAttribute("walletBalance", walletBalance);
        request.setAttribute("tickets", tickets);
        request.getRequestDispatcher("MyTickets.jsp").forward(request, response);
    }

    private void moveFlashAttribute(HttpSession session, HttpServletRequest request, String attribute) {
        if (session == null) {
            return;
        }
        Object value = session.getAttribute(attribute);
        if (value != null) {
            request.setAttribute(attribute, value);
            session.removeAttribute(attribute);
        }
    }

    private Double fetchWalletBalance(int userId) {
        Double balance = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement("SELECT balance FROM wallets WHERE user_id = ? LIMIT 1")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        java.math.BigDecimal amount = rs.getBigDecimal("balance");
                        if (amount != null) {
                            balance = amount.doubleValue();
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return balance;
    }
}
