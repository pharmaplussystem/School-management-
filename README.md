# EduNova School Management System

A responsive, GitHub-ready school management system front-end with a polished original dashboard design.

## Assets
- `assets/edunova-logo.svg` — school system logo
- `assets/school-building.svg` — dashboard illustration
- `assets/dashboard-pattern.svg` — subtle background graphic

## Included
- Responsive dashboard
- Students
- Staff
- Classes & subjects
- Attendance
- Fees & finance
- Reports
- School settings
- Supabase/PostgreSQL foundation
- Correct enum creation using a PostgreSQL `DO $$` block

## Run
Open `index.html` in a browser.

## Supabase
1. Create a Supabase project.
2. Open SQL Editor.
3. Run `supabase/schema.sql`.
4. The current HTML is a front-end preview/demo; connect the UI to Supabase Auth and tables when ready.

## Important
The SQL intentionally does not use `CREATE TYPE IF NOT EXISTS`, which caused the PostgreSQL syntax error in the earlier version.
