<%@page import="java.util.Map"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="model.UserIdentity"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String userRole = (String) session.getAttribute("userRole");
    if (userId == null || userRole == null || !"admin".equalsIgnoreCase(userRole)) {
        response.sendRedirect("Login.jsp");
        return;
    }
    List<UserIdentity> identities = (List<UserIdentity>) request.getAttribute("identityList");
    Map<String, Long> stats = (Map<String, Long>) request.getAttribute("identityStats");
    String flashMessage = (String) request.getAttribute("identityAdminMessage");
    String flashStatus = (String) request.getAttribute("identityAdminStatus");
    SimpleDateFormat fmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.ENGLISH);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Identity Approvals</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body { background: #eef1f7; font-family: 'Segoe UI', Tahoma, sans-serif; color: #111; margin: 0; }
            .Header { background: #111827; padding: 24px 30px; color: #fff; display: flex; justify-content: space-between; align-items: center; }
            .btn { background: rgba(255,255,255,0.1); color: #fff; border: 1px solid rgba(255,255,255,0.4); padding: 10px 16px; border-radius: 8px; text-decoration: none; }
            nav ul { display: flex; list-style: none; margin: 0; padding: 14px 26px; background: #fff; border-bottom: 1px solid #e2e8f0; gap: 14px; flex-wrap: wrap; }
            nav ul li a { text-decoration: none; color: #0f172a; font-weight: 600; padding: 6px 12px; border-radius: 8px; }
            .page-wrapper { max-width: 1200px; margin: 30px auto 80px; padding: 0 24px; }
            .stats-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin-bottom: 24px; }
            .stat-card { background: #fff; border-radius: 18px; padding: 18px 22px; box-shadow: 0 18px 45px rgba(15,23,42,0.08); border: 1px solid #dfe6fb; }
            .stat-card h4 { margin: 0; font-size: 13px; text-transform: uppercase; letter-spacing: 0.08em; color: #475569; }
            .stat-card span { display: block; font-size: 30px; font-weight: 700; color: #0f172a; margin-top: 8px; }
            .alert { padding: 16px 20px; border-radius: 14px; margin-bottom: 20px; font-weight: 600; }
            .alert-success { background: #dcfce7; color: #166534; border: 1px solid #bbf7d0; }
            .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
            .identity-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(340px, 1fr)); gap: 20px; }
            .identity-card { background: #fff; border-radius: 20px; padding: 24px 26px; box-shadow: 0 25px 55px rgba(15,23,42,0.08); border: 1px solid #d9e1f7; display: flex; flex-direction: column; gap: 12px; }
            .identity-card header { display: flex; justify-content: space-between; align-items: center; }
            .identity-card h3 { margin: 0; font-size: 18px; }
            .identity-card p { margin: 0; color: #475569; line-height: 1.5; }
            .status-pill { padding: 6px 14px; border-radius: 999px; font-size: 12px; font-weight: 600; letter-spacing: 0.05em; }
            .status-PENDING { background: #fef9c3; color: #854d0e; }
            .status-APPROVED { background: #dcfce7; color: #166534; }
            .status-REJECTED { background: #fee2e2; color: #991b1b; }
            .doc-links { display: flex; gap: 12px; flex-wrap: wrap; }
            .doc-links a { text-decoration: none; font-weight: 600; color: #0f62fe; }
            form { display: flex; flex-direction: column; gap: 10px; margin-top: 8px; }
            .actions { display: flex; gap: 10px; }
            .actions button { flex: 1; padding: 10px 14px; border: none; border-radius: 10px; font-weight: 600; cursor: pointer; }
            .actions button:disabled { opacity: 0.5; cursor: not-allowed; }
            .approve { background: #0f62fe; color: #fff; box-shadow: 0 16px 35px rgba(15,98,254,0.35); }
            .reject { background: #fee2e2; color: #991b1b; }
            .empty-state { text-align: center; padding: 40px; background: #fff; border-radius: 20px; border: 1px dashed #cbd5f5; color: #64748b; box-shadow: 0 20px 40px rgba(15,23,42,0.06); }
        </style>
    </head>
    <body>
        <div class="Header">
            <h2>Identity Approvals</h2>
            <a class="btn" href="MainPage.jsp">Back to Dashboard</a>
        </div>

        <div class="container">
            <nav>
                <ul>
                    <li><a href="AdminSupportTickets">Support Tickets</a></li>
                    <li><a href="AdminTopupList.jsp">Top-Ups</a></li>
                    <li><a href="AdminCreateEvent.jsp">Create Event</a></li>
                    <li><a href="AdminManageEvent.jsp">Manage Event</a></li>
                    <li><a href="AdminViewBlock.jsp">Audit Log</a></li>
                    <li><a href="AdminUserIdentity">Identity</a></li>
                </ul>
            </nav>
        </div>

        <section class="page-wrapper">
            <% if (flashMessage != null) { %>
            <div class="alert <%= "success".equals(flashStatus) ? "alert-success" : "alert-error" %>">
                <%= flashMessage %>
            </div>
            <% } %>
            <div class="stats-row">
                <div class="stat-card">
                    <h4>Pending</h4>
                    <span><%= stats != null ? stats.getOrDefault("PENDING", 0L) : 0 %></span>
                </div>
                <div class="stat-card">
                    <h4>Approved</h4>
                    <span><%= stats != null ? stats.getOrDefault("APPROVED", 0L) : 0 %></span>
                </div>
                <div class="stat-card">
                    <h4>Rejected</h4>
                    <span><%= stats != null ? stats.getOrDefault("REJECTED", 0L) : 0 %></span>
                </div>
            </div>

            <% if (identities == null || identities.isEmpty()) { %>
            <div class="empty-state">
                No identity submissions yet. Once users upload their documents, they will appear here.
            </div>
            <% } else { %>
            <div class="identity-grid">
                <% for (UserIdentity identity : identities) {
                       String status = identity.getStatus() != null ? identity.getStatus() : "PENDING";
                       boolean isApproved = "APPROVED".equals(status);
                       String idImage = identity.getIdPhotoPath();
                       String faceImage = identity.getFacePhotoPath();
                       java.sql.Timestamp updatedAt = identity.getUpdatedAt();
                       java.sql.Timestamp createdAt = identity.getCreatedAt();
                       String lastUpdated = updatedAt != null ? fmt.format(updatedAt) : (createdAt != null ? fmt.format(createdAt) : "Not available");
                %>
                <div class="identity-card">
                    <header>
                        <div>
                            <h3><%= identity.getUserFullname() != null ? identity.getUserFullname() : "User #" + identity.getUserId() %></h3>
                            <small><%= identity.getUserEmail() != null ? identity.getUserEmail() : "" %></small>
                        </div>
                        <span class="status-pill status-<%= status %>"><%= status %></span>
                    </header>
                    <p>Submitted: <%= lastUpdated %></p>
                    <div class="doc-links">
                        <% if (idImage != null && !idImage.isEmpty()) { %>
                        <a href="identity_image?file=<%= idImage %>" target="_blank" rel="noopener">View ID</a>
                        <% } %>
                        <% if (faceImage != null && !faceImage.isEmpty()) { %>
                        <a href="identity_image?file=<%= faceImage %>" target="_blank" rel="noopener">View Face</a>
                        <% } %>
                    </div>
                    <form action="AdminUserIdentity" method="post">
                        <input type="hidden" name="identityId" value="<%= identity.getIdentityId() %>">
                        <% if (identity.getVerifiedBy() != null) { %>
                        <p><strong>Verified by Admin ID:</strong> <%= identity.getVerifiedBy() %></p>
                        <% } %>
                        <div class="actions">
                            <button class="approve" type="submit" name="action" value="APPROVED" <%= isApproved ? "disabled" : "" %>>Approve</button>
                            <button class="reject" type="submit" name="action" value="REJECTED" <%= isApproved ? "disabled" : "" %>>Reject</button>
                        </div>
                    </form>
                </div>
                <% } %>
            </div>
            <% } %>
        </section>
    </body>
</html>
