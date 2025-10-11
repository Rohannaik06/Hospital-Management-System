<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Staff Directory</title>
    <style>
        /* Shared Styles for Layout, Header, and Footer */
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
        
        /* Staff-specific styles */
        .card-box {
            width: 95%; background:#fff; border-radius:10px; padding:20px 25px; margin: 0 auto 30px auto;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1); position: relative;
        }
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .card-header h2 { 
            font-size: 18px; 
            margin-bottom: 0;
            color:#222; 
        }
        .add-staff-button {
            display: flex; align-items: center; justify-content: center; width: 35px; height: 35px; background-color: #28a745;
            color: white; border-radius: 50%; text-decoration: none; font-size: 24px; font-weight: 700;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2); transition: background-color 0.2s;
        }
        .add-staff-button:hover { background-color: #218838; }
        table {
            width: 100%; border-collapse: collapse; margin-top: 20px; background: #fff;
            border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        table thead { background-color: #0a4275; color:white; }
        table th, table td { padding: 12px 16px; border-bottom: 1px solid #ddd; text-align:left; vertical-align: middle; }
        table tbody tr:hover { background-color: #f5f5f5; }

        /* Style for the delete button */
        .delete-btn {
            display: inline-block; padding: 6px 12px; font-size: 14px; font-weight: 500; color: white;
            background-color: #e63946; border: none; border-radius: 5px; text-decoration: none;
            cursor: pointer; transition: background-color 0.2s;
        }
        .delete-btn:hover { background-color: #c12a36; }
    </style>
</head>
<body>
<%
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    // NOTE: Assuming doctor's full name is stored in session to find their hospital
    String doctorFullname = (String) session.getAttribute("fullname");
    if (doctorFullname == null || doctorFullname.isEmpty()) {
        response.sendRedirect("doctorlogin.jsp");
        return;
    }
    String hospitalName = "Unknown Hospital";
    try {
        // Use the modern driver class name for MySQL 8+
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");
        
        // 1. Get the logged-in doctor's hospital name
        ps = conn.prepareStatement("SELECT hospital_name FROM doctors WHERE LOWER(TRIM(fullname)) = LOWER(TRIM(?))");
        ps.setString(1, doctorFullname);
        rs = ps.executeQuery();
        if (rs.next()) {
            hospitalName = rs.getString("hospital_name");
        }
        rs.close(); ps.close();
        
        // 2. Get all staff for that specific hospital
        // Corrected SQL to match your new schema
        String staffSql = "SELECT staff_id, fullname, role, specialization, qualification, experience, phone, email, hire_date, salary " +
                          "FROM staff WHERE hospital_name=? ORDER BY staff_id ASC";
        
        ps = conn.prepareStatement(staffSql);
        ps.setString(1, hospitalName);
        rs = ps.executeQuery();
%>
<header class="main-header">
    <div class="left-section">
        <button id="menuToggle">☰</button>
        <div class="logo-text"><%= hospitalName %></div>
    </div>
    <div class="right-section">
        <div class="profile-dropdown" onclick="toggleDropdown()">
            <div class="profile-photo">👨‍⚕️</div>
            <div class="profile-name"><%= doctorFullname %></div>
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
        <div class="card-header">
            <h2>Staff Directory</h2>
            <a href="staff_f.jsp" class="add-staff-button" title="Add New Staff">+</a>
        </div>
        <table>
            <thead>
                <tr>
                    <th>S.No.</th>
                    <th>Name</th>
                    <th>Role</th>
                    <th>Specialization</th>
                    <th>Qualification</th>
                    <th>Experience</th>
                    <th>Phone</th>
                    <th>Email</th>
                    <th>Hire Date</th>
                    <th>Salary</th>
                    <th>Actions</th> </tr>
            </thead>
            <tbody>
            <%
                boolean hasStaff = false;
                int serialNo = 1; 
                while (rs.next()) {
                    hasStaff = true;
            %>
                <tr>
                    <td><%= serialNo++ %></td> 
                    <td><%= rs.getString("fullname") %></td>
                    <td><%= rs.getString("role") %></td>
                    <td><%= rs.getString("specialization") %></td>
                    <td><%= rs.getString("qualification") %></td>
                    <td><%= rs.getInt("experience") %> years</td>
                    <td><%= rs.getString("phone") %></td>
                    <td><%= rs.getString("email") %></td>
                    <td><%= rs.getDate("hire_date") %></td>
                    <td><%= rs.getBigDecimal("salary") %></td>
                    <td>
                        <a href="delete_staff.jsp?id=<%= rs.getInt("staff_id") %>" 
                           class="delete-btn" 
                           onclick="return confirm('Are you sure you want to delete this staff member? This action cannot be undone.');">Delete</a>
                    </td>
                </tr>
            <%
                }
                if(!hasStaff) {
            %>
                <tr>
                    <td colspan="11" style="text-align:center;">No staff records found for this hospital.</td>
                </tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>
</div>
<%
    } catch (Exception e) {
%>
    <div class="dashboard-content">
        <div class="card-box">
            <h2>Error Loading Staff</h2>
            <div style="color: red; white-space: pre-wrap;"><%= e.getMessage() %></div>
        </div>
    </div>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
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
</script>
</body>
</html>