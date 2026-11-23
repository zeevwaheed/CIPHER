# CIPHER Phase 2 — Cloud Data Sync Build

This checkpoint adds an initial cloud snapshot sync layer to the Phase 1 Supabase-authenticated CIPHER frontend.


## Files to update in Supabase

If you already ran the earlier schema and auth patch, run **only**:

`infra/supabase/cloud-state-patch.sql`

It creates `cipher_cloud_state`, with a single per-user row and owner-only RLS.

## Frontend configuration

In `public.html`, locate these constants near the top of the Supabase script and replace the placeholders:

- `CIPHER_SUPABASE_URL` with your project URL
- `CIPHER_SUPABASE_ANON_KEY` with your project's public anon key (never the service-role key)
- `CIPHER_API_BASE` with the deployed backend origin, e.g. `https://your-api.onrender.com` (no trailing slash). Leave blank only if the API is served on the same origin as the frontend.

## What syncs

- finance data (income, goal, transactions)
- sticky note board JSON
- AI memories
- AI personality settings
- chat archives and legacy current chat

Cloud state loads after authentication. If a user account has no cloud data but this browser contains data, CIPHER asks before importing it. Do not import local data unless it belongs to that user.


## Limitations of this checkpoint

- Sticky-note video files remain in browser IndexedDB and do not sync between devices.
- Inline image notes can make the JSON snapshot large. Cloud sync rejects snapshots above 1.5 MB. Proper media sync needs Supabase Storage with private bucket policies and signed URLs.
- This is not a launch-ready build. It has only syntax checks, not live database/auth/security testing.
- The hosted backend currently provides authenticated AI text replies only; full AI finance actions and memory extraction still require backend integration.
- Backend rate limiting is in-memory; for public launch it should be supplemented with durable/shared controls and deployment protections.
