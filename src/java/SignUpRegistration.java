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

@WebServlet("/SignUpRegistration")
public class SignUpRegistration extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        String fullname = trimParam(request.getParameter("fullname"));
        String phone = trimParam(request.getParameter("phone"));
        String email = trimParam(request.getParameter("email"));
        String dob = trimParam(request.getParameter("dob"));
        String password = request.getParameter("password");

        List<String> validationErrors =
                ValidationUtils.validateSignup(fullname, email, password, dob, phone);
        if (!validationErrors.isEmpty()) {
            forwardWithErrors(request, response, validationErrors);
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            forwardWithServerError(request, response, "Database driver not found.");
            return;
        }

        try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD)) {

            if (emailExists(con, email)) {
                forwardWithErrors(request, response,
                        Collections.singletonList("An account with this email already exists."));
                return;
            }

            String sql = "INSERT INTO users (fullname, phone, email, dob, password) VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement pst = con.prepareStatement(sql)) {
                pst.setString(1, fullname);
                pst.setString(2, phone);
                pst.setString(3, email);
                pst.setString(4, dob);
                pst.setString(5, password);

                int row = pst.executeUpdate();
                if (row > 0) {
                    request.setAttribute("successMessage",
                            "Your account has been created successfully. You can now log in.");
                    request.getRequestDispatcher("Signup.jsp").forward(request, response);
                } else {
                    forwardWithServerError(request, response, "Registration failed. Please try again.");
                }
            }

        } catch (SQLException e) {
            forwardWithServerError(request, response, "Unable to complete registration at the moment. Please try again later.");
            e.printStackTrace();
        }
    }

    private boolean emailExists(Connection con, String email) throws SQLException {
        String query = "SELECT 1 FROM users WHERE email = ?";
        try (PreparedStatement pst = con.prepareStatement(query)) {
            pst.setString(1, email);
            try (ResultSet rs = pst.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void forwardWithErrors(HttpServletRequest request,
                                   HttpServletResponse response,
                                   List<String> errors) throws ServletException, IOException {
        request.setAttribute("errors", errors);
        request.getRequestDispatcher("Signup.jsp").forward(request, response);
    }

    private void forwardWithServerError(HttpServletRequest request,
                                        HttpServletResponse response,
                                        String message) throws ServletException, IOException {
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("Signup.jsp").forward(request, response);
    }

    private String trimParam(String value) {
        return value == null ? null : value.trim();
    }
}
