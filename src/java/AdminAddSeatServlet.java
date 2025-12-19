import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AdminAddSeatServlet")
public class AdminAddSeatServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        int eventId = Integer.parseInt(request.getParameter("eventId"));
        String seatType = request.getParameter("seatType");
        double price = Double.parseDouble(request.getParameter("price"));
        int totalQty = Integer.parseInt(request.getParameter("totalQty"));

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);

            PreparedStatement stmt = conn.prepareStatement(
                "INSERT INTO event_seats (event_id, seat_type, price, total_qty, remaining_qty) VALUES (?, ?, ?, ?, ?)"
            );

            stmt.setInt(1, eventId);
            stmt.setString(2, seatType);
            stmt.setDouble(3, price);
            stmt.setInt(4, totalQty);
            stmt.setInt(5, totalQty);

            stmt.executeUpdate();
            stmt.close();
            conn.close();

            // 🎉 SUCCESS MESSAGE
            session.setAttribute("eventAdminMessage",
                    "Seat type \"" + seatType + "\" added successfully to event ID " + eventId + "!");

            response.sendRedirect("AdminManageEventServlet");

        } catch (Exception e) {
            e.printStackTrace();

            session.setAttribute("eventAdminMessage",
                    "Failed to add seat type: " + e.getMessage());

            response.sendRedirect("AdminManageEventServlet");
        }
    }
}
