<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>User Dashboard</title>
    <style>
        /* Header and Sidebar Styles */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f6f9;
            margin: 0;
            color: #333;
        }
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
        .left-section {
            display: flex;
            align-items: center;
        }
        #menuToggle {
            font-size: 24px;
            background: none;
            border: none;
            color: white;
            margin-right: 15px;
            cursor: pointer;
        }
        .logo-text {
            font-size: 22px;
            font-weight: 600;
        }
        .center-section {
            flex-grow: 1;
            display: flex;
            justify-content: center;
        }
        .search-box {
            padding: 12px 18px 12px 40px;
            width: 320px;
            border-radius: 30px 0 0 30px;
            border: 1px solid #ccc;
            font-size: 1rem;
            outline: none;
            color: #333;
            background-color: #fff;
            transition: all 0.3s ease;
            background-image: url('https://cdn-icons-png.flaticon.com/512/622/622669.png');
            background-size: 18px;
            background-repeat: no-repeat;
            background-position: 12px center;
        }
        .search-box:focus {
            border-color: #0077b6;
            box-shadow: 0 0 8px rgba(0, 119, 182, 0.3);
        }
        .search-btn {
            padding: 12px 22px;
            background: linear-gradient(135deg, #0077b6, #00b4d8);
            border: none;
            border-radius: 0 30px 30px 0;
            color: white;
            font-weight: bold;
            cursor: pointer;
            font-size: 1rem;
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px rgba(0,0,0,0.15);
        }
        .search-btn:hover {
            background: linear-gradient(135deg, #005f87, #0096c7);
            transform: scale(1.05);
        }
        .right-section {
            position: relative;
            display: flex;
            align-items: center;
        }
        .profile-dropdown {
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .profile-photo {
            width: 42px;
            height: 42px;
            background: white;
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
            box-shadow: 0 0 6px rgba(0, 0, 0, 0.1);
            user-select: none;
            font-size: 24px;
            color: #0077b6;
        }
        .profile-name {
            font-weight: 600;
            font-size: 1.1rem;
            user-select: none;
        }
        .dropdown-menu {
            display: none;
            position: absolute;
            right: 0;
            top: 48px;
            background: white;
            border: 1px solid #ccc;
            border-radius: 5px;
            min-width: 170px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
            z-index: 1001;
        }
        .dropdown-menu a {
            display: block;
            padding: 12px 16px;
            color: #333;
            text-decoration: none;
            font-size: 15px;
        }
        .dropdown-menu a:hover {
            background-color: #f5f5f5;
        }
        .sidebar {
            width: 240px;
            background: #1f2b3e;
            position: fixed;
            top: 60px;
            left: -260px;
            height: 100%;
            transition: 0.3s ease;
            z-index: 999;
            padding-top: 20px;
        }
        .sidebar.active {
            left: 0;
        }
        .sidebar a {
            display: block;
            padding: 15px 20px;
            color: #fff;
            font-size: 16px;
            text-decoration: none;
        }
        .sidebar a:hover {
            background: #374b68;
        }
        .sidebar a.logout-link,
        .dropdown-menu a.logout-link {
            color: #e63946;
            font-weight: 600;
        }
        .sidebar a.logout-link:hover,
        .dropdown-menu a.logout-link:hover {
            background-color: #b22222;
            color: white;
        }
        .dashboard-content {
            margin-left: 0;
            padding: 30px 40px;
            transition: margin-left 0.3s ease;
            min-height: calc(100vh - 60px - 60px);
        }
        .sidebar.active ~ .dashboard-content {
            margin-left: 240px;
        }
        /* Doctor card styles */
        .cards-wrapper {
            display: flex;
            flex-wrap: wrap;
            gap: 28px;
            justify-content: center;
            margin-top: 30px;
        }
        .doctor-card {
            min-width: 410px;
            border-radius: 14px;
            box-shadow: 0 2px 20px rgba(0, 0, 0, 0.10);
            overflow: hidden;
            margin-bottom: 36px;
            background: white;
        }
        .doctor-card-top {
            background: #e3f2fd;
            text-align: center;
            padding: 42px 0;
        }
        .doctor-card-title {
            font-size: 2.1rem;
            color: #0466c8;
            font-weight: 700;
        }
        .doctor-card-body {
            background: #fff;
            padding: 28px 26px 22px 26px;
        }
        .doctor-card-body h2 {
            margin-bottom: 6px;
            color: #14213d;
            font-size: 1.32rem;
            font-weight: 700;
        }
        .doctor-card-detail {
            font-size: 1rem;
            margin-bottom: 8px;
            color: #495057;
        }
        .doctor-card-actions {
            margin-top: 18px;
            display: flex;
            justify-content: flex-end;
            gap: 18px;
        }
        .doctor-card-link {
            color: #1976d2;
            text-decoration: underline;
        }
        .doctor-card-btn {
            background: #1976d2;
            color: #fff;
            padding: 10px 22px;
            border-radius: 7px;
            text-decoration: none;
            font-weight: 500;
        }
        /* Footer styles */
        footer {
            background: #0a4275;
            color: white;
            padding: 16px 40px;
            text-align: center;
            font-size: 14px;
            position: relative;
            bottom: 0;
            width: 100%;
            box-shadow: 0 -2px 6px rgba(0,0,0,0.15);
            margin-top: 40px;
        }
        footer a {
            color: #8ecae6;
            text-decoration: none;
            margin: 0 8px;
            font-weight: 500;
        }
        footer a:hover {
            text-decoration: underline;
        }
        @media screen and (max-width: 768px) {
            .center-section { display: none; }
            .dashboard-content { padding: 20px; }
            footer {
                font-size: 12px;
                padding: 12px 20px;
            }
        }
    </style>
</head>
<body>

<%
    String fullname = (String) session.getAttribute("fullname");
    String profileEmoji = "👤";

    if (fullname == null || fullname.isEmpty()) {
        response.sendRedirect("patientlogin.jsp");
        return;
    }

    Connection conn1 = null;
    PreparedStatement ps1 = null;
    ResultSet rs1 = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn1 = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "root", "root");
        String sqlGender = "SELECT gender FROM patients WHERE fullname = ?";
        ps1 = conn1.prepareStatement(sqlGender);
        ps1.setString(1, fullname);
        rs1 = ps1.executeQuery();
        if (rs1.next()) {
            String gender = rs1.getString("gender");
            if ("Male".equalsIgnoreCase(gender)) {
                profileEmoji = "👨";
            } else if ("Female".equalsIgnoreCase(gender)) {
                profileEmoji = "👩";
            }
        }
    } catch (ClassNotFoundException e) {
        out.println("<div style='color:red;'>JDBC Driver not found: " + e.getMessage() + "</div>");
    } catch (SQLException e) {
        out.println("<div style='color:red;'>Database error: " + e.getMessage() + "</div>");
    } finally {
        try { if (rs1 != null) rs1.close(); } catch (SQLException e) {}
        try { if (ps1 != null) ps1.close(); } catch (SQLException e) {}
        try { if (conn1 != null) conn1.close(); } catch (SQLException e) {}
    }
%>

<header class="main-header">
    <div class="left-section">
        <button id="menuToggle">☰</button>
        <div class="logo-text">Health Portal System</div>
    </div>

    <div class="center-section">
        <input type="text" class="search-box" placeholder="Search hospitals..." />
        <button class="search-btn">Search</button>
    </div>

    <div class="right-section">
        <div class="profile-dropdown" onclick="toggleDropdown()">
            <div class="profile-photo"><%= profileEmoji %></div>
            <div class="profile-name"><%= fullname %></div>
            <div class="dropdown-menu" id="dropdownMenu">
                <a href="#">My Profile</a>
                <a href="#">Edit Profile</a>
                <a href="#">Appointments</a>
                <a href="patientlogin.jsp" class="logout-link">Logout</a>
            </div>
        </div>
    </div>
</header>

<nav class="sidebar" id="sidebar">
    <a href="#">My Profile</a>
    <a href="#">Appointments</a>
    <a href="#">Saved</a>
    <a href="#">Settings</a>
    <a href="#">About Us</a>
    <a href="#">Contact</a>
    <a href="patientlogin.jsp" class="logout-link">Logout</a>
</nav>

<div class="dashboard-content">
    <div class="cards-wrapper">
    <%
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "root", "root");
            String sql = "SELECT * FROM doctors ORDER BY id DESC";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
    %>
        <div class="doctor-card">
            <div class="doctor-card-top">
                <span class="doctor-card-title">HOSPITAL PHOTO</span>
            </div>
            <div class="doctor-card-body">
                <h2><%= rs.getString("hospital_name") %></h2>
                <div class="doctor-card-detail"><b>Address:</b><%= rs.getString("address") %> </div>
                <div class="doctor-card-detail"><b>Dr. Name:</b> <%= rs.getString("fullname") %></div>
                <div class="doctor-card-detail"><b>Specialization:</b> <%= rs.getString("specialization") %></div>
                <div class="doctor-card-detail"><b>Qualification:</b> <%= rs.getString("qualification") %></div>
                <div class="doctor-card-detail"><b>License:</b> <%= rs.getString("license") %></div>
                <div class="doctor-card-detail"><b>Contact:</b> <%= rs.getString("phone") %> | <%= rs.getString("email") %></div>
                <div class="doctor-card-detail" style="color:#22a6b3; font-weight: 500;">
                    Focus on <%= rs.getString("specialization") %> and preventative care.
                </div>
                <div class="doctor-card-actions">
                    <a href="#" class="doctor-card-link">View Details</a>
                    <a href="#" class="doctor-card-btn">Book Appointment</a>
                </div>
            </div>
        </div>
    <%
            }
        } catch (ClassNotFoundException e) {
            out.println("<div style='color:red;'>JDBC Driver not found: " + e.getMessage() + "</div>");
        } catch (SQLException e) {
            out.println("<div style='color:red;'>Database error: " + e.getMessage() + "</div>");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    %>
    </div>
</div>

<footer>
    &copy; 2025 Health Portal. All rights reserved. |
    <a href="/privacy-policy.html">Privacy Policy</a> |
    <a href="/contact.html">Contact Us</a>
</footer>

<script>
    document.getElementById("menuToggle").addEventListener("click", function () {
        document.getElementById("sidebar").classList.toggle("active");
    });

    function toggleDropdown() {
        const menu = document.getElementById("dropdownMenu");
        menu.style.display = (menu.style.display === "block") ? "none" : "block";
    }

    window.onclick = function (event) {
        if (!event.target.closest('.profile-dropdown')) {
            document.getElementById("dropdownMenu").style.display = "none";
        }
    };
</script>

</body>
</html>
