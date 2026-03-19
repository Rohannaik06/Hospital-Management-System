# Hospital Management System

A comprehensive, web-based Hospital Management System (HMS) designed to automate and streamline the core operations of healthcare facilities. This project replaces manual, paper-based workflows with an efficient digital solution, improving data accuracy, patient care, and overall operational efficiency.

The system provides distinct, secure portals for patients and doctors, enabling seamless management of registrations, medical records, appointments, and staff schedules.

## Key Features

This system is divided into two primary portals: one for Patients and one for Doctors.

### 👨‍⚕️ Doctor Portal
*   **Secure Login:** Doctors can authenticate securely using their credentials.
*   **Dashboard:** A central hub to view and manage all patient appointments for a selected date.
*   **Appointment Management:** Real-time ability to approve, hold (as pending), or cancel patient appointments.
*   **Patient Search:** Quickly find patients by name.
*   **Staff Management:** View a complete directory of hospital staff, add new staff members via a dedicated form, and remove staff records.
*   **Profile Management:** Doctors can view and update their professional profiles.

### ❤️ Patient Portal
*   **Secure Login & Registration:** Patients can easily create an account or log in to the system.
*   **Dashboard & Doctor Search:** A user-friendly dashboard to search for doctors by name, hospital, or specialization.
*   **Appointment Booking:** A simple form to book appointments with a chosen doctor, including a real-time view of already booked slots.
*   **Appointment History:** View a comprehensive list of upcoming and past appointments, with the option to cancel upcoming ones.
*   **Profile Management:** Patients can manage their personal information.

## Technology Stack
*   **Frontend:** JSP (JavaServer Pages), HTML, CSS, JavaScript
*   **Backend:** Java (Logic embedded in JSP files using scriptlets)
*   **Database:** MySQL
*   **Web Server:** Apache Tomcat
*   **Build Tool:** Apache Ant

## System Architecture

The application is built on a multi-tier architecture:

*   **Presentation Layer:** The user interface is rendered using JSP pages, styled with CSS, and made interactive with JavaScript. This is the layer that users directly interact with.
*   **Business Logic Layer:** The core application logic, including user authentication, data processing, and session management, is handled directly within the JSP files using Java scriptlets.
*   **Data Access Layer:** Database communication is performed using Java Database Connectivity (JDBC) from within the JSP files to execute SQL queries against the MySQL database.
*   **Database Layer:** A MySQL database stores all persistent data, including patient records, doctor profiles, staff details, and appointment information.

## Getting Started

Follow these instructions to get a local copy of the project up and running.

### Prerequisites
*   **JDK 8** or higher
*   **MySQL Server**
*   **Apache Tomcat 9** or a compatible version
*   An IDE like **NetBeans**, **IntelliJ IDEA**, or **Eclipse**

### Installation & Setup

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/rohannaik06/hospital-management-system.git
    ```

2.  **Database Setup:**
    *   Open your MySQL client (e.g., MySQL Workbench, phpMyAdmin).
    *   Create a new database named `HMS`:
        ```sql
        CREATE DATABASE HMS;
        ```
    *   Create the required tables. You can use the SQL queries from the registration and data display forms in the JSP files as a reference. Key tables include `doctors`, `patients`, `appointments`, and `staff`.

3.  **Configure the Project:**
    *   Open the project in your IDE.
    *   Locate the database connection strings, which are hardcoded in several JSP files (e.g., `doctorlogin.jsp`, `register.jsp`, `appointment.jsp`).
    *   Update the database URL, username, and password to match your MySQL setup. The default credentials in the project are `user: "root"` and `password: "root"`.

    **Example Connection String in JSP files:**
    ```java
    // Find and update this line in the relevant JSP files
    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/HMS", "your_username", "your_password");
    ```

4.  **Add JDBC Driver:**
    *   Ensure the **MySQL Connector/J** JAR file is included in your project's build path or library folder (`WEB-INF/lib`). The project is configured to use `mysql-connector-java-5.1.49-bin.jar`.

5.  **Deploy to Tomcat:**
    *   Configure your IDE to use your installed Apache Tomcat server.
    *   Build the project, which will generate a `.war` file (e.g., `HMS1.war`).
    *   Deploy the generated `.war` file to your Tomcat server.

6.  **Access the Application:**
    *   Start your Tomcat server.
    *   Open your web browser and navigate to the application's entry point, typically `index.html`.
        ```
        http://localhost:8080/HMS1/
        ```
        *Note: The context path `/HMS1` is defined in `web/META-INF/context.xml`.*
