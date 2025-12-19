<%@page import="java.text.DecimalFormat"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.List"%>
<%@page import="model.UserTicketView"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    List<UserTicketView> tickets = (List<UserTicketView>) request.getAttribute("tickets");
    String flashMessage = (String) request.getAttribute("ticketsMessage");
    String flashStatus = (String) request.getAttribute("ticketsStatus");
    String fallbackMessage = (String) request.getAttribute("fallbackMessage");
    SimpleDateFormat dateFmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.ENGLISH);
    DecimalFormat moneyFmt = new DecimalFormat("0.00");
    NumberFormat currencyFmt = NumberFormat.getCurrencyInstance(Locale.US);
    Double walletBalance = (Double) request.getAttribute("walletBalance");
    java.util.Date now = new java.util.Date();
    String navRole = (String) session.getAttribute("userRole");
    boolean navIsAdmin = navRole != null && "admin".equalsIgnoreCase(navRole);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>My Tickets</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body {
                background: #f5f6fb;
                font-size: 16px;
            }
            .ticket-wrapper {
                max-width: 1120px;
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
            .ticket-card {
                background: #fff;
                border-radius: 20px;
                padding: 26px 30px;
                margin-bottom: 24px;
                border: 1px solid #e2e8f0;
                box-shadow: 0 20px 45px rgba(15,23,42,0.08);
                display: flex;
                flex-wrap: wrap;
                gap: 20px;
            }
            .ticket-info {
                flex: 2 1 360px;
            }
            .ticket-info h3 {
                margin: 0 0 8px;
                color: #0f172a;
            }
            .ticket-meta {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
                gap: 10px;
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
                margin-top: 3px;
            }
            .status-pill {
                display: inline-flex;
                align-items: center;
                padding: 6px 14px;
                border-radius: 999px;
                font-size: 13px;
                font-weight: 600;
            }
            .status-active {
                background: #e0f2fe;
                color: #0369a1;
            }
            .status-listed {
                background: #fff7ed;
                color: #c2410c;
            }
            .status-used {
                background: #f1f5f9;
                color: #475569;
            }
            .status-rejected {
                background: #fee2e2;
                color: #991b1b;
            }
            .ticket-actions {
                flex: 1 1 260px;
                background: #f8fafc;
                border: 1px dashed #cbd5f5;
                border-radius: 18px;
                padding: 20px;
            }
            .ticket-actions h4 {
                margin: 0 0 10px;
                font-size: 18px;
                color: #0f172a;
            }
            .ticket-actions form {
                display: flex;
                flex-direction: column;
                gap: 12px;
            }
            .ticket-actions input[type="number"] {
                padding: 10px 14px;
                border-radius: 10px;
                border: 1px solid #cbd5f5;
                font-size: 16px;
            }
            .ticket-actions button {
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
            .ticket-actions button:hover {
                transform: translateY(-2px);
            }
            .action-note {
                font-size: 13px;
                color: #475569;
                line-height: 1.4;
            }
            .listing-pill {
                background: #fef3c7;
                border-radius: 12px;
                padding: 12px 16px;
                border: 1px solid #fde68a;
                font-weight: 600;
                color: #92400e;
            }
            .empty-state {
                text-align: center;
                padding: 60px 30px;
                background: #fff;
                border-radius: 22px;
                border: 1px dashed #cbd5f5;
                box-shadow: 0 20px 45px rgba(15,23,42,0.08);
            }
            .empty-state h3 {
                margin-bottom: 10px;
                color: #0f172a;
            }
            .empty-state p {
                color: #475569;
                margin-bottom: 14px;
            }
            .empty-state a {
                color: #0f62fe;
                font-weight: 600;
            }
            .history-link-btn {
                padding: 10px 20px;
                border-radius: 999px;
                background: #0f62fe;
                color: #fff;
                text-decoration: none;
                font-weight: 600;
                box-shadow: 0 10px 25px rgba(15, 98, 254, 0.25);
            }
            .history-link-btn:hover {
                background: #1552d6;
            }
            .qr-section {
                margin-top: 18px;
                padding-top: 16px;
                border-top: 1px dashed #cbd5f5;
            }
            .qr-section h4 {
                margin: 0 0 8px;
            }
            .qr-actions {
                display: flex;
                gap: 16px;
                align-items: center;
                flex-wrap: wrap;
            }
            .qr-btn {
                padding: 11px 18px;
                border: none;
                background: #0f766e;
                color: #fff;
                border-radius: 10px;
                font-weight: 600;
                cursor: pointer;
                box-shadow: 0 10px 25px rgba(15,118,110,0.25);
            }
            .qr-btn:hover {
                background: #0b5f59;
            }
            .qr-box {
                width: 240px;
                height: 240px;
                background: #f8fafc;
                border: 1px dashed #cbd5f5;
                border-radius: 14px;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 8px;
                overflow: hidden;
                margin-top: 8px;
            }
            .qr-box img {
                width: 100%;
                height: 100%;
                object-fit: contain;
            }
            .qr-status {
                margin-top: 8px;
                font-size: 12px;
                color: #475569;
            }
        </style>
    </head>
    <body>
        <div class="Header">
            <h2>My Tickets</h2>
            <div class="buttons-container">
                <a href="ViewTransactions" class="history-link-btn">View Transactions</a>
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
                        <% }%>
                </ul>
                <div class="nav-wallet-chip">
                    <span class="chip-label">Wallet Balance</span>
                    <span class="chip-amount"><%= walletBalance != null ? currencyFmt.format(walletBalance) : "No wallet yet"%></span>
                </div>
            </nav>
        </div>

        <div class="ticket-wrapper">
            <% if (flashMessage != null) {%>
            <div class="alert <%= "success".equals(flashStatus) ? "alert-success" : "alert-error"%>">
                <%= flashMessage%>
            </div>
            <% } %>
            <% if (fallbackMessage != null) {%>
            <div class="alert alert-error"><%= fallbackMessage%></div>
            <% } %>

            <% if (tickets == null || tickets.isEmpty()) { %>
            <div class="empty-state">
                <h3>No tickets found</h3>
                <p>You have not purchased any tickets yet.</p>
                <a href="ViewConcert.jsp">Find a concert to attend</a>
            </div>
            <% } else { %>
            <% for (UserTicketView ticket : tickets) {
                    boolean hasListing = ticket.getListingId() != null;
                    boolean eventUpcoming = ticket.getEventDate() == null || ticket.getEventDate().after(now);
                    String currentStatus = ticket.getTicketStatus() != null ? ticket.getTicketStatus() : "UNKNOWN";
                    boolean isActive = "ACTIVE".equalsIgnoreCase(currentStatus);
                    boolean isListed = "LISTED".equalsIgnoreCase(currentStatus);
                    boolean isRejected = "REJECT".equalsIgnoreCase(currentStatus);
                    java.util.Date lastResaleSoldAt = ticket.getLastResaleSoldAt() != null
                            ? new java.util.Date(ticket.getLastResaleSoldAt().getTime())
                            : null;
                    Integer lastResaleBuyerId = ticket.getLastResaleBuyerId();
                    boolean acquiredFromMarketplace = lastResaleSoldAt != null
                            && lastResaleBuyerId != null
                            && lastResaleBuyerId.intValue() == userId;
                    java.util.Date cooldownExpiry = null;
                    boolean inCooldown = false;
                    if (acquiredFromMarketplace) {
                        long expiryMillis = lastResaleSoldAt.getTime() + (long) 7 * 24 * 60 * 60 * 1000;
                        cooldownExpiry = new java.util.Date(expiryMillis);
                        inCooldown = now.before(cooldownExpiry);
                    }
                    boolean canList = isActive && eventUpcoming && !hasListing && !inCooldown;
                    double faceValue = ticket.getPrice();
                    double priceCap = faceValue > 0 ? faceValue : 0.01;
                    String priceMaxAttr = String.format(java.util.Locale.US, "%.2f", priceCap);
                    String statusClass = "status-used";
                    if (isActive) {
                        statusClass = "status-active";
                    } else if (isListed) {
                        statusClass = "status-listed";
                    } else if (isRejected) {
                        statusClass = "status-rejected";
                    }
            %>
            <section class="ticket-card">
                <div class="ticket-info">
                    <div class="status-pill <%= statusClass%>"><%= currentStatus%></div>
                    <h3><%= ticket.getEventName() != null ? ticket.getEventName() : "Event #" + ticket.getEventId()%></h3>
                    <div class="ticket-meta">
                        <div>
                            <span class="meta-label">Ticket ID</span>
                            <div class="meta-value">#<%= ticket.getTicketId()%></div>
                        </div>
                        <div>
                            <span class="meta-label">Seat Type</span>
                            <div class="meta-value"><%= ticket.getSeatType()%></div>
                        </div>
                        <div>
                            <span class="meta-label">Face Value</span>
                            <div class="meta-value">RM <%= moneyFmt.format(ticket.getPrice())%></div>
                        </div>
                        <div>
                            <span class="meta-label">Event Date</span>
                            <div class="meta-value">
                                <%= ticket.getEventDate() != null ? dateFmt.format(ticket.getEventDate()) : "TBA"%>
                            </div>
                        </div>
                        <div>
                            <span class="meta-label">Venue</span>
                            <div class="meta-value"><%= ticket.getVenue() != null ? ticket.getVenue() : "-"%></div>
                        </div>
                    </div>
                </div>
                <div class="ticket-actions">
                    <% if (hasListing) {%>
                    <h4>Listed on Marketplace</h4>
                    <div class="listing-pill">
                        RM <%= moneyFmt.format(ticket.getListingPrice())%> &bull;
                        Listed on <%= ticket.getListingCreatedAt() != null ? dateFmt.format(ticket.getListingCreatedAt()) : "-"%>
                    </div>
                    <p class="action-note" style="margin-top:12px;">
                        Buyers can now find this ticket under the marketplace section. You will be credited automatically when it is sold.
                    </p>
                    <form action="CancelResaleListing" method="post" style="margin-top:12px;">
                        <input type="hidden" name="ticketId" value="<%= ticket.getTicketId()%>">
                        <button type="submit" style="padding:10px 14px; border:none; border-radius:10px; background:#b91c1c; color:#fff; font-weight:700; cursor:pointer; box-shadow:0 10px 25px rgba(185,28,28,0.25);">
                            Cancel Listing
                        </button>
                    </form>
                    <% } else if (isRejected) { %>
                    <h4>Resale blocked</h4>
                    <p class="action-note">This ticket was rejected by the integrity checks and cannot be listed on the marketplace.</p>
                    <% } else if (!eventUpcoming) { %>
                    <h4>Event has passed</h4>
                    <p class="action-note">Resale is disabled once the event date has passed.</p>
                    <% } else if (inCooldown) {%>
                    <h4>Cooling-off period</h4>
                    <p class="action-note">
                        This ticket was recently purchased. You can list it on or after
                        <%= cooldownExpiry != null ? dateFmt.format(cooldownExpiry) : "the 7-day cooldown window"%>.
                    </p>
                    <p class="action-note">Smart contract enforces a 7-day holding period after each resale purchase.</p>
                    <% } else if (canList) {%>
                    <h4>List this ticket</h4>
                    <form action="CreateResaleListing" method="post">
                        <input type="hidden" name="ticketId" value="<%= ticket.getTicketId()%>">
                        <label class="meta-label" for="price-<%= ticket.getTicketId()%>">Set resale price (max RM <%= moneyFmt.format(ticket.getPrice())%>)</label>
                        <input type="number" id="price-<%= ticket.getTicketId()%>" name="listingPrice"
                               min="1" max="<%= priceMaxAttr%>" step="0.01" required>
                        <p class="action-note">
                            Smart contract rule: resale price cannot be higher than the original RM <%= moneyFmt.format(ticket.getPrice())%>.
                        </p>
                        <button type="submit">List on Marketplace</button>
                    </form>
                    <% } else {%>
                    <h4>Resale unavailable</h4>
                    <p class="action-note">This ticket is not eligible for resale because it is marked as <%= currentStatus%>.</p>
                    <% } %>
                    <div style="margin-top:12px;">
                        <% if ("USED".equalsIgnoreCase(currentStatus)) { %>
                        <p class="action-note" style="color:#991b1b;font-weight:600;">QR not available because this ticket is already used.</p>
                        <% } else if ("REJECT".equalsIgnoreCase(currentStatus)) { %>
                        <p class="action-note" style="color:#991b1b;font-weight:600;">QR not available because this ticket failed verification and was rejected.</p>
                        <% } else {%>
                        <a class="qr-toggle" style="display:inline-block; padding:10px 14px; border-radius:10px; background:#0f62fe; color:#fff; font-weight:600; text-decoration:none; box-shadow:0 10px 25px rgba(15,98,254,0.25);" href="TicketQrView?ticketId=<%= ticket.getTicketId()%>">View QR Code</a>
                        <% } %>
                    </div>
                </div>
            </section>
            <% } %>
            <% }%>
        </div>
        <script>
            (function () {
                const base = "<%= request.getContextPath()%>/TicketQr";
                const imgs = document.querySelectorAll('[id^="qr-img-"]');

                imgs.forEach((img) => {
                    const ticketId = img.id.replace("qr-img-", "");
                    const statusText = document.getElementById(`qr-status-${ticketId}`);
                    const url = base + "?ticketId=" + encodeURIComponent(ticketId) + "&_=" + Date.now();

                    if (statusText)
                        statusText.textContent = "Generating QR...";
                    img.alt = "Loading QR...";
                    img.style.opacity = "0.6";

                    fetch(url, {cache: "no-store"})
                            .then((res) => {
                                if (!res.ok) {
                                    throw new Error("Server returned " + res.status);
                                }
                                return res.blob();
                            })
                            .then((blob) => {
                                const objectUrl = URL.createObjectURL(blob);
                                img.src = objectUrl;
                                img.alt = "Ticket QR code";
                                img.style.opacity = "1";
                                if (statusText)
                                    statusText.textContent = "QR generated.";
                            })
                            .catch((err) => {
                                console.error("Ticket QR fetch failed", err);
                                img.removeAttribute("src");
                                img.alt = "QR not available";
                                img.style.opacity = "1";
                                if (statusText)
                                    statusText.textContent = "QR generation failed.";
                            });
                });
            })();
        </script>
    </body>
</html>
