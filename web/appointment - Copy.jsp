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
        footer { background: #0a4275; color: white; padding: 16px 42px; text-align: center; font-size: 14px; position: relative; bottom: 0; width: 100%; box-sizing: border-box; box-shadow: 0 -2px 6px rgba(0,0,0,0.15); margin-top: 40px; }
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
            margin: auto; /* Changed from 'auto' to ensure it centers within the dashboard-content */
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.1);
        }
        h2 {
            text-align: center;
            color: #0466c8;
            margin-bottom: 25px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
        }
        label.required::after {
            content: " *";
            color: red;
        }
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
        textarea {
            resize: vertical;
            min-height: 50px;
            max-height: 80px;
        }
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
        input[type="submit"]:hover {
            background-color: #024a7a;
        }
        .info-text {
            margin-bottom: 20px;
            font-style: italic;
            color: #555;
            text-align: center;
        }
        .message {
            text-align: center;
            margin-bottom: 15px;
            font-weight: bold;
        }
        .success {
            color: green;
        }
        .error {
            color: red;
        }
        /* New styles for booked slots display */
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
    // --- START: HEADER LOGIC ---
    String fullname = (String) session.getAttribute("fullname");
    String profileEmoji = "👤";
    String gender = "";
    
    // Check for login status
    if (fullname == null || fullname.isEmpty()) {
        // response.sendRedirect("patientlogin.jsp"); // Uncomment this line when deploying
        fullname = "Guest User"; // Placeholder for demonstration
    }

    // Database logic to fetch gender/emoji (Retained from userdashboard for completeness)
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");
        String sql = "SELECT gender FROM patients WHERE fullname = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, fullname);
        rs = ps.executeQuery();
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
    } catch (Exception e) {
        // Silently fail if DB connection for emoji fails
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (ps != null) ps.close(); } catch (Exception e) {}
        // DO NOT CLOSE conn YET, as we might need it for the main form logic later
        // It will be closed in the main form logic's finally block, or immediately if we're done here.
        if (conn != null) {
            try { conn.close(); } catch (Exception e) {}
            conn = null;
        }
    }
    // --- END: HEADER LOGIC ---

    // --- START: ORIGINAL APPOINTMENT LOGIC ---
    // The existing logic from appointment.jsp starts here.
    final int SLOT_DURATION_MINUTES = 15;
    String doctorIdParam = request.getParameter("doctorId");
    int doctorId = 0;
    
    String fetchDate = request.getParameter("fetchDate");
    boolean isAjax = fetchDate != null;

    if (doctorIdParam != null) {
        try {
            doctorId = Integer.parseInt(doctorIdParam);
        } catch (NumberFormatException e) {
            // doctorId remains 0
        }
    }

    String hospitalName = request.getParameter("hospitalName");
    String doctorName = request.getParameter("doctorName");

    if (hospitalName != null) hospitalName = URLDecoder.decode(hospitalName, "UTF-8");
    if (doctorName != null) doctorName = URLDecoder.decode(doctorName, "UTF-8");

    String message = "";
    String messageClass = "";
    boolean isPost = "POST".equalsIgnoreCase(request.getMethod()) && !isAjax; 
    boolean showPopup = false;

    // Retain form data on error
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
        // Reopen DB connection for AJAX
        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "root", "root");

            String sql = "SELECT appointmentTime FROM appointments WHERE doctorId = ? AND appointmentDate = ? AND status != 'Cancelled' ORDER BY appointmentTime";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, doctorId);
            ps.setString(2, fetchDate);
            rs = ps.executeQuery();
            
            StringBuilder bookedTimes = new StringBuilder();
            while (rs.next()) {
                if (bookedTimes.length() > 0) {
                    bookedTimes.append(",");
                }
                bookedTimes.append(new SimpleDateFormat("HH:mm").format(rs.getTime("appointmentTime")));
            }
            
            out.clearBuffer();
            out.print(bookedTimes.toString());
            return; 

        } catch (Exception e) {
            out.clearBuffer();
            out.print("");
            return;
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }

    // --- LOGIC FOR FORM SUBMISSION (POST REQUEST) ---
    if (isPost) {
        // Re-read and sanitize form data
        String doctorIdStr = request.getParameter("doctorId");
        if (doctorIdStr != null) {
            try { doctorId = Integer.parseInt(doctorIdStr); } catch (NumberFormatException e) { doctorId = 0; }
        }

        patientName = request.getParameter("patientName") != null ? request.getParameter("patientName").trim() : "";
        contactNumber = request.getParameter("contactNumber") != null ? request.getParameter("contactNumber").trim() : "";
        patientAddress = request.getParameter("patientAddress") != null ? request.getParameter("patientAddress").trim() : "";
        patientAge = request.getParameter("patientAge") != null ? request.getParameter("patientAge").trim() : "";
        weight = request.getParameter("weight") != null ? request.getParameter("weight").trim() : "";
        allergies = request.getParameter("allergies") != null ? request.getParameter("allergies").trim() : "";
        appointmentDate = request.getParameter("appointmentDate") != null ? request.getParameter("appointmentDate").trim() : "";
        appointmentTime = request.getParameter("appointmentTime") != null ? request.getParameter("appointmentTime").trim() : "";

        if (doctorId == 0 || patientName.isEmpty() || contactNumber.isEmpty() || patientAddress.isEmpty() ||
            patientAge.isEmpty() || appointmentDate.isEmpty() || appointmentTime.isEmpty()) {
            message = "Please fill in all required fields and ensure Doctor ID is valid.";
            messageClass = "error";
        } else {
            // Reopen DB connection for POST
            try {
                Class.forName("com.mysql.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "root", "root");
                boolean clashFound = false;

                // --- 1. TIME CLASH VALIDATION CHECK (ENFORCING 15-MIN SLOT) ---
                
                LocalTime requestedTime = LocalTime.parse(appointmentTime);
                String startTime = requestedTime.toString();
                String endTime = requestedTime.plusMinutes(SLOT_DURATION_MINUTES).toString(); 
                
                // Simplified query that works if everyone has 15-min slots:
                String simpleOverlapCheck = 
                    "SELECT COUNT(*) FROM appointments WHERE doctorId = ? AND appointmentDate = ? AND status != 'Cancelled' AND (" +
                    "   TIME(?) < ADDTIME(appointmentTime, '00:15:00') AND TIME(?) >= appointmentTime" +
                    ")";


                PreparedStatement checkPs = conn.prepareStatement(simpleOverlapCheck);
                checkPs.setInt(1, doctorId);
                checkPs.setDate(2, java.sql.Date.valueOf(appointmentDate));
                checkPs.setTime(3, java.sql.Time.valueOf(startTime + ":00")); // User's requested START time
                checkPs.setTime(4, java.sql.Time.valueOf(endTime + ":00"));   // User's requested END time
                
                rs = checkPs.executeQuery();
                
                if (rs.next() && rs.getInt(1) > 0) {
                    clashFound = true;
                    message = "The time " + appointmentTime + " clashes with an existing 15-minute appointment slot. Please choose a different time, preferably a 15-minute interval.";
                    messageClass = "error";
                }
                rs.close();
                checkPs.close();
                // -----------------------------------------------------------------

                if (!clashFound) {
                    // 2. --- INSERT APPOINTMENT ---
                    String insertSql = "INSERT INTO appointments (doctorId, patientName, contactNumber, patientAddress, patientAge, weight, allergies, appointmentDate, appointmentTime, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
                    ps = conn.prepareStatement(insertSql);
                    ps.setInt(1, doctorId);
                    ps.setString(2, patientName);
                    ps.setString(3, contactNumber);
                    ps.setString(4, patientAddress);
                    ps.setInt(5, Integer.parseInt(patientAge));

                    if (weight.isEmpty()) {
                        ps.setNull(6, java.sql.Types.DECIMAL);
                    } else {
                        ps.setBigDecimal(6, new java.math.BigDecimal(weight));
                    }

                    if (allergies.isEmpty()) {
                        ps.setNull(7, java.sql.Types.LONGVARCHAR);
                    } else {
                        ps.setString(7, allergies);
                    }

                    ps.setDate(8, java.sql.Date.valueOf(appointmentDate));
                    ps.setTime(9, java.sql.Time.valueOf(appointmentTime + ":00")); 

                    int result = ps.executeUpdate();
                    if (result > 0) {
                        message = "Appointment booked successfully!";
                        messageClass = "success";
                        showPopup = true; 
                        // Clear fields upon success
                        patientName = contactNumber = patientAddress = patientAge = weight = allergies = appointmentDate = appointmentTime = "";
                    } else {
                        message = "Failed to book the appointment. Please try again.";
                        messageClass = "error";
                    }
                }

            } catch (Exception e) {
                System.err.println("Database Error: " + e.getMessage()); // Log error on server console
                message = "An internal server error occurred. Please try again."; 
                messageClass = "error";
            } finally {
                try { if (rs != null) rs.close(); } catch (Exception e) {}
                try { if (ps != null) ps.close(); } catch (Exception e) {}
                try { if (conn != null) conn.close(); } catch (Exception e) {}
            }
        }
    }
    // --- END: ORIGINAL APPOINTMENT LOGIC ---
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
    <a href="#">Saved</a>
    <a href="#">About Us</a>
    <a href="#">Share</a>
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

        <form method="post" action="appointment.jsp?doctorId=<%= doctorId %>&hospitalName=<%= hospitalName %>&doctorName=<%= doctorName %>">
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
                <p><strong>Booked Slots (Each slot is ~<%= SLOT_DURATION_MINUTES %> minutes):</strong></p>
                <div class="booked-slots" id="bookedSlotsDisplay"></div>
                <small style="color:#a00; font-weight:bold;">Please choose a time that does not fall within the <%= SLOT_DURATION_MINUTES %>-minute duration of any listed slot.</small>
            </div>

            <label for="appointmentTime" class="required">Appointment Time (HH:MM):</label>
            <input type="time" name="appointmentTime" id="appointmentTime" required value="<%= appointmentTime %>" />

            <input type="submit" value="Book Appointment" />
        </form>
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

    // Original AJAX logic for fetching booked times
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

            // Append the original query string to maintain doctor/hospital context
            const originalQuery = window.location.search.substring(1);
            const url = 'appointment.jsp?' + originalQuery + '&fetchDate=' + selectedDate;

            fetch(url)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.text();
                })
                .then(text => {
                    bookedSlotsDisplay.innerHTML = '';
                    if (text.trim() === "" || text.trim() === "0") {
                        bookedSlotsDisplay.innerHTML = 'None booked yet for this date. Go ahead and choose a time!';
                        bookedSlotsContainer.style.display = 'block';
                    } else {
                        const bookedTimesArray = text.split(',');
                        bookedTimesArray.forEach(time => {
                            const span = document.createElement('span');
                            span.textContent = time;
                            span.style.padding = '3px 6px';
                            span.style.border = '1px solid #ff6f00';
                            span.style.borderRadius = '3px';
                            bookedSlotsDisplay.appendChild(span);
                        });
                        bookedSlotsContainer.style.display = 'block';
                    }
                })
                .catch(error => {
                    console.error('Fetch error:', error);
                    bookedSlotsDisplay.innerHTML = 'Could not load booked times. Please try again.';
                    bookedSlotsContainer.style.display = 'block';
                });
        }

        dateInput.addEventListener('change', fetchBookedTimes);

        // Check if the date field was pre-filled (e.g., after an error on post)
        if (dateInput.value) {
            fetchBookedTimes();
        }
    });
</script>

</body>
</html>