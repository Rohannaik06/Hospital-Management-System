<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>User Dashboard</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f6f9;
            margin: 0;
            color: #333;
        }
        .main-header {
            display: flex; justify-content: space-between; align-items: center;
            background: #0a4275; color: white; padding: 12px 24px;
            position: sticky; top: 0; z-index: 1000;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .left-section { display: flex; align-items: center; }
        #menuToggle { font-size: 24px; background: none; border: none; color: white; margin-right: 15px; cursor: pointer; }
        .logo-text { font-size: 22px; font-weight: 600; }
        .center-section { flex-grow: 1; display: flex; justify-content: center; }
        .search-box {
            padding: 12px 18px 12px 40px; width: 320px;
            border-radius: 30px 0 0 30px; border: 1px solid #ccc; font-size: 1rem;
            outline: none; background: #fff url('https://cdn-icons-png.flaticon.com/512/622/622669.png') no-repeat 12px center;
            background-size: 18px;
        }
        .search-btn { padding: 12px 22px; background: linear-gradient(135deg, #0077b6, #00b4d8); border: none;
            border-radius: 0 30px 30px 0; color: white; font-weight: bold; cursor: pointer; font-size: 1rem; }
        .search-btn:hover { background: linear-gradient(135deg, #005f87, #0096c7); transform: scale(1.05); }
        .right-section { position: relative; display: flex; align-items: center; }
        .profile-dropdown { cursor: pointer; display: flex; align-items: center; gap: 10px; }
        .profile-photo {
            width: 42px; height: 42px; background: white; border-radius: 50%; 
            display: flex; justify-content: center; align-items: center; 
            box-shadow: 0 0 6px rgba(0,0,0,0.1); font-size: 24px; color: #0077b6;
        }
        .profile-name { font-weight: 600; font-size: 1.1rem; }
        .dropdown-menu {
            display: none; position: absolute; right: 0; top: 48px;
            background: white; border: 1px solid #ccc; border-radius: 5px;
            min-width: 170px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .dropdown-menu a { display: block; padding: 12px 16px; color: #333; text-decoration: none; font-size: 15px; }
        .dropdown-menu a:hover { background-color: #f5f5f5; }
        .sidebar { width: 240px; background: #1f2b3e; position: fixed; top: 60px; left: -260px; height: 100%; transition: 0.3s ease; z-index: 999; padding-top: 20px; }
        .sidebar.active { left: 0; }
        .sidebar a { display: block; padding: 15px 20px; color: #fff; font-size: 16px; text-decoration: none; }
        .sidebar a:hover { background: #374b68; }
        .sidebar a.logout-link, .dropdown-menu a.logout-link { color: #e63946; font-weight: 600; }
        .sidebar a.logout-link:hover, .dropdown-menu a.logout-link:hover { background-color: #b22222; color: white; }
        .dashboard-content { margin-left: 0; padding: 30px 40px; transition: margin-left 0.3s ease; min-height: calc(100vh - 60px - 60px); }
        .sidebar.active ~ .dashboard-content { margin-left: 240px; }
        /* Doctor card styles */
        .cards-wrapper { display: flex; flex-wrap: wrap; gap: 28px; justify-content: center; margin-top: 30px; }
        .doctor-card {
            width: 420px; border-radius: 14px; box-shadow: 0 2px 15px rgba(0,0,0,0.1);
            overflow: hidden; background: white; transition: transform 0.3s ease;
            position: relative;
        }
        .doctor-card:hover { transform: translateY(-5px); }
        .doctor-card-top { background: #e3f2fd; text-align: center; padding: 42px 0; position: relative; }
        .doctor-card-heart {
            position: absolute;
            top: 12px;
            right: 18px;
            font-size: 24px;
            color: grey;
            cursor: pointer;
            user-select: none;
            transition: color 0.3s ease;
            z-index: 10;
        }
        .doctor-card-heart.saved { color: red; }
        .doctor-card-title { font-size: 1.6rem; color: #0466c8; font-weight: 700; }
        .doctor-card-body { padding: 24px; }
        .doctor-card-body h2 { margin-bottom: 6px; color: #14213d; font-size: 1.25rem; font-weight: 700; }
        .doctor-card-detail { font-size: 0.95rem; margin-bottom: 6px; color: #495057; }
        .doctor-card-actions { margin-top: 15px; display: flex; justify-content: space-between; align-items: center; }
        .doctor-card-link { color: #1976d2; text-decoration: underline; font-size: 0.95rem; cursor: pointer; }
        .doctor-card-btn { background: #1976d2; color: #fff; padding: 10px 20px;
            border-radius: 6px; text-decoration: none; font-weight: 500; transition: 0.2s; }
        .doctor-card-btn:hover { background: #0d47a1; }
        /* Modal styles */
        .modal {
            display: none; position: fixed; z-index: 10001; left: 0; top: 0;
            width: 100%; height: 100%; background: rgba(0,0,0,0.5);
            justify-content: center; align-items: center;
        }
        .modal-content {
            background: white; padding: 25px; border-radius: 10px;
            width: 560px; max-width: 95%;
            box-shadow: 0 4px 15px rgba(0,0,0,0.3);
            animation: fadeIn 0.3s ease;
        }
        @keyframes fadeIn { from{opacity:0; transform:scale(0.9);} to{opacity:1; transform:scale(1);} }
        .close-btn {
            float: right; font-size: 22px; font-weight: bold; color: #333; cursor: pointer;
        }
        .close-btn:hover { color: red; }
        .modal h2 { margin-top: 0; color: #0466c8; }
        .modal p { margin: 8px 0; font-size: 0.95rem; }
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
        footer a:hover { text-decoration: underline; }
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
                <a href="#">My Profile</a><a href="#">Edit Profile</a><a href="#">Appointments</a><a href="patientlogin.jsp" class="logout-link">Logout</a>
            </div>
        </div>
    </div>
</header>

<nav class="sidebar" id="sidebar">
    <a href="#">My Profile</a><a href="#">Appointments</a><a href="#">Saved</a><a href="#">Settings</a><a href="#">About Us</a><a href="#">Contact</a><a href="patientlogin.jsp" class="logout-link">Logout</a>
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
                <span class="doctor-card-heart" onclick="toggleHeart(this)" title="Save Hospital">
                    <i class="fa-solid fa-heart"></i>
                </span>
            </div>
            <div class="doctor-card-body">
                <h2><%= rs.getString("hospital_name") %></h2>
                <div class="doctor-card-detail"><b>Address:</b> <%= rs.getString("address") %></div>
                <div class="doctor-card-detail"><b>Dr. Name:</b> <%= rs.getString("fullname") %></div>
                <div class="doctor-card-detail"><b>Specialization:</b> <%= rs.getString("specialization") %></div>
                <div class="doctor-card-detail"><b>Qualification:</b> <%= rs.getString("qualification") %></div>
                <div class="doctor-card-detail"><b>License:</b> <%= rs.getString("license") %></div>
                <div class="doctor-card-detail"><b>Contact:</b> <%= rs.getString("phone") %> | <%= rs.getString("email") %></div>
                <div class="doctor-card-detail" style="color:#22a6b3; font-weight: 500;">
                    Focus on <%= rs.getString("specialization") %> and preventative care.
                </div>
                <div class="doctor-card-actions">
                    <a href="#" class="doctor-card-link" onclick="openModal('<%= rs.getString("hospital_name") %>', '<%= rs.getString("fullname") %>', '<%= rs.getString("specialization") %>', '<%= rs.getString("qualification") %>', '<%= rs.getString("license") %>', '<%= rs.getString("phone") %>', '<%= rs.getString("email") %>', '<%= rs.getString("address") %>')">View Details</a>
                    <a href="#" class="doctor-card-btn">Book Appointment</a>
                </div>
            </div>
        </div>
        <%
                }
                rs.close();
                ps.close();
                conn.close();
            } catch (Exception e) {
                out.println("<div style='color:red;'>Error: " + e.getMessage() + "</div>");
            }
        %>
    </div>
</div>

<div id="detailsModal" class="modal">
    <div class="modal-content">
        <span class="close-btn" onclick="closeModal()">&times;</span>
        <h2 id="modalHospital"></h2>
        <p><b>Doctor:</b> <span id="modalDoctor"></span></p>
        <p><b>Specialization:</b> <span id="modalSpecialization"></span></p>
        <p><b>Qualification:</b> <span id="modalQualification"></span></p>
        <p><b>License:</b> <span id="modalLicense"></span></p>
        <p><b>Contact:</b> <span id="modalContact"></span></p>
        <p><b>Address:</b> <span id="modalAddress"></span></p>
        <hr/>
        <p><b>Description:</b> This doctor is highly skilled and committed to providing the best patient care, specializing in preventative medicine and holistic health.</p>
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

    function openModal(hospital, doctor, specialization, qualification, license, phone, email, address) {
        document.getElementById("modalHospital").innerText = hospital;
        document.getElementById("modalDoctor").innerText = doctor;
        document.getElementById("modalSpecialization").innerText = specialization;
        document.getElementById("modalQualification").innerText = qualification;
        document.getElementById("modalLicense").innerText = license;
        document.getElementById("modalContact").innerText = phone + " | " + email;
        document.getElementById("modalAddress").innerText = address;
        document.getElementById("detailsModal").style.display = "flex";
    }

    function closeModal() {
        document.getElementById("detailsModal").style.display = "none";
    }

    function toggleHeart(element) {
        const icon = element.querySelector("i");
        if (icon.classList.contains("saved")) {
            icon.classList.remove("saved");
            icon.style.color = "grey";
        } else {
            icon.classList.add("saved");
            icon.style.color = "red";
        }
    }
</script>

</body>
</html>
