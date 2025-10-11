<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>User Dashboard</title>
    <style>
        /* Your existing CSS retained, but search-specific styles are removed */
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
        .sidebar { width: 240px; background: #1f2b3e; position: fixed; top: 60px; left: -260px; height: 100%; transition: 0.3s ease; z-index: 999; padding-top: 20px; }
        .sidebar.active { left: 0; }
        .sidebar a { display: block; padding: 15px 20px; color: #fff; font-size: 16px; text-decoration: none; }
        .sidebar a:hover { background: #374b68; }
        .sidebar a.logout-link, .dropdown-menu a.logout-link { color: #e63946; font-weight: 600; }
        .sidebar a.logout-link:hover, .dropdown-menu a.logout-link:hover { background-color: #b22222; color: white; }
        .dashboard-content { margin-left: 0; padding: 30px 40px; transition: margin-left 0.3s ease; min-height: calc(100vh - 60px - 60px); }
        .sidebar.active ~ .dashboard-content { margin-left: 240px; }
        /* Keeping card/modal styles for the modal which uses them */
        .modal { display: none; position: fixed; z-index: 10001; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); justify-content: center; align-items: center;}
        .modal-content { background: white; padding: 25px; border-radius: 10px; width: 560px; max-width: 95%; box-shadow: 0 4px 15px rgba(0,0,0,0.3); animation: fadeIn 0.3s ease; }
        @keyframes fadeIn { from{opacity:0; transform:scale(0.9);} to{opacity:1; transform:scale(1);} }
        .close-btn { float: right; font-size: 22px; font-weight: bold; color: #333; cursor: pointer;}
        .close-btn:hover { color: red; }
        .modal h2 { margin-top: 0; color: #0466c8; }
        .modal p { margin: 8px 0; font-size: 0.95rem; }
        footer { background: #0a4275; color: white; padding: 16px 42px; text-align: center; font-size: 14px; position: relative; bottom: 0; width: 100%; box-sizing: border-box; box-shadow: 0 -2px 6px rgba(0,0,0,0.15); margin-top: 40px; }
        footer a { color: #8ecae6; text-decoration: none; margin: 0 8px; font-weight: 500; }
        footer a:hover { text-decoration: underline; }
        @media screen and (max-width: 768px) {
            .dashboard-content { padding: 20px }
            footer { font-size: 12px; padding: 12px 20px; }
        }
    </style>
</head>
<body>

<%
    // Profile info retrieval logic - unchanged
    String fullname = (String) session.getAttribute("fullname");
    String profileEmoji = "👤"; // default icon
    String gender = "";

    if (fullname == null || fullname.isEmpty()) {
        response.sendRedirect("patientlogin.jsp");
        return;
    }
    try {
        Class.forName("com.mysql.jdbc.Driver");
        // NOTE: The database connection logic is retained here only to get the profile emoji for the header.
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");
        String sql = "SELECT gender FROM patients WHERE fullname = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, fullname);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            gender = rs.getString("gender");
            if ("male".equalsIgnoreCase(gender)) {
                profileEmoji = "👨";
            } else if ("female".equalsIgnoreCase(gender)) {
                profileEmoji = "👩";
            } else {
                profileEmoji = "🧑";
            }
        }
        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        profileEmoji = "👤";
        // To prevent an error message on an empty page, we silently fail the emoji fetch
    }
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
                <a href="userdashbaord.jsp">Home</a>
                <a href="patient_profile.jsp">My Profile</a>
                <a href="#">My Appointments</a>
                <a href="patientlogin.jsp" class="logout-link">Logout</a>
            </div>
        </div>
    </div>
</header>

<nav class="sidebar" id="sidebar">
    <a href="userdashbaord.jsp">Home</a>
    <a href="patient_profile.jsp">My Profile</a>
    <a href="#">My Appointments</a>
    <a href="patientlogin.jsp" class="logout-link">Logout</a>
</nav>
<div class="dashboard-content">
    
</div>

<div id="detailsModal" class="modal">
    <div class="modal-content">
        <span class="close-btn" onclick="closeModal()">&times;</span>
        <h2 id="modalHospital">Hospital Details</h2>
        <p><b>Doctor:</b> <span id="modalDoctor">N/A</span></p>
        <p><b>Specialization:</b> <span id="modalSpecialization">N/A</span></p>
        <p><b>Qualification:</b> <span id="modalQualification">N/A</span></p>
        <p><b>License:</b> <span id="modalLicense">N/A</span></p>
        <p><b>Contact:</b> <span id="modalContact">N/A</span></p>
        <p><b>Address:</b> <span id="modalAddress">N/A</span></p>
        <hr/>
        <p><b>Description:</b> This modal is functional but needs content from a doctor card (which was removed).</p>
    </div>
</div>

<footer>
    &copy; 2025 Health Portal. All rights reserved. | <a href="/privacy-policy.html">Privacy Policy</a> | <a href="/contact.html">Contact Us</a>
</footer>

<script>
    // Toggles the side menu
    document.getElementById("menuToggle").addEventListener("click", function () {
        document.getElementById("sidebar").classList.toggle("active");
    });

    // Toggles the profile dropdown menu
    function toggleDropdown() {
        const menu = document.getElementById("dropdownMenu");
        menu.style.display = (menu.style.display === "block") ? "none" : "block";
    }

    // Closes the dropdown when clicking outside
    window.onclick = function (event) {
        if (!event.target.closest('.profile-dropdown')) {
            document.getElementById("dropdownMenu").style.display = "none";
        }
    };

    // Modal functions (kept for structure, though no cards call them)
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
        // Heart function kept for structure
        const icon = element.querySelector("i");
        if (icon.classList.contains("saved")) {
            icon.classList.remove("saved");
            icon.style.color = "grey";
        } else {
            icon.classList.add("saved");
            icon.style.color = "red";
        }
    }
    
    function openAppointment(doctorId, doctorName, hospitalName) {
        // Appointment link function kept for structure
        doctorName = encodeURIComponent(doctorName);
        hospitalName = encodeURIComponent(hospitalName);
        window.location.href = "appointment.jsp?doctorId=" + doctorId + "&doctorName=" + doctorName + "&hospitalName=" + hospitalName;
    }
</script>

</body>
</html>