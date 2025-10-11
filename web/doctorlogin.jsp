<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--Doctor--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Doctor Login - JSP</title>
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

    if ("POST".equalsIgnoreCase(request.getMethod()) && "login".equals(request.getParameter("formType"))) {
        String username = request.getParameter("email");
        String password = request.getParameter("password");

        if (username != null && !username.isEmpty() && password != null && !password.isEmpty()) {
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                Class.forName("com.mysql.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "root", "root");

                String sql = "SELECT fullname FROM doctors WHERE email = ? AND password = ?";
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
                if (rs != null) try { rs.close(); } catch (Exception ex) {}
                if (ps != null) try { ps.close(); } catch (Exception ex) {}
                if (conn != null) try { conn.close(); } catch (Exception ex) {}
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
            <meta http-equiv="refresh" content="2; URL=doctor_dashboard.jsp" />
        <% } %>
    <% } %>

    <div id="login-form" class="<%= loginSuccess ? "hidden" : "" %>">
        <h2>Doctor Login</h2>
        <form method="post" action="doctorlogin.jsp">
            <input type="hidden" name="formType" value="login" />
            <input type="text" name="email" placeholder="Email" required />
            <input type="password" name="password" placeholder="Password" minlength="6" required />
            <button type="submit">Login</button>
        </form>
        <div class="switch-link">
            Not registered? <a href="Doctor_register.jsp">Register here</a>
        </div>
    </div>

</div>

</body>
</html>
