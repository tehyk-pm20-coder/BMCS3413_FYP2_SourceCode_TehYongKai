<%@ page import="java.util.List" %>
<%@ page import="model.BlockAuditRecord" %>
<%
    List<BlockAuditRecord> records = (List<BlockAuditRecord>) request.getAttribute("records");
    String message = (String) request.getAttribute("message");
    List<BlockAuditRecord> tamperedRecords = (List<BlockAuditRecord>) request.getAttribute("tamperedRecords");

    if (records == null && message == null) {
        response.sendRedirect("AdminViewBlockServlet");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Blockchain Audit Trail</title>
        <style>
            :root {
                --bg: #0f172a;
                --card: rgba(15, 23, 42, 0.85);
                --border: rgba(255, 255, 255, 0.08);
                --text: #f8fafc;
                --muted: #94a3b8;
                --accent: #38bdf8;
                --accent-dark: #0ea5e9;
            }

            * {
                box-sizing: border-box;
                font-family: 'Segoe UI', 'Inter', sans-serif;
            }

            body {
                margin: 0;
                min-height: 100vh;
                background: radial-gradient(circle at top, rgba(56, 189, 248, 0.4), transparent 55%),
                            radial-gradient(circle at bottom left, rgba(14, 165, 233, 0.3), transparent 60%),
                            var(--bg);
                color: var(--text);
                padding: 40px 24px 60px;
            }

            .page-header {
                max-width: 1200px;
                margin: 0 auto 24px;
            }

            h1 {
                margin: 0 0 8px;
                font-size: clamp(26px, 3vw, 34px);
            }

            .page-header p {
                margin: 0;
                color: var(--muted);
            }

            .card {
                max-width: 1200px;
                margin: 0 auto;
                background: var(--card);
                border: 1px solid var(--border);
                border-radius: 24px;
                padding: 24px;
                box-shadow: 0 30px 80px rgba(14, 165, 233, 0.18);
            }

            table {
                width: 100%;
                border-collapse: collapse;
            }

            thead th {
                text-align: left;
                padding: 14px 12px;
                font-size: 13px;
                letter-spacing: 0.06em;
                text-transform: uppercase;
                color: var(--muted);
                border-bottom: 1px solid var(--border);
            }

            tbody td {
                padding: 16px 12px;
                border-bottom: 1px solid rgba(148, 163, 184, 0.15);
                vertical-align: top;
                font-size: 15px;
            }

            tbody tr:hover {
                background: rgba(56, 189, 248, 0.08);
            }

            .hash {
                font-family: 'Fira Code', 'Consolas', monospace;
                font-size: 13px;
                word-break: break-all;
            }

            .badge {
                display: inline-flex;
                align-items: center;
                padding: 4px 10px;
                border-radius: 999px;
                background: rgba(56, 189, 248, 0.15);
                color: var(--accent);
                font-size: 13px;
            }

            .message {
                padding: 16px 18px;
                border-radius: 18px;
                border: 1px dashed var(--border);
                color: var(--muted);
                background: rgba(15, 23, 42, 0.6);
            }

            .muted {
                color: var(--muted);
                font-size: 13px;
            }

            .tamper-alert {
                border: 1px solid rgba(248, 113, 113, 0.4);
                background: rgba(248, 113, 113, 0.12);
                color: #fecaca;
                padding: 18px 20px;
                border-radius: 20px;
                margin-bottom: 18px;
            }

            .tamper-alert strong {
                color: #fee2e2;
            }

            .row-tampered {
                background: rgba(248, 113, 113, 0.12) !important;
            }

            .badge.danger {
                background: rgba(239, 68, 68, 0.15);
                color: #f87171;
            }

            .actions {
                margin-top: 18px;
                display: flex;
                gap: 12px;
            }

            .btn-link {
                padding: 10px 18px;
                border-radius: 999px;
                background: var(--accent);
                color: #0f172a;
                text-decoration: none;
                font-weight: 600;
                transition: box-shadow 0.2s ease;
            }

            .btn-link:hover {
                box-shadow: 0 15px 30px rgba(8, 145, 178, 0.35);
            }

            @media (max-width: 900px) {
                table, thead, tbody, th, td, tr {
                    display: block;
                }

                thead {
                    display: none;
                }

                tbody tr {
                    margin-bottom: 18px;
                    border: 1px solid var(--border);
                    border-radius: 16px;
                    padding: 14px;
                }

                tbody td {
                    border-bottom: none;
                    padding: 8px 0;
                }

                tbody td::before {
                    content: attr(data-label);
                    display: block;
                    font-size: 12px;
                    text-transform: uppercase;
                    letter-spacing: 0.07em;
                    color: var(--muted);
                    margin-bottom: 2px;
                }
            }
        </style>
    </head>
    <body>
        <div class="page-header">
            <h1>Blockchain Audit Trail</h1>
            <p>Monitor every ticket block stored on-chain with links to their origin records.</p>
        </div>

        <div class="card">
            <% if (tamperedRecords != null && !tamperedRecords.isEmpty()) { %>
                <div class="tamper-alert">
                    <strong>Integrity Warning:</strong> The following tickets appear to be tampered with.
                    <ul>
                        <% for (BlockAuditRecord tampered : tamperedRecords) { %>
                            <li>Ticket ID <%= tampered.getTicketId() %> (Block #<%= tampered.getBlockId() %>)</li>
                        <% } %>
                    </ul>
                </div>
            <% } %>

            <% if (message != null) { %>
                <div class="message"><%= message %></div>
            <% } else if (records != null && !records.isEmpty()) { %>
                <div class="actions">
                    <a class="btn-link" href="AdminViewBlockServlet">Refresh Ledger</a>
                    <a class="btn-link" href="AdminManageEventServlet">Back to Admin</a>
                </div>
                <div style="overflow-x: auto; margin-top: 18px;">
                    <table>
                        <thead>
                            <tr>
                                <th>Block ID</th>
                                <th>Ticket</th>
                                <th>User</th>
                                <th>Event / Seat</th>
                                <th>Hashes</th>
                                <th>Purchase Time</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (BlockAuditRecord record : records) { 
                                   String rowClass = record.isTampered() ? "row-tampered" : "";
                            %>
                                <tr class="<%= rowClass %>">
                                    <td data-label="Block ID">
                                        <div class="badge <%= record.isTampered() ? "danger" : "" %>">
                                            #<%= record.getBlockId() %>
                                            <% if (record.isTampered()) { %>
                                                &nbsp;Tampered
                                            <% } %>
                                        </div>
                                    </td>
                                    <td data-label="Ticket">
                                        <strong>ID:</strong> <%= record.getTicketId() %><br>
                                        <span class="muted">RM <%= String.format("%.2f", record.getPrice()) %></span>
                                    </td>
                                    <td data-label="User">
                                        <%= record.getFullName() != null ? record.getFullName() : "Unassigned" %><br>
                                        <span class="muted">User ID: <%= record.getUserId() %></span>
                                    </td>
                                    <td data-label="Event / Seat">
                                        <strong><%= record.getEventName() %></strong><br>
                                        Seat: <%= record.getSeatType() %>
                                    </td>
                                    <td data-label="Hashes">
                                        <div class="hash">Prev: <%= record.getPreviousHash() %></div>
                                        <div class="hash">Stored: <%= record.getBlockHash() %></div>
                                        <div class="hash">Recomputed: <%= record.getRecomputedHash() %></div>
                                    </td>
                                    <td data-label="Purchase Time">
                                        <%= record.getPurchaseTime() %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } else { %>
                <div class="message">No blockchain entries were found.</div>
            <% } %>
        </div>
    </body>
</html>
