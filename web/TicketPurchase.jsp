<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.NumberFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="java.util.List"%>
<%@page import="model.Event"%>
<%@page import="model.SeatType"%>
<%
    Event event = (Event) request.getAttribute("event");
    List<SeatType> seatTypes = (List<SeatType>) request.getAttribute("seatTypes");
    String message = (String) request.getAttribute("message");
    String purchaseMessage = (String) request.getAttribute("purchaseMessage");
    String purchaseStatus = (String) request.getAttribute("purchaseStatus");
    Boolean salesClosedAttr = (Boolean) request.getAttribute("salesClosed");
    boolean salesClosed = salesClosedAttr != null && salesClosedAttr;
    if (event == null && message == null) {
        String eventIdParam = request.getParameter("eventId");
        if (eventIdParam != null) {
            response.sendRedirect("TicketPurchaseServlet?eventId=" + eventIdParam);
        } else {
            response.sendRedirect("ViewConcert.jsp");
        }
        return;
    }
    boolean seatsAvailable = seatTypes != null && !seatTypes.isEmpty();
    SimpleDateFormat fmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.ENGLISH);
    Integer userId = (Integer) session.getAttribute("userId");
    Double walletBalance = (Double) request.getAttribute("walletBalance");
    NumberFormat currencyFmt = NumberFormat.getCurrencyInstance(Locale.US);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Ticket Purchase</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body { background: linear-gradient(120deg,#eef2ff,#f8fafc); }
            .purchase-wrapper { max-width: 1120px; margin: 40px auto 80px; padding: 0 20px; }
            .purchase-layout { display: flex; gap: 24px; flex-wrap: wrap; align-items: flex-start; }
            .wallet-summary-card { flex: 0 0 260px; background: #0f172a; color: #fff; border-radius: 20px; padding: 22px 24px; box-shadow: 0 20px 45px rgba(15,23,42,0.35); border: 1px solid rgba(255,255,255,0.15); min-width: 240px; }
            .wallet-summary-card h3 { margin: 0 0 8px; text-transform: uppercase; letter-spacing: 0.15em; font-size: 12px; opacity: 0.8; }
            .wallet-summary-card .amount { font-size: 28px; font-weight: 700; margin-bottom: 18px; display: block; }
            .wallet-summary-card p { margin: 0; font-size: 14px; opacity: 0.8; line-height: 1.4; }
            .purchase-card { flex: 1 1 640px; display: flex; flex-wrap: wrap; border-radius: 24px; overflow: hidden;
                box-shadow: 0 25px 60px rgba(15,23,42,0.2); background: #fff; border: 1px solid #e2e8f0; }
            .purchase-image { flex: 1 1 360px; min-height: 320px; }
            .purchase-image img { width: 100%; height: 100%; object-fit: cover; }
            .purchase-body { flex: 1 1 360px; padding: 30px 36px; }
            .purchase-body h1 { margin: 0 0 10px; color: #0f172a; }
            .meta { margin: 18px 0; }
            .meta label { display: block; text-transform: uppercase; letter-spacing: 0.08em; font-size: 12px; color: #64748b; }
            .meta span { display: block; font-size: 20px; font-weight: 600; color: #0f172a; margin-top: 4px; }
            .seat-select { margin-top: 24px; }
            .seat-select label { color: #000; }
            select { width: 100%; padding: 12px 14px; border-radius: 12px; border: 1px solid #cbd5f5; font-size: 16px; }
            .price-display { margin-top: 10px; font-weight: 600; color: #0f172a; }
            .actions { margin-top: 24px; display: flex; gap: 16px; flex-wrap: wrap; }
            .btn { padding: 14px 28px; border-radius: 12px; font-weight: 600; border: none; cursor: pointer; }
            .btn-primary { background: #0f62fe; color: #fff; }
            .btn-secondary { background: #e2e8f0; color: #0f172a; text-decoration:none; text-align:center; }
            .empty { text-align: center; padding: 60px 20px; color: #475569; }
            .alert { margin-bottom: 20px; padding: 14px 18px; border-radius: 12px; font-weight: 600; }
            .alert-success { background: #dcfce7; color: #065f46; border: 1px solid #bbf7d0; }
            .alert-error { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }
            @media (max-width: 992px) {
                .purchase-layout { flex-direction: column; }
                .wallet-summary-card { width: 100%; }
            }
        </style>
    </head>
    <body>
        <div class="Header">
            <h2>Ticket Purchase</h2>
            <div class="buttons-container">
                <a href="ViewConcert.jsp"><button class="btn">Back to Events</button></a>
            </div>
        </div>

        <div class="purchase-wrapper">
            <% if (purchaseMessage != null) { %>
            <div class="alert <%= "success".equals(purchaseStatus) ? "alert-success" : "alert-error" %>">
                <%= purchaseMessage %>
            </div>
            <% } %>
            <% if (message != null && event == null) { %>
            <div class="empty"><%= message %></div>
            <% } else if (event != null) { %>
            <div class="purchase-layout">
                <% if (userId != null) { %>
                <aside class="wallet-summary-card">
                    <h3>Wallet Balance</h3>
                    <span class="amount"><%= walletBalance != null ? currencyFmt.format(walletBalance) : "No wallet yet" %></span>
                    <p>Wallet funds are used automatically when you purchase a ticket.</p>
                </aside>
                <% } %>
                <section class="purchase-card">
                    <div class="purchase-image">
                        <%
                            String eventImageSrc = event.getImagePath() != null ? (request.getContextPath() + "/" + event.getImagePath()) : (request.getContextPath() + "/image/default-event.jpg");
                        %>
                        <img src="<%= eventImageSrc %>" alt="Event Image">
                    </div>
                    <div class="purchase-body">
                        <h1><%= event.getEventName() %></h1>
                        <p>Confirm the event details below and continue to select your seats.</p>

                        <div class="meta">
                            <label>Event ID</label>
                            <span><%= event.getEventId() %></span>
                        </div>
                        <div class="meta">
                            <label>Venue</label>
                            <span><%= event.getVenue() %></span>
                        </div>
                        <div class="meta">
                            <label>Date</label>
                            <span><%= event.getEventDate() != null ? fmt.format(event.getEventDate()) : "-" %></span>
                        </div>
                        <div class="meta">
                            <label>Status</label>
                            <span><%= event.getStatus() != null ? event.getStatus() : "N/A" %></span>
                        </div>

                        <% if (salesClosed) { %>
                        <div class="alert alert-error" style="margin-top:12px;">
                            Ticket sales for this event are closed.
                        </div>
                        <% } else if (seatsAvailable) { %>
                        <form action="TicketPurchaseServlet" method="post" class="purchase-form">
                            <input type="hidden" name="eventId" value="<%= event.getEventId() %>">
                            <div class="seat-select">
                                <label for="seatType">Seat Type</label>
                                <select id="seatType" name="seatTypeId" required>
                                    <option value="" data-price="0">Select a seat type</option>
                                    <% for (SeatType seat : seatTypes) { %>
                                    <option value="<%= seat.getSeatTypeId() %>" data-price="<%= seat.getPrice() %>">
                                        <%= seat.getSeatType() %> - Remaining: <%= seat.getRemainingQty() %>
                                    </option>
                                    <% } %>
                                </select>
                                <div class="price-display">Seat Price: RM <span id="seatPrice">0.00</span></div>
                                <div class="price-display" style="margin-top:6px;">Total: RM <span id="totalPrice">0.00</span></div>
                            </div>
                            <div class="actions">
                                <a href="ViewConcert.jsp" class="btn btn-secondary">Back to Events</a>
                                <button type="submit" class="btn btn-primary" id="buyBtn">Buy Ticket</button>
                            </div>
                        </form>
                        <% } else { %>
                        <div class="empty" style="padding: 30px 0;">Seat information is not available for this event.</div>
                        <% } %>
                    </div>
                </section>
            </div>
            <% } %>
        </div>
        <script>
            (function () {
                const seatDropdown = document.getElementById('seatType');
                const priceLabel = document.getElementById('seatPrice');
                const totalLabel = document.getElementById('totalPrice');
                const buyBtn = document.getElementById('buyBtn');
                if (!seatDropdown) return;

                function updatePrice() {
                    const selected = seatDropdown.options[seatDropdown.selectedIndex];
                    const price = selected ? parseFloat(selected.getAttribute('data-price') || '0') : 0;
                    priceLabel.textContent = price.toFixed(2);
                    totalLabel.textContent = price.toFixed(2);
                    if (buyBtn) {
                        buyBtn.disabled = !selected || !selected.value;
                    }
                }

                seatDropdown.addEventListener('change', updatePrice);
                updatePrice();
            })();
        </script>
    </body>
</html>
