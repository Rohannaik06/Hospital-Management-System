<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Patient Login - JSP</title>
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f0f4f8;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .form-container {
            background-color: white;
            padding: 30px 40px;
            border-radius: 12px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 400px;
        }
        h2 {
            text-align: center;
            color: #023e8a;
            margin-bottom: 25px;
        }
        input {
            width: 100%;
            padding: 12px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 10px;
            font-size: 1rem;
        }
        button {
            width: 100%;
            padding: 12px;
            background-color: #0077b6;
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 1.1rem;
            cursor: pointer;
        }
        button:hover {
            background-color: #005f87;
        }
        .switch-link {
            text-align: center;
            margin-top: 15px;
        }
        .switch-link a {
            color: #0077b6;
            text-decoration: none;
            font-weight: bold;
            cursor: pointer;
        }
        .hidden {
            display: none;
        }
        .message {
            text-align: center;
            margin-bottom: 15px;
            font-weight: bold;
        }
        .success {
            color: green;
        }
        .error {
            color: red;
        }
    </style>
</head>
<body>

<%
    String loginMessage = "";
    boolean loginSuccess = false;

    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("formType") != null && request.getParameter("formType").equals("login")) {
        String username = request.getParameter("email");
        String password = request.getParameter("password");

        if (username != null && password != null && !username.isEmpty() && !password.isEmpty()) {
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                Class.forName("com.mysql.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "root", "root");

                String sql = "SELECT fullname FROM patients WHERE username = ? AND password = ?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, username);
                ps.setString(2, password);
                rs = ps.executeQuery();

                if (rs.next()) {
                    String fullname = rs.getString("fullname");
                    
                    loginSuccess = true;
                    // Store the username and fullname in the session
                    session.setAttribute("user", username); 
                    session.setAttribute("fullname", fullname);
                    
                    loginMessage = "Login successful! Redirecting to dashboard...";
                } else {
                    loginMessage = "Invalid email or password.";
                }

            } catch (Exception e) {
                loginMessage = "Error: " + e.getMessage();
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception e) {}
                try { if (ps != null) ps.close(); } catch (Exception e) {}
                try { if (conn != null) conn.close(); } catch (Exception e) {}
            }
        } else {
            loginMessage = "Please fill in both fields.";
        }
    }
%>

<div class="form-container">

    <% if (!loginMessage.isEmpty()) { %>
        <div class="message <%= loginSuccess ? "success" : "error" %>"><%= loginMessage %></div>
        <% if (loginSuccess) { %>
            <meta http-equiv="refresh" content="2; URL=userdashbaord.jsp" />
        <% } %>
    <% } %>

    <div id="login-form" class="<%= loginSuccess ? "hidden" : "" %>">
        <h2>Patient Login</h2>
        <form method="post" action="patientlogin.jsp">
            <input type="hidden" name="formType" value="login" />
            <input type="text" name="email" placeholder="Email" required />
            <input type="password" name="password" placeholder="Password" minlength="6" required />
            <button type="submit">Login</button>
        </form>
        <div class="switch-link">
            Not registered? <a onclick="toggleForms()">Register here</a>
        </div>
    </div>

    <div id="register-form" class="hidden">
        <h2>Register</h2>
        <form method="post" action="register.jsp">
            <input type="text" name="fullname" placeholder="Full Name" required />
            <input type="text" name="address" placeholder="Address" required />
            <input type="tel" name="phone" placeholder="Phone Number" pattern="[0-9]{10}" title="Enter 10-digit phone number" required />
            <input type="text" name="username" placeholder="Username" required />
            <input type="password" name="password" placeholder="Password" minlength="6" required />
            <button type="submit">Register</button>
        </form>
        <div class="switch-link">
            Already registered? <a onclick="toggleForms()">Login here</a>
        </div>
    </div>

</div>

<script>
    function toggleForms() {
        const loginForm = document.getElementById('login-form');
        const registerForm = document.getElementById('register-form');
        loginForm.classList.toggle('hidden');
        registerForm.classList.toggle('hidden');
    }
</script>

</body>
</html>