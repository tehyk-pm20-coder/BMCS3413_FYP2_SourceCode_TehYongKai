<%@page import="java.util.List"%>
<%
    List<String> errors = (List<String>) request.getAttribute("errorMessages");
    String serverMessage = (String) request.getAttribute("serverMessage");
    String backLink = (String) request.getAttribute("backLink");
    if (backLink == null || backLink.isEmpty()) {
        backLink = "Login.jsp";
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Login Failed</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body {
                background: linear-gradient(135deg, #0f172a, #1e2945);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                color: #fff;
            }
            .failure-card {
                background: rgba(15, 15, 35, 0.85);
                border-radius: 28px;
                padding: 40px 48px;
                width: min(520px, 90%);
                box-shadow: 0 25px 70px rgba(0, 0, 0, 0.4);
                border: 1px solid rgba(255, 255, 255, 0.12);
                text-align: center;
            }
            .failure-card h1 {
                margin-bottom: 12px;
                font-size: 28px;
                color: #ffe4e6;
            }
            .failure-card p {
                margin: 0 0 20px;
                color: #d7def5;
            }
            .error-list {
                list-style: none;
                padding: 0;
                margin: 0 0 20px;
                text-align: left;
            }
            .error-list li {
                background: rgba(255, 71, 87, 0.1);
                border: 1px solid rgba(255, 71, 87, 0.3);
                padding: 10px 14px;
                border-radius: 12px;
                margin-bottom: 10px;
                color: #ff99a3;
                font-weight: 600;
            }
            .retry-btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 12px 28px;
                border-radius: 999px;
                background: linear-gradient(135deg, #ff4f6d, #f97316);
                color: #fff;
                font-size: 16px;
                font-weight: 600;
                text-decoration: none;
                box-shadow: 0 18px 40px rgba(249, 115, 22, 0.4);
                transition: transform 0.2s ease, box-shadow 0.2s ease;
            }
            .retry-btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 25px 45px rgba(249, 115, 22, 0.55);
            }
            .hint {
                margin-top: 16px;
                font-size: 14px;
                color: #cbd5f5;
            }
        </style>
    </head>
    <body>
        <section class="failure-card">
            <h1>Login Unsuccessful</h1>
            <p>Please review the information below and try again.</p>
            <% if (errors != null && !errors.isEmpty()) { %>
            <ul class="error-list">
                <% for (String err : errors) { %>
                <li><%= err %></li>
                <% } %>
            </ul>
            <% } else if (serverMessage != null) { %>
            <ul class="error-list">
                <li><%= serverMessage %></li>
            </ul>
            <% } %>
            <a href="<%= backLink %>" class="retry-btn">Return to Login</a>
            <div class="hint">You'll be redirected to the login page.</div>
        </section>
        <script>
            setTimeout(function () {
                window.location.href = "<%= backLink %>";
            }, 6000);
        </script>
    </body>
</html>
