<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Sign Up Form</title>
        <link rel="stylesheet" href="Css/signup.css?v=2">
    </head>
    <body>

        <div class="gradient-backdrop">
            <span class="orb orb-large"></span>
            <span class="orb orb-small"></span>
        </div>
        <div class="signup-wrapper">

            <div class="signup-container">
                <div class="signup-box">
                    <%
                        java.util.List<String> errors = (java.util.List<String>) request.getAttribute("errors");
                        String errorMessage = (String) request.getAttribute("errorMessage");
                        String successMessage = (String) request.getAttribute("successMessage");
                    %>
                    <h2>Create Account</h2>

                    <% if ((errors != null && !errors.isEmpty()) || errorMessage != null) { %>
                        <div class="form-alert form-alert-error">
                            <div class="form-alert-icon">!</div>
                            <div class="form-alert-body">
                                <h4>Let's fix a few details</h4>
                                <% if (errors != null && !errors.isEmpty()) { %>
                                    <ul>
                                        <% for (String error : errors) { %>
                                            <li><%= error %></li>
                                        <% } %>
                                    </ul>
                                <% } %>
                                <% if (errorMessage != null) { %>
                                    <p><%= errorMessage %></p>
                                <% } %>
                                <p class="hint">Passwords must be at least 10 characters long and meet all strength rules.</p>
                            </div>
                        </div>
                    <% } %>

                    <% if (successMessage != null) { %>
                        <div class="form-alert form-alert-success">
                            <div class="form-alert-icon">&#10003;</div>
                            <div class="form-alert-body">
                                <h4>You're all set!</h4>
                                <p><%= successMessage %></p>
                                <p class="hint">Use your email and password below to log in.</p>
                                <div class="alert-actions">
                                    <a class="pill-button" href="Login.jsp">Proceed to Login</a>
                                </div>
                            </div>
                        </div>
                    <% } %>

                    <form action="SignUpRegistration" method="POST">
                        <div class="textbox">
                            <input type="text" placeholder="Full Name" name="fullname" required>
                            <p class="field-hint">8-30 characters, letters and numbers only. Please avoid symbols or spaces.</p>
                        </div>
                        <div class="textbox">
                            <input type="tel" placeholder="Phone Number" name="phone" required>
                            <p class="field-hint">Digits only, minimum 9 and maximum 13 digits (e.g. 0123456789).</p>
                        </div>
                        <div class="textbox">
                            <input type="email" placeholder="Email Address" name="email" required>
                            <p class="field-hint">Use a valid email format. Each email can only be registered once.</p>
                        </div>
                        <div class="textbox">
                            <input type="date" placeholder="Date of Birth" name="dob" required>
                            <p class="field-hint">You must be at least 13 years old. Future dates are not allowed.</p>
                        </div>
                        <div class="textbox">
                            <input type="password" placeholder="Password" name="password" required>
                            <p class="field-hint">
                                At least 10 characters, including uppercase, lowercase, number, and special character (e.g. ! @ #).
                            </p>
                        </div>
                        <div class="button-container">
                            <button type="submit">Sign Up</button>
                        </div>
                    </form>

                    <p class="login-link">Already have an account? <a href="Login.jsp">Login</a></p>
                    <!-- Back link to main page -->
                <p class="back-link"><a href="MainPage.jsp">Back to Main Page</a></p>
                </div>
            </div>
    </body>
</html>
