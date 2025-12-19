import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/SupportTicket")
public class SupportTicketServlet extends HttpServlet {

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
        moveFlash(session, request);
        request.getRequestDispatcher("SupportTicket.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;
        if (userId == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        String subject = trim(request.getParameter("subject"));
        String category = trim(request.getParameter("category"));
        String description = trim(request.getParameter("description"));

        List<String> errors = new ArrayList<>();
        if (isBlank(subject)) {
            errors.add("Subject is required.");
        }
        if (isBlank(category)) {
            errors.add("Please choose a category.");
        }
        if (isBlank(description)) {
            errors.add("Description cannot be empty.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("validationErrors", errors);
            request.setAttribute("categoryValue", category);
            request.setAttribute("subjectValue", subject);
            request.setAttribute("descriptionValue", description);
            request.getRequestDispatcher("SupportTicket.jsp").forward(request, response);
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            errors.add("Database driver is not available.");
            request.setAttribute("validationErrors", errors);
            request.setAttribute("categoryValue", category);
            request.getRequestDispatcher("SupportTicket.jsp").forward(request, response);
            return;
        }

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement ps = conn.prepareStatement(
                     "INSERT INTO support_tickets (user_id, subject, category, description) VALUES (?, ?, ?, ?)")) {
            ps.setInt(1, userId);
            ps.setString(2, subject);
            ps.setString(3, category);
            ps.setString(4, description);
            ps.executeUpdate();
            session.setAttribute("supportStatus", "success");
            session.setAttribute("supportMessage", "Support ticket submitted successfully.");
            response.sendRedirect("SupportTicket");
        } catch (SQLException e) {
            e.printStackTrace();
            errors.add("Failed to submit support ticket. Please try again.");
            request.setAttribute("validationErrors", errors);
            request.setAttribute("categoryValue", category);
            request.getRequestDispatcher("SupportTicket.jsp").forward(request, response);
        }
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

