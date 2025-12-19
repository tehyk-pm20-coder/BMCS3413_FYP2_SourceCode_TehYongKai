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
import model.Event;
import model.SeatType;

@WebServlet("/AdminManageEventServlet")
public class AdminManageEventServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Event> events = new ArrayList<>();
        List<SeatType> seatTypes = new ArrayList<>();
        String message = null;
        String seatMessage = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                    PreparedStatement stmt = conn.prepareStatement(
                            "SELECT event_id, event_name, venue, event_date, status, event_image, created_at "
                            + "FROM events ORDER BY created_at DESC");
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
                message = "No events registered yet.";
            }

            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                    PreparedStatement seatStmt = conn.prepareStatement(
                            "SELECT seat_type_id, event_id, seat_type, price, total_qty, remaining_qty FROM event_seats ORDER BY event_id");
                    ResultSet seatRs = seatStmt.executeQuery()) {

                while (seatRs.next()) {
                    SeatType seat = new SeatType();
                    seat.setSeatTypeId(seatRs.getInt("seat_type_id"));
                    seat.setEventId(seatRs.getInt("event_id"));
                    seat.setSeatType(seatRs.getString("seat_type"));
                    seat.setPrice(seatRs.getDouble("price"));
                    seat.setTotalQty(seatRs.getInt("total_qty"));
                    seat.setRemainingQty(seatRs.getInt("remaining_qty"));
                    seatTypes.add(seat);
                }
            }

            if (seatTypes.isEmpty()) {
                seatMessage = "No seat configurations found.";
            }

        } catch (Exception e) {
            e.printStackTrace();
            message = "Unable to load events right now.";
            seatMessage = "Unable to load seat information right now.";
        }

        request.setAttribute("events", events);
        request.setAttribute("message", message);
        request.setAttribute("seatTypes", seatTypes);
        request.setAttribute("seatMessage", seatMessage);
        request.getRequestDispatcher("AdminManageEvent.jsp").forward(request, response);
    }
}
