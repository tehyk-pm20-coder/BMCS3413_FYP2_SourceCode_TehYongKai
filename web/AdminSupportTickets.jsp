<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="model.SupportTicket"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String userRole = (String) session.getAttribute("userRole");
    if (userId == null || userRole == null || !"admin".equalsIgnoreCase(userRole)) {
        response.sendRedirect("Login.jsp");
        return;
    }
    List<SupportTicket> tickets = (List<SupportTicket>) request.getAttribute("allTickets");
    List<String> validationErrors = (List<String>) request.getAttribute("validationErrors");
    String flashMessage = (String) request.getAttribute("supportMessage");
    String flashStatus = (String) request.getAttribute("supportStatus");
    SimpleDateFormat dateFmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.ENGLISH);
    int openCount = 0, progressCount = 0, closedCount = 0;
    if (tickets != null) {
        for (SupportTicket t : tickets) {
            String st = t.getStatus() != null ? t.getStatus() : "OPEN";
            if ("IN_PROGRESS".equals(st)) {
                progressCount++;
            } else if ("CLOSED".equals(st)) {
                closedCount++;
            } else {
                openCount++;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Admin Support Tickets</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body { background: #eef1f7; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #111; }
            .page-wrapper { max-width: 1280px; margin: 30px auto 80px; padding: 0 24px; }
            .hero-card { background: #fff; border-radius: 20px; padding: 28px 32px; box-shadow: 0 24px 55px rgba(15,23,42,0.08); margin-bottom: 24px; }
            .hero-card h2 { margin: 0 0 10px; font-size: 28px; color: #111; }
            .hero-card p { margin: 0; color: #444; }
            .action-bar { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 22px; }
            .action-bar a { text-decoration: none; color: #111; font-weight: 600; border: 1px solid #d7dce5; padding: 10px 18px; border-radius: 12px; background: #f6f8fd; }
            .action-bar a.primary { background: #0f62fe; color: #fff; border-color: #0f62fe; box-shadow: 0 12px 30px rgba(15,98,254,0.35); }
            .stats-row { display: flex; gap: 16px; flex-wrap: wrap; margin-bottom: 26px; }
            .stat-card { flex: 1 1 200px; background: #fff; border-radius: 16px; padding: 18px; box-shadow: 0 20px 45px rgba(15,23,42,0.08); border: 1px solid #e3e8f3; }
            .stat-card h4 { margin: 0; font-size: 13px; text-transform: uppercase; letter-spacing: 0.08em; color: #555; }
            .stat-card span { display: block; margin-top: 6px; font-size: 28px; font-weight: 700; color: #111; }
            .alert { padding: 14px 20px; border-radius: 14px; margin-bottom: 18px; font-weight: 600; }
            .alert-success { background: #dcfce7; color: #065f46; border: 1px solid #bbf7d0; }
            .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
            .ticket-list { display: grid; grid-template-columns: repeat(auto-fit, minmax(360px, 1fr)); gap: 22px; }
            .ticket-card { background: #fff; border-radius: 22px; border: 1px solid #e4e9f2; padding: 24px 26px; box-shadow: 0 22px 45px rgba(15,23,42,0.08); display: flex; flex-direction: column; min-height: 280px; }
            .ticket-card h3 { margin: 8px 0 0; color: #111; font-size: 20px; }
            .ticket-meta { margin: 12px 0 6px; font-size: 14px; color: #444; line-height: 1.4; }
            .status-pill { align-self: start; padding: 6px 14px; border-radius: 999px; font-size: 12px; font-weight: 600; }
            .status-OPEN { background: #e0f2fe; color: #0369a1; }
            .status-IN_PROGRESS { background: #fff3c8; color: #8a4b0f; }
            .status-CLOSED { background: #e2e8f0; color: #475569; }
            .ticket-body { flex: 1; color: #111; line-height: 1.65; margin: 12px 0 18px; font-size: 15px; }
            .update-form { display: flex; flex-direction: column; gap: 8px; }
            .update-form select, .update-form textarea { width: 100%; padding: 10px 12px; border-radius: 10px; border: 1px solid #cbd5f5; font-size: 14px; color: #111; background: #fdfdfd; }
            .update-form textarea { resize: vertical; min-height: 80px; }
            .update-form button { align-self: flex-start; padding: 10px 18px; border: none; border-radius: 10px; background: #111; color: #fff; font-weight: 600; cursor: pointer; box-shadow: 0 12px 30px rgba(17,17,17,0.25); }
        </style>
    </head>
    <body>
        <div class="Header">
            <h2 style="color:#fff;">Admin Support Tickets</h2>
            <div class="buttons-container">
                <a href="MainPage.jsp" class="btn">Back to Dashboard</a>
            </div>
        </div>

        <div class="page-wrapper">
            <div class="hero-card">
                <h2>Support Desk Overview</h2>
                <p>Review, respond, and resolve every ticket from one place.</p>
                <div class="action-bar">
                    <a href="AdminSupportTickets" class="primary">Admin Support Tickets</a>
                    <a href="AdminTopupList.jsp">Admin Top-Up List</a>
                    <a href="AdminCreateEvent.jsp">Create Event</a>
                    <a href="AdminManageEvent.jsp">Manage Event</a>
                    <a href="AdminViewBlock.jsp">View/Audit Blockchain</a>
                </div>
            </div>

            <div class="stats-row">
                <div class="stat-card">
                    <h4>Open Tickets</h4>
                    <span><%= openCount %></span>
                </div>
                <div class="stat-card">
                    <h4>In Progress</h4>
                    <span><%= progressCount %></span>
                </div>
                <div class="stat-card">
                    <h4>Closed</h4>
                    <span><%= closedCount %></span>
                </div>
            </div>

            <% if (flashMessage != null) { %>
            <div class="alert <%= "success".equals(flashStatus) ? "alert-success" : "alert-error" %>">
                <%= flashMessage %>
            </div>
            <% } %>
            <% if (validationErrors != null && !validationErrors.isEmpty()) { %>
            <div class="alert alert-error">
                <ul>
                    <% for (String err : validationErrors) { %>
                    <li><%= err %></li>
                    <% } %>
                </ul>
            </div>
            <% } %>

            <div class="ticket-list">
                <% if (tickets == null || tickets.isEmpty()) { %>
                <div class="ticket-card" style="justify-content:center; align-items:center;">
                    No support tickets available.
                </div>
                <% } else {
                    for (SupportTicket ticket : tickets) {
                        String statusClass = "status-" + (ticket.getStatus() != null ? ticket.getStatus() : "OPEN");
                %>
                <div class="ticket-card">
                    <span class="status-pill <%= statusClass %>"><%= ticket.getStatus() %></span>
                    <h3>#<%= ticket.getTicketId() %> - <%= ticket.getSubject() %></h3>
                    <div class="ticket-meta">
                        <strong>User:</strong> <%= ticket.getUserName() %> (ID: <%= ticket.getUserId() %>)<br>
                        <strong>Category:</strong> <%= ticket.getCategory() %> <strong>Created:</strong> <%= ticket.getCreatedAt() != null ? dateFmt.format(ticket.getCreatedAt()) : "-" %>
                    </div>
                    <div class="ticket-body"><%= ticket.getDescription() %></div>
                    <% boolean isClosed = "CLOSED".equals(ticket.getStatus()); %>
                    <% if (isClosed) { %>
                        <div class="update-form" style="opacity:0.7;">
                            <textarea readonly placeholder="Ticket closed. No further updates allowed."><%= ticket.getAdminReply() != null ? ticket.getAdminReply() : "" %></textarea>
                        </div>
                    <% } else { %>
                    <form class="update-form" action="AdminSupportTickets" method="post">
                        <input type="hidden" name="ticketId" value="<%= ticket.getTicketId() %>">
                        <select name="status" required>
                            <option value="OPEN" <%= "OPEN".equals(ticket.getStatus()) ? "selected" : "" %>>OPEN</option>
                            <option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(ticket.getStatus()) ? "selected" : "" %>>IN PROGRESS</option>
                            <option value="CLOSED" <%= "CLOSED".equals(ticket.getStatus()) ? "selected" : "" %>>CLOSED</option>
                        </select>
                        <textarea name="adminReply" placeholder="Reply to user..."><%= ticket.getAdminReply() != null ? ticket.getAdminReply() : "" %></textarea>
                        <button type="submit">Update Ticket</button>
                    </form>
                    <% } %>
                </div>
                <%  }
                   } %>
            </div>
        </div>
        <%
            boolean adminAutoRefresh = "success".equals(flashStatus);
            if (adminAutoRefresh) {
        %>
        <script>
            setTimeout(function () {
                window.location.reload();
            }, 800);
        </script>
        <%
            }
        %>
    </body>
</html>
