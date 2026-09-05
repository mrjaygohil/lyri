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

-- Create Raags Table
create table public.raags (
    id uuid default gen_random_uuid() primary key,
    name text not null unique,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS for raags
alter table public.raags enable row level security;

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

-- Create Song Raags Junction Table
create table public.song_raags (
    id uuid default gen_random_uuid() primary key,
    song_id uuid references public.songs(id) on delete cascade not null,
    raag_id uuid references public.raags(id) on delete cascade not null,
    unique(song_id, raag_id)
);

-- Enable RLS for song_raags
alter table public.song_raags enable row level security;


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

create policy "Allow authenticated users to insert tags" on public.tags
    for insert with check (auth.role() = 'authenticated');

create policy "Allow admin full access on tags" on public.tags
    for all using (public.is_admin());


-- Raags Policies
create policy "Allow public read access to raags" on public.raags
    for select using (true);

create policy "Allow authenticated users to insert raags" on public.raags
    for insert with check (auth.role() = 'authenticated');

create policy "Allow admin full access on raags" on public.raags
    for all using (public.is_admin());


-- Songs Policies
create policy "Allow public read access to active songs" on public.songs
    for select using (true); -- Can restrict to `status = true` for public client

create policy "Allow admin full access on songs" on public.songs
    for all using (public.is_admin());


-- Song Tags Policies
create policy "Allow public read access to song_tags" on public.song_tags
    for select using (true);

create policy "Allow users to manage song_tags for their own songs" on public.song_tags
    for all using (
        exists (
            select 1 from public.songs
            where id = song_tags.song_id and created_by = auth.uid()
        )
    );

create policy "Allow admin full access on song_tags" on public.song_tags
    for all using (public.is_admin());


-- Song Raags Policies
create policy "Allow public read access to song_raags" on public.song_raags
    for select using (true);

create policy "Allow users to manage song_raags for their own songs" on public.song_raags
    for all using (
        exists (
            select 1 from public.songs
            where id = song_raags.song_id and created_by = auth.uid()
        )
    );

create policy "Allow admin full access on song_raags" on public.song_raags
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
-- -------------------------------------------------------------------------
-- MOBILE APP DATABASE EXTENSIONS
-- -------------------------------------------------------------------------

-- 1. Extend profiles table with avatar, provider and banned state
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar text;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS auth_provider text DEFAULT 'email';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_banned boolean DEFAULT false;

-- 2. Extend songs table for visibility, moderation, ownership and stats
ALTER TABLE public.songs ADD COLUMN IF NOT EXISTS visibility text NOT NULL DEFAULT 'public' CHECK (visibility IN ('public', 'private'));
ALTER TABLE public.songs ADD COLUMN IF NOT EXISTS approval_status text NOT NULL DEFAULT 'approved' CHECK (approval_status IN ('pending', 'approved', 'rejected'));
ALTER TABLE public.songs ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL;
ALTER TABLE public.songs ADD COLUMN IF NOT EXISTS approved_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL;
ALTER TABLE public.songs ADD COLUMN IF NOT EXISTS views_count integer DEFAULT 0 NOT NULL;
ALTER TABLE public.songs ADD COLUMN IF NOT EXISTS likes_count integer DEFAULT 0 NOT NULL;

-- 3. Create Playlists Table
CREATE TABLE IF NOT EXISTS public.playlists (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    title text NOT NULL,
    description text,
    cover_image text,
    visibility text NOT NULL DEFAULT 'public' CHECK (visibility IN ('public', 'private')),
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS for playlists
ALTER TABLE public.playlists ENABLE ROW LEVEL SECURITY;

-- Playlists RLS Policies
CREATE POLICY "Allow public read access to public playlists" ON public.playlists
    FOR SELECT USING (visibility = 'public');

CREATE POLICY "Allow users access to their own playlists" ON public.playlists
    FOR ALL USING (auth.uid() = user_id);

-- 4. Create Playlist Songs Junction Table with custom order
CREATE TABLE IF NOT EXISTS public.playlist_songs (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    playlist_id uuid REFERENCES public.playlists(id) ON DELETE CASCADE NOT NULL,
    song_id uuid REFERENCES public.songs(id) ON DELETE CASCADE NOT NULL,
    order_no integer NOT NULL,
    UNIQUE(playlist_id, song_id)
);

-- Enable RLS for playlist_songs
ALTER TABLE public.playlist_songs ENABLE ROW LEVEL SECURITY;

-- Playlist Songs RLS Policies
CREATE POLICY "Allow public read access to playlist songs" ON public.playlist_songs
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.playlists 
            WHERE id = playlist_songs.playlist_id AND (visibility = 'public' OR user_id = auth.uid())
        )
    );

CREATE POLICY "Allow users to modify songs in their own playlists" ON public.playlist_songs
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.playlists
            WHERE id = playlist_songs.playlist_id AND user_id = auth.uid()
        )
    );

-- 5. Create Favorites Table
CREATE TABLE IF NOT EXISTS public.favorites (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    song_id uuid REFERENCES public.songs(id) ON DELETE CASCADE NOT NULL,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(user_id, song_id)
);

-- Enable RLS for favorites
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

-- Favorites RLS Policies
CREATE POLICY "Allow users to view their own favorites" ON public.favorites
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Allow users to manage their own favorites" ON public.favorites
    FOR ALL USING (auth.uid() = user_id);

-- Update trigger function handle_new_user to capture metadata and create profile correctly
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger as $$
DECLARE
  assigned_role text;
  full_name text;
  avatar_url text;
  provider_name text;
BEGIN
  assigned_role := coalesce(new.raw_user_meta_data->>'role', 'user');
  IF assigned_role NOT IN ('admin', 'user') THEN
    assigned_role := 'user';
  END IF;

  full_name := coalesce(
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'name',
    split_part(new.email, '@', 1)
  );

  avatar_url := coalesce(
    new.raw_user_meta_data->>'avatar_url',
    new.raw_user_meta_data->>'picture',
    ''
  );

  provider_name := coalesce(
    new.raw_app_meta_data->>'provider',
    'email'
  );

  INSERT INTO public.profiles (id, full_name, email, role, avatar, auth_provider, is_banned)
  VALUES (
    new.id,
    full_name,
    new.email,
    assigned_role,
    avatar_url,
    provider_name,
    false
  )
  ON CONFLICT (id) DO UPDATE SET
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    avatar = COALESCE(profiles.avatar, EXCLUDED.avatar),
    auth_provider = EXCLUDED.auth_provider;

  RETURN new;
END;
$$ language plpgsql security definer;

-- Update Songs RLS to allow pending/private states and user uploads
DROP POLICY IF EXISTS "Allow public read access to active songs" ON public.songs;
CREATE POLICY "Allow public read access to active songs" ON public.songs
    FOR SELECT USING (status = true AND visibility = 'public' AND approval_status = 'approved');

CREATE POLICY "Allow users to view their own songs regardless of status" ON public.songs
    FOR SELECT USING (auth.uid() = created_by);

CREATE POLICY "Allow users to insert their own songs" ON public.songs
    FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Allow users to update their own songs" ON public.songs
    FOR UPDATE USING (auth.uid() = created_by) WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Allow users to delete their own songs" ON public.songs
    FOR DELETE USING (auth.uid() = created_by);


