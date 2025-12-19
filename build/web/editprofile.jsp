<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="model.UserProfile"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    UserProfile profile = (UserProfile) request.getAttribute("profile");
    String profileMessage = (String) request.getAttribute("profileMessage");
    String profileStatus = (String) request.getAttribute("profileStatus");
    List<String> validationErrors = (List<String>) request.getAttribute("validationErrors");
    String profileError = (String) request.getAttribute("profileError");
    SimpleDateFormat dateFmt = new SimpleDateFormat("yyyy-MM-dd");
    String navRole = (String) session.getAttribute("userRole");
    boolean navIsAdmin = navRole != null && "admin".equalsIgnoreCase(navRole);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Edit Profile</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body { background: #f5f6fb; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
            .profile-wrapper { max-width: 920px; margin: 30px auto 60px; padding: 0 20px; }
            .profile-card { background: #ffffff; border-radius: 24px; padding: 32px 36px;
                box-shadow: 0 25px 60px rgba(15,23,42,0.1); border: 1px solid #e2e8f0; }
            .profile-card h2 { margin-top: 0; color: #0f172a; }
            .profile-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 18px 26px; margin-top: 24px; }
            label { font-size: 13px; text-transform: uppercase; letter-spacing: 0.08em; color: #64748b; font-weight: 600; }
            input { width: 100%; padding: 12px 14px; border-radius: 12px; border: 1px solid #cbd5f5; font-size: 16px; color: #0f172a; }
            input:focus { outline: none; border-color: #0f62fe; box-shadow: 0 0 0 3px rgba(15,98,254,0.15); }
            .actions { margin-top: 30px; display: flex; gap: 16px; flex-wrap: wrap; }
            .btn-primary { background: #0f62fe; color: #fff; border: none; padding: 14px 30px; border-radius: 12px; font-size: 16px; font-weight: 600; cursor: pointer; box-shadow: 0 18px 40px rgba(15,98,254,0.35); }
            .btn-secondary { background: #e2e8f0; color: #0f172a; border: none; padding: 14px 30px; border-radius: 12px; font-size: 16px; font-weight: 600; cursor: pointer; }
            .alert { padding: 14px 20px; border-radius: 14px; margin-bottom: 20px; font-weight: 600; }
            .alert-success { background: #dcfce7; color: #065f46; border: 1px solid #bbf7d0; }
            .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
            .error-list { margin-top: 10px; padding-left: 18px; }
            .empty-profile { padding: 30px; background: #fff; border-radius: 20px; border: 1px dashed #cbd5f5; text-align: center; color: #475569; }
        </style>
    </head>
    <body>
        <div class="Header">
            <h2>Edit Profile</h2>
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

        <section class="profile-wrapper">
            <% if (profileMessage != null) { %>
            <div class="alert <%= "success".equals(profileStatus) ? "alert-success" : "alert-error" %>">
                <%= profileMessage %>
            </div>
            <% } %>
            <% if (validationErrors != null && !validationErrors.isEmpty()) { %>
            <div class="alert alert-error">
                Please correct the following:
                <ul class="error-list">
                    <% for (String err : validationErrors) { %>
                    <li><%= err %></li>
                    <% } %>
                </ul>
            </div>
            <% } %>
            <% if (profileError != null) { %>
            <div class="empty-profile"><%= profileError %></div>
            <% } else if (profile == null) { %>
            <div class="empty-profile">No profile information found.</div>
            <% } else { 
                   String fullname = profile.getFullname() != null ? profile.getFullname() : "";
                   String phone = profile.getPhone() != null ? profile.getPhone() : "";
                   String email = profile.getEmail() != null ? profile.getEmail() : "";
                   String dobValue = profile.getDob() != null ? dateFmt.format(profile.getDob()) : "";
            %>
            <div class="profile-card">
                <h2>Your Information</h2>
                <form action="EditProfile" method="post">
                    <div class="profile-grid">
                        <div>
                            <label for="fullname">Full Name</label>
                            <input type="text" id="fullname" name="fullname" value="<%= fullname %>" placeholder="<%= fullname %>" required>
                        </div>
                        <div>
                            <label for="phone">Phone Number</label>
                            <input type="text" id="phone" name="phone" value="<%= phone %>" placeholder="<%= phone %>" required>
                        </div>
                        <div>
                            <label for="email">Email Address</label>
                            <input type="email" id="email" name="email" value="<%= email %>" placeholder="<%= email %>" required>
                        </div>
                        <div>
                            <label for="dob">Date of Birth</label>
                            <input type="date" id="dob" name="dob" value="<%= dobValue %>" placeholder="<%= dobValue %>" required>
                        </div>
                        <div>
                            <label for="password">Password</label>
                            <input type="password" id="password" name="password" placeholder="Enter new password (optional)">
                        </div>
                    </div>
                    <div class="actions">
                        <button type="submit" class="btn-primary">Save Changes</button>
                        <a href="MainPage.jsp" class="btn-secondary" style="text-decoration:none; text-align:center;">Cancel</a>
                    </div>
                </form>
            </div>
            <% } %>
        </section>
    </body>
</html>
