-- CIPHER hosted beta schema. Run in Supabase SQL Editor.
-- RLS is enabled and owner-only access policies are created on every table.
create table if not exists public.user_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  display_name text,
  personality jsonb not null default '{}'::jsonb
);
create table if not exists public.memories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category text not null default 'General',
  content text not null check (char_length(content) <= 2000),
  pinned boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null default 'New chat',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  role text not null check (role in ('user','assistant')),
  content text not null check (char_length(content) <= 20000),
  created_at timestamptz not null default now()
);
create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text,
  content jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create table if not exists public.finance_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  entry_type text not null check (entry_type in ('expense','saving')),
  amount numeric(12,2) not null check (amount > 0),
  category text not null,
  description text not null,
  entry_date date not null,
  created_at timestamptz not null default now()
);

alter table public.user_profiles enable row level security;
alter table public.memories enable row level security;
alter table public.conversations enable row level security;
alter table public.chat_messages enable row level security;
alter table public.notes enable row level security;
alter table public.finance_entries enable row level security;

-- Policies: users can only select/insert/update/delete their own rows.
do $$ begin
  create policy "profile owner access" on public.user_profiles for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "memories owner access" on public.memories for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "conversations owner access" on public.conversations for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "chat messages owner access" on public.chat_messages for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "notes owner access" on public.notes for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
exception when duplicate_object then null; end $$;
do $$ begin
  create policy "finance entries owner access" on public.finance_entries for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
exception when duplicate_object then null; end $$;
create index if not exists memories_user_idx on public.memories(user_id);
create index if not exists conversations_user_updated_idx on public.conversations(user_id, updated_at desc);
create index if not exists messages_conversation_idx on public.chat_messages(conversation_id, created_at);
create index if not exists finance_user_date_idx on public.finance_entries(user_id, entry_date desc);

-- Cloud snapshot used by the CIPHER beta to sync core app state. Each account has one private row.
create table if not exists public.cipher_cloud_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.cipher_cloud_state enable row level security;
do $$ begin
  create policy "cipher cloud state owner access" on public.cipher_cloud_state
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
exception when duplicate_object then null; end $$;
