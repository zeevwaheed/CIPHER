# CIPHER — Final Launch Package (pre-deployment)

CIPHER is a personal finance companion with a browser frontend, Supabase authentication and cloud snapshot storage, and a server-side AI endpoint. It is free for end users; third-party providers may impose usage quotas or change free model availability. No paid fallback is configured.


## What is included
- Frontend: `public/public.html`
- Static soundtrack: `public/pixel-party.mp3`
- Node server: `server-hosted.js`
- Supabase additive SQL: `infra/supabase/phase3-required-schema.sql`
- Render deployment blueprint: `render.yaml`
- Automated local smoke tests: `npm test`
- `.env.example` for local configuration

## You must do these account-dependent steps before public launch

### 1) Supabase setup
1. Open the Supabase project you created.
2. Go to **SQL Editor** and create a new query.
3. Open and copy the full contents of `infra/supabase/phase3-required-schema.sql` from this package.
4. Paste and Run it. It creates the additive `user_profiles` and `cipher_cloud_state` tables and owner-only RLS policies.
5. In **Project Settings → API**, copy the project URL and the public/anon (publishable) key. Do not use the service-role secret in this app.
6. In **Authentication → URL Configuration**, later add your deployed website URL to the Site URL and allowed redirect URLs.

### 2) AI provider key
1. Create/sign in to an OpenRouter account and create an API key.
2. Keep it private. Do not paste it into the HTML, GitHub, or chat.
3. The provider's free model availability and rate limits can change; CIPHER has no paid fallback.

### 3) Deploy to Render (free plan)
1. Create a GitHub account if needed and a **private repository** for this project.
2. Upload/extract this ZIP on your computer. Do not upload `.env` or secrets.
3. Commit the folder contents to the repository (the root should contain `package.json`, `server-hosted.js`, `render.yaml`, and `public/`).
4. In Render, create a new Blueprint deployment from the repository and use `render.yaml`.
5. In the Render service's Environment settings, add:
   - `SUPABASE_URL` = your Supabase project URL
   - `SUPABASE_ANON_KEY` = public/anon/publishable key
   - `OPENROUTER_API_KEY` = your OpenRouter secret API key
   - `OPENROUTER_MODEL` = optional; leave the blueprint default initially
6. Deploy. Copy the generated `https://...onrender.com` service URL.
7. In Supabase Authentication URL settings, set the site URL and allowed redirects to the Render URL.
8. Open the live URL and test signup, profile setup, logout/login, and cloud data persistence.

## Before inviting the public — REQUIRED verification
- Test with Account A and Account B in separate private browser sessions.
- Add unique finance entries, notes, and memories to A; sign out.
- Sign in as B and confirm A's data is not visible.
- Add data to B; sign out and back in as A. Confirm A's data remains unchanged.
- Test password reset and the deployed AI endpoint.
- Check that the service is not leaking secrets in `/config.js`, source, logs, or browser developer tools.
- Review the privacy notice and terms before sharing publicly.

## Known limitations / not verified
- **This package has not been deployed to your accounts.** Supabase and hosting credentials are not included.
- Live signup/login, live cloud synchronization, real AI provider requests, and cross-account isolation are not yet verified. The local smoke test is not a substitute for those checks.
- Cloud persistence uses one JSON snapshot per user (`cipher_cloud_state`), not the separately provisioned chat/memory/note tables. This is a beta storage bridge.
- Note videos are stored in local IndexedDB and do not transfer between devices. Images/drawing data can make snapshots large; cloud sync refuses snapshots above its size threshold.
- AI currently provides conversational responses. It does not reliably emit structured finance actions, so the app's AI transaction/action execution flow is not connected to the backend's response schema.
- In-memory server rate limits reset when the service restarts and are not a distributed abuse-control system.
- Strict Content Security Policy is not enabled because the legacy frontend uses inline scripts/styles; this needs a CSP-compatible refactor before a production-grade public launch.
- Free hosting/model plans can sleep, throttle, or change limits. A free deployment is not a promise of uninterrupted service.

## Local smoke test
Requires Node.js 20+:
```bash
npm test
```

Run locally:
```bash
cp .env.example .env
# Fill in the private values in .env locally
npm start
```
Then visit `http://localhost:3000`.
