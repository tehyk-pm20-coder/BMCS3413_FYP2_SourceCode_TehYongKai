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

@WebServlet("/AdminSupportTickets")
public class AdminSupportTicketServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            response.sendRedirect("Login.jsp");
            return;
        }

        request.setAttribute("allTickets", fetchAllTickets());
        moveFlash(session, request);
        request.getRequestDispatcher("AdminSupportTickets.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String ticketIdStr = request.getParameter("ticketId");
        String status = trim(request.getParameter("status"));
        String adminReply = trim(request.getParameter("adminReply"));

        List<String> errors = new ArrayList<>();
        int ticketId = 0;
        try {
            ticketId = Integer.parseInt(ticketIdStr);
        } catch (NumberFormatException e) {
            errors.add("Invalid ticket identifier.");
        }
        if (isBlank(status)) {
            errors.add("Status is required.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("validationErrors", errors);
            request.setAttribute("allTickets", fetchAllTickets());
            request.getRequestDispatcher("AdminSupportTickets.jsp").forward(request, response);
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            errors.add("Database driver not available.");
            request.setAttribute("validationErrors", errors);
            request.setAttribute("allTickets", fetchAllTickets());
            request.getRequestDispatcher("AdminSupportTickets.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE support_tickets SET status=?, admin_reply=? WHERE ticket_id=?")) {
            ps.setString(1, status);
            ps.setString(2, adminReply);
            ps.setInt(3, ticketId);
            int rows = ps.executeUpdate();
            if (rows > 0) {
                session.setAttribute("supportStatus", "success");
                session.setAttribute("supportMessage", "Ticket updated successfully.");
            } else {
                session.setAttribute("supportStatus", "error");
                session.setAttribute("supportMessage", "Ticket not found.");
            }
            response.sendRedirect("AdminSupportTickets");
        } catch (SQLException e) {
            e.printStackTrace();
            errors.add("Unable to update ticket.");
            request.setAttribute("validationErrors", errors);
            request.setAttribute("allTickets", fetchAllTickets());
            request.getRequestDispatcher("AdminSupportTickets.jsp").forward(request, response);
        }
    }

    private List<SupportTicket> fetchAllTickets() {
        List<SupportTicket> tickets = new ArrayList<>();
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return tickets;
        }
        String sql = "SELECT st.ticket_id, st.user_id, st.subject, st.category, st.status, "
                + "st.description, st.admin_reply, st.created_at, st.updated_at, u.fullname "
                + "FROM support_tickets st JOIN users u ON st.user_id = u.id "
                + "ORDER BY st.created_at DESC";
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                SupportTicket ticket = new SupportTicket();
                ticket.setTicketId(rs.getInt("ticket_id"));
                ticket.setUserId(rs.getInt("user_id"));
                ticket.setSubject(rs.getString("subject"));
                ticket.setCategory(rs.getString("category"));
                ticket.setStatus(rs.getString("status"));
                ticket.setDescription(rs.getString("description"));
                ticket.setAdminReply(rs.getString("admin_reply"));
                ticket.setCreatedAt(rs.getTimestamp("created_at"));
                ticket.setUpdatedAt(rs.getTimestamp("updated_at"));
                ticket.setUserName(rs.getString("fullname"));
                tickets.add(ticket);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    private boolean isAdmin(HttpSession session) {
        if (session == null) {
            return false;
        }
        String role = (String) session.getAttribute("userRole");
        return role != null && "admin".equalsIgnoreCase(role);
    }

    private void moveFlash(HttpSession session, HttpServletRequest request) {
        if (session == null) {
            return;
        }
        Object status = session.getAttribute("supportStatus");
        Object message = session.getAttribute("supportMessage");
        if (message != null) {
            request.setAttribute("supportStatus", status);
            request.setAttribute("supportMessage", message);
            session.removeAttribute("supportStatus");
            session.removeAttribute("supportMessage");
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}

