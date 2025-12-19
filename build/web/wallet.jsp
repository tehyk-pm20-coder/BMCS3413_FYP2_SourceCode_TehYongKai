<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

    Integer walletId = (Integer) request.getAttribute("walletId");
    String status = (String) request.getAttribute("status");
    String walletAddress = (String) request.getAttribute("walletAddress");
    Double balance = (Double) request.getAttribute("balance");
    String message = (String) request.getAttribute("message");
    String navRole = (String) session.getAttribute("userRole");
    boolean navIsAdmin = navRole != null && "admin".equalsIgnoreCase(navRole);

    if (message == null && walletId == null) {
        message = "No wallet found for your account yet.";
    }

    NumberFormat currency = NumberFormat.getCurrencyInstance(Locale.US);
%>


<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>My Wallet</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body {
                background: #f5f6fb;
            }
            .wallet-main {
                display: flex;
                justify-content: center;
                width: 100%;
                padding: 30px 20px 60px;
            }
            .wallet-section {
                width: 100%;
                max-width: 960px;
            }
            .wallet-card {
                width: 100%;
                padding: 32px 36px;
                border-radius: 18px;
                background: #ffffff;
                box-shadow: 0 20px 45px rgba(2, 6, 23, 0.15);
                border: 1px solid #e2e8f0;
            }
            .wallet-header {
                display: flex;
                align-items: center;
                margin-bottom: 28px;
                border-bottom: 1px solid #e2e8f0;
                padding-bottom: 16px;
            }
            .wallet-header h2 {
                margin: 0;
                color: #0f172a;
            }
            .wallet-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                gap: 22px 28px;
            }
            .wallet-item {
                background: #f8fafc;
                border-radius: 14px;
                padding: 18px;
                border: 1px solid #e2e8f0;
            }
            .wallet-label {
                color: #64748b;
                font-size: 13px;
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }
            .wallet-value {
                font-size: 20px;
                font-weight: 600;
                color: #111827;
                margin-top: 8px;
                word-break: break-word;
            }
            .wallet-actions {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-top: 30px;
                gap: 16px;
                flex-wrap: wrap;
            }
            .wallet-actions form {
                margin: 0;
            }
            .wallet-btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 12px 30px;
                border-radius: 10px;
                font-size: 16px;
                font-weight: 600;
                text-decoration: none;
                min-width: 180px;
                border: none;
                cursor: pointer;
                transition: background-color 0.3s ease, transform 0.2s ease;
            }
            .wallet-btn.primary {
                background-color: #0052a4;
                color: #fff;
                box-shadow: 0 12px 25px rgba(0, 82, 164, 0.3);
            }
            .wallet-btn.primary:hover {
                background-color: #0b66c3;
                transform: translateY(-2px);
            }
            .wallet-btn.secondary {
                background-color: #e2e8f0;
                color: #1e293b;
            }
            .wallet-btn.secondary:hover {
                background-color: #cbd5f5;
                transform: translateY(-2px);
            }
            .wallet-status {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 6px 18px;
                border-radius: 30px;
                background: #e0f2fe;
                color: #0369a1;
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                font-size: 12px;
            }
            .wallet-empty {
                max-width: 560px;
                margin: 0 auto;
                padding: 40px 30px;
                border-radius: 22px;
                background: #fdf5ee;
                border: 2px solid #f1b787;
                text-align: center;
                box-shadow: 0 18px 45px rgba(149, 64, 17, 0.15);
            }
            .wallet-empty h3 {
                color: #8b2c0f;
                font-size: 26px;
                margin-bottom: 24px;
            }
            .wallet-empty a {
                color: #8b2c0f;
                font-weight: 700;
                text-decoration: underline;
                display: inline-block;
                margin-top: 18px;
            }
            .wallet-empty p {
                margin: 0;
            }
            .create-wallet-form {
                margin-top: 10px;
                display: flex;
                justify-content: center;
            }
            .create-wallet-btn {
                background-color: #073b78;
                color: #fff;
                border: none;
                padding: 12px 32px;
                border-radius: 10px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: transform 0.2s ease, background-color 0.3s ease;
                box-shadow: 0 10px 20px rgba(7, 59, 120, 0.25);
            }
            .create-wallet-btn:hover {
                background-color: #0c4fa4;
                transform: translateY(-2px);
            }
            .toast-overlay {
                position: fixed;
                inset: 0;
                background: rgba(15, 23, 42, 0.45);
                display: flex;
                justify-content: center;
                align-items: flex-start;
                padding-top: 120px;
                z-index: 2000;
            }
            .toast-card {
                background: #ffffff;
                border-radius: 22px;
                padding: 30px 34px;
                text-align: center;
                max-width: 420px;
                width: calc(100% - 40px);
                box-shadow: 0 25px 45px rgba(15, 23, 42, 0.35);
                border: 1px solid #dbeafe;
                animation: toastDrop 0.35s ease;
            }
            .toast-card h3 {
                margin: 0 0 10px;
                color: #0f172a;
                font-size: 26px;
            }
            .toast-card p {
                margin: 0 0 18px;
                color: #475569;
                font-size: 16px;
                line-height: 1.4;
            }
            .toast-card button {
                border: none;
                border-radius: 30px;
                padding: 10px 30px;
                background: #0f62fe;
                color: #fff;
                font-size: 15px;
                font-weight: 600;
                cursor: pointer;
                box-shadow: 0 15px 30px rgba(15, 98, 254, 0.35);
            }
            .toast-card button:hover {
                background: #0b4dd8;
            }
            @keyframes toastDrop {
                from {
                    opacity: 0;
                    transform: translateY(-20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            
            
        </style>
    </head>

    <body>

        <div class="Header">
            <h2>NFT Blockchain Concert Ticket</h2>
            <div class="buttons-container">
                <a href="EditProfile"><button class="btn">Edit Profile</button></a>
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

        <main class="wallet-main">
            <div class="wallet-section">
                <% if (message != null) {%>
                <div class="wallet-empty">
                    <h3><%= message%></h3>
                    <% if (walletId == null) {%>
                    <form action="CreateWallet" method="post" class="create-wallet-form">
                        <input type="hidden" name="userId" value="<%= userId%>">
                        <button type="submit" class="create-wallet-btn">Create Wallet</button>
                    </form>
                    <% } %>
                    <p><a href="MainPage.jsp">Return to Home</a></p>
                </div>

                <% } else {%>
                <section class="wallet-card">
                    <div class="wallet-header">
                        <h2>My Wallet</h2>
                    </div>

                    <div class="wallet-grid">
                        <div class="wallet-item">
                            <div class="wallet-label">Wallet ID</div>
                            <div class="wallet-value"><%= walletId%></div>
                        </div>
                        <div class="wallet-item">
                            <div class="wallet-label">Wallet Address</div>
                            <div class="wallet-value"><%= walletAddress%></div>
                        </div>
                        <div class="wallet-item">
                            <div class="wallet-label">Balance</div>
                            <div class="wallet-value"><%= currency.format(balance != null ? balance : 0.0)%></div>
                        </div>
                        <div class="wallet-item">
                            <div class="wallet-label">Status</div>
                            <div class="wallet-value">
                                <span class="wallet-status"><%= status != null ? status : "Unknown"%></span>
                            </div>
                        </div>
                    </div>
                    <div class="wallet-actions">
                        <a href="MainPage.jsp" class="wallet-btn secondary">Back to Main Page</a>
                        <a href="ViewTransactions" class="wallet-btn secondary">View Transactions</a>
                        <form action="topup.jsp" method="get">
                            <input type="hidden" name="userId" value="<%= userId%>">
                            <button type="submit" class="wallet-btn primary">Top Up Balance</button>
                        </form>
                    </div>
                </section>
                <% }%>
            </div>
        </main>

        <%
            String topupMessage = (String) session.getAttribute("topupMessage");
            if (topupMessage != null) {
        %>
        <div class="toast-overlay" id="topupToastOverlay">
            <div class="toast-card">
                <h3>Top-Up Submitted</h3>
                <p><%= topupMessage%></p>
                <button type="button" id="toastCloseBtn">Okay</button>
            </div>
        </div>
        <script>
            (function () {
                const overlay = document.getElementById('topupToastOverlay');
                const closeBtn = document.getElementById('toastCloseBtn');
                function dismissToast() {
                    if (overlay) {
                        overlay.style.display = 'none';
                    }
                }
                if (closeBtn) {
                    closeBtn.addEventListener('click', dismissToast);
                }
                if (overlay) {
                    overlay.addEventListener('click', function (event) {
                        if (event.target === overlay) {
                            dismissToast();
                        }
                    });
                }
            })();
        </script>
        <%
                session.removeAttribute("topupMessage");
            }
        %>

    </body>
</html>
