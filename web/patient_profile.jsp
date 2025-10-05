<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>Patient Profile</title>
    <style>
        /* Reset box-sizing */
        * {
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #dce8f6, #f4f7f8);
            margin: 0;
            padding: 25px 15px;
            color: #2c3e50;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: flex-start;
        }
        .container {
            max-width: 1200px;
            width: 100%;
            background: #fff;
            padding: 30px 40px;
            border-radius: 18px;
            box-shadow: 0 14px 38px rgba(0,0,0,0.1);
            transition: box-shadow 0.25s ease;
        }
        .container:hover {
            box-shadow: 0 18px 46px rgba(0,0,0,0.15);
        }
        h1 {
            color: #0078d4;
            font-weight: 700;
            font-size: 2.2rem;
            border-bottom: 3px solid #0078d4;
            padding-bottom: 10px;
            margin-bottom: 28px;
            letter-spacing: 0.02em;
        }
        .profile {
            display: flex;
            flex-wrap: wrap;
            gap: 32px;
            align-items: center;
        }
        .profile-photo {
            font-size: 110px;
            width: 180px;
            height: 180px;
            background-color: #e1ecf9;
            color: #0b5ed7;
            border-radius: 24px;
            box-shadow: 0 6px 20px rgba(11, 94, 215, 0.28);
            display: flex;
            align-items: center;
            justify-content: center;
            user-select: none;
            flex-shrink: 0;
        }
        .profile-details {
            flex: 1 1 360px;
            min-width: 270px;
        }
        .profile-details h2 {
            font-weight: 700;
            font-size: 1.65rem;
            margin: 0 0 10px;
            color: #0b3d91;
        }
        .profile-details p {
            margin: 6px 0;
            font-size: 1rem;
            line-height: 1.4;
            color: #495057;
        }
        .profile-details p strong {
            color: #0b5ed7;
            font-weight: 600;
        }
        .info-section {
            margin-top: 42px;
        }
        .info-section h3 {
            font-size: 1.5rem;
            font-weight: 700;
            color: #0b5ed7;
            border-bottom: 2.5px solid #0b5ed7;
            padding-bottom: 6px;
            margin-bottom: 22px;
        }
        .info-list {
            list-style: none;
            padding: 0;
            margin: 0;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 18px;
        }
        .info-list li {
            background: #e9f1fe;
            padding: 18px 24px;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 600;
            color: #234e9b;
            box-shadow: inset 0 0 11px #b3d0fe;
            transition: background-color 0.3s ease;
            cursor: default;
            user-select: none;
        }
        .info-list li:hover {
            background-color: #c8dbfc;
        }
        @media (max-width: 720px) {
            .profile {
                flex-direction: column;
                align-items: center;
            }
            .profile-details {
                text-align: center;
            }
        }
    </style>
</head>
<body>
<div class="container" role="main" aria-label="Patient Profile Card">
    <h1>Patient Profile</h1>
    <section class="profile" aria-labelledby="patient-name">
        <div class="profile-photo" aria-label="Patient icon" role="img" title="Patient Icon">
            🙎‍♂️
        </div>
        <div class="profile-details">
            <h2 id="patient-name">John Doe</h2>
            <p><strong>Age:</strong> 45</p>
            <p><strong>Gender:</strong> Male</p>
            <p><strong>Contact:</strong> (123) 456-7890</p>
            <p><strong>Email:</strong> johndoe@example.com</p>
            <p><strong>Address:</strong> 123 Main St, Springfield, USA</p>
        </div>
    </section>

    <section class="info-section" aria-labelledby="medical-info">
        <h3 id="medical-info">Medical Information</h3>
        <ul class="info-list">
            <li><strong>Blood Type:</strong> O+</li>
            <li><strong>Allergies:</strong> Penicillin, Peanuts</li>
            <li><strong>Medications:</strong> Lisinopril, Metformin</li>
            <li><strong>Chronic Conditions:</strong> Hypertension, Type 2 Diabetes</li>
            <li><strong>Last Visit:</strong> 2025-09-15</li>
            <li><strong>Primary Physician:</strong> Dr. Smith</li>
        </ul>
    </section>
</div>
</body>
</html>
