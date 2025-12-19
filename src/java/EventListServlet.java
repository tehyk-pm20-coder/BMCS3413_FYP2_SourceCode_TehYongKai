import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.RequestDispatcher;
import model.Event;

@WebServlet("/EventListServlet")
public class EventListServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Event> events = new ArrayList<>();
        String message = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                    PreparedStatement stmt = conn.prepareStatement(
                            "SELECT event_id, event_name, venue, event_date, status, event_image FROM events ORDER BY event_date ASC");
                    ResultSet rs = stmt.executeQuery()) {

                while (rs.next()) {
                    Event ev = new Event();
                    ev.setEventId(rs.getInt("event_id"));
                    ev.setEventName(rs.getString("event_name"));
                    ev.setVenue(rs.getString("venue"));
                    ev.setEventDate(rs.getTimestamp("event_date"));
                    ev.setStatus(rs.getString("status"));
                    ev.setImagePath(rs.getString("event_image"));
                    events.add(ev);
                }
            }

            if (events.isEmpty()) {
                message = "No events available at the moment.";
            }

        } catch (Exception e) {
            e.printStackTrace();
            message = "Unable to load events at this time.";
        }



        HttpSession session = request.getSession(false);
        if (session != null) {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId != null) {
                request.setAttribute("walletBalance", fetchWalletBalance(userId));
            }
        }

        request.setAttribute("events", events);
        request.setAttribute("message", message);

        RequestDispatcher rd = request.getRequestDispatcher("ViewConcert.jsp");
        rd.forward(request, response);
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
