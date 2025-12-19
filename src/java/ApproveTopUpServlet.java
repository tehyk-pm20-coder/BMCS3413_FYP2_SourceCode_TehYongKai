import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/ApproveTopUpServlet")
public class ApproveTopUpServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int topupId = Integer.parseInt(request.getParameter("topupId"));

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);

            
            PreparedStatement get = conn.prepareStatement(
                "SELECT user_id, amount FROM wallet_topup WHERE id=? AND status='PENDING'"
            );
            get.setInt(1, topupId);
            ResultSet rs = get.executeQuery();

            if (!rs.next()) {
                response.getWriter().println("Invalid or already approved top-up.");
                return;
            }

            int userId = rs.getInt("user_id");
            double amount = rs.getDouble("amount");

            rs.close();
            get.close();

            
            PreparedStatement updateBal = conn.prepareStatement(
                "UPDATE wallets SET balance = balance + ? WHERE user_id = ?"
            );
            updateBal.setDouble(1, amount);
            updateBal.setInt(2, userId);
            updateBal.executeUpdate();
            updateBal.close();

            
            PreparedStatement updateStatus = conn.prepareStatement(
                "UPDATE wallet_topup SET status='APPROVED' WHERE id=?"
            );
            updateStatus.setInt(1, topupId);
            updateStatus.executeUpdate();
            updateStatus.close();

            conn.close();

            request.setAttribute("approvedUserId", userId);
            request.setAttribute("approvedAmount", amount);
            request.getRequestDispatcher("TopUpApprovalSuccess.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Approval failed: " + e.getMessage());
        }
    }
}
