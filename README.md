# Hospital Management System 🏥
> A digital solution to replace manual hospital record-keeping and streamline patient-doctor workflows.

![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Apache Tomcat](https://img.shields.io/badge/Apache%20Tomcat-F8DC75?style=for-the-badge&logo=apache-tomcat&logoColor=black)

---

## 📑 Table of Contents
* [Overview](#-overview)
* [Key Features](#-key-features)
* [System Architecture](#-how-it-works)
* [Project Preview](#-project-preview)
* [Getting Started](#-how-to-run-it-locally)

---

## 🚀 Overview
Managing a hospital with paper records is slow and prone to errors. This application digitizes the entire process. It provides a **Patient Portal** to book appointments and a **Doctor/Admin Portal** to manage daily schedules, staff, and medical records in real-time.

---

## 💡 Key Features
* **👩‍⚕️ For Doctors:** Manage daily appointments, approve/cancel requests, and update professional profiles.
* **👨‍ Patient Focus:** Search for doctors, book slots, and track appointment history easily.
* **🏢 Admin Control:** Manage staff directories, roles, and salary data from one central hub.
* **🔒 Secure Access:** Role-based logins ensure doctors and patients only see relevant data.

---

## 🏗 How it works
* **UI Layer:** HTML/JSP pages for a clean, user-friendly experience.
* **Logic Layer:** Java Servlets and Scriptlets process logins and bookings.
* **Database Layer:** JDBC connects the app to MySQL, ensuring all records are safely saved.

---

## 📸 Project Preview

### **Doctor & Admin Operations**
| Dashboard | Staff Directory | Appointments | Profile |
| :---: | :---: | :---: | :---: |
| ![Dashboard](Screenshots/doctor_a.png) | ![Staff](Screenshots/doctor_s.png) | ![Appointments](Screenshots/doctor_a.png) | ![Profile](Screenshots/doctor_p.png) |

### **Patient Experience**
| Home | Login | Register | Dashboard | My Appointments |
| :---: | :---: | :---: | :---: | :---: |
| ![Home](Screenshots/Home.png) | ![Login](Screenshots/Patient_l.png) | ![Register](Screenshots/Patient_r.png) | ![Dashboard](Screenshots/user_p.png) | ![Appointments](Screenshots/user_a.png) |

---

## 🚀 How to Run It Locally
1. **Clone:** `git clone https://github.com/rohannaik06/hospital-management-system.git`
2. **Database:** Create a database named `HMS` in MySQL and run the SQL schema.
3. **Configure:** Update your DB credentials in the JSP files.
4. **Deploy:** Import to your IDE and run on Apache Tomcat.
5. **Launch:** Access `http://localhost:8080/HMS1/`

---

## 👨‍💻 Developed By
**Rohan Naik** | [LinkedIn](https://www.linkedin.com/in/rohannaik06) | [Email](mailto:rohannaik1426@gmail.com)
*Built as an academic project for Java Web Technologies.*
