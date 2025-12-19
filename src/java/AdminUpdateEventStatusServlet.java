import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/AdminUpdateEventStatusServlet")
public class AdminUpdateEventStatusServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String eventIdParam = request.getParameter("eventId");
        String status = request.getParameter("status");

        if (eventIdParam == null || status == null) {
            session.setAttribute("eventAdminMessage", "Invalid request. Please try again.");
            response.sendRedirect("AdminManageEventServlet");
            return;
        }

        try {
            int eventId = Integer.parseInt(eventIdParam);
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                    PreparedStatement stmt = conn.prepareStatement("UPDATE events SET status=? WHERE event_id=?")) {
                stmt.setString(1, status);
                stmt.setInt(2, eventId);
                int updated = stmt.executeUpdate();
                if (updated > 0) {
                    session.setAttribute("eventAdminMessage", "Event #" + eventId + " status updated to " + status + ".");
                } else {
                    session.setAttribute("eventAdminMessage", "No event updated. It may have been removed.");
                }
            }
        } catch (NumberFormatException nfe) {
            session.setAttribute("eventAdminMessage", "Invalid event identifier.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("eventAdminMessage", "Failed to update event: " + e.getMessage());
        }

        response.sendRedirect("AdminManageEventServlet");
    }
}
