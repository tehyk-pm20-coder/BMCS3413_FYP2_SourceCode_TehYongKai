<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    boolean loggedIn = (userId != null);
    String userRole = (String) session.getAttribute("userRole");
    String userFullname = (String) session.getAttribute("userFullname");
    boolean isAdmin = "admin".equalsIgnoreCase(userRole);
    String walletLink = "WalletServlet";
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>NFT Concert Ticketing</title>
        <link rel="stylesheet" type="text/css" href="Css/Header.css">
        <style>
            body {
                margin: 0;
                font-family: "Segoe UI", Tahoma, sans-serif;
                font-size: 16px;
                color: #eef2f7;
                background: linear-gradient(135deg, #0f1624, #1d2a44 40%, #15273f);
                overflow-x: hidden;
            }
            body::before, body::after {
                content: "";
                position: fixed;
                top: -50%;
                left: 0;
                width: 200%;
                height: 200%;
                background-image:
                    radial-gradient(2px 2px at 20px 30px, rgba(255, 255, 255, 0.75), transparent 40%),
                    radial-gradient(2px 2px at 130px 80px, rgba(255, 255, 255, 0.7), transparent 40%),
                    radial-gradient(3px 3px at 220px 120px, rgba(255, 255, 255, 0.6), transparent 45%),
                    radial-gradient(2px 2px at 340px 200px, rgba(255, 255, 255, 0.65), transparent 40%),
                    radial-gradient(2px 2px at 420px 40px, rgba(255, 255, 255, 0.55), transparent 40%);
                background-repeat: repeat;
                animation: snowfall 28s linear infinite;
                pointer-events: none;
                opacity: 0.5;
            }
            body::after {
                animation-duration: 36s;
                opacity: 0.35;
                filter: blur(1px);
            }
            @keyframes snowfall {
                0% { transform: translateY(-10%); }
                100% { transform: translateY(20%); }
            }
            .buttons-container {
                gap: 10px;
                flex-wrap: wrap;
            }
            .buttons-container form {
                margin: 0;
            }
            .Header {
                background: linear-gradient(135deg, #0f1624, #1d2a44 45%, #15273f);
                padding: 26px 30px;
                border-bottom: 1px solid rgba(255, 255, 255, 0.15);
                display: flex;
                justify-content: space-between;
                align-items: center;
                backdrop-filter: blur(10px);
            }
            .Header h2 {
                margin: 0;
                font-size: 2rem;
                letter-spacing: 0.6px;
                color: #f7fbff;
                text-shadow: 0 8px 24px rgba(122, 245, 255, 0.18);
            }
            .btn {
                background: rgba(255, 255, 255, 0.12);
                color: #f7fbff;
                font-size: 1rem;
                padding: 12px 20px;
                border: 1px solid rgba(255, 255, 255, 0.3);
                border-radius: 10px;
                cursor: pointer;
                transition: transform 0.12s ease, box-shadow 0.2s ease, border-color 0.2s ease;
            }
            .btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 12px 24px rgba(0, 0, 0, 0.28);
                border-color: rgba(122, 245, 255, 0.6);
            }
            .container {
                background: transparent;
            }
            nav {
                background: #ffffff;
                border: 1px solid rgba(0, 0, 0, 0.08);
                border-radius: 9px;
                padding: 10px 18px;
                box-shadow: 0 18px 35px rgba(0, 0, 0, 0.35);
                backdrop-filter: blur(10px);
            }
            nav ul li {
                color: #111;
                letter-spacing: 0.2px;
                text-transform: none;
                font-weight: 650;
            }
            nav ul li:hover {
                color: #0a2540;
                background-color: #eef6ff;
                border-radius: 8px;
            }
            .dropdown-menu {
                background: #ffffff;
                border: 1px solid rgba(0, 0, 0, 0.08);
                border-radius: 10px;
                box-shadow: 0 14px 30px rgba(0, 0, 0, 0.35);
                backdrop-filter: blur(8px);
                padding: 10px 0;
            }
            .dropdown-menu li {
                color: #111;
                font-size: 0.95rem;
                font-weight: 500;
            }
            .dropdown-menu li:hover {
                background-color: #eef6ff;
                color: #0a2540;
                border-left: 3px solid rgba(122, 245, 255, 0.8);
            }
            main {
                max-width: 1200px;
                margin: 30px auto 60px;
                padding: 0 24px;
            }
            .hero {
                position: relative;
                padding: 70px 30px 50px;
                text-align: center;
                max-width: 1100px;
                margin: 0 auto;
            }
            .hero h1 {
                font-size: 2.6rem;
                margin: 0 0 15px;
                background: linear-gradient(90deg, #7af5ff, #a877ff, #f6c3ff);
                -webkit-background-clip: text;
                color: transparent;
                text-shadow: 0 8px 30px rgba(122, 245, 255, 0.2);
            }
            .hero p.lead {
                font-size: 1.1rem;
                max-width: 820px;
                margin: 0 auto 30px;
                line-height: 1.6;
                color: #dce6ff;
            }
            .info-cards {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
                gap: 26px;
                margin: 30px auto;
                max-width: 1100px;
                padding: 0 30px;
            }
            .card {
                background: linear-gradient(180deg, rgba(255, 255, 255, 0.08), rgba(255, 255, 255, 0.02));
                border: 1px solid rgba(255, 255, 255, 0.08);
                border-radius: 16px;
                padding: 26px;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.25);
                backdrop-filter: blur(6px);
                font-size: 1.15rem;
            }
            .card h3 {
                margin: 0 0 10px;
                color: #f7fbff;
                font-size: 1.5rem;
            }
            .card p {
                margin: 0;
                color: #cdd7f3;
                line-height: 1.5;
                font-size: 1.25rem;
            }
            .cta-buttons {
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 16px;
                flex-wrap: wrap;
                margin-top: 22px;
            }
            .cta-buttons a {
                text-decoration: none;
            }
            .btn-glow {
                padding: 14px 26px;
                border-radius: 14px;
                border: none;
                color: #0f1624;
                font-weight: 700;
                font-size: 1.1rem;
                background: linear-gradient(135deg, #7af5ff, #b4a7ff 55%, #f6c3ff);
                box-shadow: 0 10px 30px rgba(122, 245, 255, 0.35);
                cursor: pointer;
                transition: transform 0.15s ease, box-shadow 0.15s ease;
            }
            .btn-glow.secondary {
                color: #eef2f7;
                background: transparent;
                border: 1px solid rgba(255, 255, 255, 0.3);
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.35);
            }
            .btn-glow:hover {
                transform: translateY(-3px);
                box-shadow: 0 15px 35px rgba(122, 245, 255, 0.5);
            }
        </style>
    </head>
    <body>
        <div class="Header">
            <h2>NFT BlockChain Concert Ticket</h2>
            <div class="buttons-container">
                <% if (loggedIn) { %>
                    <span style="color:#f7fbff;font-weight:600;">
                        Welcome, <%= userFullname != null ? userFullname : (userId != null ? "User" : "Guest") %>
                        <%= isAdmin ? " (Role: Admin)" : "" %>
                    </span>
                <% } %>
                <% if (!loggedIn) { %>
                <a href="Login.jsp">
                    <button class="btn" id="login">Login</button>
                </a>
                <% } %>
                <% if (!isAdmin) { %>
                <a href="EditProfile">
                    <button class="btn" id="edit">Edit Profile</button>
                </a>
                <% if (loggedIn) { %>
                <a href="<%= walletLink%>">
                    <button class="btn" id="viewWallet">View Wallet</button>
                </a>
                <% } %>
                <% } %>
                <% if (loggedIn) { %>
                <a href="LogoutServlet">
                    <button class="btn" id="logout">Logout</button>
                </a>
                <% } %>
            </div>
        </div>

        <div class="container">
            <nav>
                <ul>
                    <% if (!isAdmin) { %>
                        <li><a href="MainPage.jsp">Home</a></li>
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
                        <li><a href="UserIdentityUpload">Identity Verification</a></li>
                    <% } else { %>
                        <li><a href="AdminSupportTickets">View Admin Support Ticket</a></li>
                        <li><a href="AdminTopupList.jsp">Admin Top-Up List</a></li>
                        <li><a href="AdminCreateEvent.jsp">Create Event</a></li>
                        <li><a href="AdminManageEvent.jsp">Manage Event</a></li>
                        <li><a href="AdminViewBlock.jsp">View/Audit BlockChain</a></li>
                        <li><a href="AdminUserIdentity">Identity Approvals</a></li>
                        <li><a href="checkin.jsp">Check-In QR code</a></li>
                        
                    <% } %>
                </ul>
            </nav>
        </div>

        <main>
            <section class="hero">
                <h1>On-Chain Concert Tickets, Yours Forever</h1>
                <p class="lead">
                    Secure, tradable tickets powered by our audited smart contract. Claim ownership that cannot be forged,
                    enjoy instant verification.
                </p>
                <div class="cta-buttons">
                    <a href="ViewConcert.jsp">
                        <button class="btn-glow">View Events</button>
                    </a>
                    <a href="ResaleMarketplace">
                        <button class="btn-glow secondary">Resale Marketplace</button>
                    </a>
                </div>
            </section>

            <section class="info-cards">
                <div class="card">
                    <h3>Smart Contracts</h3>
                    <p>Resale Tickets in marketplace will be enforced rules to ensure fairness ticket trading and stop black market overpricing</p>
                </div>
                <div class="card">
                    <h3>Instant QR Verification</h3>
                    <p>Show your QR code at the entry, staff scan once to validate entry and block reuse in real time.</p>
                </div>
                <div class="card">
                    <h3>Verified Identity</h3>
                    <p>Identity checks link tickets to verified profiles, reducing ticket scalping and keeping resales compliant.</p>
                </div>
            </section>

        </main>
    </body>
</html>
