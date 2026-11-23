-- CIPHER Phase 1: cloud profile fields for Supabase Auth integration
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS username text;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS date_of_birth date;
ALTER TABLE public.user_profiles ADD COLUMN IF NOT EXISTS sex text;
CREATE UNIQUE INDEX IF NOT EXISTS user_profiles_username_lower_unique
  ON public.user_profiles (lower(username)) WHERE username IS NOT NULL;
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
-- Owner-only policy from the original schema remains in effect.
