import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/AdminCreateEventServlet")
@MultipartConfig
public class AdminCreateEventServlet extends HttpServlet {

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/fyp";
    private static final String JDBC_USER = "root";
    private static final String JDBC_PASSWORD = "";

    private static final Path UPLOAD_ROOT = Paths.get("C:", "FYPUploads", "event_images");
    private static final Path CONTEXT_IMAGE_DIR = Paths.get("C:", "Users", "User", "Documents", "NetBeansProjects", "FYPProject", "web", "event_images");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String eventName = request.getParameter("eventName");
        String venue = request.getParameter("venue");
        String eventDate = request.getParameter("eventDate");

        Part filePart = request.getPart("eventImage");

        // Guard against null/empty uploads
        if (filePart == null || filePart.getSize() == 0) {
            session.setAttribute("eventMessage", "Please select an image to upload.");
            response.sendRedirect("AdminCreateEvent.jsp");
            return;
        }

        try {
            Files.createDirectories(UPLOAD_ROOT); // ensure directory exists

            String originalName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String storedFileName = System.currentTimeMillis() + "_" + originalName;
            Path destination = UPLOAD_ROOT.resolve(storedFileName);

            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, destination, StandardCopyOption.REPLACE_EXISTING);
            }

            Files.createDirectories(CONTEXT_IMAGE_DIR);
            Path contextDestination = CONTEXT_IMAGE_DIR.resolve(storedFileName);
            Files.copy(destination, contextDestination, StandardCopyOption.REPLACE_EXISTING);

            String imagePath = "event_images/" + storedFileName;

            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
                    PreparedStatement stmt = conn.prepareStatement(
                            "INSERT INTO events (event_name, venue, event_date, status, event_image) VALUES (?, ?, ?, 'OPEN', ?)")) {

                stmt.setString(1, eventName);
                stmt.setString(2, venue);
                stmt.setString(3, eventDate);
                stmt.setString(4, imagePath);
                stmt.executeUpdate();
            }

            session.setAttribute("eventMessage", "Event created successfully!");
            response.sendRedirect("AdminCreateEvent.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("eventMessage", "Error: " + e.getMessage());
            response.sendRedirect("AdminCreateEvent.jsp");
        }
    }
}
