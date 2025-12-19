import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.TransactionHistoryItem;

@WebServlet("/ViewTransactions")
public class ViewTransactionsServlet extends HttpServlet {

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

        List<TransactionHistoryItem> history = new ArrayList<>();
        String fallbackMessage = null;

        String sql = "SELECT rl.listing_id, rl.ticket_id, rl.event_id, rl.seat_type, rl.original_price, "
                + "rl.listing_price, rl.status, rl.created_at, rl.sold_at, rl.seller_id, rl.buyer_id, "
                + "e.event_name, e.event_date, e.venue, "
                + "seller.fullname AS seller_name, buyer.fullname AS buyer_name "
                + "FROM ticket_resale_listings rl "
                + "JOIN events e ON rl.event_id = e.event_id "
                + "LEFT JOIN users seller ON rl.seller_id = seller.id "
                + "LEFT JOIN users buyer ON rl.buyer_id = buyer.id "
                + "WHERE rl.status = 'SOLD' AND (rl.seller_id = ? OR rl.buyer_id = ?) "
                + "ORDER BY COALESCE(rl.sold_at, rl.created_at) DESC, rl.listing_id DESC";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(sql)) {

                ps.setInt(1, userId);
                ps.setInt(2, userId);

                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        TransactionHistoryItem item = new TransactionHistoryItem();
                        item.setListingId(rs.getInt("listing_id"));
                        item.setTicketId(rs.getInt("ticket_id"));
                        item.setEventId(rs.getInt("event_id"));
                        item.setEventName(rs.getString("event_name"));
                        item.setEventDate(rs.getTimestamp("event_date"));
                        item.setVenue(rs.getString("venue"));
                        item.setSeatType(rs.getString("seat_type"));
                        item.setOriginalPrice(rs.getDouble("original_price"));
                        item.setListingPrice(rs.getDouble("listing_price"));
                        item.setStatus(rs.getString("status"));
                        item.setCreatedAt(rs.getTimestamp("created_at"));
                        item.setSoldAt(rs.getTimestamp("sold_at"));
                        item.setSellerName(rs.getString("seller_name"));
                        item.setBuyerName(rs.getString("buyer_name"));

                        Integer sellerId = (Integer) rs.getObject("seller_id");
                        Integer buyerId = (Integer) rs.getObject("buyer_id");
                        item.setSellerView(sellerId != null && sellerId.equals(userId));
                        item.setBuyerView(buyerId != null && buyerId.equals(userId));

                        history.add(item);
                    }
                }
            }
        } catch (Exception e) {
            fallbackMessage = "Unable to load your transaction history right now. Please try again later.";
            e.printStackTrace();
        }

        request.setAttribute("transactions", history);
        if (fallbackMessage != null) {
            request.setAttribute("fallbackMessage", fallbackMessage);
        }
        request.getRequestDispatcher("ViewTransactions.jsp").forward(request, response);
    }
}
