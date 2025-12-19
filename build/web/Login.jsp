<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Login Form</title>
        <link rel="stylesheet" href="Css/login.css?v=2">
    </head>
    <body>
        <div class="gradient-backdrop">
            <span class="orb orb-large"></span>
            <span class="orb orb-small"></span>
        </div>
        <div class="login-wrapper">
            <div class="info-panel">
                <div class="brand-pill">NFT BlockChain Concert Ticketing System</div>
                <h1>Welcome Back</h1>
                <p>Sign up to Create a New Account to Start Purchasing Ticket !</p>
            </div>
            <div class="login-box">
                <h2>Login</h2>
                <form action="LoginServlet" method="POST">
                    <div class="textbox">
                        <input type="text" placeholder="Enter Your Email" name="email" required>
                    </div>
                    <div class="textbox">
                        <input type="password" placeholder="Enter Your Password" name="password" required>
                    </div>
                    <div class="button-container">
                        <button type="submit" class="btn">Login</button>
                    </div>
                    <div class="signup-link">
                        <p>Don't have an account? <a href="Signup.jsp">Sign Up</a></p>
                    </div>
                    <!-- Back link to main page -->
                    <p class="back-link"><a href="MainPage.jsp">Back to Main Page</a></p>
                </form>
            </div>
        </div>
    </body>
</html>
