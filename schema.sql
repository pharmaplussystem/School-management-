-- CORRECTED SCHOOL MANAGEMENT SYSTEM SQL
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname='app_role' AND typnamespace='public'::regnamespace) THEN
  CREATE TYPE public.app_role AS ENUM ('super_admin','administrator','headteacher','teacher','accountant','librarian','parent','student','staff');
 END IF;
END $$;

CREATE TABLE IF NOT EXISTS public.schools (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), name text NOT NULL, location text, phone text, email text,
 logo_url text, academic_year text DEFAULT '2026', current_term text DEFAULT 'Term 1',
 currency text DEFAULT 'UGX', created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.profiles (
 id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
 school_id uuid REFERENCES public.schools(id) ON DELETE SET NULL,
 full_name text, role public.app_role DEFAULT 'staff', phone text,
 active boolean NOT NULL DEFAULT true, created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.classes (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
 name text NOT NULL, stream text, academic_year text, active boolean DEFAULT true, created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.subjects (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
 name text NOT NULL, code text, active boolean DEFAULT true, created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.students (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
 admission_number text NOT NULL, first_name text NOT NULL, middle_name text, last_name text NOT NULL,
 date_of_birth date, gender text, photo_url text, class_id uuid REFERENCES public.classes(id) ON DELETE SET NULL,
 address text, previous_school text, emergency_contact text, active boolean DEFAULT true,
 created_at timestamptz DEFAULT now(), UNIQUE(school_id,admission_number)
);

CREATE TABLE IF NOT EXISTS public.parents (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
 full_name text NOT NULL, phone text, email text, address text, created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.student_parents (
 student_id uuid NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
 parent_id uuid NOT NULL REFERENCES public.parents(id) ON DELETE CASCADE,
 relationship text, primary_contact boolean DEFAULT false, PRIMARY KEY(student_id,parent_id)
);

CREATE TABLE IF NOT EXISTS public.staff (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), school_id uuid NOT NULL REFERENCES public.schools(id) ON DELETE CASCADE,
 profile_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL, staff_number text,
 full_name text NOT NULL, phone text, email text, position text, department text, created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_profiles_school ON public.profiles(school_id);
CREATE INDEX IF NOT EXISTS idx_students_school ON public.students(school_id);
CREATE INDEX IF NOT EXISTS idx_students_class ON public.students(class_id);
CREATE INDEX IF NOT EXISTS idx_classes_school ON public.classes(school_id);
CREATE INDEX IF NOT EXISTS idx_subjects_school ON public.subjects(school_id);

ALTER TABLE public.schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_parents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.staff ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "authenticated schools" ON public.schools;
CREATE POLICY "authenticated schools" ON public.schools FOR ALL TO authenticated USING(true) WITH CHECK(true);
DROP POLICY IF EXISTS "own profile read" ON public.profiles;
CREATE POLICY "own profile read" ON public.profiles FOR SELECT TO authenticated USING(id=auth.uid());
DROP POLICY IF EXISTS "own profile update" ON public.profiles;
CREATE POLICY "own profile update" ON public.profiles FOR UPDATE TO authenticated USING(id=auth.uid()) WITH CHECK(id=auth.uid());
DROP POLICY IF EXISTS "authenticated classes" ON public.classes;
CREATE POLICY "authenticated classes" ON public.classes FOR ALL TO authenticated USING(true) WITH CHECK(true);
DROP POLICY IF EXISTS "authenticated subjects" ON public.subjects;
CREATE POLICY "authenticated subjects" ON public.subjects FOR ALL TO authenticated USING(true) WITH CHECK(true);
DROP POLICY IF EXISTS "authenticated students" ON public.students;
CREATE POLICY "authenticated students" ON public.students FOR ALL TO authenticated USING(true) WITH CHECK(true);
DROP POLICY IF EXISTS "authenticated parents" ON public.parents;
CREATE POLICY "authenticated parents" ON public.parents FOR ALL TO authenticated USING(true) WITH CHECK(true);
DROP POLICY IF EXISTS "authenticated student parents" ON public.student_parents;
CREATE POLICY "authenticated student parents" ON public.student_parents FOR ALL TO authenticated USING(true) WITH CHECK(true);
DROP POLICY IF EXISTS "authenticated staff" ON public.staff;
CREATE POLICY "authenticated staff" ON public.staff FOR ALL TO authenticated USING(true) WITH CHECK(true);

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path=public AS $$
BEGIN
 INSERT INTO public.profiles(id,full_name,role)
 VALUES(NEW.id,COALESCE(NEW.raw_user_meta_data->>'full_name',split_part(COALESCE(NEW.email,''),'@',1)),'staff')
 ON CONFLICT(id) DO NOTHING;
 RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

SELECT 'School Management System database installed successfully.' AS status;
