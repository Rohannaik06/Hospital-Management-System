<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Patient Registration</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f0f4f8;
            margin: 0;
            padding: 0;
            height: 100vh;
        }
        .wrapper {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100%;
            transition: filter 0.3s ease;
        }
        .blur {
            filter: blur(4px);
        }
        .form-container {
            background-color: white;
            padding: 30px 40px;
            border-radius: 12px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 400px;
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
        h2 {
            color: #023e8a;
            text-align: center;
            margin-bottom: 25px;
        }
        .message {
            text-align: center;
            margin-bottom: 15px;
            font-weight: bold;
            color: green;
        }
        .error {
            color: red;
        }
        /* Modal */
        .modal {
            display: none;
            position: fixed;
            z-index: 999;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            backdrop-filter: blur(4px);
            background-color: rgba(0, 0, 0, 0.3);
            justify-content: center;
            align-items: center;
        }
        .modal-content {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            text-align: center;
            box-shadow: 0 8px 20px rgba(0,0,0,0.2);
        }
        .modal-content h3 {
            color: #2a9d8f;
            margin-bottom: 20px;
        }
        .modal-content a {
            display: inline-block;
            margin-top: 10px;
            padding: 10px 20px;
            background-color: #0077b6;
            color: white;
            text-decoration: none;
            border-radius: 8px;
        }
        .modal-content a:hover {
            background-color: #005f87;
        }
    </style>
</head>
<body>

<div class="wrapper" id="mainWrapper">
    <div class="form-container">

<%
    String message = "";
    boolean isError = false;
    boolean showSuccessModal = false;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String fullname = request.getParameter("fullname");
        String address = request.getParameter("address");
        String phone = request.getParameter("phone");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (fullname == null || address == null || phone == null || username == null || password == null ||
            fullname.trim().isEmpty() || address.trim().isEmpty() || phone.trim().isEmpty() || username.trim().isEmpty() || password.trim().isEmpty()) {
            message = "Please fill in all fields.";
            isError = true;
        } else {
            Connection conn = null;
            PreparedStatement ps = null;
            try {
                Class.forName("com.mysql.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "root", "root");

                // Check if username already exists
                String checkSql = "SELECT COUNT(*) FROM patients WHERE username = ?";
                ps = conn.prepareStatement(checkSql);
                ps.setString(1, username);
                ResultSet rs = ps.executeQuery();
                rs.next();
                int count = rs.getInt(1);
                rs.close();
                ps.close();

                if (count > 0) {
                    message = "Username already taken. Please choose another.";
                    isError = true;
                } else {
                    String sql = "INSERT INTO patients (fullname, address, phone, username, password) VALUES (?, ?, ?, ?, ?)";
                    ps = conn.prepareStatement(sql);
                    ps.setString(1, fullname);
                    ps.setString(2, address);
                    ps.setString(3, phone);
                    ps.setString(4, username);
                    ps.setString(5, password); // Should hash in real apps

                    int result = ps.executeUpdate();

                    if (result > 0) {
                        showSuccessModal = true;
                    } else {
                        message = "Registration failed. Please try again.";
                        isError = true;
                    }
                }

            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                isError = true;
            } finally {
                try { if (ps != null) ps.close(); } catch (Exception e) {}
                try { if (conn != null) conn.close(); } catch (Exception e) {}
            }
        }
    }
%>

<h2>Patient Registration</h2>

<% if (!message.isEmpty()) { %>
    <div class="message <%= isError ? "error" : "" %>"><%= message %></div>
<% } %>

<form method="post" action="register.jsp">
    <input type="text" name="fullname" placeholder="Full Name" required />
    <input type="text" name="address" placeholder="Address" required />
    <input type="tel" name="phone" placeholder="Phone Number" pattern="[0-9]{10}" title="Enter 10-digit phone number" required />
    <input type="text" name="username" placeholder="Username" required />
    <input type="password" name="password" placeholder="Password" minlength="6" required />
    <button type="submit">Register</button>
</form>

    </div>
</div>

<% if (showSuccessModal) { %>
    <script>
        document.addEventListener("DOMContentLoaded", function() {
            document.getElementById("mainWrapper").classList.add("blur");
            document.getElementById("successModal").style.display = "flex";
        });
    </script>
<% } %>

<div class="modal" id="successModal">
    <div class="modal-content">
        <h3>Registered Successfully!</h3>
        <a href="patientlogin.jsp">Go to Login</a>
    </div>
</div>

</body>
</html>
