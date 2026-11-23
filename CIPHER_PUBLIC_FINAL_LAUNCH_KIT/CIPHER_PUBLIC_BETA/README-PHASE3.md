# CIPHER Public Beta — Phase 3 checkpoint

This checkpoint consolidates the app into a **single hosted Node service** that serves the existing CIPHER frontend and the protected AI endpoint from one origin.

## What's changed
- Frontend now reads Supabase settings from `/config.js` generated at runtime by the server. No project credentials are hardcoded into the HTML.
- The server serves `public/public.html` at `/` and static assets (including `pixel-party.mp3`).
- `/api/health` reports backend configuration status.
- `/api/chat` verifies the Supabase access token before contacting OpenRouter, with simple per-IP and per-user rate limits.
- Security headers are added to static and API responses.
- Added `infra/supabase/phase3-required-schema.sql`, an additive migration for `user_profiles` and `cipher_cloud_state`, with owner-only RLS.
- Existing CIPHER finance/notes/memory/chat browser state is currently synchronized as one JSON snapshot. This is a beta bridge, not the final normalized design. Note videos and oversized media are not cloud synced.

## Required Supabase setup
1. In Supabase SQL Editor, create a **new query**.
2. Open and paste `infra/supabase/phase3-required-schema.sql`.
3. Run it. It is additive and does not change the existing finance tables.
4. Do not use service-role/secret keys in frontend settings.

The app's signup flow currently asks for a profile after successful sign-up. Profile writes target `user_profiles`.

## Local smoke test
- Use Node.js 20 or later.
- Copy `.env.example` to `.env` and enter the Supabase project URL and publishable/anon key, plus the OpenRouter API key for AI.
- `npm start` or `node server-hosted.js`.
- Visit `http://localhost:3000/`.
- `GET /api/health` should report authConfigured and aiConfigured based on env values.

## Deployment shape
Deploy this folder as a Node service with `npm start`, Node 20+, and the environment variables above. It serves both the frontend and API, so frontend API calls are same-origin. The free hosting URL is provider-generated.

## Important status
This is still a development checkpoint. No live Supabase test has been run here, no deployment has been performed, and no two-user RLS test has been completed. Before public launch, test signup/login, email recovery, cloud state sync, data migration, two-account isolation, abuse controls, and account deletion/export. Supabase and AI free tiers can change limits or availability. The frontend snapshot storage also needs further work for media and user data lifecycle handling.

## Phase 3.1 hardening update

- AI requests now include a bounded system prompt containing the supplied financial context, saved memories, and personality controls.
- Context is truncated to limits before it is added to the AI request. Transaction context is limited to the 40 most recent records.
- Request body size handling now drains the request safely after the size limit is exceeded instead of pausing the stream.
- AI provider calls have a 45-second timeout and provider errors are logged by status without returning raw provider content to the client.
- Added `npm test` automated local smoke tests for health, runtime config, homepage, MP3, unauthenticated AI access, and unknown routes.

### Updated local checks
- `node --check server-hosted.js`: passed
- `node --check test-hosted-server.js`: passed
- Inline frontend JavaScript syntax check: passed
- `npm test`: passed
- Obvious hardcoded-secret scan: no real keys found (the backend intentionally references `OPENROUTER_API_KEY` from the environment).

### Still not verified
No live Supabase authentication, database/RLS, cloud-sync recovery, deployment, provider availability, or two-account isolation tests have been performed. This remains a public-beta candidate, not a verified production launch.
