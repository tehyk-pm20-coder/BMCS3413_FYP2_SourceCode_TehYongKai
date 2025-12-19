<%@ page language="java" %>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %>

<!DOCTYPE html>
<html>
    <head>
        <title>Create Event</title>
        <style>
            body {
                font-family: "Segoe UI", Arial, sans-serif;
                padding: 40px;
                background: radial-gradient(circle at 20% 20%, #e0f2ff, #f8fafc 45%);
                color: #0f172a;
            }
            .shell { max-width: 780px; margin: 0 auto; }
            .flash {
                background:#d1fae5;
                color:#065f46;
                padding:12px 16px;
                margin-bottom:18px;
                border-radius:10px;
                border:1px solid #bbf7d0;
                box-shadow:0 10px 30px rgba(16,185,129,0.15);
            }
            .card {
                background: #fff;
                border-radius: 16px;
                padding: 28px 32px;
                box-shadow: 0 24px 60px rgba(15,23,42,0.12);
                border: 1px solid #e2e8f0;
            }
            h2 { margin: 0 0 10px; }
            .subtitle { margin:0 0 22px; color:#475569; }
            label {
                display:block;
                font-weight:700;
                font-size:14px;
                margin-top:14px;
                color:#0f172a;
            }
            input[type="text"],
            input[type="datetime-local"],
            input[type="file"] {
                width:97%;
                padding:12px 14px;
                margin-top:8px;
                border-radius:10px;
                border:1px solid #cbd5e1;
                background:#f8fafc;
                font-size:15px;
            }
            input[type="file"] {
                padding:10px;
                background:#fff;
            }
            button {
                margin-top:18px;
                padding:12px 16px;
                width:100%;
                background: linear-gradient(135deg, #0f62fe, #2563eb);
                border:none;
                color:#fff;
                font-weight:700;
                border-radius:12px;
                cursor:pointer;
                box-shadow:0 14px 30px rgba(37,99,235,0.25);
                transition: transform 0.1s ease, box-shadow 0.1s ease;
            }
            button:hover { transform: translateY(-1px); box-shadow:0 18px 36px rgba(37,99,235,0.3); }
            button:active { transform: translateY(0); }
        </style>
    </head>

    <body>
        <div class="shell">
            <%
                String message = (String) session.getAttribute("eventMessage");
                if (message != null) {
            %>
            <div class="flash"><%= message%></div>
            <%
                    session.removeAttribute("eventMessage");
                }
            %>

            <div class="card">
                <h2>Create New Event</h2>
                <p class="subtitle">Fill in the event details and upload a cover image.</p>

                <form action="AdminCreateEventServlet" method="post" enctype="multipart/form-data">

                    <label>Event Name</label>
                    <input type="text" name="eventName" required>

                    <label>Venue</label>
                    <input type="text" name="venue" required>

                    <label>Event Date & Time</label>
                    <input type="datetime-local" name="eventDate" required>

                    <label>Event Image</label>
                    <input type="file" name="eventImage" accept="image/*" required>

                    <button type="submit">Create Event</button>
                </form>
                <div style="margin-top:12px; text-align:right;">
                    <a href="MainPage.jsp" style="color:#0f62fe; font-weight:700; text-decoration:none;">Back to Main</a>
                </div>
            </div>
        </div>
    </body>
</html>
