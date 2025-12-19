<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String eventId = request.getParameter("eventId");
    if (eventId == null) {
        response.sendRedirect("AdminManageEventServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Create Seat Type</title>
    <style>
        :root {
            --bg: linear-gradient(135deg, #0f172a, #111827 35%, #0b1220);
            --panel: #0f172a;
            --panel-border: rgba(255,255,255,0.08);
            --text-main: #e5e7eb;
            --text-muted: #9ca3af;
            --accent: #38bdf8;
            --accent-2: #a855f7;
            --input-bg: rgba(255,255,255,0.04);
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: "Inter", "Segoe UI", sans-serif;
            background: var(--bg);
            color: var(--text-main);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 32px 16px;
        }
        .card {
            width: min(520px, 100%);
            background: var(--panel);
            border: 1px solid var(--panel-border);
            border-radius: 16px;
            padding: 28px 26px;
            box-shadow: 0 30px 80px rgba(0,0,0,0.45);
        }
        .heading {
            margin: 0 0 18px;
            font-size: 22px;
            font-weight: 700;
        }
        .subheading {
            margin: 0 0 24px;
            color: var(--text-muted);
            font-size: 14px;
        }
        .badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            border-radius: 12px;
            background: rgba(56, 189, 248, 0.12);
            color: #bae6fd;
            border: 1px solid rgba(56,189,248,0.4);
            font-weight: 600;
            font-size: 13px;
        }
        form { display: grid; gap: 16px; }
        label {
            display: block;
            font-weight: 600;
            margin-bottom: 6px;
            color: var(--text-main);
            letter-spacing: 0.01em;
        }
        input[type="text"], input[type="number"] {
            width: 100%;
            padding: 12px 14px;
            border-radius: 10px;
            border: 1px solid var(--panel-border);
            background: var(--input-bg);
            color: var(--text-main);
            font-size: 15px;
        }
        input[type="text"]:focus, input[type="number"]:focus {
            outline: 2px solid rgba(56,189,248,0.35);
            border-color: rgba(56,189,248,0.5);
            box-shadow: 0 0 0 6px rgba(56,189,248,0.08);
        }
        .hint { color: var(--text-muted); font-size: 13px; margin-top: 4px; }
        .btn-primary {
            border: none;
            border-radius: 12px;
            padding: 13px 16px;
            background: linear-gradient(135deg, var(--accent), var(--accent-2));
            color: #0b1220;
            font-weight: 700;
            cursor: pointer;
            transition: transform 0.15s ease, box-shadow 0.2s ease;
            box-shadow: 0 16px 40px rgba(56,189,248,0.25);
        }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 20px 50px rgba(56,189,248,0.32); }
        .footer-links {
            margin-top: 18px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 14px;
            color: var(--text-muted);
            gap: 10px;
            flex-wrap: wrap;
        }
        .back-link {
            color: #bfdbfe;
            text-decoration: none;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .back-link:hover { color: #e0f2fe; }
    </style>
</head>
<body>
<div class="card">
    <div style="display:flex; justify-content: space-between; align-items:center; gap:12px; margin-bottom:10px;">
        <h2 class="heading">Create Seat Type</h2>
        <span class="badge">Event ID: <%= eventId %></span>
    </div>
    <p class="subheading">Define the seat category, set the face value, and publish inventory instantly.</p>
    <form action="AdminAddSeatServlet" method="post">
        <input type="hidden" name="eventId" value="<%= eventId %>">

        <div>
            <label for="seatType">Seat Type</label>
            <input type="text" id="seatType" name="seatType" placeholder="VIP, CAT 1, Rock Zone" required>
            <div class="hint">Use a clear label so buyers recognize the section.</div>
        </div>

        <div>
            <label for="price">Price (RM)</label>
            <input type="number" id="price" name="price" step="0.01" min="0" required>
            <div class="hint">Set the face value for this seat category.</div>
        </div>

        <div>
            <label for="totalQty">Total Quantity</label>
            <input type="number" id="totalQty" name="totalQty" min="1" required>
            <div class="hint">Total seats available for this category.</div>
        </div>

        <button type="submit" class="btn-primary">Save Seat Type</button>
    </form>
    <div class="footer-links">
        <a class="back-link" href="AdminManageEventServlet">&#8592; Back to Events</a>
        <span>Need changes later? Edit seats under Manage Event.</span>
    </div>
</div>
</body>
</html>
