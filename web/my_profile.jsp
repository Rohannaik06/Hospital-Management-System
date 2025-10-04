<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Profile</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f6f9;
            color: #333;
        }

        /* Header */
        .main-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #0a4275;
            color: white;
            padding: 16px 30px;
            position: sticky;
            top: 0;
            z-index: 1000;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .left-section { display: flex; align-items: center; }
        #menuToggle {
            font-size: 30px; background: none; border: none; color: white; margin-right: 20px;
            cursor: pointer; user-select: none;
        }
        .logo-text { font-size: 26px; font-weight: 600; user-select: none; }
        .right-section { position: relative; display: flex; align-items: center; }
        .profile-dropdown { cursor: pointer; display: flex; align-items: center; gap: 12px; }
        .profile-photo-header {
            width: 50px; height: 50px; background: white; border-radius: 50%;
            display: flex; justify-content: center; align-items: center;
            box-shadow: 0 0 6px rgba(0,0,0,0.1);
            font-size: 28px; color: #0077b6;
        }
        .profile-name-header { font-weight: 600; font-size: 1.25rem; }
        .dropdown-menu {
            display: none; position: absolute; right: 0; top: 58px; background: white;
            border: 1px solid #ccc; border-radius: 6px; min-width: 190px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1); z-index: 1001;
        }
        .dropdown-menu a {
            display: block; padding: 14px 20px; color: #333; text-decoration: none; font-size: 16px;
        }
        .dropdown-menu a:hover { background: #f5f5f5; }
        .dropdown-menu a.logout-link { color: #e63946; font-weight: 600; }
        .dropdown-menu a.logout-link:hover { background: #b22222; color: white; }

        /* Sidebar */
        .sidebar {
            width: 280px; background: #1f2b3e; position: fixed; top: 70px; left: -300px;
            height: 100%; transition: 0.3s ease; z-index: 999; padding-top: 25px;
        }
        .sidebar.active { left: 0; }
        .sidebar a {
            display: block; padding: 18px 24px; color: #fff; font-size: 18px; text-decoration: none;
        }
        .sidebar a:hover { background: #374b68; }
        .sidebar a.logout-link { color: #e63946; font-weight: 600; }
        .sidebar a.logout-link:hover { background: #b22222; color: white; }

        /* Content */
        .dashboard-content {
            margin-left: 0; padding: 36px 48px; transition: margin-left 0.3s ease;
            min-height: calc(100vh - 120px);
        }
        .sidebar.active ~ .dashboard-content { margin-left: 280px; }

        /* Footer */
        footer {
            background: #023e8a; color: white; text-align: center; padding: 18px 10px;
            font-size: 1rem; position: fixed; width: 100%; bottom: 0; left: 0;
        }
        footer a { color: #90e0ef; text-decoration: none; }
        footer a:hover { text-decoration: underline; }

        @media (max-width: 768px) {
            .dashboard-content { margin-left: 0 !important; padding: 20px; }
            .sidebar { top: 60px; }
            footer { position: static; }
        }

        /* Profile Page Styles */
        .profile-container {
            max-width: 1100px; margin: 50px auto; background: #fff;
            border-radius: 10px; padding: 36px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .profile-header-content {
            display: flex; align-items: center; gap: 30px;
            border-bottom: 2px solid #eee; padding-bottom: 24px; margin-bottom: 24px;
        }
        .profile-photo {
            width: 120px; height: 120px; background: #0a4275; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 50px; color: white; box-shadow: 0 0 8px rgba(0,0,0,0.15);
        }
        .profile-basic h2 { font-size: 28px; font-weight: 700; color: #0a4275; margin: 0; }
        .profile-basic p { margin: 7px 0 0; font-size: 17px; color: #666; }
        .profile-details {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(290px, 1fr)); gap: 24px;
        }
        .detail-card {
            background: #fafafa; padding: 24px; border-radius: 8px; border: 1px solid #eee;
        }
        .detail-card h3 { font-size: 20px; font-weight: 600; color: #0077b6; margin-top: 0; }
        .detail-card p { font-size: 16px; color: #444; margin: 8px 0 0; }
        .update-btn {
            display: inline-block; margin-top: 28px; padding: 13px 30px;
            background: #0a4275; color: white; border-radius: 6px; text-decoration: none;
            transition: 0.3s;
        }
        .update-btn:hover { background: #06508d; }
    </style>
</head>
<body>

<%
    String fullname = (String) session.getAttribute("fullname");
    if (fullname == null || fullname.isEmpty()) {
        response.sendRedirect("doctorlogin.jsp");
        return;
    }

    // Variables to hold doctor details
    String hospitalName = "Unknown Hospital";
    String email = "";
    String phone = "";
    String specialization = "";
    String address = "";
    String qualification = "";
    String license = "";
    Connection conn = null; 
    PreparedStatement ps = null; 
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");
        String sql = "SELECT hospital_name, email, phone, specialization, address, qualification, license FROM doctors WHERE LOWER(TRIM(fullname)) = LOWER(TRIM(?))";
        ps = conn.prepareStatement(sql);
        ps.setString(1, fullname);
        rs = ps.executeQuery();
        if (rs.next()) {
            hospitalName = rs.getString("hospital_name");
            email = rs.getString("email");
            phone = rs.getString("phone");
            specialization = rs.getString("specialization");
            address = rs.getString("address");
            qualification = rs.getString("qualification");
            license = rs.getString("license");
        }
    } catch (Exception e) {
        out.println("Database error: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) {}
        try { if (ps != null) ps.close(); } catch (SQLException e) {}
        try { if (conn != null) conn.close(); } catch (SQLException e) {}
    }
%>

<!-- Header -->
<header class="main-header">
    <div class="left-section">
        <button id="menuToggle">☰</button>
        <div class="logo-text"><%= hospitalName %></div>
    </div>
    <div class="right-section">
        <div class="profile-dropdown" onclick="toggleDropdown()">
            <div class="profile-photo-header">👨‍⚕️</div>
            <div class="profile-name-header"><%= fullname %></div>
            <div class="dropdown-menu" id="dropdownMenu">
                <a href="my_profile.jsp">My Profile</a>
                <a href="doctor_dashboard.jsp">Appointments</a>
                <a href="doctorlogin.jsp" class="logout-link">Logout</a>
            </div>
        </div>
    </div>
</header>

<!-- Sidebar -->
<nav class="sidebar" id="sidebar">
    <a href="my_profile.jsp">My Profile</a>
    <a href="doctor_dashboard.jsp">Appointments</a>
    <a href="#">Patients</a>
    <a href="#">Settings</a>
    <a href="#">About Us</a>
    <a href="#">Contact</a>
    <a href="doctorlogin.jsp" class="logout-link">Logout</a>
</nav>

<!-- Main Content -->
<div class="dashboard-content">
    <div class="profile-container">
        <div class="profile-header-content">
            <div class="profile-photo">👨‍⚕️</div>
            <div class="profile-basic">
                <h2><%= fullname %></h2>
                <p>Specialist: <%= specialization %></p>
                <p>Hospital: <span style="font-weight:600; color:#023e8a;"><%= hospitalName %></span></p>
            </div>
        </div>

        <div class="profile-details">
            <div class="detail-card">
                <h3>Contact Information</h3>
                <p>Email: <%= email %></p>
                <p>Phone: <%= phone %></p>
            </div>
            <div class="detail-card">
                <h3>Professional Details</h3>
                <p>Qualification: <%= qualification %></p>
                <p>License No.: <%= license %></p>
            </div>
            <div class="detail-card">
                <h3>Address</h3>
                <p><%= address %></p>
            </div>
        </div>

        <a href="edit_profile.jsp" class="update-btn">Edit Profile</a>
    </div>
</div>

<!-- Footer -->
<footer>
    &copy; 2025 Health Portal. All rights reserved.
</footer>

<!-- JS -->
<script>
    const menuToggle = document.getElementById("menuToggle");
    const sidebar = document.getElementById("sidebar");
    const dropdownMenu = document.getElementById("dropdownMenu");

    menuToggle.addEventListener("click", () => {
        sidebar.classList.toggle("active");
    });
    function toggleDropdown() {
        dropdownMenu.style.display = (dropdownMenu.style.display === "block") ? "none" : "block";
    }
    window.addEventListener("click", (e) => {
        if (!e.target.closest(".profile-dropdown")) {
            dropdownMenu.style.display = "none";
        }
    });
</script>

</body>
</html>
