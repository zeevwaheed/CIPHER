-- Apply once in Supabase SQL Editor for the CIPHER beta cloud snapshot sync.
create table if not exists public.cipher_cloud_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  state jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table public.cipher_cloud_state enable row level security;
drop policy if exists "cipher cloud state owner access" on public.cipher_cloud_state;
create policy "cipher cloud state owner access" on public.cipher_cloud_state
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
