<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="model.SupportTicket"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    List<SupportTicket> tickets = (List<SupportTicket>) request.getAttribute("userTickets");
    SimpleDateFormat dateFmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.ENGLISH);
    String navRole = (String) session.getAttribute("userRole");
    boolean navIsAdmin = navRole != null && "admin".equalsIgnoreCase(navRole);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Support Ticket List</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body { background: #f5f6fb; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
            .tickets-wrapper { max-width: 1080px; margin: 30px auto 60px; padding: 0 20px; }
            .ticket-card { background: #fff; border: 1px solid #e2e8f0; border-radius: 22px; padding: 26px 30px; margin-bottom: 22px; box-shadow: 0 18px 40px rgba(15,23,42,0.08); }
            .ticket-header { display: flex; justify-content: space-between; flex-wrap: wrap; gap: 10px; }
            .ticket-header h3 { color: #0f172a; margin: 0; font-size: 20px; }
            .status-pill { padding: 6px 14px; border-radius: 999px; font-size: 13px; font-weight: 600; text-transform: uppercase; }
            .status-OPEN { background: #e0f2fe; color: #0369a1; }
            .status-IN_PROGRESS { background: #fef3c7; color: #92400e; }
            .status-CLOSED { background: #e2e8f0; color: #475569; }
            .ticket-meta { margin-top: 8px; color: #475569; font-size: 14px; }
            .ticket-body { margin-top: 14px; color: #0f172a; line-height: 1.65; font-size: 15px; }
            .admin-reply { margin-top: 12px; padding: 12px 16px; border-radius: 14px; background: #eef2ff; border: 1px solid #c7d2fe; color: #1e3a8a; }
            .empty-card { background: #fff; border-radius: 20px; padding: 30px; border: 1px dashed #cbd5f5; color: #475569; text-align: center; }
        </style>
    </head>
    <body>
        <div class="Header">
            <h2>Support Ticket List</h2>
            <div class="buttons-container">
                <a href="SupportTicket" class="btn">Create New Ticket</a>
                <a href="MainPage.jsp" class="btn">Back to Dashboard</a>
            </div>
        </div>

        <div class="container">
            <nav>
                <ul>
                    <li class="dropdown">
                        Home
                        <ul class="dropdown-menu">
                            <li><a href="MainPage.jsp">Dashboard</a></li>
                            <li><a href="WalletServlet">Wallet</a></li>
                        </ul>
                    </li>
                    
                    <li><a href="ViewConcert.jsp">Event/Concert</a></li>
                    <li><a href="ResaleMarketplace">Marketplace</a></li>
                    
                    <li class="dropdown">
                        Support Ticket
                        <ul class="dropdown-menu">
                            <li><a href="SupportTicket">Create Support Ticket</a></li>
                            <li><a href="SupportTicketList">Support Ticket List</a></li>
                        </ul>
                    </li>
                    <% if (navIsAdmin) { %>
                    <li><a href="AdminSupportTickets">Admin Support</a></li>
                    <% } %>
                </ul>
            </nav>
        </div>

        <section class="tickets-wrapper">
            <% if (tickets == null || tickets.isEmpty()) { %>
            <div class="empty-card">You have not created any support tickets yet.</div>
            <% } else {
                for (SupportTicket ticket : tickets) {
                    String statusClass = "status-" + (ticket.getStatus() != null ? ticket.getStatus() : "OPEN");
            %>
            <div class="ticket-card">
                <div class="ticket-header">
                    <h3><%= ticket.getSubject() %></h3>
                    <span class="status-pill <%= statusClass %>"><%= ticket.getStatus() %></span>
                </div>
                <div class="ticket-meta">
                    Category: <strong><%= ticket.getCategory() %></strong> Created: <%= ticket.getCreatedAt() != null ? dateFmt.format(ticket.getCreatedAt()) : "-" %>
                </div>
                <div class="ticket-body"><%= ticket.getDescription() %></div>
                <% if (ticket.getAdminReply() != null && !ticket.getAdminReply().isEmpty()) { %>
                <div class="admin-reply">
                    <strong>Admin reply:</strong>
                    <div><%= ticket.getAdminReply() %></div>
                </div>
                <% } %>
            </div>
            <%      }
                } %>
        </section>
    </body>
</html>
