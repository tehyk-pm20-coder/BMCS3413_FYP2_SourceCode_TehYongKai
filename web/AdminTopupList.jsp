<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Admin - Top Up Requests</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body { background: radial-gradient(circle at 20% 20%, #e0f2ff, #f8fafc 45%); color:#0f172a; font-family:"Segoe UI", Arial, sans-serif; margin:0; }
            .hero { padding:26px 30px; display:flex; justify-content:space-between; align-items:center; background:#0f172a; color:#fff; }
            .hero h2 { margin:0; font-size:22px; }
            .hero-buttons { display:flex; gap:10px; }
            .hero-buttons a button { background:#1d4ed8; border:none; color:#fff; padding:10px 14px; border-radius:10px; font-weight:700; cursor:pointer; box-shadow:0 10px 25px rgba(37,99,235,0.35); }
            .hero-buttons a button:hover { background:#1e40af; }

            .admin-wrapper { padding: 32px 20px 70px; max-width: 1100px; margin: 0 auto; }
            .admin-card { background:#fff; border-radius:18px; padding:26px 30px; box-shadow:0 22px 50px rgba(15,23,42,0.15); border:1px solid #e2e8f0; }
            .card-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:22px; }
            .card-header h2 { margin:0; font-size:20px; }
            .card-header a { color:#0f62fe; text-decoration:none; font-weight:700; }

            table { width:100%; border-collapse:collapse; border-radius:14px; overflow:hidden; box-shadow:0 12px 28px rgba(15,23,42,0.08); }
            thead { background:#0f172a; color:#fff; }
            th, td { padding:14px 16px; text-align:left; font-size:15px; }
            tbody tr:nth-child(even) { background:#f8fafc; }
            tbody tr:nth-child(odd) { background:#fff; }
            tbody tr:hover { background:#f1f5ff; }
            .status-pill { display:inline-flex; padding:6px 14px; border-radius:999px; font-size:12px; font-weight:700; text-transform:uppercase; background:#fff7c2; color:#92400e; }
            .approve-btn { background:linear-gradient(135deg,#059669,#10b981); color:#fff; border:none; border-radius:12px; padding:10px 16px; font-weight:700; cursor:pointer; box-shadow:0 10px 24px rgba(16,185,129,0.25); }
            .approve-btn:hover { background:linear-gradient(135deg,#047857,#0ea16e); }
            .empty-state { text-align:center; padding:40px 0; color:#475569; }
        </style>
    </head>
    <body>
        <div class="hero">
            <h2>Admin Console</h2>
            <div class="hero-buttons">
                <a href="MainPage.jsp"><button>Back to Main</button></a>
                <a href="MainPage.jsp"><button>Admin Home</button></a>
            </div>
        </div>

        <main class="admin-wrapper">
            <div class="admin-card">
                <div class="admin-header">
                    <h2>Pending Top-Up Requests</h2>

                </div>
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>User ID</th>
                            <th>Amount (RM)</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/fyp", "root", "");
                            PreparedStatement stmt = conn.prepareStatement("SELECT * FROM wallet_topup WHERE status='PENDING' ORDER BY id DESC");
                            ResultSet rs = stmt.executeQuery();

                            boolean hasRows = false;
                            while (rs.next()) {
                                hasRows = true;
                        %>
                        <tr>
                            <td><%= rs.getInt("id") %></td>
                            <td><%= rs.getInt("user_id") %></td>
                            <td>RM <%= String.format("%.2f", rs.getDouble("amount")) %></td>
                            <td><span class="status-pill pending"><%= rs.getString("status") %></span></td>
                            <td>
                                <form action="ApproveTopUpServlet" method="post">
                                    <input type="hidden" name="topupId" value="<%= rs.getInt("id") %>">
                                    <button type="submit" class="approve-btn">Approve</button>
                                </form>
                            </td>
                        </tr>
                        <%
                            }
                            rs.close();
                            stmt.close();
                            conn.close();
                            if (!hasRows) {
                        %>
                        <tr>
                            <td colspan="5" class="empty-state">No pending top-up requests at the moment.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </main>
    </body>
</html>
