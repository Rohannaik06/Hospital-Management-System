<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Delete Staff Status</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background-color: #f8f9fa; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .container { text-align: center; padding: 40px; background-color: #fff; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); max-width: 700px; border-top: 5px solid #d9534f; }
        h1 { color: #d9534f; margin-bottom: 15px; }
        p { font-size: 1.1em; color: #333; }
        .error-details { text-align: left; background-color: #f9f2f4; color: #c7254e; border: 1px solid #e4b9c0; padding: 15px; border-radius: 5px; margin-top: 20px; font-family: 'Courier New', monospace; white-space: pre-wrap; word-wrap: break-word; }
        a { display: inline-block; margin-top: 25px; padding: 10px 20px; background-color: #007bff; color: white; text-decoration: none; border-radius: 5px; transition: background-color 0.2s; }
        a:hover { background-color: #0056b3; }
    </style>
</head>
<body>
<%
    // 1. Get the staff ID from the URL.
    String staffIdStr = request.getParameter("id");
    Connection conn = null;
    PreparedStatement ps = null;

    // 2. Validate that the ID was actually passed.
    if (staffIdStr == null || staffIdStr.trim().isEmpty()) {
%>
    <div class="container">
        <h1>Deletion Failed</h1>
        <p>The server did not receive a staff ID to delete.</p>
        <div class="error-details"><strong>Reason:</strong> The URL parameter 'id' was missing.</div>
        <a href="staff.jsp">Return to Staff Directory</a>
    </div>
<%
        return; // Stop the script.
    }

    try {
        // 3. Connect to the database using the modern driver.
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS?useSSL=false&serverTimezone=UTC", "root", "root");
        
        // 4. Prepare a secure DELETE statement.
        String sql = "DELETE FROM staff WHERE staff_id = ?";
        ps = conn.prepareStatement(sql);
        
        int staffId = Integer.parseInt(staffIdStr);
        ps.setInt(1, staffId);
        
        // 5. Execute the deletion.
        int rowsAffected = ps.executeUpdate();
        
        // 6. Check if the deletion was successful.
        if (rowsAffected > 0) {
            // SUCCESS! Redirect back to the staff list.
            response.sendRedirect("staff.jsp");
        } else {
            // The query ran, but no rows were deleted (ID not found).
%>
    <div class="container">
        <h1>Deletion Failed</h1>
        <p>No staff member was found with the specified ID.</p>
        <div class="error-details"><strong>Reason:</strong> A staff member with ID <strong><%= staffId %></strong> does not exist in the database. It may have already been deleted.</div>
        <a href="staff.jsp">Return to Staff Directory</a>
    </div>
<%
        }
        
    } catch (Exception e) {
        // 7. CATCH THE ERROR AND DISPLAY IT ON SCREEN!
        // This is the most important part for debugging.
%>
    <div class="container">
        <h1>Database Error Occurred</h1>
        <p>The staff member could not be deleted due to a server or database error.</p>
        <div class="error-details">
            <strong>Error Type:</strong> <%= e.getClass().getName() %>
            <br><br>
            <strong>Message:</strong> <%= e.getMessage() %>
        </div>
        <a href="staff.jsp">Return to Staff Directory</a>
    </div>
<%
        e.printStackTrace(); // Also prints the full error to your server console (e.g., Tomcat logs).
    } finally {
        // 8. Always close database resources.
        if (ps != null) try { ps.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
</body>
</html>