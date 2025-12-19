import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import model.UserIdentity;

@WebServlet("/AdminUserIdentity")
public class AdminUserIdentityServlet extends HttpServlet {

    private static final String STATUS_APPROVED = "APPROVED";
    private static final String STATUS_REJECTED = "REJECTED";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            response.sendRedirect("Login.jsp");
            return;
        }
        moveFlash(session, request);
        List<UserIdentity> identities = UserIdentityDAO.findAll();
        request.setAttribute("identityList", identities);
        request.setAttribute("identityStats", buildStats(identities));
        request.getRequestDispatcher("AdminUserIdentityList.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            response.sendRedirect("Login.jsp");
            return;
        }

        Integer adminId = (Integer) session.getAttribute("userId");
        String identityIdParam = request.getParameter("identityId");
        String action = request.getParameter("action");
        List<String> errors = new ArrayList<>();

        int identityId = parseId(identityIdParam, errors);
        String status = normalizeStatus(action, errors);

        if (!errors.isEmpty()) {
            session.setAttribute("identityAdminStatus", "error");
            session.setAttribute("identityAdminMessage", String.join(" ", errors));
            response.sendRedirect("AdminUserIdentity");
            return;
        }

        try {
            UserIdentityDAO.updateStatus(identityId, status, adminId);
            session.setAttribute("identityAdminStatus", "success");
            session.setAttribute("identityAdminMessage", "Identity request updated successfully.");
        } catch (SQLException e) {
            e.printStackTrace();
            session.setAttribute("identityAdminStatus", "error");
            session.setAttribute("identityAdminMessage", "Unable to update the selected request.");
        }
        response.sendRedirect("AdminUserIdentity");
    }

    private Map<String, Long> buildStats(List<UserIdentity> identities) {
        Map<String, Long> stats = new HashMap<>();
        stats.put("PENDING", 0L);
        stats.put("APPROVED", 0L);
        stats.put("REJECTED", 0L);
        if (identities == null) {
            return stats;
        }
        for (UserIdentity identity : identities) {
            String status = identity.getStatus() != null ? identity.getStatus() : "PENDING";
            stats.put(status, stats.getOrDefault(status, 0L) + 1);
        }
        return stats;
    }

    private boolean isAdmin(HttpSession session) {
        if (session == null) {
            return false;
        }
        String role = (String) session.getAttribute("userRole");
        return role != null && "admin".equalsIgnoreCase(role);
    }

    private void moveFlash(HttpSession session, HttpServletRequest request) {
        if (session == null) {
            return;
        }
        Object status = session.getAttribute("identityAdminStatus");
        Object message = session.getAttribute("identityAdminMessage");
        if (message != null) {
            request.setAttribute("identityAdminStatus", status);
            request.setAttribute("identityAdminMessage", message);
            session.removeAttribute("identityAdminStatus");
            session.removeAttribute("identityAdminMessage");
        }
    }

    private int parseId(String param, List<String> errors) {
        try {
            return Integer.parseInt(param);
        } catch (NumberFormatException e) {
            errors.add("Invalid identity request selected.");
            return 0;
        }
    }

    private String normalizeStatus(String action, List<String> errors) {
        if (STATUS_APPROVED.equalsIgnoreCase(action)) {
            return STATUS_APPROVED;
        }
        if (STATUS_REJECTED.equalsIgnoreCase(action)) {
            return STATUS_REJECTED;
        }
        errors.add("Please choose a valid action.");
        return null;
    }

}
