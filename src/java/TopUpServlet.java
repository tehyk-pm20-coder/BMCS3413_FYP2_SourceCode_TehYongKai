
import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/TopUpServlet")
public class TopUpServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.getWriter().println("Error: User not logged in.");
            return;
        }

        double amount = Double.parseDouble(request.getParameter("amount"));

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);

            PreparedStatement stmt = conn.prepareStatement(
                    "INSERT INTO wallet_topup (user_id, amount, status) VALUES (?, ?, 'PENDING')"
            );
            stmt.setInt(1, userId);
            stmt.setDouble(2, amount);
            stmt.executeUpdate();

            stmt.close();
            conn.close();

            // Store success message for wallet.jsp
            session.setAttribute("topupMessage", "Top-up request submitted! Waiting for admin approval.");

            // Redirect back to wallet.jsp
            response.sendRedirect("WalletServlet");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Top-up failed: " + e.getMessage());
            response.sendRedirect("WalletServlet");

        }
    }
}
