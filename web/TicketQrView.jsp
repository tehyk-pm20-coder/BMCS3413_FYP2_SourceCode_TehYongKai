<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="model.UserTicketView"%>
<%
    UserTicketView ticket = (UserTicketView) request.getAttribute("ticket");
    String error = (String) request.getAttribute("error");
    SimpleDateFormat dateFmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.ENGLISH);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Ticket QR</title>
        <style>
            body { font-family: Arial, sans-serif; background:#f5f6fb; margin:0; padding:0; display:flex; justify-content:center; align-items:center; min-height:100vh; }
            .card { background:#fff; border:1px solid #e2e8f0; border-radius:16px; padding:24px 28px; box-shadow:0 18px 40px rgba(15,23,42,0.08); width:420px; }
            h2 { margin:0 0 6px; color:#0f172a; }
            p { margin:0 0 12px; color:#475569; }
            .meta { margin: 10px 0; }
            .meta div { margin-bottom:6px; color:#0f172a; }
            .label { font-size:12px; color:#64748b; text-transform:uppercase; letter-spacing:0.06em; display:block; }
            .value { font-weight:700; }
            .qr-box { margin-top:16px; width:430px; height:430px; border:1px dashed #cbd5f5; border-radius:12px; display:flex; align-items:center; justify-content:center; overflow:hidden; margin-left:auto; margin-right:auto; }
            .qr-box img { width:100%; height:100%; object-fit:contain; }
            .status { text-align:center; font-size:12px; color:#475569; margin-top:8px; }
            .back-link { display:inline-block; margin-top:16px; padding:10px 16px; background:#0f62fe; color:#fff; border-radius:10px; text-decoration:none; font-weight:700; box-shadow:0 10px 25px rgba(15,98,254,0.25); }
            .back-link:hover { background:#1552d6; }
            .error { color:#b91c1c; background:#fee2e2; border:1px solid #fecaca; padding:12px; border-radius:10px; font-weight:700; }
        </style>
    </head>
    <body>
        <div class="card">
            <h2>Ticket QR</h2>
            <p>Scan this code for check-in verification.</p>
            <% if (error != null || ticket == null) { %>
                <div class="error"><%= error != null ? error : "Ticket not found." %></div>
                <a class="back-link" href="MyTickets">Back to My Tickets</a>
            <% } else { %>
                <div class="meta">
                    <div><span class="label">Ticket ID</span><span class="value">#<%= ticket.getTicketId() %></span></div>
                    <div><span class="label">Event</span><span class="value"><%= ticket.getEventName() %></span></div>
                    <div><span class="label">Seat</span><span class="value"><%= ticket.getSeatType() %></span></div>
                    <div><span class="label">Status</span><span class="value"><%= ticket.getTicketStatus() %></span></div>
                    <div><span class="label">Event Date</span><span class="value"><%= ticket.getEventDate() != null ? dateFmt.format(ticket.getEventDate()) : "TBA" %></span></div>
                    <div><span class="label">Venue</span><span class="value"><%= ticket.getVenue() != null ? ticket.getVenue() : "-" %></span></div>
                </div>
                <div class="qr-box">
                    <img id="qr-img" alt="QR loading...">
                </div>
                <div class="status" id="qr-status">Generating QR...</div>
                <a class="back-link" href="MyTickets">Back to My Tickets</a>
            <% } %>
        </div>
        <% if (ticket != null) { %>
        <script>
            (function() {
                const img = document.getElementById("qr-img");
                const status = document.getElementById("qr-status");
                const url = "<%= request.getContextPath() %>/TicketQr?ticketId=<%= ticket.getTicketId() %>&_=" + Date.now();
                img.alt = "Loading QR...";
                img.style.opacity = "0.6";
                fetch(url, { cache: "no-store" })
                    .then((res) => {
                        if (!res.ok) throw new Error("Server returned " + res.status);
                        return res.blob();
                    })
                    .then((blob) => {
                        const objectUrl = URL.createObjectURL(blob);
                        img.src = objectUrl;
                        img.alt = "Ticket QR code";
                        img.style.opacity = "1";
                        if (status) status.textContent = "QR generated.";
                    })
                    .catch((err) => {
                        console.error("QR fetch failed", err);
                        img.removeAttribute("src");
                        img.alt = "QR not available";
                        img.style.opacity = "1";
                        if (status) status.textContent = "QR generation failed.";
                    });
            })();
        </script>
        <% } %>
    </body>
</html>
