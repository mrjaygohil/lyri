-- SUPABASE DATABASE SCHEMA AND RLS POLICIES FOR LYRICS ADMIN APP

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. Create Profiles Table
create table public.profiles (
    id uuid references auth.users on delete cascade primary key,
    full_name text,
    email text,
    role text not null default 'user' check (role in ('admin', 'user')),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for profiles
alter table public.profiles enable row level security;

-- 2. Create Categories Table
create table public.categories (
    id uuid default gen_random_uuid() primary key,
    name text not null,
    image text,
    status boolean default true not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for categories
alter table public.categories enable row level security;

-- 3. Create Tags Table
create table public.tags (
    id uuid default gen_random_uuid() primary key,
    name text not null unique,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for tags
alter table public.tags enable row level security;

-- 4. Create Songs Table
create table public.songs (
    id uuid default gen_random_uuid() primary key,
    title text not null,
    lyrics text not null,
    singer_name text,
    album_name text,
    language text,
    category_id uuid references public.categories(id) on delete set null,
    thumbnail text,
    status boolean default true not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for songs
alter table public.songs enable row level security;

-- 5. Create Song Tags Junction Table
create table public.song_tags (
    id uuid default gen_random_uuid() primary key,
    song_id uuid references public.songs(id) on delete cascade not null,
    tag_id uuid references public.tags(id) on delete cascade not null,
    unique(song_id, tag_id)
);

-- Enable RLS for song_tags
alter table public.song_tags enable row level security;


-- =========================================================================
-- TRIGGER: Automatically create a Profile when a User signs up
-- =========================================================================

create or replace function public.handle_new_user()
returns trigger as $$
declare
  assigned_role text;
begin
  -- Safely extract and check role from metadata
  assigned_role := coalesce(new.raw_user_meta_data->>'role', 'user');
  if assigned_role not in ('admin', 'user') then
    assigned_role := 'user';
  end if;

  insert into public.profiles (id, full_name, email, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', 'New User'),
    new.email,
    assigned_role
  );
  return new;
end;
$$ language plpgsql security definer;

-- Create trigger
create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- =========================================================================
-- HELPER FUNCTION: Check if the current user is an Admin
-- =========================================================================

create or replace function public.is_admin()
returns boolean as $$
begin
  return exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'admin'
  );
end;
$$ language plpgsql security definer;


-- =========================================================================
-- RLS POLICIES
-- =========================================================================

-- Profiles Policies
create policy "Allow public read access to profiles" on public.profiles
    for select using (true);

create policy "Allow individual user to update their own profile" on public.profiles
    for update using (auth.uid() = id);

create policy "Allow admin to update any profile" on public.profiles
    for update using (public.is_admin());

create policy "Allow admin to delete any profile" on public.profiles
    for delete using (public.is_admin());


-- Categories Policies
create policy "Allow public read access to active categories" on public.categories
    for select using (true); -- Can restrict to `status = true` if public app shouldn't see disabled categories

create policy "Allow admin full access on categories" on public.categories
    for all using (public.is_admin());


-- Tags Policies
create policy "Allow public read access to tags" on public.tags
    for select using (true);

create policy "Allow admin full access on tags" on public.tags
    for all using (public.is_admin());


-- Songs Policies
create policy "Allow public read access to active songs" on public.songs
    for select using (true); -- Can restrict to `status = true` for public client

create policy "Allow admin full access on songs" on public.songs
    for all using (public.is_admin());


-- Song Tags Policies
create policy "Allow public read access to song_tags" on public.song_tags
    for select using (true);

create policy "Allow admin full access on song_tags" on public.song_tags
    for all using (public.is_admin());


-- =========================================================================
-- STORAGE BUCKETS SETUP
-- =========================================================================
-- Run these commands manually or insert rows into storage.buckets if needed.
-- Note: In Supabase, you can create the 'song-thumbnails' bucket via the Dashboard UI.
-- Ensure the bucket is set to 'Public'.
-- RLS policies for storage objects bucket 'song-thumbnails':
-- 
-- 1. Policy: Allow public read access to song-thumbnails
--    (bucket_id = 'song-thumbnails')
-- 2. Policy: Allow admins to insert/update/delete objects in song-thumbnails
--    (bucket_id = 'song-thumbnails' and public.is_admin())


-- =========================================================================
-- TROUBLESHOOTING & CLEANUP: "Database error querying schema" (500)
-- =========================================================================
-- If you inserted an admin user manually via SQL, you may have gotten a 500 error on sign-in
-- ("Database error querying schema"). This is because:
-- 1. Certain GoTrue columns (like recovery_token) cannot be NULL; they must be empty strings.
-- 2. A matching identity was not created in the `auth.identities` table.
--
-- Choose either Option A (Recommended) or Option B to resolve this:
--
-- -------------------------------------------------------------------------
-- OPTION A: Clean up & Create via Dashboard (Recommended & Safest)
-- -------------------------------------------------------------------------
-- 1. Run this query in the SQL Editor to delete the malformed user record:
--    delete from auth.users where email = 'admin@lyri.com';
--
-- 2. Go to the Supabase Dashboard -> Auth -> Users -> Add User -> Create User.
--    Create a user with 'admin@lyri.com' and your password.
--
-- 3. Run this query in the SQL Editor to promote the user's profile to admin:
--    update public.profiles set role = 'admin' where email = 'admin@lyri.com';
--
-- -------------------------------------------------------------------------
-- OPTION B: Clean up & Create fully via SQL
-- -------------------------------------------------------------------------
-- Run the following script in your SQL Editor to delete any existing user with this email
-- and correctly insert them into all required auth tables (with correct defaults and matching identities):
--
-- do $$
-- declare
--   new_user_id uuid := gen_random_uuid();
--   admin_email text := 'admin@lyri.com';          -- <--- Change Email here if needed
--   admin_password text := 'AdminPassword123!';    -- <--- Change Password here if needed
--   admin_password_hash text;
-- begin
--   -- 1. Ensure the pgcrypto extension is active
--   create extension if not exists pgcrypto;
--
--   -- 2. Hash the password using bcrypt (matching Supabase default)
--   admin_password_hash := crypt(admin_password, gen_salt('bf', 10));
--
--   -- 3. Clean up existing email if present
--   delete from auth.users where email = admin_email;
--
--   -- 4. Insert user into auth.users (populating all required token/change fields with empty strings)
--   insert into auth.users (
--     instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
--     raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
--     confirmation_token, email_change, email_change_token_new, email_change_confirm_status,
--     recovery_token, email_change_token_current, phone, phone_confirmed_at, phone_change,
--     phone_change_token_new, phone_change_confirm_status, banned_until,
--     reauthentication_token, reauthentication_sent_at, is_super_admin, is_sso_user
--   ) values (
--     '00000000-0000-0000-0000-000000000000', new_user_id, 'authenticated', 'authenticated', admin_email,
--     admin_password_hash, now(), '{"provider":"email","providers":["email"]}',
--     '{"full_name":"Admin User","role":"admin"}', now(), now(),
--     '', '', '', 0, '', '', null, null, '', '', 0, null, '', null, false, false
--   );
--
--   -- 5. Insert matching identity into auth.identities (required to prevent scan/login errors)
--   insert into auth.identities (
--     id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at
--   ) values (
--     new_user_id::text, new_user_id, jsonb_build_object('sub', new_user_id::text, 'email', admin_email),
--     'email', now(), now(), now()
--   );
--
--   -- 6. Ensure the profile is created and updated to admin
--   insert into public.profiles (id, full_name, email, role)
--   values (new_user_id, 'Admin User', admin_email, 'admin')
--   on conflict (id) do update set role = 'admin', full_name = 'Admin User', email = admin_email;
-- end $$;

