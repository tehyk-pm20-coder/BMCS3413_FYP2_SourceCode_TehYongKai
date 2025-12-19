<%@page import="java.util.List"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    List<String> validationErrors = (List<String>) request.getAttribute("validationErrors");
    String subjectValue = (String) request.getAttribute("subjectValue");
    String descriptionValue = (String) request.getAttribute("descriptionValue");
    String categoryValue = (String) request.getAttribute("categoryValue");
    String flashMessage = (String) request.getAttribute("supportMessage");
    String flashStatus = (String) request.getAttribute("supportStatus");
    String navRole = (String) session.getAttribute("userRole");
    boolean navIsAdmin = navRole != null && "admin".equalsIgnoreCase(navRole);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Create Support Ticket</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body { background: #f5f6fb; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
            .support-wrapper { max-width: 1080px; margin: 30px auto 60px; padding: 0 20px; }
            .card { background: #fff; border-radius: 24px; padding: 30px 34px; box-shadow: 0 20px 55px rgba(15,23,42,0.12); border: 1px solid #e2e8f0; }
            .card h2 { margin-top: 0; color: #0f172a; }
            .support-form { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 20px 26px; margin-top: 20px; }
            .support-form label { font-size: 13px; text-transform: uppercase; letter-spacing: 0.08em; color: #64748b; font-weight: 600; }
            .support-form input, .support-form select, .support-form textarea {
                width: 100%; padding: 12px 14px; border-radius: 12px; border: 1px solid #cbd5f5; font-size: 16px; color: #0f172a;
            }
            .support-form textarea { min-height: 140px; resize: vertical; grid-column: 1 / -1; }
            .support-form button { grid-column: 1 / -1; padding: 14px 30px; border: none; border-radius: 12px; background: #0f62fe; color: #fff; font-weight: 600; cursor: pointer; box-shadow: 0 18px 40px rgba(15,98,254,0.35); }
            .support-form button:hover { transform: translateY(-1px); }
            .alert { padding: 14px 20px; border-radius: 14px; margin-bottom: 18px; font-weight: 600; }
            .alert-success { background: #dcfce7; color: #065f46; border: 1px solid #bbf7d0; }
            .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
            .link-row { margin-top: 20px; text-align: right; }
            .link-row a { color: #0f62fe; font-weight: 600; text-decoration: none; }
        </style>
    </head>
    <body>
        <div class="Header">
            <h2>Support Center</h2>
            <div class="buttons-container">
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
                        My Ticket
                        <ul class="dropdown-menu">
                            <li><a href="MyTickets">Check My Tickets</a></li>
                        </ul>
                    </li>
                    
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

        <section class="support-wrapper">
            <% if (flashMessage != null) { %>
            <div class="alert <%= "success".equals(flashStatus) ? "alert-success" : "alert-error" %>">
                <%= flashMessage %>
            </div>
            <% } %>
            <% if (validationErrors != null && !validationErrors.isEmpty()) { %>
            <div class="alert alert-error">
                Please fix the following issues:
                <ul>
                    <% for (String err : validationErrors) { %>
                    <li><%= err %></li>
                    <% } %>
                </ul>
            </div>
            <% } %>

            <div class="card">
                <h2>Submit a Ticket</h2>
                <form class="support-form" action="SupportTicket" method="post">
                    <div>
                        <label for="subject">Subject</label>
                        <input type="text" id="subject" name="subject" value="<%= subjectValue != null ? subjectValue : "" %>" placeholder="Describe your issue briefly" required>
                    </div>
                    <div>
                        <label for="category">Category</label>
                        <select id="category" name="category" required>
                            <option value="">Select a category</option>
                            <%
                                String[] categories = {"PAYMENT", "TICKET", "ACCOUNT", "QR", "OTHER"};
                                String selectedCategory = categoryValue;
                            %>
                            <% for (String cat : categories) { %>
                            <option value="<%= cat %>" <%= cat.equals(selectedCategory) ? "selected" : "" %>><%= cat %></option>
                            <% } %>
                        </select>
                    </div>
                    <div style="grid-column: 1 / -1;">
                        <label for="description">Description</label>
                        <textarea id="description" name="description" required placeholder="Share a detailed description so our support team can assist you faster."><%= descriptionValue != null ? descriptionValue : "" %></textarea>
                    </div>
                    <button type="submit">Submit Ticket</button>
                </form>
            </div>
            <div class="link-row">
                <a href="SupportTicketList">View my tickets &raquo;</a>
            </div>
        </section>
        <%
            boolean autoRefresh = "success".equals(flashStatus);
            if (autoRefresh) {
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
