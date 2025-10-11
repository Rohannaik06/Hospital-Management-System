<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%!
    // Helper class to hold appointment data
    public class Appointment {
        public int id;
        public String doctorName;
        public String specialization;
        public String patientName;
        public String status;
        public Timestamp appointmentDate;

        public String getFormattedDate() {
            if (appointmentDate != null) {
                return new SimpleDateFormat("dd MMMM yyyy, hh:mm a").format(appointmentDate);
            }
            return "N/A";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Appointments</title>
    <style>
        /* All CSS styles remain the same. No changes are needed. */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; color: #333; }
        .main-header { display: flex; justify-content: space-between; align-items: center; background: #0a4275; color: white; padding: 12px 24px; width: 100%; position: sticky; top: 0; z-index: 1000; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .left-section { display: flex; align-items: center; }
        #menuToggle { font-size: 30px; background: none; border: none; color: white; margin-right: 20px; cursor: pointer; user-select: none; }
        .logo-text { font-size: 26px; font-weight: 600; user-select: none; }
        .right-section { position: relative; display: flex; align-items: center; }
        .profile-dropdown { cursor: pointer; display: flex; align-items: center; gap: 12px; }
        .profile-photo-header { width: 50px; height: 50px; background: white; border-radius: 50%; display: flex; justify-content: center; align-items: center; box-shadow: 0 0 6px rgba(0,0,0,0.1); font-size: 28px; color: #0077b6; }
        .profile-name-header { font-weight: 600; font-size: 1.25rem; }
        .dropdown-menu { display: none; position: absolute; right: 0; top: 58px; background: white; border: 1px solid #ccc; border-radius: 6px; min-width: 190px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); z-index: 1001; }
        .dropdown-menu a { display: block; padding: 14px 20px; color: #333; text-decoration: none; font-size: 16px; }
        .dropdown-menu a:hover { background: #f5f5f5; }
        .dropdown-menu .logout-link { color: #e63946; font-weight: 600; }
        .dropdown-menu .logout-link:hover { background: #b22222 !important; color: white !important; }
        .sidebar { width: 280px; background: #1f2b3e; position: fixed; top: 70px; left: -300px; height: 100%; transition: 0.3s ease; z-index: 999; padding-top: 25px; }
        .sidebar.active { left: 0; }
        .sidebar a { display: block; padding: 18px 24px; color: #fff; font-size: 18px; text-decoration: none; }
        .sidebar a:hover { background: #374b68; }
        .sidebar .logout-link { color: #e63946; font-weight: 600; }
        .sidebar .logout-link:hover { background: #b22222 !important; color: white !important; }
        .dashboard-content { margin-left: 0; padding: 36px 48px; transition: margin-left 0.3s ease; min-height: calc(100vh - 120px); padding-bottom: 80px; }
        .sidebar.active ~ .dashboard-content { margin-left: 280px; }
        footer { background: #023e8a; color: white; text-align: center; padding: 18px 10px; font-size: 1rem; width: 100%; position: fixed; bottom: 0; left: 0; }
        .appointments-container { max-width: 1200px; margin: 20px auto; background: #fff; border-radius: 10px; padding: 30px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .appointments-container h1 { color: #0a4275; margin-bottom: 25px; font-size: 28px; border-bottom: 2px solid #eee; padding-bottom: 15px; }
        .appointments-container h2 { font-size: 22px; color: #0077b6; margin-top: 40px; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 1px solid #ddd; }
        .appointments-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        .appointments-table th, .appointments-table td { padding: 15px; text-align: left; border-bottom: 1px solid #ddd; }
        .appointments-table th { background: #f8f9fa; font-weight: 600; color: #333; }
        .status { padding: 5px 12px; border-radius: 15px; color: white; font-weight: 600; font-size: 0.85rem; text-align: center; display: inline-block; }
        .status.pending { background: #ffc107; color: #333; }
        .status.approved { background: #28a745; }
        .status.scheduled { background: #0077b6; }
        .status.confirmed { background: #5a9b44; }
        .status.completed { background: #6c757d; }
        .status.cancelled { background: #e63946; }
        .cancel-btn { background: #dc3545; color: white; border: none; padding: 8px 15px; border-radius: 5px; cursor: pointer; font-weight: 600; transition: background 0.3s ease; }
        .cancel-btn:hover { background: #c82333; }
        .no-appointments { text-align: center; padding: 40px; font-size: 18px; color: #777; }
    </style>
</head>
<body>

<%
    String sessionFullname = (String) session.getAttribute("fullname");
    if (sessionFullname == null || sessionFullname.isEmpty()) {
        response.sendRedirect("patientlogin.jsp");
        return;
    }

    String profileEmoji = "🧑";
    int patientId = -1;
    Connection conn = null;
    List<Appointment> upcomingAppointments = new ArrayList<>();
    List<Appointment> historicalAppointments = new ArrayList<>();

    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");

        // Cancellation logic
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String appointmentIdToCancel = request.getParameter("cancel_id");
            if (appointmentIdToCancel != null && !appointmentIdToCancel.isEmpty()) {
                String updateSql = "UPDATE appointments SET status = 'Cancelled' WHERE id = ? AND patientId = (SELECT pid FROM patients WHERE fullname = ?)";
                try (PreparedStatement psUpdate = conn.prepareStatement(updateSql)) {
                    psUpdate.setInt(1, Integer.parseInt(appointmentIdToCancel));
                    psUpdate.setString(2, sessionFullname);
                    psUpdate.executeUpdate();
                }
                response.sendRedirect("myappointments.jsp");
                return;
            }
        }

        // Fetch patient ID and gender
        String patientSql = "SELECT pid, gender FROM patients WHERE fullname = ?";
        try (PreparedStatement ps = conn.prepareStatement(patientSql)) {
            ps.setString(1, sessionFullname);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    patientId = rs.getInt("pid");
                    String gender = rs.getString("gender");
                    if ("male".equalsIgnoreCase(gender)) profileEmoji = "👨";
                    else if ("female".equalsIgnoreCase(gender)) profileEmoji = "👩";
                }
            }
        }

        if (patientId != -1) {
            String appointmentsSql = "SELECT " +
                                     "a.id, " +
                                     "d.fullname AS doctor_name, " +
                                     "d.specialization AS doctor_specialization, " +
                                     "a.patientName, " +
                                     "a.status, " +
                                     "CONCAT(a.appointmentDate, ' ', a.appointmentTime) AS full_appointment_date " +
                                     "FROM appointments a " +
                                     "JOIN doctors d ON a.doctorId = d.id " +
                                     "WHERE a.patientId = ? " +
                                     "ORDER BY full_appointment_date DESC";

            try (PreparedStatement ps = conn.prepareStatement(appointmentsSql)) {
                ps.setInt(1, patientId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Appointment appt = new Appointment();
                        appt.id = rs.getInt("id");
                        appt.doctorName = rs.getString("doctor_name");
                        appt.specialization = rs.getString("doctor_specialization");
                        appt.patientName = rs.getString("patientName");
                        appt.appointmentDate = rs.getTimestamp("full_appointment_date");
                        appt.status = rs.getString("status");

                        boolean isPast = appt.appointmentDate != null && appt.appointmentDate.before(new java.util.Date());
                        boolean isFinished = "Completed".equalsIgnoreCase(appt.status) || "Cancelled".equalsIgnoreCase(appt.status);

                        if (isPast || isFinished) {
                            historicalAppointments.add(appt);
                        } else {
                            upcomingAppointments.add(appt);
                        }
                    }
                }
            }
        }

    } catch (Exception e) {
        // e.printStackTrace(); 
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
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
            <div class="profile-name-header"><%= sessionFullname %></div>
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
    <div class="appointments-container">
        <h1>My Appointments</h1>

        <h2>Upcoming Appointments</h2>
        <table class="appointments-table">
            <thead>
                <tr>
                    <th>Doctor Name</th>
                    <th>Specialization</th>
                    <th>Appointment Date & Time</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
            <% if (upcomingAppointments.isEmpty()) { %>
                <tr><td colspan="5" class="no-appointments">You have no upcoming appointments.</td></tr>
            <% } else {
                for (Appointment appt : upcomingAppointments) { %>
                <tr>
                    <td><%= appt.doctorName %></td>
                    <td><%= appt.specialization %></td>
                    <td><%= appt.getFormattedDate() %></td>
                    <td><span class="status <%= appt.status.toLowerCase() %>"><%= appt.status %></span></td>
                    <td>
                        <% if (!"Cancelled".equalsIgnoreCase(appt.status) && !"Completed".equalsIgnoreCase(appt.status)) { %>
                            <form method="POST" action="myappointments.jsp" onsubmit="return confirm('Are you sure you want to cancel this appointment?');">
                                <input type="hidden" name="cancel_id" value="<%= appt.id %>">
                                <button type="submit" class="cancel-btn">Cancel</button>
                            </form>
                        <% } else { %>
                            -
                        <% } %>
                    </td>
                </tr>
            <%  }
               } %>
            </tbody>
        </table>

        <h2>Appointment History</h2>
        <table class="appointments-table">
            <thead>
                <tr>
                    <th>Patient Name</th>
                    <th>Doctor Name</th>
                    <th>Date & Time</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
            <% if (historicalAppointments.isEmpty()) { %>
                <tr><td colspan="4" class="no-appointments">You have no past appointments.</td></tr>
            <% } else {
                // *** THIS IS THE CORRECTED CODE BLOCK ***
                // Sorting history to show the most recent first using Java 7 compatible syntax
                Collections.sort(historicalAppointments, new Comparator<Appointment>() {
                    @Override
                    public int compare(Appointment o1, Appointment o2) {
                        // Handle nulls to place them at the end
                        if (o1.appointmentDate == null && o2.appointmentDate == null) {
                            return 0;
                        }
                        if (o1.appointmentDate == null) {
                            return 1; // o1 is null, it should come after o2
                        }
                        if (o2.appointmentDate == null) {
                            return -1; // o2 is null, it should come after o1
                        }
                        // Reverse order: compare o2 to o1 for descending sort
                        return o2.appointmentDate.compareTo(o1.appointmentDate);
                    }
                });
                for (Appointment appt : historicalAppointments) { %>
                <tr>
                    <td><%= appt.patientName %></td>
                    <td><%= appt.doctorName %></td>
                    <td><%= appt.getFormattedDate() %></td>
                    <td><span class="status <%= appt.status.toLowerCase() %>"><%= appt.status %></span></td>
                </tr>
            <%  }
               } %>
            </tbody>
        </table>
    </div>
</div>

<footer>
    &copy; 2025 Health Portal. All rights reserved.
</footer>

<script>
    // JavaScript is unchanged
    const menuToggle = document.getElementById("menuToggle");
    const sidebar = document.getElementById("sidebar");
    const dropdownMenu = document.getElementById("dropdownMenu");
    menuToggle.addEventListener("click", () => sidebar.classList.toggle("active"));
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