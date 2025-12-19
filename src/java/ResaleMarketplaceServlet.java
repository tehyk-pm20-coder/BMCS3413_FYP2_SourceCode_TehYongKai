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
import javax.servlet.http.HttpSession;
import model.ResaleListingView;

@WebServlet("/ResaleMarketplace")
public class ResaleMarketplaceServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<ResaleListingView> listings = new ArrayList<>();
        String fallbackMessage = null;
        HttpSession session = request.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        Double walletBalance = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(
                         "SELECT rl.listing_id, rl.ticket_id, rl.event_id, rl.seller_id, rl.seat_type, "
                         + "rl.original_price, rl.listing_price, rl.created_at, "
                         + "e.event_name, e.event_date, e.venue, "
                         + "u.fullname AS seller_name "
                         + "FROM ticket_resale_listings rl "
                         + "JOIN tickets t ON rl.ticket_id = t.ticket_id "
                         + "JOIN events e ON rl.event_id = e.event_id "
                         + "JOIN users u ON rl.seller_id = u.id "
                         + "WHERE rl.status = 'LISTED' AND t.status <> 'REJECT' "
                         + "ORDER BY e.event_date ASC, rl.created_at ASC")) {

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        ResaleListingView view = new ResaleListingView();
                        view.setListingId(rs.getInt("listing_id"));
                        view.setTicketId(rs.getInt("ticket_id"));
                        view.setEventId(rs.getInt("event_id"));
                        view.setSellerId(rs.getInt("seller_id"));
                        view.setSeatType(rs.getString("seat_type"));
                        view.setOriginalPrice(rs.getDouble("original_price"));
                        view.setListingPrice(rs.getDouble("listing_price"));
                        view.setCreatedAt(rs.getTimestamp("created_at"));
                        view.setEventName(rs.getString("event_name"));
                        view.setEventDate(rs.getTimestamp("event_date"));
                        view.setVenue(rs.getString("venue"));
                        view.setSellerName(rs.getString("seller_name"));
                        listings.add(view);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            fallbackMessage = "Unable to load marketplace listings. Please try again later.";
        }

        if (userId != null) {
            walletBalance = fetchWalletBalance(userId);
        }

        moveFlashAttribute(session, request, "marketStatus");
        moveFlashAttribute(session, request, "marketMessage");

        if (fallbackMessage != null) {
            request.setAttribute("fallbackMessage", fallbackMessage);
        }
        request.setAttribute("walletBalance", walletBalance);
        request.setAttribute("marketListings", listings);
        request.getRequestDispatcher("ResaleMarketplace.jsp").forward(request, response);
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
