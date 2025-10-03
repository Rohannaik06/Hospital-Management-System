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
            padding: 12px 24px;
            position: sticky;
            top: 0;
            z-index: 1000;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .left-section { display: flex; align-items: center; }
        #menuToggle {
            font-size: 26px; background: none; border: none; color: white; margin-right: 15px;
            cursor: pointer; user-select: none;
        }
        .logo-text { font-size: 22px; font-weight: 600; user-select: none; }
        .right-section { position: relative; display: flex; align-items: center; }
        .profile-dropdown { cursor: pointer; display: flex; align-items: center; gap: 10px; }
        .profile-photo-header {
            width: 42px; height: 42px; background: white; border-radius: 50%;
            display: flex; justify-content: center; align-items: center;
            box-shadow: 0 0 6px rgba(0,0,0,0.1);
            font-size: 24px; color: #0077b6;
        }
        .profile-name-header { font-weight: 600; font-size: 1.1rem; }
        .dropdown-menu {
            display: none; position: absolute; right: 0; top: 48px; background: white;
            border: 1px solid #ccc; border-radius: 5px; min-width: 170px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1); z-index: 1001;
        }
        .dropdown-menu a {
            display: block; padding: 12px 16px; color: #333; text-decoration: none; font-size: 15px;
        }
        .dropdown-menu a:hover { background: #f5f5f5; }
        .dropdown-menu a.logout-link { color: #e63946; font-weight: 600; }
        .dropdown-menu a.logout-link:hover { background: #b22222; color: white; }

        /* Sidebar */
        .sidebar {
            width: 240px; background: #1f2b3e; position: fixed; top: 60px; left: -260px;
            height: 100%; transition: 0.3s ease; z-index: 999; padding-top: 20px;
        }
        .sidebar.active { left: 0; }
        .sidebar a {
            display: block; padding: 15px 20px; color: #fff; font-size: 16px; text-decoration: none;
        }
        .sidebar a:hover { background: #374b68; }
        .sidebar a.logout-link { color: #e63946; font-weight: 600; }
        .sidebar a.logout-link:hover { background: #b22222; color: white; }

        /* Content */
        .dashboard-content {
            margin-left: 0; padding: 30px 40px; transition: margin-left 0.3s ease;
            min-height: calc(100vh - 120px);
        }
        .sidebar.active ~ .dashboard-content { margin-left: 240px; }

        /* Footer */
        footer {
            background: #023e8a; color: white; text-align: center; padding: 15px 10px;
            font-size: 0.9rem; position: fixed; width: 100%; bottom: 0; left: 0;
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
            max-width: 900px; margin: 40px auto; background: #fff;
            border-radius: 10px; padding: 30px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .profile-header-content {
            display: flex; align-items: center; gap: 25px;
            border-bottom: 2px solid #eee; padding-bottom: 20px; margin-bottom: 20px;
        }
        .profile-photo {
            width: 100px; height: 100px; background: #0a4275; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 40px; color: white; box-shadow: 0 0 8px rgba(0,0,0,0.15);
        }
        .profile-basic h2 { font-size: 24px; font-weight: 700; color: #0a4275; margin: 0; }
        .profile-basic p { margin: 5px 0 0; font-size: 15px; color: #666; }
        .profile-details {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px;
        }
        .detail-card {
            background: #fafafa; padding: 20px; border-radius: 8px; border: 1px solid #eee;
        }
        .detail-card h3 { font-size: 18px; font-weight: 600; color: #0077b6; margin-top: 0; }
        .detail-card p { font-size: 15px; color: #444; margin: 8px 0 0; }
        .update-btn {
            display: inline-block; margin-top: 25px; padding: 10px 25px;
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

    String hospitalName = "Unknown Hospital";
    Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");
        String sql = "SELECT hospital_name FROM doctors WHERE LOWER(TRIM(fullname)) = LOWER(TRIM(?))";
        ps = conn.prepareStatement(sql);
        ps.setString(1, fullname);
        rs = ps.executeQuery();
        if (rs.next()) { hospitalName = rs.getString("hospital_name"); }
    } catch (Exception e) { out.println("Database error: " + e.getMessage()); }
    finally {
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
    <a href="#">Prescriptions</a>
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
                <p>Specialist: Cardiologist</p>
                <p>Hospital: <span style="font-weight:600; color:#023e8a;"><%= hospitalName %></span></p>
            </div>
        </div>

        <div class="profile-details">
            <div class="detail-card">
                <h3>Contact Information</h3>
                <p>Email: doctor@example.com</p>
                <p>Phone: +91 9876543210</p>
            </div>
            <div class="detail-card">
                <h3>Professional Details</h3>
                <p>Experience: 12 Years</p>
                <p>Department: Cardiology</p>
            </div>
            <div class="detail-card">
                <h3>Availability</h3>
                <p>Mon - Fri: 10 AM - 6 PM</p>
                <p>Sat: 10 AM - 2 PM</p>
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
