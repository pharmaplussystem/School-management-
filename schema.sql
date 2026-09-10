CREATE DATABASE IF NOT EXISTS school_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE school_management;

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','teacher','bursar','student','parent') NOT NULL DEFAULT 'admin',
  full_name VARCHAR(150) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE classes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  section VARCHAR(100),
  class_teacher VARCHAR(150),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE students (
  id INT AUTO_INCREMENT PRIMARY KEY,
  admission_no VARCHAR(50) UNIQUE NOT NULL,
  first_name VARCHAR(80) NOT NULL,
  last_name VARCHAR(80) NOT NULL,
  gender ENUM('Male','Female','Other') NOT NULL,
  date_of_birth DATE,
  guardian_name VARCHAR(150),
  guardian_phone VARCHAR(40),
  class_id INT,
  status ENUM('Active','Inactive') DEFAULT 'Active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE SET NULL
);

CREATE TABLE teachers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  employee_no VARCHAR(50) UNIQUE NOT NULL,
  full_name VARCHAR(150) NOT NULL,
  phone VARCHAR(40),
  email VARCHAR(150),
  subject VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE subjects (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  code VARCHAR(30) UNIQUE NOT NULL
);

CREATE TABLE attendance (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  attendance_date DATE NOT NULL,
  status ENUM('Present','Absent','Late','Excused') NOT NULL,
  UNIQUE(student_id, attendance_date),
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

CREATE TABLE payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  payment_date DATE NOT NULL,
  method ENUM('Cash','Mobile Money','Bank','Other') DEFAULT 'Cash',
  reference VARCHAR(100),
  description VARCHAR(255),
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

CREATE TABLE results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  subject_id INT NOT NULL,
  term VARCHAR(50) NOT NULL,
  score DECIMAL(5,2) NOT NULL,
  grade VARCHAR(5),
  remarks VARCHAR(255),
  FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
);

INSERT INTO classes (name, section, class_teacher) VALUES
('Senior 1','A','Demo Teacher'),
('Senior 2','A','Demo Teacher');

INSERT INTO subjects (name, code) VALUES
('Mathematics','MATH'),
('English','ENG'),
('Science','SCI'),
('ICT','ICT');

INSERT INTO users (username, password_hash, role, full_name)
VALUES ('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC3m6f9n8bV7aQ5mQe1K', 'admin', 'System Administrator');

CREATE TABLE IF NOT EXISTS school_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  school_name VARCHAR(200) NOT NULL DEFAULT 'My School',
  address VARCHAR(255),
  phone VARCHAR(50),
  email VARCHAR(150),
  academic_year VARCHAR(20),
  current_term VARCHAR(50),
  logo_path VARCHAR(255),
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO school_settings (school_name, address, phone, email, academic_year, current_term)
SELECT 'My School', '', '', '', YEAR(CURDATE()), 'Term 1'
WHERE NOT EXISTS (SELECT 1 FROM school_settings);
