<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Locale"%>
<%@page import="model.ResaleListingView"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    boolean loggedIn = (userId != null);
    List<ResaleListingView> listings = (List<ResaleListingView>) request.getAttribute("marketListings");
    String flashMessage = (String) request.getAttribute("marketMessage");
    String flashStatus = (String) request.getAttribute("marketStatus");
    String fallbackMessage = (String) request.getAttribute("fallbackMessage");
    SimpleDateFormat dateFmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.ENGLISH);
    DecimalFormat moneyFmt = new DecimalFormat("0.00");
    NumberFormat currencyFmt = NumberFormat.getCurrencyInstance(Locale.US);
    Double walletBalance = (Double) request.getAttribute("walletBalance");
    String navRole = (String) session.getAttribute("userRole");
    boolean navIsAdmin = navRole != null && "admin".equalsIgnoreCase(navRole);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Ticket Resale Marketplace</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body {
                background: #f9fafc;
                font-size: 16px;
            }
            .market-container {
                max-width: 1200px;
                margin: 30px auto 60px;
                padding: 0 20px;
            }
            .alert {
                padding: 14px 20px;
                border-radius: 12px;
                margin-bottom: 20px;
                font-weight: 600;
            }
            .alert-success {
                background: #dcfce7;
                border: 1px solid #bbf7d0;
                color: #065f46;
            }
            .alert-error {
                background: #fee2e2;
                border: 1px solid #fecaca;
                color: #991b1b;
            }
            .listing-card {
                background: #fff;
                border-radius: 20px;
                padding: 24px 28px;
                margin-bottom: 20px;
                border: 1px solid #e2e8f0;
                box-shadow: 0 20px 50px rgba(15,23,42,0.08);
                display: flex;
                gap: 22px;
                flex-wrap: wrap;
            }
            .listing-info {
                flex: 2 1 420px;
            }
            .listing-info h3 {
                margin: 0 0 10px;
                color: #0f172a;
            }
            .listing-meta {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
                gap: 12px;
                margin-top: 14px;
            }
            .meta-label {
                font-size: 12px;
                text-transform: uppercase;
                letter-spacing: 0.08em;
                color: #64748b;
            }
            .meta-value {
                font-weight: 600;
                color: #0f172a;
                margin-top: 4px;
            }
            .seller-tag {
                display: inline-flex;
                align-items: center;
                padding: 6px 10px;
                border-radius: 999px;
                background: #f1f5f9;
                color: #475569;
                font-weight: 600;
                font-size: 13px;
            }
            .listing-actions {
                flex: 1 1 240px;
                background: #f8fafc;
                border-radius: 18px;
                padding: 20px;
                border: 1px dashed #cbd5f5;
                display: flex;
                flex-direction: column;
                gap: 14px;
            }
            .listing-actions h4 {
                margin: 0;
                color: #111;
            }
            .listing-actions button {
                padding: 12px;
                border: none;
                border-radius: 10px;
                background: #0f62fe;
                color: #fff;
                font-weight: 600;
                cursor: pointer;
                box-shadow: 0 10px 25px rgba(15,98,254,0.25);
                transition: transform 0.2s ease;
            }
            .listing-actions button:hover {
                transform: translateY(-2px);
            }
            .listing-actions button[disabled] {
                background: #cbd5f5;
                color: #475569;
                cursor: not-allowed;
                box-shadow: none;
            }
            .action-note {
                font-size: 13px;
                color: #475569;
                line-height: 1.4;
            }
            .empty-market {
                text-align: center;
                padding: 70px 30px;
                background: #fff;
                border-radius: 24px;
                border: 1px dashed #cbd5f5;
                box-shadow: 0 20px 50px rgba(15,23,42,0.08);
            }
            .empty-market h3 {
                margin-bottom: 12px;
                color: #0f172a;
            }
            .empty-market p {
                color: #475569;
                margin-bottom: 14px;
            }
            .empty-market a {
                color: #0f62fe;
                font-weight: 600;
            }
        </style>
    </head>
    <body>
        <div class="Header">
            <h2>Ticket Resale Marketplace</h2>
            <div class="buttons-container">

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
                <% if (loggedIn) { %>
                <div class="nav-wallet-chip">
                    <span class="chip-label">Wallet Balance</span>
                    <span class="chip-amount"><%= walletBalance != null ? currencyFmt.format(walletBalance) : "No wallet yet" %></span>
                </div>
                <% } %>
            </nav>
        </div>

        <div class="market-container">
            <% if (!loggedIn) { %>
            <div class="alert alert-error">Login to buy tickets and access your wallet.</div>
            <% } %>
            <% if (flashMessage != null) {%>
            <div class="alert <%= "success".equals(flashStatus) ? "alert-success" : "alert-error"%>">
                <%= flashMessage%>
            </div>
            <% } %>
            <% if (fallbackMessage != null) {%>
            <div class="alert alert-error"><%= fallbackMessage%></div>
            <% } %>

            <% if (listings == null || listings.isEmpty()) { %>
            <div class="empty-market">
                <h3>No resale listings yet</h3>
                <p>Listings will appear here when sellers put their tickets back on the market.</p>
                <a href="MyTickets">List one of your tickets</a>
            </div>
            <% } else { %>
            <% for (ResaleListingView listing : listings) {
                    boolean isOwner = loggedIn && listing.getSellerId() == userId;
                    String priceDisplay = moneyFmt.format(listing.getListingPrice());
            %>
            <section class="listing-card">
                <div class="listing-info">
                    <div class="seller-tag">
                        Seller: <%= listing.getSellerName() != null ? listing.getSellerName() : ("User #" + listing.getSellerId())%>
                        <% if (isOwner) { %>&nbsp;(you)<% }%>
                    </div>
                    <h3><%= listing.getEventName()%></h3>
                    <div class="listing-meta">
                        <div>
                            <span class="meta-label">Listing ID</span>
                            <div class="meta-value">#<%= listing.getListingId()%></div>
                        </div>
                        <div>
                            <span class="meta-label">Seat Type</span>
                            <div class="meta-value"><%= listing.getSeatType()%></div>
                        </div>
                        <div>
                            <span class="meta-label">Resale Price</span>
                            <div class="meta-value">RM <%= priceDisplay%></div>
                        </div>
                        <div>
                            <span class="meta-label">Original Price Cap</span>
                            <div class="meta-value">RM <%= moneyFmt.format(listing.getOriginalPrice())%></div>
                        </div>
                        <div>
                            <span class="meta-label">Event Date</span>
                            <div class="meta-value"><%= listing.getEventDate() != null ? dateFmt.format(listing.getEventDate()) : "TBA"%></div>
                        </div>
                        <div>
                            <span class="meta-label">Venue</span>
                            <div class="meta-value"><%= listing.getVenue() != null ? listing.getVenue() : "-"%></div>
                        </div>
                        <div>
                            <span class="meta-label">Listed On</span>
                            <div class="meta-value"><%= listing.getCreatedAt() != null ? dateFmt.format(listing.getCreatedAt()) : "-"%></div>
                        </div>
                    </div>
                </div>
                <div class="listing-actions">
                    <h4>Smart contract</h4>
                    <p class="action-note">
                        Anti-scalping rules enforce that the resale price never exceeds the original RM <%= moneyFmt.format(listing.getOriginalPrice())%>.
                        Funds move wallet-to-wallet and ownership is written to the blockchain after purchase.
                    </p>
                    <form action="BuyResaleTicket" method="post">
                        <input type="hidden" name="listingId" value="<%= listing.getListingId()%>">
                        <button type="submit" <%= (!loggedIn || isOwner) ? "disabled" : ""%>>
                            <%= isOwner ? "Your Listing" : "Buy for RM " + priceDisplay%>
                        </button>
                    </form>
                    <% if (!loggedIn) { %>
                    <p class="action-note">Please log in to continue.</p>
                    <% } else if (isOwner) { %>
                    <p class="action-note">This is your ticket. Other buyers can purchase it from the marketplace.</p>
                    <% } else { %>
                    <p class="action-note">Ensure your wallet has enough balance before confirming.</p>
                    <% } %>
                </div>
            </section>
            <% } %>
            <% }%>
        </div>
    </body>
</html>
