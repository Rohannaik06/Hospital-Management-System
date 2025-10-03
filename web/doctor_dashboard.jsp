<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Doctor Dashboard</title>
    <style>
        /* Your existing styles... */
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
            min-height: calc(100vh - 120px);
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
            .dashboard-content { padding: 20px; }
        }

        /* Card and input styling */
        .card-box {
            width: 90%;
            background: #fff;
            border-radius: 10px;
            padding: 20px 25px;
            margin: 0 auto 30px auto;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
            position: relative;
        }
        .card-box h2 {
            font-size: 18px;
            margin-bottom: 15px;
            color: #222;
        }
        .search-container {
            position: relative;
            width: 100%;
        }
        .search-input {
            width: 100%;
            padding: 12px 40px 12px 14px;
            font-size: 16px;
            border: 1px solid #ccc;
            border-radius: 6px;
            outline: none;
        }
        .search-input:focus {
            border-color: #0077b6;
            box-shadow: 0 0 5px rgba(0, 119, 182, 0.4);
        }
        .date-picker {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            border: none;
            background: transparent;
            outline: none;
            font-size: 16px;
        }
        .date-picker::-webkit-calendar-picker-indicator {
            cursor: pointer;
            filter: invert(30%) sepia(30%) saturate(500%) hue-rotate(190deg);
        }
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
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");

        String sql = "SELECT hospital_name FROM doctors WHERE LOWER(TRIM(fullname)) = LOWER(TRIM(?))";
        ps = conn.prepareStatement(sql);
        ps.setString(1, fullname);
        rs = ps.executeQuery();

        if (rs.next()) {
            hospitalName = rs.getString("hospital_name");
        }
    } catch (Exception e) {
        out.println("Database error: " + e.getMessage());
    } finally {
        try { if (rs != null) rs.close(); } catch (SQLException e) {}
        try { if (ps != null) ps.close(); } catch (SQLException e) {}
        try { if (conn != null) conn.close(); } catch (SQLException e) {}
    }

    // Get today's date string formatted as yyyy-MM-dd for HTML date input value and min attribute
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String todayDateStr = sdf.format(new Date());
%>

<header class="main-header">
    <div class="left-section">
        <button id="menuToggle">☰</button>
        <div class="logo-text"><%= hospitalName %></div>
    </div>

    <div class="right-section">
        <div class="profile-dropdown" onclick="toggleDropdown()">
            <div class="profile-photo">👨‍⚕️</div>
            <div class="profile-name"><%= fullname %></div>
            <div class="dropdown-menu" id="dropdownMenu">
                <a href="my_profile.jsp">My Profile</a>
                <a href="doctor_dashboard.jsp">Appointments</a>
                <a href="doctorlogin.jsp" class="logout-link">Logout</a>
            </div>
        </div>
    </div>
</header>

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

<div class="dashboard-content">
    <div class="card-box">
        <h2>Appointments for <span id="selectedDate"><%= new java.text.SimpleDateFormat("EEEE, MMMM dd, yyyy").format(new java.util.Date()) %></span></h2>
        <div class="search-container">
            <input type="text" placeholder="Search patient name..." class="search-input" />
            <input type="date" id="appointmentDatePicker" class="date-picker" title="Select Date"
                   value="<%= todayDateStr %>"
                   min="<%= todayDateStr %>" />
        </div>
    </div>
</div>

<footer>
    &copy; 2025 Health Portal. All rights reserved.
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

    const datePicker = document.getElementById('appointmentDatePicker');
    const selectedDateSpan = document.getElementById('selectedDate');

    // Update the heading whenever date picker changes
    datePicker.addEventListener('change', function() {
        const selectedDate = new Date(this.value);
        if (!isNaN(selectedDate)) {
            const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
            selectedDateSpan.textContent = selectedDate.toLocaleDateString(undefined, options);
        }
    });
</script>

</body>
</html>
