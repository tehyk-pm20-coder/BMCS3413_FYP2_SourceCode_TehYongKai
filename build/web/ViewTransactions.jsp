<%@page import="java.text.NumberFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.List"%>
<%@page import="model.TransactionHistoryItem"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    List<TransactionHistoryItem> transactions = (List<TransactionHistoryItem>) request.getAttribute("transactions");
    String fallbackMessage = (String) request.getAttribute("fallbackMessage");
    SimpleDateFormat dateFmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.ENGLISH);
    NumberFormat currency = NumberFormat.getCurrencyInstance(Locale.US);
    String navRole = (String) session.getAttribute("userRole");
    boolean navIsAdmin = navRole != null && "admin".equalsIgnoreCase(navRole);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>My Transactions</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body {
                background: #f5f6fb;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }
            .header-actions {
                display: flex;
                align-items: center;
                gap: 12px;
            }
            .header-actions a {
                padding: 10px 18px;
                border-radius: 10px;
                background: #0f62fe;
                color: #fff;
                text-decoration: none;
                font-weight: 600;
                box-shadow: 0 10px 25px rgba(15, 98, 254, 0.25);
            }
            .transaction-wrapper {
                max-width: 1100px;
                margin: 30px auto 60px;
                padding: 0 20px;
            }
            .empty-state, .fallback-state {
                background: #fff;
                border-radius: 22px;
                padding: 50px 30px;
                text-align: center;
                border: 1px dashed #cbd5f5;
                box-shadow: 0 20px 45px rgba(15,23,42,0.08);
            }
            .empty-state h3, .fallback-state h3 {
                margin-bottom: 12px;
                color: #0f172a;
            }
            .transaction-card {
                background: #fff;
                border-radius: 20px;
                padding: 26px 30px;
                border: 1px solid #e2e8f0;
                box-shadow: 0 20px 45px rgba(15,23,42,0.08);
                margin-bottom: 22px;
                display: flex;
                flex-wrap: wrap;
                gap: 18px;
            }
            .tx-meta {
                flex: 2 1 360px;
            }
            .tx-meta h3 {
                margin: 0 0 6px;
                color: #0f172a;
            }
            .tx-meta p {
                margin: 0;
                color: #475569;
            }
            .tx-badges {
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
                margin-top: 12px;
            }
            .badge {
                padding: 6px 14px;
                border-radius: 999px;
                font-size: 13px;
                font-weight: 600;
                background: #e2e8f0;
                color: #0f172a;
            }
            .badge-buy {
                background: #dbeafe;
                color: #1d4ed8;
            }
            .badge-sell {
                background: #fef3c7;
                color: #c2410c;
            }
            .tx-info-grid {
                flex: 1 1 260px;
                background: #f8fafc;
                border: 1px dashed #cbd5f5;
                border-radius: 18px;
                padding: 18px;
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
                gap: 14px;
            }
            .info-label {
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                color: #64748b;
            }
            .info-value {
                font-weight: 600;
                color: #0f172a;
                margin-top: 4px;
            }
            .history-hint {
                margin: 18px 0 26px;
                color: #475569;
                font-size: 15px;
                background: #e0f2fe;
                border-left: 4px solid #0284c7;
                padding: 14px 16px;
                border-radius: 12px;
            }
        </style>
    </head>
    <body>
        <div class="Header">
            <h2>Resale Transactions</h2>
            <div class="buttons-container header-actions">
                <a href="MyTickets">Back to My Tickets</a>
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

        <div class="transaction-wrapper">
            <div class="history-hint">
                Completed resale listings that involved your account appear here, whether you were the buyer or the seller.
            </div>

            <% if (fallbackMessage != null) {%>
            <div class="fallback-state">
                <h3>We couldn't load your transactions.</h3>
                <p><%= fallbackMessage%></p>
                <p><a href="MyTickets">Return to My Tickets</a></p>
            </div>
            <% } else if (transactions == null || transactions.isEmpty()) { %>
            <div class="empty-state">
                <h3>No resale transactions yet</h3>
                <p>Once you buy or sell tickets on the marketplace, they will be listed here.</p>
                <p><a href="ResaleMarketplace">Browse Marketplace</a></p>
            </div>
            <% } else {
                for (TransactionHistoryItem item : transactions) {
                    boolean isBuyer = item.isBuyerView();
                    String roleLabel = isBuyer ? "Purchased" : "Sell";
                    String counterparty = isBuyer
                            ? (item.getSellerName() != null ? item.getSellerName() : "Seller")
                            : (item.getBuyerName() != null ? item.getBuyerName() : "Buyer");
                    java.sql.Timestamp eventTimestamp = item.getSoldAt() != null ? item.getSoldAt() : item.getCreatedAt();
                    String eventTimeLabel = eventTimestamp != null ? dateFmt.format(eventTimestamp) : "Pending";
            %>
            <div class="transaction-card">
                <div class="tx-meta">
                    <h3><%= item.getEventName()%></h3>
                    <p>Listing #<%= item.getListingId()%> - Ticket #<%= item.getTicketId()%></p>
                    <div class="tx-badges">
                        <span class="badge <%= isBuyer ? "badge-buy" : "badge-sell"%>"><%= roleLabel%></span>
                        <span class="badge">Status: <%= item.getStatus()%></span>
                        <span class="badge">Counterparty: <%= counterparty%></span>
                    </div>
                </div>
                <div class="tx-info-grid">
                    <div>
                        <div class="info-label">Seat Type</div>
                        <div class="info-value"><%= item.getSeatType()%></div>
                    </div>
                    <div>
                        <div class="info-label">Sold Price</div>
                        <div class="info-value"><%= currency.format(item.getListingPrice())%></div>
                    </div>
                    <div>
                        <div class="info-label">Originally Listed</div>
                        <div class="info-value"><%= dateFmt.format(item.getCreatedAt())%></div>
                    </div>
                    <div>
                        <div class="info-label">Transaction Completed</div>
                        <div class="info-value"><%= eventTimeLabel%></div>
                    </div>
                </div>
            </div>
            <%   } // end for
                } // end else %>
        </div>
    </body>
</html>
