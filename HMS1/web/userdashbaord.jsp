<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Dashboard</title>
    <style>
        /* Reset and Base Styles */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f6f9;
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

        /* Modern Search Styles */
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
        footer {
            background: #023e8a;
            color: white;
            text-align: center;
            padding: 15px 10px;
            font-size: 0.9rem;
        }
        footer a {
            color: #90e0ef;
            text-decoration: none;
        }
        footer a:hover {
            text-decoration: underline;
        }
        @media screen and (max-width: 768px) {
            .center-section { display: none; }
            .dashboard-content { padding: 20px; }
        }
    </style>
</head>
<body>

<%
    String fullname = (String) session.getAttribute("fullname");
    String profileEmoji = "👤"; // default emoji

    if (fullname == null || fullname.isEmpty()) {
        response.sendRedirect("patientlogin.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "root", "root");

        String sql = "SELECT gender FROM patients WHERE fullname = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, fullname);
        rs = ps.executeQuery();

        if (rs.next()) {
            String gender = rs.getString("gender");
            if ("Male".equalsIgnoreCase(gender)) {
                profileEmoji = "👨";
            } else if ("Female".equalsIgnoreCase(gender)) {
                profileEmoji = "👩";
            }
        }
    } catch (Exception e) {
        System.err.println("Database error: " + e.getMessage());
    } finally {
        try { if(rs != null) rs.close(); } catch(SQLException e) {}
        try { if(ps != null) ps.close(); } catch(SQLException e) {}
        try { if(conn != null) conn.close(); } catch(SQLException e) {}
    }
%>

<header class="main-header">
    <div class="left-section">
        <button id="menuToggle">☰</button>
        <div class="logo-text">Health Portal System</div>
    </div>

    <div class="center-section">
        <input type="text" class="search-box" placeholder="Search hospitals...">
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
    <!-- Dashboard main content -->
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
