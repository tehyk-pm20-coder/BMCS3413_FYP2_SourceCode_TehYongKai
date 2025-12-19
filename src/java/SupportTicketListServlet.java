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
import model.SupportTicket;

@WebServlet("/SupportTicketList")
public class SupportTicketListServlet extends HttpServlet {

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

        request.setAttribute("userTickets", fetchTicketsForUser(userId));
        request.getRequestDispatcher("SupportTicketList.jsp").forward(request, response);
    }

    private List<SupportTicket> fetchTicketsForUser(int userId) {
        List<SupportTicket> tickets = new ArrayList<>();
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return tickets;
        }
        String sql = "SELECT ticket_id, subject, category, status, description, admin_reply, created_at, updated_at "
                + "FROM support_tickets WHERE user_id=? ORDER BY created_at DESC";
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    SupportTicket ticket = new SupportTicket();
                    ticket.setTicketId(rs.getInt("ticket_id"));
                    ticket.setUserId(userId);
                    ticket.setSubject(rs.getString("subject"));
                    ticket.setCategory(rs.getString("category"));
                    ticket.setStatus(rs.getString("status"));
                    ticket.setDescription(rs.getString("description"));
                    ticket.setAdminReply(rs.getString("admin_reply"));
                    ticket.setCreatedAt(rs.getTimestamp("created_at"));
                    ticket.setUpdatedAt(rs.getTimestamp("updated_at"));
                    tickets.add(ticket);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }
}

