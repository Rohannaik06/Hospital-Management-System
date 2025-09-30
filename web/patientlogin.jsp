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
        .register-link {
            text-align: center;
            margin-top: 16px;
            font-size: 14px;
        }
        .register-link a {
            color: #0077b6;
            text-decoration: none;
            font-weight: 600;
        }
        .register-link a:hover {
            text-decoration: underline;
            cursor: pointer;
        }
    </style>
</head>
<body>

<%
    String loginMessage = "";
    boolean loginSuccess = false;

    if ("POST".equalsIgnoreCase(request.getMethod()) && "login".equals(request.getParameter("formType"))) {
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

    <h2>Patient Login</h2>
    <form method="post" action="patientlogin.jsp">
        <input type="hidden" name="formType" value="login" />
        <input type="text" name="email" placeholder="Email" required />
        <input type="password" name="password" placeholder="Password" minlength="6" required />
        <button type="submit">Login</button>
    </form>

    <div class="register-link">
        Not registered? <a href="register.jsp">Create an account</a>
    </div>
</div>

</body>
</html>
