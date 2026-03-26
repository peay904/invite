# Jellyfin Invite System

## Project Overview
A self-contained invite page that lets a recipient register their own account on a personal Jellyfin server. No backend required — the page makes API calls directly to Jellyfin from the browser.

## Stack
Not yet decided. When helping build the UI, ask which stack the user prefers before generating code — plain HTML/CSS/JS, React, or Vue are all reasonable choices for this project. Plain HTML is simplest since there's no build step and the file can be opened or hosted anywhere.

## Scope
Claude Code is helping with all of the following:
- **UI**: building the invite page interface
- **API integration**: wiring up Jellyfin API calls on form submit
- **Testing & debugging**: checking API responses, CORS issues, error states
- **Hosting & deployment**: getting the page accessible so the invite link works

## How It Works
1. Admin generates/sends the invite link (the HTML file or a hosted URL)
2. User opens the page, picks a username + password, submits
3. Page calls Jellyfin API to create the account instantly
4. Optionally applies a permission policy to the new user

## Key Files
- `invite.html` (or equivalent) — the invite page (UI + API logic)
- `CLAUDE.md` — this file
- `skills/JELLYFIN_API.md` — Jellyfin API reference for this project
- `skills/INVITE_LOGIC.md` — invite control patterns (expiry, single-use, codes)
- `skills/HOSTING.md` — options for hosting the page so invite links work

## Config Block
All user-editable settings live in a single `CONFIG` object at the top of the script section in `invite.html`. Nothing else in the file should need editing for normal use. Config includes:
- `serverUrl` — Jellyfin server base URL
- `apiKey` — admin API key (generated in Jellyfin Dashboard → API Keys)
- `expiresAt` — optional ISO date string to expire the invite
- `singleUse` / `singleUseToken` — optional single-use enforcement via URL token
- `requireInviteCode` / `inviteCode` — optional secret phrase gate
- `newUserPolicy` — Jellyfin permission object applied on registration

## Jellyfin API
Base URL: whatever is set in `CONFIG.serverUrl`
Auth header required on every request:
```
X-Emby-Authorization: MediaBrowser Token="YOUR_API_KEY"
```
Full API reference: https://api.jellyfin.org

### Endpoints used
| Action | Method | Path |
|---|---|---|
| Create user | POST | `/Users/New` |
| Set permissions | POST | `/Users/{userId}/Policy` |

### Create user request body
```json
{ "Name": "username", "Password": "password" }
```
Response includes `Id` — save this for the policy call.

### Policy request body
Send a partial or full Jellyfin `UserPolicy` object. Any fields omitted will use Jellyfin defaults. Common fields:
```json
{
  "IsAdministrator": false,
  "EnableRemoteAccess": true,
  "EnableMediaPlayback": true,
  "EnableAudioPlaybackTranscoding": true,
  "EnableVideoPlaybackTranscoding": true,
  "EnableContentDeletion": false,
  "EnableContentDownloading": false,
  "SimultaneousStreamLimit": 2
}
```

## Testing & Debugging
- Always test API calls against a real Jellyfin server — there's no mock
- Check the browser Network tab first; Jellyfin's raw response usually explains the problem clearly
- To verify an API key before building the UI, test it with curl:
  ```bash
  curl -H 'X-Emby-Authorization: MediaBrowser Token="YOUR_KEY"' http://YOUR_SERVER:8096/Users
  ```
  A JSON array means the key is valid. A 401 means the key is wrong or missing.
- Common failure points: wrong port in `serverUrl`, trailing slash, invalid API key, CORS block
- Test all three invite states manually: valid, expired, and already-used token

## CORS
The page makes browser-side API calls to Jellyfin, so CORS applies. Options:
- **Easiest**: serve `invite.html` from the Jellyfin server itself (e.g. drop in `/web/` folder, access via `http://your-server/web/invite.html`)
- **Alternative**: configure Jellyfin's allowed origins in Dashboard → Networking
- **Local `file://` won't work** — browsers block cross-origin requests from file:// by default

## Constraints & Assumptions
- No backend / server-side logic — everything runs in the browser
- Admin API key is embedded in the file — only share the link with people you trust, or gate it behind an invite code
- Single-use token enforcement uses `localStorage` — it's per-device, not truly server-enforced
- Email is not a native Jellyfin user field; collecting it requires a plugin (e.g. jellyfin-accounts) or custom handling
