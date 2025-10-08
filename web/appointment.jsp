<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.LocalTime" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>Book Appointment</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f6f9;
            padding: 30px;
        }
        .form-container {
            background: white;
            max-width: 500px;
            margin: auto;
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
    // --- SETUP VARIABLES ---
    final int SLOT_DURATION_MINUTES = 15; // Define the duration here
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
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
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
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            boolean clashFound = false;

            try {
                Class.forName("com.mysql.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "root", "root");

                // --- 1. NEW TIME CLASH VALIDATION CHECK (ENFORCING 15-MIN SLOT) ---
                
                // Convert chosen time to LocalTime object
                LocalTime requestedTime = LocalTime.parse(appointmentTime);
                
                // Calculate the start time of the 15-minute slot requested by the user
                String startTime = requestedTime.toString(); // HH:MM:00
                
                // Calculate the end time of the 15-minute slot requested by the user
                String endTime = requestedTime.plusMinutes(SLOT_DURATION_MINUTES).toString(); 
                
                /* * The following query checks two overlap conditions based on the 15-minute slot:
                 * * Condition A: The START time of an existing appointment's 15-min slot is between
                 * the user's requested START and END time. (This also catches exact clashes).
                 * Condition B: The user's requested START time is between the START time of an 
                 * existing appointment and the END time of that existing appointment's 15-min slot.
                 * * NOTE: This assumes the existing appointments ALSO take 15 minutes.
                 */
                String checkSql = 
                    "SELECT COUNT(*) FROM appointments " +
                    "WHERE doctorId = ? AND appointmentDate = ? AND status != 'Cancelled' AND (" +
                    "    (appointmentTime < ? AND ADDTIME(appointmentTime, '00:15:00') > ?) " + // checks if an existing slot starts before and ends after the request starts
                    "    OR (appointmentTime = ?) " + // checks for exact match
                    "    OR (? < ADDTIME(appointmentTime, '00:15:00') AND ? > appointmentTime)" + // checks if request overlaps an existing slot
                    ")";
                    
                // Simplified query that works if everyone has 15-min slots:
                String simpleOverlapCheck = 
                    "SELECT COUNT(*) FROM appointments WHERE doctorId = ? AND appointmentDate = ? AND status != 'Cancelled' AND (" +
                    "    TIME(?) < ADDTIME(appointmentTime, '00:15:00') AND TIME(?) >= appointmentTime" + // checks if request is inside or overlaps existing slot
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
%>

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

<script>
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

            const url = 'appointment.jsp?doctorId=' + doctorId + '&fetchDate=' + selectedDate;

            fetch(url)
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.text();
                })
                .then(text => {
                    bookedSlotsDisplay.innerHTML = '';
                    if (text.trim() === "") {
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

        if (dateInput.value) {
            fetchBookedTimes();
        }
    });
</script>

</body>
</html>