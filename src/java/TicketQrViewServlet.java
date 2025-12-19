import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.UserTicketView;

@WebServlet("/TicketQrView")
public class TicketQrViewServlet extends HttpServlet {

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

        String ticketIdParam = request.getParameter("ticketId");
        if (ticketIdParam == null) {
            response.sendRedirect("MyTickets");
            return;
        }

        int ticketId;
        try {
            ticketId = Integer.parseInt(ticketIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("MyTickets");
            return;
        }

        UserTicketView ticket = fetchTicket(userId, ticketId);
        if (ticket == null) {
            request.setAttribute("error", "Ticket not found or not owned by you.");
        }
        request.setAttribute("ticket", ticket);
        request.getRequestDispatcher("TicketQrView.jsp").forward(request, response);
    }

    private UserTicketView fetchTicket(int userId, int ticketId) {
        UserTicketView view = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement(
                         "SELECT t.ticket_id, t.event_id, t.event_name, t.seat_type, t.price, t.status, "
                         + "e.event_date, e.venue "
                         + "FROM tickets t "
                         + "LEFT JOIN events e ON t.event_id = e.event_id "
                         + "WHERE t.ticket_id = ? AND t.user_id = ?")) {
                ps.setInt(1, ticketId);
                ps.setInt(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        view = new UserTicketView();
                        view.setTicketId(rs.getInt("ticket_id"));
                        view.setEventId(rs.getInt("event_id"));
                        view.setEventName(rs.getString("event_name"));
                        view.setSeatType(rs.getString("seat_type"));
                        view.setPrice(rs.getDouble("price"));
                        view.setTicketStatus(rs.getString("status"));
                        view.setEventDate(rs.getTimestamp("event_date"));
                        view.setVenue(rs.getString("venue"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return view;
    }
}
