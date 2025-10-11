<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>User Dashboard</title>
    <style>
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
        
        /* Styles for Appointment Table */
        .appointments-container {
            background-color: #fff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .appointments-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .appointments-table th, .appointments-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        .appointments-table th {
            background-color: #f8f9fa;
            font-weight: 600;
            color: #333;
        }
        .appointments-table tr:hover {
            background-color: #f1f1f1;
        }
        .status {
            padding: 5px 10px;
            border-radius: 15px;
            font-size: 0.8rem;
            font-weight: bold;
            color: #fff;
            text-transform: uppercase;
        }
        .status-pending { background-color: #ffc107; color: #333; }
        .status-approved { background-color: #28a745; }
        .status-cancelled { background-color: #dc3545; }
        
        footer { background: #0a4275; color: white; padding: 16px 42px; text-align: center; font-size: 14px; width: 100%; box-sizing: border-box; box-shadow: 0 -2px 6px rgba(0,0,0,0.15); margin-top: 40px; }
        footer a { color: #8ecae6; text-decoration: none; margin: 0 8px; font-weight: 500; }
        footer a:hover { text-decoration: underline; }
        @media screen and (max-width: 768px) {
            .dashboard-content { padding: 20px }
            .appointments-table th, .appointments-table td { padding: 8px; font-size: 0.9rem; }
        }
    </style>
</head>
<body>

<%
    String fullname = (String) session.getAttribute("fullname");
    String profileEmoji = "👤";
    int patientId = 0;

    if (fullname == null || fullname.isEmpty()) {
        response.sendRedirect("patientlogin.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");
        
        String sql = "SELECT pid, gender FROM patients WHERE fullname = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, fullname);
        rs = ps.executeQuery();

        if (rs.next()) {
            patientId = rs.getInt("pid");
            String gender = rs.getString("gender");
            if ("male".equalsIgnoreCase(gender)) profileEmoji = "👨";
            else if ("female".equalsIgnoreCase(gender)) profileEmoji = "👩";
            else profileEmoji = "🧑";
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
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
            <div class="profile-photo"><%= profileEmoji %></div>
            <div class="profile-name"><%= fullname %></div>
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
        <h2>Pending Appointments</h2>
        <table class="appointments-table">
            <thead>
                <tr>
                    <th>Doctor</th>
                    <th>Specialization</th>
                    <th>Date</th>
                    <th>Time</th>
                    <th>Status</th>
                    </tr>
            </thead>
            <tbody>
            <%
                Connection pendingConn = null;
                PreparedStatement pendingPs = null;
                ResultSet pendingRs = null;
                boolean hasPending = false;

                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    pendingConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");

                    String pendingSql = "SELECT a.id, d.fullname AS doctorName, d.specialization, a.appointmentDate, a.appointmentTime, a.status " +
                                        "FROM appointments a JOIN doctors d ON a.doctorId = d.id " +
                                        "WHERE a.patientId = ? AND a.status IN ('Pending', 'Approved') AND a.appointmentDate >= CURDATE() " +
                                        "ORDER BY a.appointmentDate ASC, a.appointmentTime ASC";
                    
                    pendingPs = pendingConn.prepareStatement(pendingSql);
                    pendingPs.setInt(1, patientId);
                    pendingRs = pendingPs.executeQuery();

                    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMMM yyyy");
                    SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm a");

                    while (pendingRs.next()) {
                        hasPending = true;
            %>
                        <tr>
                            <td>Dr. <%= pendingRs.getString("doctorName") %></td>
                            <td><%= pendingRs.getString("specialization") %></td>
                            <td><%= dateFormat.format(pendingRs.getDate("appointmentDate")) %></td>
                            <td><%= timeFormat.format(pendingRs.getTime("appointmentTime")) %></td>
                            <td><span class="status status-<%= pendingRs.getString("status").toLowerCase() %>"><%= pendingRs.getString("status") %></span></td>
                            </tr>
            <%
                    }
                    if (!hasPending) {
            %>
                        <tr><td colspan="5" style="text-align:center; padding: 20px;">You have no pending appointments.</td></tr>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
            %>
                    <tr><td colspan="5" style="text-align:center; color:red; padding: 20px;">Error loading pending appointments. Check server logs for details.</td></tr>
            <%
                } finally {
                    if (pendingRs != null) try { pendingRs.close(); } catch (SQLException e) {}
                    if (pendingPs != null) try { pendingPs.close(); } catch (SQLException e) {}
                    if (pendingConn != null) try { pendingConn.close(); } catch (SQLException e) {}
                }
            %>
            </tbody>
        </table>
    </div>

    <div class="appointments-container" style="margin-top: 30px;">
        <h2>Appointment History</h2>
        <table class="appointments-table">
            <thead>
                <tr>
                    <th>Doctor</th>
                    <th>Specialization</th>
                    <th>Date</th>
                    <th>Status</th>
                    <th>Booked On</th>
                </tr>
            </thead>
            <tbody>
            <%
                Connection historyConn = null;
                PreparedStatement historyPs = null;
                ResultSet historyRs = null;
                boolean hasHistory = false;

                try {
                    Class.forName("com.mysql.jdbc.Driver");
                    historyConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");

                    String historySql = "SELECT d.fullname AS doctorName, d.specialization, a.appointmentDate, a.status, a.created_at " +
                                        "FROM appointments a JOIN doctors d ON a.doctorId = d.id " +
                                        "WHERE a.patientId = ? AND (a.status = 'Cancelled' OR a.appointmentDate < CURDATE()) " +
                                        "ORDER BY a.appointmentDate DESC, a.appointmentTime DESC";
                    
                    historyPs = historyConn.prepareStatement(historySql);
                    historyPs.setInt(1, patientId);
                    historyRs = historyPs.executeQuery();

                    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMMM yyyy");

                    while (historyRs.next()) {
                        hasHistory = true;
            %>
                        <tr>
                            <td>Dr. <%= historyRs.getString("doctorName") %></td>
                            <td><%= historyRs.getString("specialization") %></td>
                            <td><%= dateFormat.format(historyRs.getDate("appointmentDate")) %></td>
                            <td><span class="status status-<%= historyRs.getString("status").toLowerCase() %>"><%= historyRs.getString("status") %></span></td>
                            <td><%= new SimpleDateFormat("dd-MM-yyyy").format(historyRs.getTimestamp("created_at")) %></td>
                        </tr>
            <%
                    }
                    if (!hasHistory) {
            %>
                        <tr><td colspan="5" style="text-align:center; padding: 20px;">You have no appointment history.</td></tr>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace(); 
            %>
                    <tr><td colspan="5" style="text-align:center; color:red; padding: 20px;">Error loading appointment history. Check server logs for details.</td></tr>
            <%
                } finally {
                    if (historyRs != null) try { historyRs.close(); } catch (SQLException e) {}
                    if (historyPs != null) try { historyPs.close(); } catch (SQLException e) {}
                    if (historyConn != null) try { historyConn.close(); } catch (SQLException e) {}
                }
            %>
            </tbody>
        </table>
    </div>
</div>

<footer>
    &copy; <%= new SimpleDateFormat("yyyy").format(new Date()) %> Health Portal. All rights reserved. | <a href="#">Privacy Policy</a> | <a href="#">Contact Us</a>
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