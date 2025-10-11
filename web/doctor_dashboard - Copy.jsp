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
        /* Your original styles */
        * { margin:0; padding:0; box-sizing:border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f6f9;
            color: #333;
        }
        .main-header { display: flex; justify-content: space-between; align-items: center; background: #0a4275; color: white; padding: 12px 24px; position: sticky; top: 0; z-index: 1000; box-shadow: 0 2px 4px rgba(0,0,0,0.1);}
        .left-section { display:flex; align-items:center; }
        #menuToggle { font-size: 24px; background:none; border:none; color: white; margin-right: 15px; cursor:pointer;}
        .logo-text { font-size: 22px; font-weight: 600; }
        .right-section { position: relative; display:flex; align-items:center; }
        .profile-dropdown { cursor:pointer; display:flex; align-items:center; gap: 10px;}
        .profile-photo {
            width: 42px; height:42px; background: white; border-radius:50%; display:flex; justify-content:center; align-items:center;
            box-shadow: 0 0 6px rgba(0,0,0,0.1); user-select:none; font-size:24px; color:#0077b6;
        }
        .profile-name { font-weight:600; font-size:1.1rem; user-select:none;}
        .dropdown-menu {
            display:none; position:absolute; right:0; top:48px; background:white; border:1px solid #ccc;
            border-radius:5px; min-width:170px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); z-index:1001;
        }
        .dropdown-menu a { display:block; padding:12px 16px; color:#333; text-decoration:none; font-size:15px;}
        .dropdown-menu a:hover { background-color:#f5f5f5; }
        .sidebar {
            width: 240px; background:#1f2b3e; position:fixed; top:60px; left:-260px; height:100%; transition:0.3s ease;
            z-index: 999; padding-top: 20px;
        }
        .sidebar.active { left: 0; }
        .sidebar a {
            display: block; padding:15px 20px; color:#fff; font-size: 16px; text-decoration:none;
        }
        .sidebar a:hover {
            background: #374b68;
        }
        .sidebar a.logout-link, .dropdown-menu a.logout-link {
            color: #e63946; font-weight: 600;
        }
        .sidebar a.logout-link:hover, .dropdown-menu a.logout-link:hover {
            background-color: #b22222; color:white;
        }
        .dashboard-content {
            margin-left: 0; padding: 30px 40px; transition: margin-left 0.3s ease; min-height: calc(100vh - 120px);
        }
        .sidebar.active ~ .dashboard-content { margin-left: 240px; }
        footer {
            background: #023e8a; color: white; text-align:center; padding: 15px 10px; font-size: 0.9rem;
            position: fixed; width: 100%; bottom: 0; left: 0;
        }
        footer a { color:#90e0ef; text-decoration:none; }
        footer a:hover { text-decoration: underline; }
        @media screen and (max-width: 768px) { .dashboard-content { padding: 20px; } }
        .card-box {
            width: 90%; background:#fff; border-radius:10px; padding:20px 25px; margin: 0 auto 30px auto;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1); position: relative;
        }
        .card-box h2 { font-size: 18px; margin-bottom: 15px; color:#222; }
        
        /* Layout for Search and Button: Search fills space, button is fixed size */
        .search-and-button-row { 
            display: flex; 
            align-items: center; 
            gap: 15px; /* Space between search and button */
            margin-bottom: 12px;
        }
        .search-container { 
            position: relative; 
            width: 100%; /* Allows it to take up the full available space */
            flex-grow: 1; /* Makes it consume the remaining horizontal space */
        }
        
        /* Plus Button Style */
        .add-patient-btn-inline {
            background-color: #28a745; /* Green */
            color: white;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            display: flex;
            justify-content: center;
            align-items: center;
            text-decoration: none;
            font-size: 24px; 
            font-weight: 700;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
            flex-shrink: 0; /* Ensures the button doesn't shrink */
        }
        .add-patient-btn-inline:hover {
            background-color: #218838;
        }

        .search-input {
            width: 100%; /* Must be 100% of its container (search-container) */
            padding: 12px 40px 12px 14px; 
            font-size: 16px; 
            border: 1px solid #ccc; 
            border-radius: 6px;
            outline:none;
        }
        .search-input:focus {
            border-color: #0077b6; box-shadow: 0 0 5px rgba(0,119,182,0.4);
        }
        .date-picker {
            position: absolute; right: 10px; top: 50%; transform: translateY(-50%);
            cursor: pointer; border:none; background: transparent; outline:none; font-size:16px;
        }
        .date-picker::-webkit-calendar-picker-indicator { cursor:pointer; filter: invert(30%) sepia(30%) saturate(500%) hue-rotate(190deg); }
        table {
            width: 100%; border-collapse: collapse; margin-top: 20px; background: #fff;
            border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        table thead { background-color: #0a4275; color:white; }
        table th, table td { padding: 12px 16px; border-bottom: 1px solid #ddd; text-align:left; }
        table tbody tr:hover { background-color: #f5f5f5; }
        select.status-select {
            font-weight: 600; padding: 4px 10px; border-radius: 6px; border: 1px solid #ccc; cursor: pointer; color:white;
            background-color: chocolate; /* default */
        }
        select.status-select.Pending { background-color: chocolate; }
        select.status-select.Approved { background-color: green; }
        select.status-select.Cancelled { background-color: red; }
        .time-box {
            display: inline-block;
            background-color: #f0f4f8;
            border: 1px solid #b0bec5;
            border-radius: 6px;
            padding: 4px 8px;
            font-weight: 600;
            color: #37474f;
            font-family: monospace;
            min-width: 70px;
            text-align: center;
        }
    </style>
</head>
<body>
<%!
    public String getStatusClass(String status) {
        if (status == null) return "Pending";
        status = status.trim().toLowerCase();
        switch(status) {
            case "pending": return "Pending";
            case "approved": return "Approved";
            case "cancelled": return "Cancelled";
            default: return "Pending";
        }
    }
%>
<%
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    String statusUpdateError = null; // Variable to hold update error message

    // --- 🚨 START: FORM SUBMISSION PROCESSOR 🚨 ---
    String submittedAppointmentIdStr = request.getParameter("appointmentId");
    String submittedStatus = request.getParameter("status");

    if (submittedAppointmentIdStr != null && submittedStatus != null) {
        // This block executes when the status form is submitted
        
        try {
            int appointmentId = Integer.parseInt(submittedAppointmentIdStr.trim());
            
            Class.forName("com.mysql.jdbc.Driver"); 
            Connection connUpdate = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");

            String sql = "UPDATE appointments SET status = ? WHERE id = ?";
            PreparedStatement psUpdate = connUpdate.prepareStatement(sql);
            psUpdate.setString(1, submittedStatus.trim());
            psUpdate.setInt(2, appointmentId);

            int rowsAffected = psUpdate.executeUpdate();
            
            psUpdate.close();
            connUpdate.close();

            if (rowsAffected == 0) {
                 statusUpdateError = "Error: Appointment ID " + appointmentId + " not found.";
            }

        } catch (NumberFormatException e) {
            statusUpdateError = "Error: Invalid appointment ID format.";
        } catch (Exception e) {
            statusUpdateError = "Database update failed: " + e.getMessage();
        }
    }
    // --- 🛑 END: FORM SUBMISSION PROCESSOR 🛑 ---


    // --- START: NORMAL PAGE RENDERING LOGIC ---
    String fullname = (String) session.getAttribute("fullname");
    if (fullname == null || fullname.isEmpty()) {
        response.sendRedirect("doctorlogin.jsp");
        return;
    }
    String hospitalName = "Unknown Hospital";
    
    String selectedDateStr = request.getParameter("date");
    if (selectedDateStr == null || selectedDateStr.trim().isEmpty()) {
        selectedDateStr = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
    }
    String displayDate = "";
    try {
        // Use SimpleDateFormat to parse the selected date for display
        java.util.Date dateObj = new SimpleDateFormat("yyyy-MM-dd").parse(selectedDateStr);
        displayDate = new SimpleDateFormat("EEEE, MMMM dd, yyyy").format(dateObj);
    } catch(Exception e) {
        // Fallback if date parsing fails
        displayDate = selectedDateStr;
    }
    
    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");
        
        // 1. Get hospital name
        ps = conn.prepareStatement("SELECT hospital_name FROM doctors WHERE LOWER(TRIM(fullname)) = LOWER(TRIM(?))");
        ps.setString(1, fullname);
        rs = ps.executeQuery();
        if (rs.next()) hospitalName = rs.getString("hospital_name");
        rs.close();
        ps.close();
        
        // 2. Get all doctor IDs for that hospital
        ps = conn.prepareStatement("SELECT id FROM doctors WHERE hospital_name = ?");
        ps.setString(1, hospitalName);
        rs = ps.executeQuery();
        java.util.List<Integer> doctorIds = new java.util.ArrayList<>();
        while (rs.next()) doctorIds.add(rs.getInt("id"));
        rs.close();
        ps.close();
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
                 <a href="staff.jsp">Staff</a>
                <a href="doctorlogin.jsp" class="logout-link">Logout</a>
            </div>
        </div>
    </div>
</header>
<nav class="sidebar" id="sidebar">
    <a href="my_profile.jsp">My Profile</a>
    <a href="doctor_dashboard.jsp">Appointments</a>
    <a href="staff.jsp">Staff</a>
    <a href="doctorlogin.jsp" class="logout-link">Logout</a>
</nav>

<div class="dashboard-content">
    <div class="card-box">
        <h2>Appointments for <span id="selectedDate"><%= displayDate %></span></h2>
        
        <% if (statusUpdateError != null) { %>
            <p style="color: red; font-weight: bold; margin-bottom: 15px;"><%= statusUpdateError %></p>
        <% } %>

        <div class="search-and-button-row">
            <div class="search-container">
                <input type="text" placeholder="Search patient name..." class="search-input" id="patientSearch" />
                <input type="date" id="appointmentDatePicker" class="date-picker" title="Select Date"
                    value="<%= selectedDateStr %>" />
                    </div>
            <a href="add_patient.jsp" class="add-patient-btn-inline" title="Add New Patient">
                +
            </a>
        </div>
        
        <%
            if (doctorIds.isEmpty()) {
        %>
        <p>No doctors found for hospital "<%= hospitalName %>". No appointments available.</p>
        <%
            } else {
                StringBuilder inClause = new StringBuilder();
                for (int i = 0; i < doctorIds.size(); i++) {
                    inClause.append("?");
                    if (i < doctorIds.size() - 1) inClause.append(",");
                }
                String sql = "SELECT id, patientName, contactNumber, patientAddress, patientAge, weight, allergies, appointmentTime, status " +
                             "FROM appointments WHERE doctorId IN (" + inClause.toString() + ") AND appointmentDate = ? " +
                             // FIX 2: Removed the redundant time constraint (AND appointmentTime >= '10:00:00')
                             "ORDER BY appointmentTime ASC";
                ps = conn.prepareStatement(sql);
                int idx = 1;
                for (Integer id : doctorIds) ps.setInt(idx++, id);
                ps.setString(idx, selectedDateStr);
                rs = ps.executeQuery();
        %>
        <table id="appointmentsTable">
            <thead>
                <tr>
                    <th>Patient Name</th>
                    <th>Contact Number</th>
                    <th>Address</th>
                    <th>Age</th>
                    <th>Weight (kg)</th>
                    <th>Allergies</th>
                    <th>Appointment Time</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                    while(rs.next()) {
                        int appointmentId = rs.getInt("id");
                        String patientName = rs.getString("patientName");
                        String contactNumber = rs.getString("contactNumber");
                        String patientAddress = rs.getString("patientAddress");
                        int patientAge = rs.getInt("patientAge");
                        java.math.BigDecimal weight = rs.getBigDecimal("weight");
                        String allergies = rs.getString("allergies");
                        Time appointmentTime = rs.getTime("appointmentTime");
                        String currentStatus = rs.getString("status");
                        // Format time to 12-hour format with AM/PM
                        String formattedTime = "";
                        if (appointmentTime != null) {
                            try {
                                java.util.Date t = new java.text.SimpleDateFormat("HH:mm:ss").parse(appointmentTime.toString());
                                formattedTime = new java.text.SimpleDateFormat("hh:mm a").format(t);
                            } catch (Exception e) {
                                formattedTime = appointmentTime.toString();
                            }
                        }
                %>
                <tr>
                    <td class="patient-name"><%= patientName %></td>
                    <td><%= contactNumber %></td>
                    <td><%= patientAddress %></td>
                    <td><%= patientAge %></td>
                    <td><%= (weight != null) ? weight.toString() : "N/A" %></td>
                    <td><%= (allergies != null && !allergies.trim().isEmpty()) ? allergies : "None" %></td>
                    <td><span class="time-box"><%= formattedTime %></span></td>
                    <td>
                        <form action="doctor_dashboard.jsp" method="post" style="margin: 0;">
                            <input type="hidden" name="appointmentId" value="<%= appointmentId %>" />
                            <input type="hidden" name="date" value="<%= selectedDateStr %>" />
                            <select class="status-select <%= getStatusClass(currentStatus) %>" 
                                        name="status" 
                                        onchange="this.form.submit();">
                                <option value="Pending" <%= "Pending".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Pending</option>
                                <option value="Approved" <%= "Approved".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Approved</option>
                                <option value="Cancelled" <%= "Cancelled".equalsIgnoreCase(currentStatus) ? "selected" : "" %>>Cancelled</option>
                            </select>
                        </form>
                    </td>
                </tr>
                <%
                    }
                    rs.close();
                    ps.close();
                }
            } catch (Exception e) {
        %>
        <p style="color:red;">Error: <%= e.getMessage() %></p>
        <%
            } finally {
                try { if(rs!=null) rs.close(); } catch(Exception e) {}
                try { if(ps!=null) ps.close(); } catch(Exception e) {}
                try { if(conn!=null) conn.close(); } catch(Exception e) {}
            }
        %>
            </tbody>
        </table>
    </div>
</div>
<footer>
    &copy; 2025 Health Portal. All rights reserved.
</footer>
<script>
document.getElementById("menuToggle").addEventListener("click", function(){
    document.getElementById("sidebar").classList.toggle("active");
});
function toggleDropdown(){
    const menu = document.getElementById("dropdownMenu");
    menu.style.display = (menu.style.display === "block") ? "none" : "block";
}
window.onclick = function(event) {
    if(!event.target.closest('.profile-dropdown')){
        document.getElementById("dropdownMenu").style.display = "none";
    }
};
document.getElementById('appointmentDatePicker').addEventListener('change', function(){
    const selectedDate = this.value;
    // Redirects the page with the newly selected date as a query parameter
    let newUrl = window.location.pathname + '?date=' + encodeURIComponent(selectedDate);
    window.location.href = newUrl;
});
const searchInput = document.getElementById('patientSearch');
const table = document.getElementById('appointmentsTable');
searchInput.addEventListener('keyup', function(){
    let filter = this.value.toLowerCase();
    let rows = table.querySelectorAll("tbody tr");
    rows.forEach(function(row){
        let nameCell = row.querySelector(".patient-name");
        // Check if the patient name cell exists and contains the filter text
        row.style.display = (nameCell && nameCell.textContent.toLowerCase().indexOf(filter) > -1) ? "" : "none";
    });
});

window.onload = function(){
    // Apply class for styling the status select based on its initial value
    document.querySelectorAll('select.status-select').forEach(function(sel){
        let val = sel.value;
        // Capitalize first letter and ensure rest is lowercase (e.g., pending -> Pending)
        let className = val.charAt(0).toUpperCase() + val.slice(1).toLowerCase();
        sel.classList.add(className);
    });
};
</script>
</body>
</html>