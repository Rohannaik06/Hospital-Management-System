<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Dashboard</title>
    <style>
        /* Reset and Base Styles */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f6f9;
            color: #333;
        }

        /* Header */
        .main-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #0a4275;
            color: white;
            padding: 12px 24px;
            position: sticky;
            top: 0;
            z-index: 1000;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .left-section {
            display: flex;
            align-items: center;
        }

        #menuToggle {
            font-size: 24px;
            background: none;
            border: none;
            color: white;
            margin-right: 15px;
            cursor: pointer;
        }

        .logo-text {
            font-size: 22px;
            font-weight: 600;
        }

        .center-section {
            flex-grow: 1;
            display: flex;
            justify-content: center;
        }

        .search-box {
            padding: 7px 10px;
            width: 280px;
            border-radius: 4px;
            border: 1px solid #ccc;
            outline: none;
        }

        .search-btn {
            padding: 7px 15px;
            margin-left: 8px;
            background: #01b6f5;
            border: none;
            border-radius: 4px;
            color: white;
            font-weight: 500;
            cursor: pointer;
        }

        .right-section {
            position: relative;
        }

        .profile-dropdown {
            display: flex;
            align-items: center;
            cursor: pointer;
        }

        .profile-img {
            width: 34px;
            height: 34px;
            border-radius: 50%;
            margin-right: 8px;
            object-fit: cover;
            border: 2px solid #fff;
        }

        .profile-name {
            font-weight: 500;
        }

        .dropdown-menu {
            display: none;
            position: absolute;
            right: 0;
            top: 48px;
            background: white;
            border: 1px solid #ccc;
            border-radius: 5px;
            min-width: 170px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }

        .dropdown-menu a {
            display: block;
            padding: 12px 16px;
            color: #333;
            text-decoration: none;
            font-size: 15px;
        }

        .dropdown-menu a:hover {
            background-color: #f5f5f5;
        }

        /* Sidebar */
        .sidebar {
            width: 240px;
            background: #1f2b3e;
            position: fixed;
            top: 60px;
            left: -260px;
            height: 100%;
            transition: 0.3s ease;
            z-index: 999;
            padding-top: 20px;
        }

        .sidebar.active {
            left: 0;
        }

        .sidebar a {
            display: block;
            padding: 15px 20px;
            color: #fff;
            font-size: 16px;
            text-decoration: none;
        }

        .sidebar a:hover {
            background: #374b68;
        }

        /* Main Content */
        .dashboard-content {
            margin-left: 0;
            padding: 30px 40px;
            transition: margin-left 0.3s ease;
            min-height: calc(100vh - 60px - 60px); /* header + footer height */
        }

        .sidebar.active ~ .dashboard-content {
            margin-left: 240px;
        }

        /* Footer */
        footer {
            background: #023e8a;
            color: white;
            text-align: center;
            padding: 15px 10px;
            font-size: 0.9rem;
        }

        footer a {
            color: #90e0ef;
            text-decoration: none;
        }

        footer a:hover {
            text-decoration: underline;
        }

        /* Responsive */
        @media screen and (max-width: 768px) {
            .center-section {
                display: none;
            }

            .dashboard-content {
                padding: 20px;
            }
        }
    </style>
</head>
<body>

    <!-- Header -->
    <header class="main-header">
        <div class="left-section">
            <button id="menuToggle">&#9776;</button>
            <div class="logo-text">Health Portal System</div>
        </div>

        <div class="center-section">
            <input type="text" class="search-box" placeholder="Search hospitals...">
            <button class="search-btn">Search</button>
        </div>

        <div class="right-section">
            <div class="profile-dropdown" onclick="toggleDropdown()">
                <img src="profile.png" alt="Profile" class="profile-img">
                <span class="profile-name">John Doe</span>
                <div class="dropdown-menu" id="dropdownMenu">
                    <a href="#">My Profile</a>
                    <a href="#">Edit Profile</a>
                    <a href="#">Appointments</a>
                    <a href="#">Logout</a>
                </div>
            </div>
        </div>
    </header>

    <!-- Sidebar -->
    <nav class="sidebar" id="sidebar">
        <a href="#">My Profile</a>
        <a href="#">Appointments</a>
        <a href="#">Saved</a>
        <a href="#">Settings</a>
        <a href="#">About Us</a>
        <a href="#">Contact</a>
        <a href="#">Logout</a>
    </nav>

    <!-- Main Dashboard Content -->
    <div class="dashboard-content">
        <h2>Welcome back, John!</h2>
        <p>Here is your dashboard where you can manage appointments, profile, and more.</p>
        <!-- Add dashboard cards or data panels here -->
    </div>

    <!-- Footer -->
    <footer>
        &copy; 2025 Health Portal. All rights reserved. | 
        <a href="/privacy-policy.html">Privacy Policy</a> | 
        <a href="/contact.html">Contact Us</a>
    </footer>

    <!-- Script -->
    <script>
        // Sidebar toggle
        document.getElementById("menuToggle").addEventListener("click", function () {
            document.getElementById("sidebar").classList.toggle("active");
        });

        // Profile dropdown
        function toggleDropdown() {
            const menu = document.getElementById("dropdownMenu");
            menu.style.display = (menu.style.display === "block") ? "none" : "block";
        }

        // Close dropdown when clicking outside
        window.onclick = function (event) {
            if (!event.target.closest('.profile-dropdown')) {
                document.getElementById("dropdownMenu").style.display = "none";
            }
        };
    </script>

</body>
</html>
