<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Doctor Registration - JSP</title>
    <style>
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
            background: white;
            padding: 30px 40px;
            width: 100%;
            max-width: 450px;
            border-radius: 12px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
            text-align: center;
        }
        h2 {
            color: #023e8a;
            margin-bottom: 25px;
        }
        input, textarea {
            width: 100%;
            padding: 12px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 10px;
            font-size: 1rem;
            box-sizing: border-box;
        }
        button {
            width: 100%;
            padding: 12px;
            background: #0077b6;
            border: none;
            border-radius: 10px;
            color: white;
            font-size: 1.1rem;
            cursor: pointer;
        }
        button:hover {
            background: #005f87;
        }
        .message {
            font-weight: bold;
            margin-bottom: 15px;
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
<div class="form-container">

<%
    String message = "";
    boolean success = false;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String fullname = request.getParameter("fullname");
        String specialization = request.getParameter("specialization");
        String hospitalName = request.getParameter("hospital_name");
        String address = request.getParameter("address");
        String license = request.getParameter("license");
        String qualification = request.getParameter("qualification");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (fullname != null && specialization != null && license != null && qualification != null &&
            phone != null && email != null && hospitalName != null && address != null && password != null &&
            !fullname.isEmpty() && !specialization.isEmpty() && !license.isEmpty() && !qualification.isEmpty() &&
            !phone.isEmpty() && !email.isEmpty() && !hospitalName.isEmpty() && !address.isEmpty() && !password.isEmpty()) {

            Connection conn = null;
            PreparedStatement ps = null;
            try {
                Class.forName("com.mysql.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "root", "root");

                String sql = "INSERT INTO doctors (fullname, specialization, hospital_name, address, license, qualification, phone, email, password) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, fullname);
                ps.setString(2, specialization);
                ps.setString(3, hospitalName);
                ps.setString(4, address);
                ps.setString(5, license);
                ps.setString(6, qualification);
                ps.setString(7, phone);
                ps.setString(8, email);
                ps.setString(9, password); // For real-world applications, remember to hash passwords

                int rows = ps.executeUpdate();
                if (rows > 0) {
                    success = true;
                    message = "Registration successful! You can now login.";
                } else {
                    message = "Registration failed. Please try again.";
                }

            } catch (Exception e) {
                message = "Error: " + e.getMessage();
            } finally {
                if (ps != null) try { ps.close(); } catch (Exception ex) {}
                if (conn != null) try { conn.close(); } catch (Exception ex) {}
            }
        } else {
            message = "Please fill all the fields.";
        }
    }
%>

<% if (!message.isEmpty()) { %>
    <div class="message <%= success ? "success" : "error" %>"><%= message %></div>
    <% if (success) { %>
        <script>
            alert('Registration successful! You can now login.');
            window.location.href = 'doctorlogin.jsp';
        </script>
    <% } %>
<% } %>

<% if (!success) { %>
    <h2>Doctor Registration</h2>
    <form method="post" action="Doctor_register.jsp">
        <input type="text" name="fullname" placeholder="Full Name" required />
        <input type="text" name="specialization" placeholder="Specialization (e.g., Cardiologist)" required />
        <input type="text" name="hospital_name" placeholder="Hospital Name" required />
        <input type="text" name="address" placeholder="Address" required />
        <input type="text" name="license" placeholder="Medical License Number" required />
        <input type="text" name="qualification" placeholder="Qualification (e.g., MBBS, MD)" required />
        <input type="tel" name="phone" placeholder="Phone Number" pattern="[0-9]{10}" title="Enter 10-digit phone number" required />
        <input type="email" name="email" placeholder="Email Address" required />
        <input type="password" name="password" placeholder="Password" minlength="6" required />
        <button type="submit">Register</button>
    </form>
<% } %>

</div>
</body>
</html>
