# CIPHER Public Beta – starter security infrastructure

This package creates the first online infrastructure scaffold. **It is not yet safe for public users or sensitive financial data.** The existing CIPHER frontend is still localStorage-based; it must be integrated with Supabase Auth and the database before public launch.


## What's included
- `public.html`: copy of the current CIPHER UI (static preview; not connected to cloud accounts yet)
- `server-hosted.js`: starter API that verifies Supabase Auth tokens before proxying AI requests; no AI key exposed to browser
- `infra/supabase/schema.sql`: database tables with Row Level Security owner policies for profiles, memory, chat, notes, finance
- `.env.example`: environment variable template
- `server-local-backup.js`: backup of the existing local backend

## Suggested free-beta stack
- Supabase Auth + Postgres (free tier; configure policies and backups)
- Render Web Service (free tier; sleeping/ephemeral limitations)
- OpenRouter free model (provider quotas/availability may change)
- No custom domain required: use Render's generated subdomain

## Setup (after you create accounts)
1. Create a Supabase project.
2. In Supabase SQL Editor, run `infra/supabase/schema.sql`.
3. Create a Render Web Service from this folder/repository. Use Node runtime and start command `node server-hosted.js`.
4. Set environment variables in Render using `.env.example` as a guide. Never upload a real `.env` to a public repo.
5. Set `APP_ORIGIN` to your Render URL.
6. Test authentication and API endpoints before any public announcement.

## Remaining required work before launch
- Integrate Supabase signup/login into frontend.
- Replace local-only chat, memory, notes and finance persistence with authenticated database reads/writes.
- Private media storage bucket + signed URLs, size/type validation, upload limits.
- Add CSRF/origin protection suitable for the final auth approach, stronger rate limits, abuse protection, and user deletion/export workflow.
- Add database backup/restore procedure; verify free-tier backup limitations.
- Run a two-account isolation test against every table and endpoint.
- Add privacy notice, terms, and AI/data disclosure.
- Review OpenRouter model/provider data retention settings and minimize what is sent.
- Do not store highly sensitive data until security review and integration tests pass.

## Local syntax check
`node --check server-hosted.js`
