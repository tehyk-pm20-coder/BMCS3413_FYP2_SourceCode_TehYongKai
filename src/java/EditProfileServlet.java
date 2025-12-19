import java.io.IOException;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.UserProfile;

@WebServlet("/EditProfile")
public class EditProfileServlet extends HttpServlet {

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

        UserProfile profile = fetchProfile(userId);
        if (profile == null) {
            request.setAttribute("profileError", "Unable to load your profile information.");
        } else {
            request.setAttribute("profile", profile);
        }

        moveFlashMessage(session, request);

        request.getRequestDispatcher("editprofile.jsp").forward(request, response);
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

        String fullname = trim(request.getParameter("fullname"));
        String phone = trim(request.getParameter("phone"));
        String email = trim(request.getParameter("email"));
        String dobParam = trim(request.getParameter("dob"));
        String password = trim(request.getParameter("password"));

        List<String> errors = new ArrayList<>();
        if (isBlank(fullname)) {
            errors.add("Full name is required.");
        }
        if (isBlank(phone)) {
            errors.add("Phone number is required.");
        }
        if (isBlank(email)) {
            errors.add("Email address is required.");
        }

        Date dob = null;
        if (isBlank(dobParam)) {
            errors.add("Date of birth is required.");
        } else {
            try {
                dob = Date.valueOf(LocalDate.parse(dobParam));
            } catch (Exception e) {
                errors.add("Provide a valid date of birth.");
            }
        }

        if (!errors.isEmpty()) {
            request.setAttribute("validationErrors", errors);
            UserProfile formProfile = new UserProfile();
            formProfile.setId(userId);
            formProfile.setFullname(fullname);
            formProfile.setPhone(phone);
            formProfile.setEmail(email);
            formProfile.setDob(dob);
            request.setAttribute("profile", formProfile);
            request.getRequestDispatcher("editprofile.jsp").forward(request, response);
            return;
        }

        boolean updatePassword = !isBlank(password);
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            errors.add("Database driver not available.");
            request.setAttribute("validationErrors", errors);
            request.getRequestDispatcher("editprofile.jsp").forward(request, response);
            return;
        }

        String sql = updatePassword
                ? "UPDATE users SET fullname=?, phone=?, email=?, dob=?, password=? WHERE id=?"
                : "UPDATE users SET fullname=?, phone=?, email=?, dob=? WHERE id=?";

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fullname);
            ps.setString(2, phone);
            ps.setString(3, email);
            ps.setDate(4, dob);
            if (updatePassword) {
                ps.setString(5, password);
                ps.setInt(6, userId);
            } else {
                ps.setInt(5, userId);
            }
            ps.executeUpdate();

            session.setAttribute("userFullname", fullname);
            session.setAttribute("profileStatus", "success");
            session.setAttribute("profileMessage", "Profile updated successfully.");
            response.sendRedirect("EditProfile");
        } catch (SQLException e) {
            e.printStackTrace();
            errors.add("Failed to update profile. Please try again.");
            request.setAttribute("validationErrors", errors);
            UserProfile formProfile = new UserProfile();
            formProfile.setId(userId);
            formProfile.setFullname(fullname);
            formProfile.setPhone(phone);
            formProfile.setEmail(email);
            formProfile.setDob(dob);
            request.setAttribute("profile", formProfile);
            request.getRequestDispatcher("editprofile.jsp").forward(request, response);
        }
    }

    private UserProfile fetchProfile(int userId) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }

        String sql = "SELECT fullname, phone, email, dob FROM users WHERE id = ?";
        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    UserProfile profile = new UserProfile();
                    profile.setId(userId);
                    profile.setFullname(rs.getString("fullname"));
                    profile.setPhone(rs.getString("phone"));
                    profile.setEmail(rs.getString("email"));
                    profile.setDob(rs.getDate("dob"));
                    return profile;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private void moveFlashMessage(HttpSession session, HttpServletRequest request) {
        if (session == null) {
            return;
        }
        Object status = session.getAttribute("profileStatus");
        Object message = session.getAttribute("profileMessage");
        if (message != null) {
            request.setAttribute("profileStatus", status);
            request.setAttribute("profileMessage", message);
            session.removeAttribute("profileStatus");
            session.removeAttribute("profileMessage");
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }
}
