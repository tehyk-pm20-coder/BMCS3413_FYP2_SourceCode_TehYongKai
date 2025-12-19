
<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="model.Event"%>

<%
    List<Event> events = (List<Event>) request.getAttribute("events");
    String message = (String) request.getAttribute("message");

    if (events == null && message == null) {
        response.sendRedirect("EventListServlet");
        return;
    }
    SimpleDateFormat fmt = new SimpleDateFormat("dd MMM yyyy", Locale.ENGLISH);
    String navRole = (String) session.getAttribute("userRole");
    boolean navIsAdmin = navRole != null && "admin".equalsIgnoreCase(navRole);
    Integer userId = (Integer) session.getAttribute("userId");
    boolean loggedIn = (userId != null);
    Double walletBalance = (Double) request.getAttribute("walletBalance");
    NumberFormat currencyFmt = NumberFormat.getCurrencyInstance(Locale.US);
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Concert Events</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body {
                background: #f5f6fb;
            }
            .events-main {
                padding: 30px 20px 60px;
                max-width: 1200px;
                margin: 0 auto;
            }
            .events-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 26px;
                margin-top: 20px;
            }
            .event-card {
                background: #ffffff;
                border-radius: 18px;
                box-shadow: 0 18px 38px rgba(15, 23, 42, 0.18);
                overflow: hidden;
                border: 1px solid #e2e8f0;
                display: flex;
                flex-direction: column;
            }
            .event-card img {
                width: 100%;
                height: 200px;
                object-fit: cover;
            }
            .event-info {
                padding: 20px 22px 24px;
                display: flex;
                flex-direction: column;
                flex: 1;
            }
            .event-info h3 {
                margin: 10px 0 6px;
                color: #0f172a;
                font-size: 22px;
            }
            .event-info p {
                margin: 4px 0;
                color: #475569;
            }
            .status-pill {
                align-self: flex-start;
                padding: 4px 12px;
                border-radius: 999px;
                font-size: 12px;
                font-weight: 600;
                background: #e0f2fe;
                color: #0369a1;
                text-transform: uppercase;
            }
            .btn-view {
                margin-top: auto;
                text-align: center;
                background: #0f62fe;
                color: #fff;
                padding: 12px;
                border-radius: 12px;
                text-decoration: none;
                font-weight: 600;
                transition: background 0.2s ease;
            }
            .btn-view:hover {
                background: #0b4dd8;
            }
            .empty-state {
                margin-top: 40px;
                text-align: center;
                color: #475569;
                font-size: 18px;
            }
        </style>
    </head>
    <body>

        <div class="Header">
            <h2>NFT BlockChain Concert Ticket</h2>
            <div class="buttons-container">
                <a href="MainPage.jsp"><button class="btn">Back to Main</button></a>
                
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
                <% if (loggedIn) { %>
                <div class="nav-wallet-chip">
                    <span class="chip-label">Wallet Balance</span>
                    <span class="chip-amount"><%= walletBalance != null ? currencyFmt.format(walletBalance) : "No wallet yet" %></span>
                </div>
                <% } %>
            </nav>
        </div>

        <main class="events-main">
            <h2>Available Concert Events</h2>

            <% if (message != null && (events == null || events.isEmpty())) { %>
            <div class="empty-state"><%= message %></div>
            <% } %>

            <div class="events-grid">
                <%
                    if (events != null && !events.isEmpty()) {
                        for (Event ev : events) {
                %>
                <div class="event-card">
                    <%
                        String imageSrc = ev.getImagePath() != null ? (request.getContextPath() + "/" + ev.getImagePath()) : (request.getContextPath() + "/image/default-event.jpg");
                    %>
                    <img src="<%= imageSrc %>" alt="Event Image">
                    <div class="event-info">
                        <span class="status-pill"><%= ev.getStatus() != null ? ev.getStatus() : "N/A" %></span>
                        <h3><%= ev.getEventName() %></h3>
                        <p><strong>Venue:</strong> <%= ev.getVenue() %></p>
                        <p><strong>Date:</strong> <%= ev.getEventDate() != null ? fmt.format(ev.getEventDate()) : "-" %></p>
                        <a class="btn-view" href="TicketPurchase.jsp?eventId=<%= ev.getEventId() %>">View Event</a>
                    </div>
                </div>
                <%      }
                    } %>
            </div>
        </main>
    </body>
</html>
