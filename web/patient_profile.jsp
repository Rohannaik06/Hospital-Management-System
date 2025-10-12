<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Patient Profile</title>
    <style>
        /* BASE STYLES - Unchanged */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f6f9;
            color: #333;
        }

        /* Header - Unchanged */
        .main-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #0a4275;
            color: white;
            padding: 12px 24px;
            width: 100%;
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
        .dropdown-menu .logout-link { color: #e63946; font-weight: 600; }
        .dropdown-menu .logout-link:hover { background: #b22222 !important; color: white !important; }

        /* Sidebar - Unchanged */
        .sidebar {
            width: 280px; background: #1f2b3e; position: fixed; top: 70px; left: -300px;
            height: 100%; transition: 0.3s ease; z-index: 999; padding-top: 25px;
        }
        .sidebar.active { left: 0; }
        .sidebar a {
            display: block; padding: 18px 24px; color: #fff; font-size: 18px; text-decoration: none;
        }
        .sidebar a:hover { background: #374b68; }
        .sidebar .logout-link { color: #e63946; font-weight: 600; }
        .sidebar .logout-link:hover { background: #b22222 !important; color: white !important; }

        /* Content Area - Unchanged */
        .dashboard-content {
            margin-left: 0; padding: 36px 48px; transition: margin-left 0.3s ease;
            min-height: calc(100vh - 120px);
            padding-bottom: 80px;
        }
        .sidebar.active ~ .dashboard-content { margin-left: 280px; }

        /* Footer - Unchanged */
        footer {
            background: #023e8a; color: white; text-align: center; 
            padding: 18px 10px; font-size: 1rem; 
            width: 100%; position: fixed; 
            bottom: 0; left: 0;
        }
        footer a { color: #90e0ef; text-decoration: none; }
        footer a:hover { text-decoration: underline; }

        @media (max-width: 768px) {
            .dashboard-content { margin-left: 0 !important; padding: 20px; padding-bottom: 80px; }
            .sidebar { top: 60px; }
            .profile-details { flex-direction: column; } /* Stack cards on small screens */
        }

        /* --- MODIFIED PROFILE STYLES --- */
        .profile-container {
            max-width: 1000px; /* MODIFICATION: Increased width */
            margin: 30px auto;
            background: #fff;
            border-radius: 10px;
            padding: 24px 30px; /* Adjusted padding */
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        
        .profile-header-content {
            display: flex;
            align-items: center;
            gap: 20px;
            border-bottom: 2px solid #eee;
            padding-bottom: 20px;
            margin-bottom: 20px;
        }
        .profile-photo {
            width: 90px;
            height: 90px;
            background: #0a4275;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            color: white;
            box-shadow: 0 0 8px rgba(0,0,0,0.15);
            flex-shrink: 0;
        }
        .profile-basic h2 {
            font-size: 28px;
            font-weight: 700;
            color: #0a4275;
            margin: 0;
        }
        .profile-basic p {
            margin: 5px 0 0;
            font-size: 16px;
            color: #666;
        }
        
        /* MODIFICATION: Using Flexbox to place inner divs on one line */
        .profile-details {
            display: flex;
            gap: 24px; /* Space between the two cards */
            align-items: flex-start; /* Aligns items to the top */
        }

        .detail-card {
            background: #fafafa;
            padding: 20px;
            border-radius: 8px;
            border: 1px solid #eee;
            flex: 1; /* Allows both cards to grow and share space */
        }
        .detail-card h3 {
            font-size: 18px;
            font-weight: 600;
            color: #0077b6;
            margin-top: 0;
            border-bottom: 1px solid #eee;
            padding-bottom: 8px;
            margin-bottom: 12px;
        }
        .detail-item {
            font-size: 15px;
            color: #444;
            margin: 10px 0;
            line-height: 1.5;
        }
        .detail-item strong {
            display: inline-block;
            min-width: 110px;
            color: #333;
            font-weight: 600;
        }

        .update-btn-group {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            display: flex;
            gap: 15px;
        }
        .update-btn {
            display: inline-block;
            padding: 12px 25px;
            background: #0a4275;
            color: white;
            border-radius: 6px;
            text-decoration: none;
            transition: 0.3s;
            font-weight: 600;
            font-size: 15px;
        }
        .update-btn:hover { background: #06508d; }
    </style>
</head>
<body>

<%
    // --- JSP LOGIC - Unchanged ---
    String sessionFullname = (String) session.getAttribute("fullname");
    String profileEmoji = "🧑"; 

    if (sessionFullname == null || sessionFullname.isEmpty()) {
        response.sendRedirect("patientlogin.jsp");
        return;
    }
    
    String patientId = "N/A";
    String patientFullname = sessionFullname;
    String patientGender = "N/A";
    String patientAddress = "Not Provided";
    String patientPhone = "N/A";
    String patientUsername = "N/A";
    String patientCreatedAt = "N/A";
    
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");
        
        String sql = "SELECT pid, fullname, gender, address, phone, username, created_at FROM patients WHERE fullname = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, sessionFullname);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            patientId = String.valueOf(rs.getInt("pid"));
            patientFullname = rs.getString("fullname");
            patientGender = rs.getString("gender") != null ? rs.getString("gender") : "N/A";
            patientAddress = rs.getString("address") != null ? rs.getString("address") : "Not Provided";
            patientPhone = rs.getString("phone") != null ? rs.getString("phone") : "N/A";
            patientUsername = rs.getString("username") != null ? rs.getString("username") : "N/A";
            
            Timestamp ts = rs.getTimestamp("created_at");
            if (ts != null) {
                patientCreatedAt = new SimpleDateFormat("dd MMMM, yyyy 'at' hh:mm a").format(ts);
            }

            if ("male".equalsIgnoreCase(patientGender)) {
                profileEmoji = "👨";
            } else if ("female".equalsIgnoreCase(patientGender)) {
                profileEmoji = "👩";
            }
        }
        
    } catch (Exception e) {
        // Handle exception
    } finally {
        try { if(rs!=null) rs.close(); } catch(Exception e) {}
        try { if(ps!=null) ps.close(); } catch(Exception e) {}
        try { if(conn!=null) conn.close(); } catch(Exception e) {}
    }
%>

<header class="main-header">
    <div class="left-section">
        <button id="menuToggle">☰</button>
        <div class="logo-text">Health Portal System</div>
    </div>
    <div class="right-section">
        <div class="profile-dropdown" onclick="toggleDropdown()">
            <div class="profile-photo-header"><%= profileEmoji %></div>
            <div class="profile-name-header"><%= patientFullname %></div>
            <div class="dropdown-menu" id="dropdownMenu">
                <a href="userdashbaord.jsp">Home</a>
                <a href="patient_profile.jsp">My Profile</a>
                <a href="myappointments.jsp">My Appointments</a>
                <a href="patientlogin.jsp" class="logout-link">Logout</a>
            </div>
        </div>
    </div>
</header>

<nav class="sidebar" id="sidebar">
    <a href="userdashbaord.jsp">Home</a>
    <a href="patient_profile.jsp">My Profile</a>
    <a href="myappointments.jsp">My Appointments</a>
    <a href="patientlogin.jsp" class="logout-link">Logout</a>
</nav>

<div class="dashboard-content">
    <div class="profile-container">
        
        <div class="profile-header-content">
            <div class="profile-photo"><%= profileEmoji %></div>
            <div class="profile-basic">
                <h2><%= patientFullname %></h2>
                <p>Account Type: <span style="font-weight:600; color:#023e8a;">Registered Patient</span></p>
                <p>Patient ID: <%= patientId %></p>
            </div>
        </div>

        <div class="profile-details">
            <div class="detail-card">
                <h3>Account Information</h3>
                <p class="detail-item"><strong>Full Name:</strong> <%= patientFullname %></p>
                <p class="detail-item"><strong>Gender:</strong> <%= patientGender.toUpperCase() %></p>
                <p class="detail-item"><strong>Username:</strong> <%= patientUsername %></p>
                <p class="detail-item"><strong>Phone:</strong> <%= patientPhone %></p>
                <p class="detail-item"><strong>Account Since:</strong> <%= patientCreatedAt %></p>
            </div>
            
            <div class="detail-card">
                <h3>Residential Address</h3>
                <p class="detail-item"><%= patientAddress %></p>
                <br><br><br><br><br><br>
            </div>
        </div>

        <div class="update-btn-group">
            <a href="edit_patient_profile.jsp" class="update-btn">Edit Details</a>
            <a href="change_password.jsp" class="update-btn" style="background:#4CAF50;">Change Password</a>
        </div>
            
    </div>
</div>

<footer>
    &copy; 2025 Health Portal. All rights reserved.
</footer>

<script>
    // --- JAVASCRIPT - Unchanged ---
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