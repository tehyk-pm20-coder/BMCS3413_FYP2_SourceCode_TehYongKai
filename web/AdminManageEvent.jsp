<%-- 
    Document   : AdminManageEvent
    Created on : Nov 15, 2025, 12:22:26 AM
    Author     : User
--%>

<%@page import="java.util.List"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Locale"%>
<%@page import="model.Event"%>
<%@page import="model.SeatType"%>
<%
    List<Event> events = (List<Event>) request.getAttribute("events");
    List<SeatType> seatTypes = (List<SeatType>) request.getAttribute("seatTypes");
    String pageMessage = (String) request.getAttribute("message");
    String seatMessage = (String) request.getAttribute("seatMessage");
    String flash = (String) session.getAttribute("eventAdminMessage");
    if (events == null && pageMessage == null && flash == null) {
        response.sendRedirect("AdminManageEventServlet");
        return;
    }
    if (flash != null) {
        session.removeAttribute("eventAdminMessage");
    }
    SimpleDateFormat fmt = new SimpleDateFormat("dd MMM yyyy, hh:mm a", Locale.ENGLISH);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Manage Events</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body { background: linear-gradient(135deg,#e2e8f0,#f8fafc); color:#0f172a; }
            .admin-main { padding: 30px 20px 80px; max-width: 1200px; margin: 0 auto; }
            .panel { background:#fff; border-radius:16px; padding:24px 26px; box-shadow:0 20px 50px rgba(15,23,42,0.12); border:1px solid #e2e8f0; margin-bottom:24px; }
            table { width:100%; border-collapse:separate; border-spacing:0 10px; }
            thead { background:transparent; color:#0f172a; }
            thead th { background:#0f172a; color:#fff; }
            th, td { padding:14px 16px; text-align:left; font-size:15px; }
            tbody tr { background:#fff; }
            tbody tr:hover { background:#f8fafc; }
            tbody tr td:first-child, thead th:first-child { border-top-left-radius:12px; border-bottom-left-radius:12px; }
            tbody tr td:last-child, thead th:last-child { border-top-right-radius:12px; border-bottom-right-radius:12px; }
            .status-pill { padding:6px 14px; border-radius:999px; font-size:12px; text-transform:uppercase; }
            .status-pill.OPEN { background:#dcfce7; color:#166534; }
            .status-pill.CLOSED { background:#fee2e2; color:#991b1b; }
            .action-form { display:flex; gap:8px; align-items:center; }
            select { padding:6px 10px; border-radius:10px; border:1px solid #cbd5f5; background:#f8fafc; }
            button { padding:9px 16px; border-radius:10px; border:none; background:#0f62fe; color:#fff; cursor:pointer; font-weight:700; box-shadow:0 12px 28px rgba(15,98,254,0.2); }
            button:hover { background:#0b4dd8; }
            .flash { padding:16px; margin-bottom:20px; border-radius:12px; background:#ecfdf5; border:1px solid #bbf7d0; color:#065f46; box-shadow:0 12px 24px rgba(16,185,129,0.1); }
            .page-message { text-align:center; padding:40px 0; color:#475569; }
            .seat-section { margin-top: 40px; }
            .seat-section h3 { margin-bottom: 12px; }
        </style>
    </head>
    <body>
        <div class="Header" style="background:#0f172a;color:#fff;padding:16px 20px;border-bottom:1px solid #0f172a;">
            <h2 style="margin:0;">Admin Event Management</h2>
            <div class="buttons-container" style="display:flex; gap:10px;">
                <a href="AdminCreateEvent.jsp"><button class="btn">Create Event</button></a>
                <a href="MainPage.jsp"><button class="btn">Back to Main</button></a>
                <a href="MainPage.jsp"><button class="btn">Admin Home</button></a>
            </div>
        </div>

        <main class="admin-main">
            <h2>Events Overview</h2>

            <% if (flash != null) {%>
            <div class="flash"><%= flash%></div>
            <% } %>

            <% if (pageMessage != null && (events == null || events.isEmpty())) {%>
            <p class="page-message"><%= pageMessage%></p>
            <% } else if (events != null && !events.isEmpty()) { %>
            <div style="overflow-x:auto;">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Event</th>
                            <th>Venue</th>
                            <th>Date</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Event ev : events) {%>
                        <tr>
                            <td><%= ev.getEventId()%></td>
                            <td><%= ev.getEventName()%></td>
                            <td><%= ev.getVenue()%></td>
                            <td><%= ev.getEventDate() != null ? fmt.format(ev.getEventDate()) : "-"%></td>
                            <td><span class="status-pill <%= ev.getStatus() != null ? ev.getStatus() : ""%>"><%= ev.getStatus()%></span></td>
                            <td>
                                <form class="action-form" action="AdminUpdateEventStatusServlet" method="post">
                                    <input type="hidden" name="eventId" value="<%= ev.getEventId()%>">
                                    <select name="status">
                                        <option value="OPEN" <%= "OPEN".equals(ev.getStatus()) ? "selected" : ""%>>Open</option>
                                        <option value="CLOSED" <%= "CLOSED".equals(ev.getStatus()) ? "selected" : ""%>>Closed</option>
                                    </select>
                                    <button type="submit">Update</button>
                                </form>

                                <!-- NEW BUTTON: Create Seat -->
                                <form action="AdminCreateSeat.jsp" method="get">
                                    <input type="hidden" name="eventId" value="<%= ev.getEventId()%>">
                                    <button type="submit" style="background:#16a34a;">Create Seat</button>
                                </form> 


                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% }%>
            <section class="seat-section">
                <div class="panel">
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;">
                        <h3 style="margin:0;">Seat Types</h3>
                    </div>
                    <% if (seatMessage != null && (seatTypes == null || seatTypes.isEmpty())) { %>
                        <p class="page-message"><%= seatMessage %></p>
                    <% } else if (seatTypes != null && !seatTypes.isEmpty()) { %>
                        <div style="overflow-x:auto;">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Seat Type ID</th>
                                        <th>Event ID</th>
                                        <th>Seat Type</th>
                                        <th>Price (RM)</th>
                                        <th>Total Qty</th>
                                        <th>Remaining Qty</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (SeatType seat : seatTypes) { %>
                                    <tr>
                                        <td><%= seat.getSeatTypeId() %></td>
                                        <td><%= seat.getEventId() %></td>
                                        <td><%= seat.getSeatType() %></td>
                                        <td><%= String.format("%.2f", seat.getPrice()) %></td>
                                        <td><%= seat.getTotalQty() %></td>
                                        <td><%= seat.getRemainingQty() %></td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                </div>
            </section>
        </main>
    </body>
</html>
