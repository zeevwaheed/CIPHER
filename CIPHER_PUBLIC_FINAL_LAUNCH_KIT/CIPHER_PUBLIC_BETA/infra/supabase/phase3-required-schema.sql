-- CIPHER hosted setup requirements: apply in Supabase SQL Editor.
-- Additive only. Does not alter the existing finance tables.

create table if not exists public.user_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  username text,
  date_of_birth date,
  sex text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index if not exists user_profiles_username_lower_unique
  on public.user_profiles (lower(username)) where username is not null;
alter table public.user_profiles enable row level security;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='user_profiles' AND policyname='user_profiles_owner_access') THEN
    CREATE POLICY user_profiles_owner_access ON public.user_profiles
      FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

create table if not exists public.cipher_cloud_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.cipher_cloud_state enable row level security;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='cipher_cloud_state' AND policyname='cipher_cloud_state_owner_access') THEN
    CREATE POLICY cipher_cloud_state_owner_access ON public.cipher_cloud_state
      FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;
