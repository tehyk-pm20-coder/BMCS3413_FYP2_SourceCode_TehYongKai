<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    Integer approvedUserId = (Integer) request.getAttribute("approvedUserId");
    Double approvedAmount = (Double) request.getAttribute("approvedAmount");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Top-Up Approved</title>
        <link rel="stylesheet" href="Css/Header.css">
        <style>
            body {
                background: linear-gradient(135deg, #e0f2ff, #f8fafc);
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }
            .success-wrapper {
                display: flex;
                justify-content: center;
                align-items: center;
                flex: 1;
                padding: 40px 20px;
            }
            .success-card {
                max-width: 560px;
                width: 100%;
                background: #fff;
                border-radius: 24px;
                padding: 40px 36px;
                text-align: center;
                box-shadow: 0 30px 60px rgba(15, 118, 195, 0.25);
                border: 1px solid #cfe0ff;
            }
            .success-card h1 {
                color: #0f4c81;
                margin-bottom: 12px;
                font-size: 32px;
            }
            .success-card p {
                color: #475569;
                margin-bottom: 24px;
                font-size: 18px;
            }
            .success-meta {
                background: #f1f5ff;
                border-radius: 16px;
                padding: 18px;
                margin-bottom: 30px;
                color: #0f172a;
                font-weight: 600;
            }
            .action-row {
                display: flex;
                gap: 16px;
                flex-wrap: wrap;
                justify-content: center;
            }
            .action-row a {
                flex: 1;
                min-width: 180px;
                border-radius: 12px;
                padding: 14px;
                font-size: 16px;
                font-weight: 600;
                text-decoration: none;
                text-align: center;
            }
            .primary {
                background: #0f62fe;
                color: white;
                box-shadow: 0 15px 30px rgba(15, 98, 254, 0.3);
            }
            .secondary {
                background: #e2e8f0;
                color: #0f172a;
            }
        </style>
    </head>
    <body>
        <div class="Header">
            <h2>Top-Up Approval</h2>
        </div>
        <div class="success-wrapper">
            <section class="success-card">
                <h1>Top-Up Approved</h1>
                <p>The wallet has been updated successfully.</p>
                <div class="success-meta">
                    User ID: <%= approvedUserId != null ? approvedUserId : "-"%><br>
                    Amount Credited: RM <%= approvedAmount != null ? String.format("%.2f", approvedAmount) : "0.00"%>
                </div>
                <div class="action-row">
                    <a href="AdminTopupList.jsp" class="secondary">Back to Requests</a>
                    <a href="MainPage.jsp" class="primary">Return to Main Page</a>
                </div>
            </section>
        </div>
    </body>
</html>
