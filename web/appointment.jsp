<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.LocalTime" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Book Appointment</title>
    <style>
        /* --- Styles for Header, Sidebar, Footer (from userdashboard.jsp) --- */
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
        footer { background: #0a4275; color: white; padding: 16px 42px; text-align: center; font-size: 14px; width: 100%; box-sizing: border-box; box-shadow: 0 -2px 6px rgba(0,0,0,0.15); margin-top: 40px; }
        footer a { color: #8ecae6; text-decoration: none; margin: 0 8px; font-weight: 500; }
        footer a:hover { text-decoration: underline; }
        @media screen and (max-width: 768px) {
              .dashboard-content { padding: 20px }
              footer { font-size: 12px; padding: 12px 20px; }
        }
        /* --- Original Styles for Appointment Form --- */
        .form-container {
            background: white;
            max-width: 500px;
            margin: auto;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.1);
        }
        h2 { text-align: center; color: #0466c8; margin-bottom: 25px; }
        label { display: block; margin-bottom: 8px; font-weight: 600; color: #333; }
        label.required::after { content: " *"; color: red; }
        input[type="text"], input[type="number"], input[type="date"], input[type="time"], textarea {
            width: 100%;
            padding: 10px;
            margin-bottom: 18px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 1rem;
            color: #333;
            box-sizing: border-box;
        }
        textarea { resize: vertical; min-height: 50px; max-height: 80px; }
        input[type="submit"] {
            background-color: #0466c8;
            color: white;
            padding: 12px;
            font-size: 1.1rem;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            width: 100%;
            font-weight: 600;
        }
        input[type="submit"]:hover { background-color: #024a7a; }
        .info-text { margin-bottom: 20px; font-style: italic; color: #555; text-align: center; }
        .message { text-align: center; margin-bottom: 15px; font-weight: bold; }
        .success { color: green; }
        .error { color: red; }
        #bookedSlotsContainer {
            margin-top: 5px;
            margin-bottom: 15px;
            padding: 10px;
            border: 1px solid #ffcc00;
            background: #fff8e1;
            border-radius: 6px;
            font-size: 0.9rem;
        }
        .booked-slots {
            font-weight: 600;
            color: #ff6f00;
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 5px;
        }
    </style>
</head>
<body>

<%
    // --- START: HEADER AND PATIENT ID LOGIC ---
    String fullname = (String) session.getAttribute("fullname");
    String profileEmoji = "👤";
    // MODIFICATION: Added variable to store patient ID
    int patientId = 0; 

    // Check for login status
    if (fullname == null || fullname.isEmpty()) {
        response.sendRedirect("patientlogin.jsp");
        return; 
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        // MODIFICATION: Use the modern driver class name
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "root", "root");
        
        // MODIFICATION: Fetch both pid and gender
        String sql = "SELECT pid, gender FROM patients WHERE fullname = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, fullname);
        rs = ps.executeQuery();
        if (rs.next()) {
            // MODIFICATION: Store the patient's ID
            patientId = rs.getInt("pid"); 
            String gender = rs.getString("gender");
            if ("male".equalsIgnoreCase(gender)) profileEmoji = "👨";
            else if ("female".equalsIgnoreCase(gender)) profileEmoji = "👩";
            else profileEmoji = "🧑";
        }
    } catch (Exception e) {
        System.err.println("Header DB Error: " + e.getMessage());
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
    // --- END: HEADER AND PATIENT ID LOGIC ---

    final int SLOT_DURATION_MINUTES = 15;
    String doctorIdParam = request.getParameter("doctorId");
    int doctorId = 0;
    
    String fetchDate = request.getParameter("fetchDate");
    boolean isAjax = fetchDate != null;

    if (doctorIdParam != null) {
        try {
            doctorId = Integer.parseInt(doctorIdParam);
        } catch (NumberFormatException e) {
            doctorId = 0;
        }
    }

    String hospitalName = request.getParameter("hospitalName");
    String doctorName = request.getParameter("doctorName");

    if (hospitalName != null) hospitalName = URLDecoder.decode(hospitalName, "UTF-8");
    if (doctorName != null) doctorName = URLDecoder.decode(doctorName, "UTF-8");

    String message = "";
    String messageClass = "";
    boolean isPost = "POST".equalsIgnoreCase(request.getMethod()) && !isAjax; 

    String patientName = "";
    String contactNumber = "";
    String patientAddress = "";
    String patientAge = "";
    String weight = "";
    String allergies = "";
    String appointmentDate = "";
    String appointmentTime = "";

    // --- LOGIC FOR FETCHING BOOKED TIMES (AJAX REQUEST) ---
    if (isAjax) {
        Connection ajaxConn = null;
        PreparedStatement ajaxPs = null;
        ResultSet ajaxRs = null;
        try {
            Class.forName("com.mysql.jdbc.Driver");
            ajaxConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "root", "root");

            String sql = "SELECT appointmentTime FROM appointments WHERE doctorId = ? AND appointmentDate = ? AND status != 'Cancelled' ORDER BY appointmentTime";
            ajaxPs = ajaxConn.prepareStatement(sql);
            ajaxPs.setInt(1, doctorId);
            ajaxPs.setString(2, fetchDate);
            ajaxRs = ajaxPs.executeQuery();
            
            StringBuilder bookedTimes = new StringBuilder();
            while (ajaxRs.next()) {
                if (bookedTimes.length() > 0) bookedTimes.append(",");
                bookedTimes.append(new SimpleDateFormat("HH:mm").format(ajaxRs.getTime("appointmentTime")));
            }
            
            out.clearBuffer();
            out.print(bookedTimes.toString());
            return; 
        } catch (Exception e) {
            out.clearBuffer();
            out.print("");
            return;
        } finally {
            if (ajaxRs != null) try { ajaxRs.close(); } catch (SQLException e) {}
            if (ajaxPs != null) try { ajaxPs.close(); } catch (SQLException e) {}
            if (ajaxConn != null) try { ajaxConn.close(); } catch (SQLException e) {}
        }
    }

    // --- LOGIC FOR FORM SUBMISSION (POST REQUEST) ---
    if (isPost) {
        patientName = request.getParameter("patientName") != null ? request.getParameter("patientName").trim() : "";
        contactNumber = request.getParameter("contactNumber") != null ? request.getParameter("contactNumber").trim() : "";
        patientAddress = request.getParameter("patientAddress") != null ? request.getParameter("patientAddress").trim() : "";
        patientAge = request.getParameter("patientAge") != null ? request.getParameter("patientAge").trim() : "";
        weight = request.getParameter("weight") != null ? request.getParameter("weight").trim() : "";
        allergies = request.getParameter("allergies") != null ? request.getParameter("allergies").trim() : "";
        appointmentDate = request.getParameter("appointmentDate") != null ? request.getParameter("appointmentDate").trim() : "";
        appointmentTime = request.getParameter("appointmentTime") != null ? request.getParameter("appointmentTime").trim() : "";

        // MODIFICATION: Added validation check for patientId
        if (patientId == 0) {
            message = "Error: Could not identify the logged-in patient. Please log out and try again.";
            messageClass = "error";
        } else if (doctorId == 0 || patientName.isEmpty() || contactNumber.isEmpty() || patientAddress.isEmpty() ||
            patientAge.isEmpty() || appointmentDate.isEmpty() || appointmentTime.isEmpty()) {
            message = "Please fill in all required fields.";
            messageClass = "error";
        } else {
            Connection postConn = null;
            PreparedStatement postPs = null;
            ResultSet postRs = null;
            try {
                Class.forName("com.mysql.jdbc.Driver");
                postConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "root", "root");
                
                String clashCheckSql = "SELECT COUNT(*) FROM appointments WHERE doctorId = ? AND appointmentDate = ? AND status != 'Cancelled' AND TIME(?) = appointmentTime";
                PreparedStatement checkPs = postConn.prepareStatement(clashCheckSql);
                checkPs.setInt(1, doctorId);
                checkPs.setDate(2, java.sql.Date.valueOf(appointmentDate));
                checkPs.setTime(3, java.sql.Time.valueOf(appointmentTime + ":00"));
                postRs = checkPs.executeQuery();
                
                boolean clashFound = false;
                if (postRs.next() && postRs.getInt(1) > 0) {
                    clashFound = true;
                    message = "The selected time slot is already booked. Please choose a different time.";
                    messageClass = "error";
                }
                postRs.close();
                checkPs.close();

                if (!clashFound) {
                    // MODIFICATION: Added patientId and appointmentDuration to the INSERT statement
                    String insertSql = "INSERT INTO appointments (doctorId, patientId, patientName, contactNumber, patientAddress, patientAge, weight, allergies, appointmentDate, appointmentTime, appointmentDuration, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
                    postPs = postConn.prepareStatement(insertSql);

                    // MODIFICATION: Set all parameters with correct indices
                    postPs.setInt(1, doctorId);
                    postPs.setInt(2, patientId); // SETTING THE PATIENT ID
                    postPs.setString(3, patientName);
                    postPs.setString(4, contactNumber);
                    postPs.setString(5, patientAddress);
                    postPs.setInt(6, Integer.parseInt(patientAge));

                    if (weight.isEmpty()) postPs.setNull(7, java.sql.Types.DECIMAL);
                    else postPs.setBigDecimal(7, new java.math.BigDecimal(weight));

                    if (allergies.isEmpty()) postPs.setNull(8, java.sql.Types.LONGVARCHAR);
                    else postPs.setString(8, allergies);

                    postPs.setDate(9, java.sql.Date.valueOf(appointmentDate));
                    postPs.setTime(10, java.sql.Time.valueOf(appointmentTime + ":00"));
                    postPs.setInt(11, SLOT_DURATION_MINUTES); // SETTING THE DURATION

                    int result = postPs.executeUpdate();
                    if (result > 0) {
                        message = "Appointment booked successfully!";
                        messageClass = "success";
                        patientName = contactNumber = patientAddress = patientAge = weight = allergies = appointmentDate = appointmentTime = "";
                    } else {
                        message = "Failed to book the appointment. Please try again.";
                        messageClass = "error";
                    }
                }
            } catch (Exception e) {
                System.err.println("Database Error on POST: " + e.getMessage());
                message = "An internal server error occurred. Please try again."; 
                messageClass = "error";
                e.printStackTrace();
            } finally {
                if (postRs != null) try { postRs.close(); } catch (SQLException e) {}
                if (postPs != null) try { postPs.close(); } catch (SQLException e) {}
                if (postConn != null) try { postConn.close(); } catch (SQLException e) {}
            }
        }
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
    <div class="form-container">
        <h2>Book Appointment</h2>
        <p class="info-text">
            Booking appointment with Dr. <strong><%= doctorName != null ? doctorName : "N/A" %></strong>
            at <strong><%= hospitalName != null ? hospitalName : "N/A" %></strong>
        </p>

        <% if (!message.isEmpty()) { %>
            <div class="message <%= messageClass %>"><%= message %></div>
        <% } %>

        <form method="post" action="appointment.jsp?doctorId=<%= doctorId %>&hospitalName=<%= java.net.URLEncoder.encode(hospitalName != null ? hospitalName : "", "UTF-8") %>&doctorName=<%= java.net.URLEncoder.encode(doctorName != null ? doctorName : "", "UTF-8") %>">
            <input type="hidden" name="doctorId" value="<%= doctorId %>" />

            <label for="patientName" class="required">Patient Name:</label>
            <input type="text" name="patientName" id="patientName" required placeholder="Enter your full name" value="<%= patientName %>" />

            <label for="contactNumber" class="required">Contact Number:</label>
            <input type="text" name="contactNumber" id="contactNumber" required placeholder="Enter phone number" value="<%= contactNumber %>" />

            <label for="patientAddress" class="required">Patient Address:</label>
            <textarea name="patientAddress" id="patientAddress" required placeholder="Enter your address"><%= patientAddress %></textarea>

            <label for="patientAge" class="required">Patient Age:</label>
            <input type="number" name="patientAge" id="patientAge" required min="0" max="120" placeholder="Enter your age" value="<%= patientAge %>" />

            <label for="weight">Weight (kg):</label>
            <input type="number" name="weight" id="weight" step="0.01" min="0" placeholder="Enter your weight in kilograms" value="<%= weight %>" />

            <label for="allergies">Allergies:</label>
            <textarea name="allergies" id="allergies" placeholder="Mention any allergies (if none, leave blank)"><%= allergies %></textarea>

            <label for="appointmentDate" class="required">Appointment Date:</label>
            <input type="date" name="appointmentDate" id="appointmentDate" required min="<%= new SimpleDateFormat("yyyy-MM-dd").format(new Date()) %>" value="<%= appointmentDate %>" />

            <div id="bookedSlotsContainer" style="display:none;">
                <p><strong>Booked Slots on this Day:</strong></p>
                <div class="booked-slots" id="bookedSlotsDisplay"></div>
            </div>

            <label for="appointmentTime" class="required">Appointment Time (HH:MM):</label>
            <input type="time" name="appointmentTime" id="appointmentTime" required value="<%= appointmentTime %>" />

            <input type="submit" value="Book Appointment" />
        </form>
    </div>
</div>

<footer>
    &copy; <%= new SimpleDateFormat("yyyy").format(new Date()) %> Health Portal. All rights reserved. | <a href="/privacy-policy.html">Privacy Policy</a> | <a href="/contact.html">Contact Us</a>
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

    document.addEventListener('DOMContentLoaded', function() {
        const dateInput = document.getElementById('appointmentDate');
        const doctorId = document.querySelector('input[name="doctorId"]').value;
        const bookedSlotsContainer = document.getElementById('bookedSlotsContainer');
        const bookedSlotsDisplay = document.getElementById('bookedSlotsDisplay');

        function fetchBookedTimes() {
            const selectedDate = dateInput.value;
            if (!selectedDate || doctorId == 0) {
                bookedSlotsContainer.style.display = 'none';
                return;
            }
            const url = `appointment.jsp?doctorId=${doctorId}&fetchDate=${selectedDate}`;
            fetch(url)
                .then(response => response.ok ? response.text() : Promise.reject('Network response was not ok'))
                .then(text => {
                    bookedSlotsDisplay.innerHTML = '';
                    if (!text.trim()) {
                        bookedSlotsDisplay.innerHTML = '<span>None booked yet for this date. Go ahead and choose a time!</span>';
                    } else {
                        text.split(',').forEach(time => {
                            const span = document.createElement('span');
                            span.textContent = time;
                            span.style.padding = '3px 6px';
                            span.style.background = '#ffe0b2';
                            span.style.border = '1px solid #ff9800';
                            span.style.borderRadius = '4px';
                            bookedSlotsDisplay.appendChild(span);
                        });
                    }
                    bookedSlotsContainer.style.display = 'block';
                })
                .catch(error => {
                    console.error('Fetch error:', error);
                    bookedSlotsDisplay.innerHTML = 'Could not load booked times. Please try again.';
                    bookedSlotsContainer.style.display = 'block';
                });
        }
        dateInput.addEventListener('change', fetchBookedTimes);
        if (dateInput.value) {
            fetchBookedTimes();
        }
    });
</script>

</body>
</html>