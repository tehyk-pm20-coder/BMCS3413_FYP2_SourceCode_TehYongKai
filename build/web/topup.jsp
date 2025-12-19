<%@ page import="javax.servlet.http.*, javax.servlet.*" %>

<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    String successMessage = (String) request.getAttribute("successMessage");
    Double submittedAmount = (Double) request.getAttribute("submittedAmount");
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Top Up Wallet</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body {
                background: linear-gradient(135deg, #eef2ff, #f8fafc);
                min-height: 100vh;
            }
            .topup-wrapper {
                display: flex;
                justify-content: center;
                padding: 40px 20px 80px;
            }
            .topup-card {
                width: 100%;
                max-width: 640px;
                background: #fff;
                border-radius: 22px;
                padding: 36px 40px 44px;
                box-shadow: 0 25px 55px rgba(15, 23, 42, 0.15);
                border: 1px solid #e2e8f0;
            }
            .topup-card h2 {
                margin: 0 0 10px;
                font-size: 32px;
                color: #0f172a;
            }
            .topup-card p {
                color: #475569;
                margin-bottom: 30px;
            }
            .form-group {
                margin-bottom: 24px;
            }
            label {
                font-size: 15px;
                font-weight: 600;
                color: #1e293b;
                display: block;
                margin-bottom: 8px;
            }
            input[type="number"] {
                width: 100%;
                padding: 14px 16px;
                border-radius: 12px;
                border: 1px solid #cbd5f5;
                font-size: 18px;
                transition: box-shadow 0.2s ease, border-color 0.2s ease;
            }
            input[type="number"]:focus {
                outline: none;
                border-color: #2563eb;
                box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.2);
            }
            .topup-actions {
                display: flex;
                justify-content: space-between;
                gap: 16px;
                flex-wrap: wrap;
            }
            .btn-link,
            .btn-primary {
                flex: 1;
                min-width: 180px;
                text-align: center;
                border-radius: 12px;
                padding: 14px 12px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                border: none;
                text-decoration: none;
            }
            .btn-link {
                background: #e2e8f0;
                color: #0f172a;
            }
            .btn-link:hover {
                background: #cbd5f5;
            }
            .btn-primary {
                background: #0f62fe;
                color: #fff;
                box-shadow: 0 15px 30px rgba(15, 98, 254, 0.35);
            }
            .btn-primary:hover {
                background: #0b4dd8;
            }
            .info-note {
                margin-top: 18px;
                color: #475569;
                font-size: 14px;
            }
            .alert-success {
                border-radius: 16px;
                padding: 16px 18px;
                margin-bottom: 22px;
                background: #ecfdf5;
                border: 1px solid #bbf7d0;
                color: #0f5132;
                font-weight: 600;
                box-shadow: inset 0 1px 0 rgba(255,255,255,0.5);
            }
        </style>
    </head>
    <body>
        <div class="Header">
            <h2>NFT Blockchain Concert Ticket</h2>
            <div class="buttons-container">
                <a href="wallet.jsp"><button class="btn">My Wallet</button></a>
            </div>
        </div>

        <div class="container">
            <nav>
                <ul>
                    <li class="dropdown"><a href="MainPage.jsp">Home</a></li>
                    <li class="dropdown"><a href="WalletServlet">Wallet</a></li>
                    <li class="dropdown"><a href="AdminTopupList.jsp">Admin Top-Up List</a></li>
                </ul>
            </nav>
        </div>

        <section class="topup-wrapper">
            <div class="topup-card">
                <h2>Top Up Wallet</h2>
                <p>Securely submit a top-up request. An administrator will review and approve it shortly.</p>
                <% if (successMessage != null) { %>
                <div class="alert-success">
                    <%= successMessage %>
                    <% if (submittedAmount != null) { %>
                    <br>Amount submitted: RM <%= String.format("%.2f", submittedAmount) %>
                    <% } %>
                </div>
                <% } %>
                <form action="TopUpServlet" method="post">
                    <input type="hidden" name="userId" value="<%= userId%>">
                    <div class="form-group">
                        <label for="amount">Enter Amount (RM)</label>
                        <input type="number" id="amount" name="amount" step="0.01" min="1" placeholder="e.g. 50.00" required>
                    </div>
                    <div class="topup-actions">
                        <a href="MainPage.jsp" class="btn-link">Cancel</a>
                        <button type="submit" class="btn-primary">Submit Top-Up</button>
                    </div>
                </form>
                <p class="info-note">Once approved, the balance will reflect automatically in your wallet.</p>
            </div>
        </section>
    </body>
</html>
