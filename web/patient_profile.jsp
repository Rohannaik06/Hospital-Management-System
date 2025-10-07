<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Patient Profile</title>
    <style>
        /* Existing Header, Sidebar, and Footer Styles (kept intact) */
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; margin: 0; color: #333; }
        .main-header { display: flex; justify-content: space-between; align-items: center; background: #0a4275; color: white; padding: 12px 24px; position: sticky; top: 0; z-index: 1000; box-shadow: 0 2px 4px rgba(0,0,0,0.1);}
        .left-section { display: flex; align-items: center; }
        #menuToggle { font-size: 24px; background: none; border: none; color: white; margin-right: 15px; cursor: pointer; }
        .logo-text { font-size: 22px; font-weight: 600; }
        .right-section { position: relative; display: flex; align-items: center; }
        .profile-dropdown { cursor: pointer; display: flex; align-items: center; gap: 10px; } 
        .profile-photo { width: 42px; height: 42px; background: white; border-radius: 50%; display: flex; justify-content: center; align-items: center; box-shadow: 0 0 6px rgba(0,0,0,0.1); font-size: 24px; color: #0077b6; }
        .profile-name { font-weight: 600; font-size: 1.1rem; }
        .dropdown-menu { display: none; position: absolute; right: 0; top: 48px; background: white; border: 1px solid #ccc; border-radius: 5px; min-width: 170px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);}
        .dropdown-menu a { display: block; padding: 12px 16px; color: #333; text-decoration: none; font-size: 15px; }
        .dropdown-menu a:hover { background-color: #f5f5f5; }
        
        /* Sidebar Styles */
        .sidebar { width: 240px; background: #1f2b3e; position: fixed; top: 60px; left: -260px; height: 100%; transition: 0.3s ease; z-index: 999; padding-top: 20px; }
        .sidebar.active { left: 0; }
        .sidebar a { display: block; padding: 15px 20px; color: #fff; font-size: 16px; text-decoration: none; }
        .sidebar a:hover { background: #374b68; }
        .sidebar a.logout-link, .dropdown-menu a.logout-link { color: #e63946; font-weight: 600; }
        .sidebar a.logout-link:hover, .dropdown-menu a.logout-link:hover { background-color: #b22222; color: white; }
        .dashboard-content { margin-left: 0; padding: 30px 40px; transition: margin-left 0.3s ease; min-height: calc(100vh - 60px - 56px); }
        .sidebar.active ~ .dashboard-content { margin-left: 240px; }
        footer { background: #0a4275; color: white; padding: 16px 42px; text-align: center; font-size: 14px; position: relative; bottom: 0; width: 100%; box-sizing: border-box; box-shadow: 0 -2px 6px rgba(0,0,0,0.15); }

        /* --- Profile Page Styles --- */
        .profile-container {
            max-width: 650px; 
            margin: 0 auto;
        }
        .profile-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            padding: 30px;
        }
        
        /* Header Styling with Emoji */
        .profile-header {
            display: flex; /* Enable Flexbox */
            align-items: center;
            text-align: left; 
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid #eee;
        }
        
        /* NEW: Large Emoji/Icon Container */
        .header-icon {
            font-size: 48px; /* Large emoji size */
            margin-right: 15px;
            padding: 10px;
            border-radius: 8px;
            background: #f0f4f8; /* Light background for the icon area */
            line-height: 1;
        }

        .header-text h1 {
            color: #0a4275;
            font-size: 2.2rem;
            margin: 0; 
        }
        .header-text p {
            color: #555;
            font-size: 1.1rem;
            margin: 5px 0 0 0; 
        }

        /* Detail Rows */
        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 15px 0;
            border-bottom: 1px solid #f0f0f0;
            font-size: 1.1rem;
        }
        .detail-row:last-of-type {
            border-bottom: none;
        }
        .detail-label {
            font-weight: 600;
            color: #444;
        }
        .detail-value {
            color: #111;
            font-weight: 500;
        }

        /* Action Buttons */
        .action-links {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
        .action-links a {
            color: #0077b6;
            text-decoration: none;
            font-weight: 600;
            margin-right: 20px;
            transition: color 0.2s;
        }
        .action-links a:hover {
            color: #005f99;
            text-decoration: underline;
        }
    </style>
</head>
<body>

<%
    // --- JSP LOGIC START ---
    String fullname = (String) session.getAttribute("fullname");
    String profileEmoji = "👤"; 

    if (fullname == null || fullname.isEmpty()) {
        response.sendRedirect("patientlogin.jsp");
        return;
    }
    
    // Variables to hold patient data
    String patientGender = "N/A";
    String patientAddress = "N/A";
    String patientPhone = "N/A";
    String patientUsername = "N/A";
    String patientCreatedAt = "N/A";
    
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");
        
        // Select all core fields from the schema
        String sql = "SELECT fullname, gender, address, phone, username, created_at FROM patients WHERE fullname = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, fullname);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            patientGender = rs.getString("gender");
            patientAddress = rs.getString("address");
            patientPhone = rs.getString("phone");
            patientUsername = rs.getString("username");
            
            // Format creation timestamp
            Timestamp ts = rs.getTimestamp("created_at");
            if (ts != null) {
                patientCreatedAt = new java.text.SimpleDateFormat("MMM dd, yyyy").format(ts);
            }

            // Determine profile emoji
            if ("male".equalsIgnoreCase(patientGender)) {
                profileEmoji = "👨";
            } else if ("female".equalsIgnoreCase(patientGender)) {
                profileEmoji = "👩";
            } else {
                profileEmoji = "🧑";
            }
        }
        
    } catch (Exception e) {
        // Error handling ignored for simplicity
    } finally {
        try { if(rs!=null) rs.close(); } catch(Exception e) {}
        try { if(ps!=null) ps.close(); } catch(Exception e) {}
        try { if(conn!=null) conn.close(); } catch(Exception e) {}
    }
    // --- JSP LOGIC END ---
%>

<header class="main-header">
    <div class="left-section">
        <button id="menuToggle">☰</button>
        <div class="logo-text">Health Portal System</div>
    </div>
    <div class="right-section">
        <div class="profile-dropdown" onclick="toggleDropdown()">   
            <div class="profile-photo"><%= profileEmoji %></div>
            <div class="profile-name"><%= fullname %></div>
            <div class="dropdown-menu" id="dropdownMenu">
                <a href="patient_profile.jsp">My Profile</a>
                <a href="userdashbaord.jsp">Home</a>
                <a href="patientlogin.jsp" class="logout-link">Logout</a>
            </div>
        </div>
    </div>
</header>

<nav class="sidebar" id="sidebar">
    <a href="patient_profile.jsp">My Profile</a>
    <a href="userdashbaord.jsp">Home</a>
    <a href="#">Settings</a>
    <a href="#">About Us</a>
    <a href="patientlogin.jsp" class="logout-link">Logout</a>
</nav>

<div class="dashboard-content">

    <div class="profile-container">
        <div class="profile-card">
            
            <div class="profile-header">
                <div class="header-icon">
                    <%= profileEmoji %>
                </div>
                
                <div class="header-text">
                    <h1><%= fullname %></h1>
                    <p>Registered Account Details</p>
                </div>
            </div>

            <div class="info-section">
                
                <div class="detail-row">
                    <span class="detail-label">Full Name</span>
                    <span class="detail-value"><%= fullname %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Username</span>
                    <span class="detail-value"><%= patientUsername %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Gender</span>
                    <span class="detail-value"><%= patientGender.toUpperCase() %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Phone Number</span>
                    <span class="detail-value"><%= patientPhone %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Address</span>
                    <span class="detail-value"><%= patientAddress %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Member Since</span>
                    <span class="detail-value"><%= patientCreatedAt %></span>
                </div>
                
                <div class="action-links">
                    <a href="#" onclick="alert('In a real application, this would open a form to EDIT your details.'); return false;">Edit Profile</a>
                    <a href="#" onclick="alert('In a real application, this would open a form to CHANGE your password.'); return false;">Change Password</a>
                </div>
            </div>
        </div>
    </div>
</div>

<footer>
    &copy; 2025 Health Portal. All rights reserved. | <a href="/privacy-policy.html">Privacy Policy</a> | <a href="/contact.html">Contact Us</a>
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