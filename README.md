# School Management System v2

PHP + MySQL responsive school administration system.

## Modules
- Dashboard
- Students
- Teachers & staff
- Classes and subjects
- Attendance
- Fees & payments
- Exams & results
- Parent/student-ready role structure
- Reports-ready database structure
- Responsive mobile interface

## Installation
Requirements: PHP 8.1+, MySQL 8+, Apache/Nginx.

1. Create/import the database using `database/schema.sql`.
2. Update `config/database.php`.
3. Serve the `public` directory.
4. Sign in with the demo account:
   - Username: admin
   - Password: admin123

Change the demo password before deployment.

## Recommended production additions
Configure HTTPS, backups, CSRF protection, audit logging, password reset, granular permissions, receipt/report PDF generation, SMS integration, and payment-provider integration before using the system in a real school.
