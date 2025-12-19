
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.security.PrivateKey;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.Event;
import model.SeatType;


@WebServlet("/TicketPurchaseServlet")
public class TicketPurchaseServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        Double walletBalance = null;
        if (userId != null) {
            walletBalance = fetchWalletBalance(userId);
        }
        request.setAttribute("walletBalance", walletBalance);

        String eventIdParam = request.getParameter("eventId");

        if (eventIdParam == null) {
            request.setAttribute("message", "Missing event identifier.");
            request.getRequestDispatcher("TicketPurchase.jsp").forward(request, response);
            return;
        }

        List<SeatType> seatTypes = new ArrayList<>();
        boolean salesClosed = false;

        try {
            int eventId = Integer.parseInt(eventIdParam);

            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD); PreparedStatement stmt = conn.prepareStatement(
                    "SELECT event_id, event_name, venue, event_date, status, event_image "
                    + "FROM events WHERE event_id = ?"); PreparedStatement seatStmt = conn.prepareStatement(
                            "SELECT seat_type_id, event_id, seat_type, price, total_qty, remaining_qty "
                            + "FROM event_seats WHERE event_id = ? ORDER BY seat_type_id ASC")) {

                stmt.setInt(1, eventId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        Event ev = new Event();
                        ev.setEventId(rs.getInt("event_id"));
                        ev.setEventName(rs.getString("event_name"));
                        ev.setVenue(rs.getString("venue"));
                        ev.setEventDate(rs.getTimestamp("event_date"));
                        ev.setStatus(rs.getString("status"));
                        ev.setImagePath(Objects.toString(rs.getString("event_image"), null));

                        salesClosed = "CLOSED".equalsIgnoreCase(ev.getStatus());
                        request.setAttribute("salesClosed", salesClosed);
                        request.setAttribute("event", ev);
                    } else {
                        request.setAttribute("message", "Event not found or no longer available.");
                    }
                }

                seatStmt.setInt(1, eventId);
                try (ResultSet seatRs = seatStmt.executeQuery()) {
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
            }
        } catch (NumberFormatException nfe) {
            request.setAttribute("message", "Invalid event identifier.");
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Unable to load event information.");
        }

        if (session != null) {
            String purchaseMessage = (String) session.getAttribute("purchaseMessage");
            if (purchaseMessage != null) {
                request.setAttribute("purchaseMessage", purchaseMessage);
                request.setAttribute("purchaseStatus", session.getAttribute("purchaseStatus"));
                session.removeAttribute("purchaseMessage");
                session.removeAttribute("purchaseStatus");
            }
        }

        request.setAttribute("seatTypes", seatTypes);
        request.setAttribute("salesClosed", salesClosed);
        request.getRequestDispatcher("TicketPurchase.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String eventIdParam = request.getParameter("eventId");
        String seatTypeIdParam = request.getParameter("seatTypeId");

        int userId = (Integer) session.getAttribute("userId");
        int eventId;
        int seatTypeId;

        try {
            eventId = Integer.parseInt(eventIdParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("EventListServlet");
            return;
        }

        String identityStatus = fetchIdentityStatus(userId);
        if (identityStatus == null || !"VERIFIED".equalsIgnoreCase(identityStatus)) {
            setIdentityRedirectFlash(session);
            response.sendRedirect("UserIdentityUpload");
            return;
        }

        try {
            seatTypeId = Integer.parseInt(seatTypeIdParam);
        } catch (NumberFormatException e) {
            setPurchaseFlash(session, "error", "Please select a valid seat type.");
            response.sendRedirect("TicketPurchaseServlet?eventId=" + eventId);
            return;
        }

        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
            conn.setAutoCommit(false);

            if (!TicketBlockchain.isChainValid()) {
                conn.rollback();
                setPurchaseFlash(session, "error", "Blockchain integrity check failed. Please try again.");
                response.sendRedirect("TicketPurchaseServlet?eventId=" + eventId);
                return;
            }

            double seatPrice;
            int remainingQty;
            String seatLabel;
            String eventName;
            String eventStatus;

            try (PreparedStatement seatStmt = conn.prepareStatement(
                    "SELECT s.seat_type, s.price, s.remaining_qty, e.event_name, e.status "
                    + "FROM event_seats s JOIN events e ON s.event_id = e.event_id "
                    + "WHERE s.seat_type_id=? AND s.event_id=? FOR UPDATE")) {
                seatStmt.setInt(1, seatTypeId);
                seatStmt.setInt(2, eventId);
                try (ResultSet seatRs = seatStmt.executeQuery()) {
                    if (!seatRs.next()) {
                        conn.rollback();
                        setPurchaseFlash(session, "error", "Seat type could not be found for this event.");
                        response.sendRedirect("TicketPurchaseServlet?eventId=" + eventId);
                        return;
                    }
                    seatLabel = seatRs.getString("seat_type");
                    seatPrice = seatRs.getDouble("price");
                    remainingQty = seatRs.getInt("remaining_qty");
                    eventName = seatRs.getString("event_name");
                    eventStatus = seatRs.getString("status");
                }
            }

            if ("CLOSED".equalsIgnoreCase(eventStatus)) {
                conn.rollback();
                setPurchaseFlash(session, "error", "Ticket sales for this event are closed.");
                response.sendRedirect("TicketPurchaseServlet?eventId=" + eventId);
                return;
            }

            if (remainingQty < 1) {
                conn.rollback();
                setPurchaseFlash(session, "error", "This seat type is sold out.");
                response.sendRedirect("TicketPurchaseServlet?eventId=" + eventId);
                return;
            }

            int walletId;
            double currentBalance;
            try (PreparedStatement walletStmt = conn.prepareStatement(
                    "SELECT wallet_id, balance FROM wallets WHERE user_id=? FOR UPDATE")) {
                walletStmt.setInt(1, userId);
                try (ResultSet walletRs = walletStmt.executeQuery()) {
                    if (!walletRs.next()) {
                        conn.rollback();
                        setPurchaseFlash(session, "error", "Please create a wallet before purchasing tickets.");
                        response.sendRedirect("TicketPurchaseServlet?eventId=" + eventId);
                        return;
                    }
                    walletId = walletRs.getInt("wallet_id");
                    currentBalance = walletRs.getDouble("balance");
                }
            }
            double totalCost = seatPrice;
            if (currentBalance < totalCost) {
                conn.rollback();
                setPurchaseFlash(session, "error", "Insufficient wallet balance for this purchase.");
                response.sendRedirect("TicketPurchaseServlet?eventId=" + eventId);
                return;
            }

            try (PreparedStatement updateSeats = conn.prepareStatement(
                    "UPDATE event_seats SET remaining_qty = remaining_qty - 1 WHERE seat_type_id=?")) {
                updateSeats.setInt(1, seatTypeId);
                updateSeats.executeUpdate();
            }

            try (PreparedStatement updateWallet = conn.prepareStatement(
                    "UPDATE wallets SET balance = balance - ? WHERE wallet_id=?")) {
                updateWallet.setDouble(1, totalCost);
                updateWallet.setInt(2, walletId);
                updateWallet.executeUpdate();
            }

            int ticketId = -1;

            try (PreparedStatement insertTicket = conn.prepareStatement(
                    "INSERT INTO tickets (user_id, event_id, event_name, seat_type, price, status, block_hash, purchase_time) "
                    + "VALUES (?, ?, ?, ?, ?, 'ACTIVE', ?, NOW())",
                    Statement.RETURN_GENERATED_KEYS)) {

                insertTicket.setInt(1, userId);
                insertTicket.setInt(2, eventId);
                insertTicket.setString(3, eventName);
                insertTicket.setString(4, seatLabel);
                insertTicket.setDouble(5, seatPrice);
                insertTicket.setString(6, "pending-block");

                insertTicket.executeUpdate();

                ResultSet rsKeys = insertTicket.getGeneratedKeys();
                if (rsKeys.next()) {
                    ticketId = rsKeys.getInt(1);
                }
            }

            if (ticketId <= 0) {
                throw new SQLException("Failed to create ticket record.");
            }

            TicketBlock newBlock = TicketBlockchain.appendBlock(conn, ticketId);

            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE tickets SET block_hash=? WHERE ticket_id=?")) {

                ps.setString(1, newBlock.getBlockHash());
                ps.setInt(2, ticketId);
                ps.executeUpdate();
            }

            conn.commit();
            setPurchaseFlash(session, "success",
                    String.format("Successfully purchased 1 × %s seat for RM %.2f. Enjoy the show!", seatLabel, totalCost));
            response.sendRedirect("TicketPurchaseServlet?eventId=" + eventId);

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            setPurchaseFlash(session, "error", "Ticket purchase failed. Please try again.");
            response.sendRedirect("TicketPurchaseServlet?eventId=" + eventId);
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    private void setPurchaseFlash(HttpSession session, String status, String message) {
        if (session != null) {
            session.setAttribute("purchaseStatus", status);
            session.setAttribute("purchaseMessage", message);
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

    private String fetchIdentityStatus(int userId) {
        String status = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                 PreparedStatement ps = conn.prepareStatement("SELECT identity_status FROM users WHERE id = ? LIMIT 1")) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        status = rs.getString("identity_status");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return status;
    }

    private void setIdentityRedirectFlash(HttpSession session) {
        if (session == null) {
            return;
        }
        session.setAttribute("identityStatus", "error");
        session.setAttribute("identityMessage", "Please complete identity verification to continue.");
    }
}
