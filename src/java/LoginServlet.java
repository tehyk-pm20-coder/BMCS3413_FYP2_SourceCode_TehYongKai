
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        String email = trimParam(request.getParameter("email"));
        String password = request.getParameter("password");

        List<String> validationErrors = ValidationUtils.validateLogin(email, password);
        if (!validationErrors.isEmpty()) {
            respondWithErrors(request, response, validationErrors, "Login.jsp");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            respondWithServerError(request, response, "Database driver not found.");
            return;
        }

        String sql = "SELECT id, role, fullname FROM users WHERE email = ? AND password = ?";

        try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
             PreparedStatement pst = con.prepareStatement(sql)) {

            pst.setString(1, email);
            pst.setString(2, password);

            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    String userRole = rs.getString("role");
                    String fullname = rs.getString("fullname");

                    HttpSession session = request.getSession();
                    session.setAttribute("userId", userId);
                    session.setAttribute("userRole", userRole);
                    session.setAttribute("userFullname", fullname);

                    response.sendRedirect("MainPage.jsp");
                } else {
                    respondWithErrors(request, response,
                            Collections.singletonList("Invalid email or password. Please try again."),
                            "Login.jsp");
                }
            }

        } catch (SQLException e) {
            respondWithServerError(request, response, "Unable to complete login at the moment. Please try again later.");
            e.printStackTrace();
        }
    }

    private void respondWithErrors(HttpServletRequest request,
                                   HttpServletResponse response,
                                   List<String> errors,
                                   String backLink) throws IOException, ServletException {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        request.setAttribute("errorMessages", errors);
        request.setAttribute("backLink", backLink);
        request.getRequestDispatcher("LoginFailed.jsp").forward(request, response);
    }

    private void respondWithServerError(HttpServletRequest request,
                                        HttpServletResponse response,
                                        String message) throws IOException, ServletException {
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        request.setAttribute("serverMessage", message);
        request.setAttribute("backLink", "Login.jsp");
        request.getRequestDispatcher("LoginFailed.jsp").forward(request, response);
    }

    private String trimParam(String value) {
        return value == null ? null : value.trim();
    }
}


