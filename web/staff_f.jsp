<%@ page import="java.sql.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add Staff Member</title>
    <style>
        /* Base styles from original for consistency */
        * {margin:0; padding:0; box-sizing:border-box;}
        body {font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background:#f4f6f9; color:#333; line-height:1.6;}
        .main-header {display:flex; justify-content:space-between; align-items:center; background:#0a4275; color:white; padding:12px 24px; position:sticky; top:0; z-index:1000; box-shadow:0 2px 4px rgba(0,0,0,0.1);}
        .left-section {display:flex; align-items:center;}
        #menuToggle {font-size:24px; background:none; border:none; color:white; margin-right:15px; cursor:pointer; padding:5px;}
        .logo-text {font-size:22px; font-weight:600;}
        .right-section {position:relative; display:flex; align-items:center;}
        .profile-dropdown {cursor:pointer; display:flex; align-items:center; gap:10px;}
        .profile-photo {width:42px; height:42px; background:white; border-radius:50%; display:flex; justify-content:center; align-items:center; box-shadow:0 0 6px rgba(0,0,0,0.1); user-select:none; font-size:24px; color:#0077b6;}
        .profile-name {font-weight:600; font-size:1.1rem; user-select:none;}
        .dropdown-menu {display:none; position:absolute; right:0; top:48px; background:white; border:1px solid #ddd; border-radius:6px; min-width:170px; box-shadow:0 6px 12px rgba(0,0,0,0.15); z-index:1001; overflow:hidden;}
        .dropdown-menu a {display:block; padding:12px 16px; color:#333; text-decoration:none; font-size:15px; transition:background-color 0.2s;}
        .dropdown-menu a:hover {background-color:#e9ecef;}
        .sidebar {width:240px; background:#1f2b3e; position:fixed; top:66px; left:-240px; height:100%; transition:left 0.3s ease; z-index:999; padding-top:20px; box-shadow:2px 0 5px rgba(0,0,0,0.1);}
        .sidebar.active {left:0;}
        .sidebar a {display:block; padding:15px 20px; color:#fff; font-size:16px; text-decoration:none; transition:background-color 0.2s, padding-left 0.2s;}
        .sidebar a:hover {background:#374b68; padding-left:25px;}
        .sidebar a.logout-link, .dropdown-menu a.logout-link {color:#ff6b6b; font-weight:600;}
        .sidebar a.logout-link:hover, .dropdown-menu a.logout-link:hover {background-color:#e63946; color:white;}
        .dashboard-content {margin-left:0; padding:30px 40px; transition:margin-left 0.3s ease; min-height:calc(100vh - 120px);}
        .sidebar.active ~ .dashboard-content {margin-left:240px;}
        footer {background:#023e8a; color:white; text-align:center; padding:15px 10px; font-size:0.9rem; position:fixed; width:100%; bottom:0; left:0; box-shadow:0 -2px 4px rgba(0,0,0,0.05);}
        footer a {color:#90e0ef; text-decoration:none;}
        footer a:hover {text-decoration:underline;}
        
        /* MODERN FORM STYLES */
        .card-box {
            max-width: 900px;
            background: #fff;
            border-radius: 12px;
            padding: 30px;
            margin: 30px auto;
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
        }
        .card-box h2 {
            font-size: 24px;
            margin-bottom: 25px;
            color: #0a4275;
            border-bottom: 2px solid #e0e0e0;
            padding-bottom: 10px;
        }
        .staff-form {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px 30px;
        }
        .form-group {
            margin-bottom: 0;
        }
        .form-label {
            font-weight: 600;
            margin-bottom: 8px;
            display: block;
            color: #555;
            font-size: 15px;
        }
        .form-input, .form-select {
            width: 100%;
            padding: 12px 15px;
            font-size: 16px;
            border-radius: 8px;
            border: 1px solid #ced4da;
            transition: border-color 0.2s, box-shadow 0.2s;
            background-color: #f8f9fa;
            appearance: none;
            /* Re-add select arrow for consistency */
            background-image: url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23000000%22%20d%3D%22M287%20177.3L154.7%2045.1c-6.8-6.8-17.7-6.8-24.5%200L5.4%20177.3c-6.8%206.8-6.8%2017.7%200%2024.5l12.2%2012.2c6.8%206.8%2017.7%206.8%2024.5%200L142.2%20110.2l99.9%2099.9c6.8%206.8%2017.7%206.8%2024.5%200l12.2-12.2c6.8-6.8%206.8-17.7%200-24.5z%22%2F%3E%3C%2Fsvg%3E');
            background-repeat: no-repeat;
            background-position: right 15px center;
            background-size: 12px;
            padding-right: 40px;
        }
        .form-input:focus, .form-select:focus {
            border-color: #0a4275;
            box-shadow: 0 0 0 0.25rem rgba(10, 66, 117, 0.25);
            outline: none;
            background-color: #fff;
        }
        .form-row-full {
            grid-column: span 2;
        }
        .form-actions {
            margin-top: 10px;
            text-align: right;
        }
        .btn {
            background: #0a4275;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 50px;
            font-size: 17px;
            cursor: pointer;
            font-weight: 600;
            transition: background 0.3s, transform 0.1s;
        }
        .btn:hover {
            background: #023e8a;
            transform: translateY(-1px);
        }
        .success-message {
            color: #28a745;
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .error-message {
            color: #dc3545;
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        @media (max-width:960px) {
            .card-box {max-width: 95%;}
        }
        @media (max-width:700px) {
            .dashboard-content {padding:15px;}
            .card-box {padding:20px; margin-top:20px;}
            .staff-form {grid-template-columns:1fr; gap:15px;}
            .form-row-full {grid-column:span 1;}
            .form-actions {text-align: center;}
            .sidebar {top: 54px;}
        }
    </style>
</head>
<body>
<%
    String fullname = (String) session.getAttribute("fullname");
    if (fullname == null || fullname.isEmpty()) {
        response.sendRedirect("doctorlogin.jsp");
        return;
    }
    String hospitalName = "Unknown Hospital";
    Integer loggedInDoctorId = null; // Variable to store the logged-in doctor's ID
    
    // Database connection details
    final String DB_URL = "jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC";
    final String DB_USER = "root";
    final String DB_PASS = "root";
    final String DB_DRIVER = "com.mysql.jdbc.Driver";

    // --- LOGIC TO FETCH DOCTOR'S ID AND HOSPITAL NAME ---
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        Class.forName(DB_DRIVER);
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        
        // Fetch both ID and hospital name in one query
        ps = conn.prepareStatement("SELECT id, hospital_name FROM doctors WHERE LOWER(TRIM(fullname))=LOWER(TRIM(?))");
        ps.setString(1, fullname);
        rs = ps.executeQuery();
        if (rs.next()) {
            loggedInDoctorId = rs.getInt("id"); // Get the logged-in doctor's ID
            hospitalName = rs.getString("hospital_name");
        }
        // No need to close/re-open connections/statements here if you reuse them, 
        // but for safety/clarity, we'll follow the pattern of closing the used ones.
        rs.close(); 
        ps.close();
    } catch(Exception e) {
        hospitalName = "Hospital Management System";
        // Log error for debugging: System.out.println("Error fetching doctor ID/Hospital: " + e.getMessage());
    } finally {
        // Safe closing of resources
        try{ if(rs!=null)rs.close(); }catch(Exception e){}
        try{ if(ps!=null)ps.close(); }catch(Exception e){}
        try{ if(conn!=null)conn.close(); }catch(Exception e){}
    }
    // --- END LOGIC TO FETCH DOCTOR'S ID AND HOSPITAL NAME ---

    String successMsg = "";
    String errorMsg = "";

    // On form submission
    if("POST".equalsIgnoreCase(request.getMethod())) {
        String docIdParam = request.getParameter("doctor_id"); // The ID from the form (can be empty)
        String sname = request.getParameter("fullname");
        String role = request.getParameter("role");
        String spec = request.getParameter("specialization");
        String qual = request.getParameter("qualification");
        String exp = request.getParameter("experience");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String hire = request.getParameter("hire_date");
        String salary = request.getParameter("salary");

        // Determine the Doctor ID to insert: use the form parameter if provided, otherwise use the logged-in doctor's ID
        Integer insertDoctorId = loggedInDoctorId;
        if (docIdParam != null && !docIdParam.trim().isEmpty()) {
            try {
                // If a doctor ID is explicitly entered in the form, use that instead.
                insertDoctorId = Integer.parseInt(docIdParam.trim());
            } catch (NumberFormatException e) {
                errorMsg = "Error: Invalid format for Doctor ID. Please enter a number or leave blank.";
                // Skip the database insert if there's a format error
            }
        }
        
        // Only proceed with DB insert if no error message was set from the NumberFormatException
        if (errorMsg.isEmpty()) {
            conn = null;
            ps = null;
            try {
                Class.forName(DB_DRIVER);
                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                ps = conn.prepareStatement(
                    "INSERT INTO staff (doctor_id, fullname, role, specialization, qualification, experience, hospital_name, phone, email, hire_date, salary) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
                );
                
                // Set Doctor ID (now using insertDoctorId which defaults to loggedInDoctorId or null if loggedInDoctorId is null and form is empty)
                if(insertDoctorId != null)
                    ps.setInt(1, insertDoctorId.intValue());
                else
                    ps.setNull(1, java.sql.Types.INTEGER);
                    
                ps.setString(2, sname);
                ps.setString(3, role);
                ps.setString(4, spec);
                ps.setString(5, qual);
                
                // Set Experience (can be null)
                if(exp != null && !exp.trim().isEmpty())
                    ps.setInt(6, Integer.parseInt(exp));
                else
                    ps.setNull(6, java.sql.Types.INTEGER);
                    
                ps.setString(7, hospitalName); // Hospital Name from Doctor's profile
                ps.setString(8, phone);
                ps.setString(9, email);
                
                // Set Hire Date (can be null)
                if(hire != null && !hire.trim().isEmpty())
                    ps.setDate(10, java.sql.Date.valueOf(hire));
                else
                    ps.setNull(10, java.sql.Types.DATE);
                    
                // Set Salary (can be null)
                if(salary != null && !salary.trim().isEmpty())
                    ps.setBigDecimal(11, new java.math.BigDecimal(salary));
                else
                    ps.setNull(11, java.sql.Types.DECIMAL);

                int r = ps.executeUpdate();
                if(r>0) successMsg = "Staff member **" + sname + "** added successfully! Assigned Doctor ID: " + (insertDoctorId != null ? insertDoctorId : "NULL");
                else errorMsg = "Failed to add staff member. No rows affected.";
            } catch(SQLIntegrityConstraintViolationException ex) {
                // This catch block will fire if the doctor_id used in the INSERT doesn't exist.
                errorMsg = "Error: Invalid Doctor ID or data integrity violation. Please ensure the Doctor ID is correct. " + ex.getMessage();
            } catch(NumberFormatException ex) {
                // Catches error for exp/salary if they are invalid numbers
                errorMsg = "Error: Please check the format of Experience or Salary fields (must be valid numbers).";
            } catch(Exception ex) {
                errorMsg = "Database or system error: " + ex.getMessage();
            } finally {
                try{ if(ps!=null)ps.close(); }catch(Exception ex){}
                try{ if(conn!=null)conn.close(); }catch(Exception ex){}
            }
        }
    }
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
                <a href="staff.jsp">Staff List</a>
                <a href="doctorlogin.jsp" class="logout-link">Logout</a>
            </div>
        </div>
    </div>
</header>
<nav class="sidebar" id="sidebar">
    <a href="my_profile.jsp">My Profile</a>
    <a href="doctor_dashboard.jsp">Appointments</a>
    <a href="staff.jsp">Staff List</a>
    <a href="doctorlogin.jsp" class="logout-link">Logout</a>
</nav>
<div class="dashboard-content">
    <div class="card-box">
        <h2>New Staff Member Registration</h2>
        <%
        if(!successMsg.isEmpty()) {
        %>
            <div class="success-message">🎉 <%= successMsg %></div>
        <% } else if(!errorMsg.isEmpty()) { %>
            <div class="error-message">🛑 <%= errorMsg %></div>
        <% } %>
        <form class="staff-form" method="POST" autocomplete="off">
            
            <div class="form-group">
                <label class="form-label" for="fullname">Full Name<span style="color: red;"> *</span></label>
                <input type="text" id="fullname" name="fullname" class="form-input" placeholder="e.g., Jane Doe" required>
            </div>
            
            <div class="form-group">
                <label class="form-label" for="role">Role<span style="color: red;"> *</span></label>
                <select id="role" name="role" class="form-select" required>
                    <option value="">-- Select Role --</option>
                    <option value="Nurse">Nurse</option>
                    <option value="Physician Assistant">Physician Assistant</option>
                    <option value="Technician">Technician (Lab/Radiology)</option>
                    <option value="Administrator">Administrator (Front Office)</option>
                    <option value="Accountant">Accountant/Billing</option>
                    <option value="Support Staff">Support Staff (Housekeeping/Aide)</option>
                    <option value="Other">Other</option>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label" for="specialization">Specialization/Department</label>
                <input type="text" id="specialization" name="specialization" class="form-input" placeholder="e.g., ICU, Pediatric, HR">
            </div>
            <div class="form-group">
                <label class="form-label" for="qualification">Qualification</label>
                <input type="text" id="qualification" name="qualification" class="form-input" placeholder="e.g., BSN, MBA, MD">
            </div>
            <div class="form-group">
                <label class="form-label" for="experience">Experience (in Years)</label>
                <input type="number" id="experience" name="experience" class="form-input" min="0" step="1" pattern="\d*" placeholder="0">
            </div>
            <div class="form-group">
                <label class="form-label" for="doctor_id">Supervising Doctor ID (Default: <%= loggedInDoctorId != null ? loggedInDoctorId : "N/A" %>)</label>
                <input type="number" id="doctor_id" name="doctor_id" class="form-input" min="1" pattern="\d*" placeholder="<%= loggedInDoctorId != null ? loggedInDoctorId : "Optional" %>">
            </div>
            
            <div class="form-group">
                <label class="form-label" for="phone">Phone Number</label>
                <input type="tel" id="phone" name="phone" class="form-input" placeholder="+91 98765 43210">
            </div>
            <div class="form-group">
                <label class="form-label" for="email">Email Address</label>
                <input type="email" id="email" name="email" class="form-input" placeholder="staff.name@hospital.com">
            </div>
            <div class="form-group">
                <label class="form-label" for="hire_date">Hire Date</label>
                <input type="date" id="hire_date" name="hire_date" class="form-input">
            </div>
            <div class="form-group">
                <label class="form-label" for="salary">Annual Salary (INR)</label>
                <input type="number" id="salary" name="salary" class="form-input" step="0.01" min="0" placeholder="500000.00">
            </div>

            <div class="form-actions form-row-full">
                <button type="submit" class="btn">➕ Add Staff Member</button>
            </div>
        </form>
    </div>
</div>
<footer>
    &copy; 2025 Health Portal. All rights reserved. <a href="#">Privacy Policy</a>
</footer>
<script>
document.getElementById("menuToggle").addEventListener("click", function(){
    document.getElementById("sidebar").classList.toggle("active");
    // Optionally toggle margin on content
    const content = document.querySelector(".dashboard-content");
    if(document.getElementById("sidebar").classList.contains("active")) {
        content.style.marginLeft = "240px";
    } else {
        content.style.marginLeft = "0";
    }
});
function toggleDropdown(){
    const menu = document.getElementById("dropdownMenu");
    menu.style.display = (menu.style.display === "block") ? "none" : "block";
}
window.onclick = function(event) {
    if(!event.target.closest('.profile-dropdown') && !event.target.closest('.dropdown-menu')){
        document.getElementById("dropdownMenu").style.display = "none";
    }
};

// Ensure sidebar content shift on initial load if needed (optional)
document.addEventListener('DOMContentLoaded', () => {
    // This is mainly for smooth transition setup, doesn't need to do anything on load
});
</script>
</body>
</html>