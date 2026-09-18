-- EduNova School Management System
-- Supabase/PostgreSQL schema. This avoids "CREATE TYPE IF NOT EXISTS" because
-- PostgreSQL does not support that syntax for CREATE TYPE.

create extension if not exists pgcrypto;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'app_role') then
    create type public.app_role as enum (
      'super_admin','administrator','headteacher','teacher',
      'accountant','librarian','parent','student','staff'
    );
  end if;
end $$;

create table if not exists public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  location text,
  phone text,
  email text,
  logo_url text,
  currency text default 'UGX',
  academic_year text default '2026',
  created_at timestamptz default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  school_id uuid references public.schools(id) on delete set null,
  full_name text,
  role public.app_role default 'staff',
  phone text,
  avatar_url text,
  created_at timestamptz default now()
);

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  admission_no text not null,
  full_name text not null,
  gender text,
  date_of_birth date,
  class_name text,
  stream text,
  parent_name text,
  parent_phone text,
  status text default 'active',
  created_at timestamptz default now(),
  unique(school_id, admission_no)
);

create table if not exists public.staff (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  full_name text not null,
  role text not null,
  department text,
  phone text,
  email text,
  status text default 'active',
  created_at timestamptz default now()
);

create table if not exists public.classes (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  name text not null,
  stream text,
  class_teacher_id uuid references public.staff(id) on delete set null,
  created_at timestamptz default now()
);

create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  name text not null,
  code text,
  created_at timestamptz default now()
);

create table if not exists public.attendance (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  student_id uuid not null references public.students(id) on delete cascade,
  attendance_date date not null default current_date,
  status text not null check (status in ('present','absent','late','excused')),
  created_at timestamptz default now(),
  unique(student_id, attendance_date)
);

create table if not exists public.fee_payments (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references public.schools(id) on delete cascade,
  student_id uuid not null references public.students(id) on delete cascade,
  amount numeric(14,2) not null check (amount >= 0),
  payment_method text,
  reference text,
  payment_date date not null default current_date,
  notes text,
  created_at timestamptz default now()
);

create index if not exists students_school_idx on public.students(school_id);
create index if not exists staff_school_idx on public.staff(school_id);
create index if not exists attendance_school_date_idx on public.attendance(school_id, attendance_date);
create index if not exists fees_school_date_idx on public.fee_payments(school_id, payment_date);

alter table public.schools enable row level security;
alter table public.profiles enable row level security;
alter table public.students enable row level security;
alter table public.staff enable row level security;
alter table public.classes enable row level security;
alter table public.subjects enable row level security;
alter table public.attendance enable row level security;
alter table public.fee_payments enable row level security;

-- Development policies. Tighten these before production deployment.
do $$ begin
  create policy "authenticated schools access" on public.schools for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "authenticated profiles access" on public.profiles for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "authenticated students access" on public.students for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "authenticated staff access" on public.staff for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "authenticated classes access" on public.classes for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "authenticated subjects access" on public.subjects for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "authenticated attendance access" on public.attendance for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "authenticated fees access" on public.fee_payments for all to authenticated using (true) with check (true);
exception when duplicate_object then null; end $$;
