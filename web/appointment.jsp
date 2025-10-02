<%@ page import="java.sql.*" %>
<%@ page import="java.net.URLDecoder" %>
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
    </style>
</head>
<body>

<%
    String doctorIdParam = request.getParameter("doctorId");
    int doctorId = 0;
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
    boolean isPost = "POST".equalsIgnoreCase(request.getMethod());
    boolean showPopup = false;

    String patientName = "";
    String contactNumber = "";
    String patientAddress = "";
    String patientAge = "";
    String weight = "";
    String allergies = "";
    String appointmentDate = "";
    String appointmentTime = "";

    if (isPost) {
        String doctorIdStr = request.getParameter("doctorId");
        if (doctorIdStr != null) {
            try {
                doctorId = Integer.parseInt(doctorIdStr);
            } catch (NumberFormatException e) {
                doctorId = 0;
            }
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
            try {
                Class.forName("com.mysql.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "root", "root");

                String sql = "INSERT INTO appointments (doctorId, patientName, contactNumber, patientAddress, patientAge, weight, allergies, appointmentDate, appointmentTime, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
                ps = conn.prepareStatement(sql);
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
                ps.setTime(9, java.sql.Time.valueOf(appointmentTime + ":00")); // append seconds for SQL Time

                int result = ps.executeUpdate();
                if (result > 0) {
                    message = "Appointment booked successfully!";
                    messageClass = "success";
                    showPopup = true; // to show the popup
                    // Clear fields
                    patientName = contactNumber = patientAddress = patientAge = weight = allergies = appointmentDate = appointmentTime = "";
                } else {
                    message = "Failed to book the appointment. Please try again.";
                    messageClass = "error";
                }

            } catch (Exception e) {
                message = "Error: " + e.getMessage();
                messageClass = "error";
            } finally {
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

    <form method="post" action="appointment.jsp">
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
        <input type="date" name="appointmentDate" id="appointmentDate" required min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" value="<%= appointmentDate %>" />

        <label for="appointmentTime" class="required">Appointment Time:</label>
        <input type="time" name="appointmentTime" id="appointmentTime" required value="<%= appointmentTime %>" />

        <input type="submit" value="Book Appointment" />
    </form>
</div>

<% if (showPopup) { %>
<script>
    alert("Your appointment request is received. You will get a proper slot after checking the doctor's availability for the selected date and time.");
</script>
<% } %>

</body>
</html>
