# SKILL: Jellyfin API

Reference for interacting with the Jellyfin REST API from the browser (no backend).

## Auth
Every request needs this header:
```
X-Emby-Authorization: MediaBrowser Token="YOUR_API_KEY"
```
Generate an API key in: Jellyfin Dashboard → API Keys → click `+`

The key goes in `CONFIG.apiKey` in `invite.html`. It is embedded in the page, so treat the invite link like a secret if you're not using an invite code gate.

---

## Endpoint: Create User
```
POST /Users/New
```

### Request
```json
{
  "Name": "desired_username",
  "Password": "desired_password"
}
```

### Success response `200`
```json
{
  "Id": "abc123...",
  "Name": "desired_username",
  ...
}
```
Save `Id` — you need it for the policy call.

### Error cases
| Status | Meaning |
|---|---|
| 400 | Username already exists, or invalid input |
| 401 | Missing or invalid API key |
| 403 | Key doesn't have admin privileges |

---

## Endpoint: Set User Policy
```
POST /Users/{userId}/Policy
```
Call this immediately after creating the user to override default permissions.

### Request body
Send only the fields you want to set — omitted fields keep Jellyfin defaults.
```json
{
  "IsAdministrator": false,
  "IsHidden": false,
  "IsDisabled": false,
  "EnableRemoteAccess": true,
  "EnableLiveTvAccess": false,
  "EnableMediaPlayback": true,
  "EnableAudioPlaybackTranscoding": true,
  "EnableVideoPlaybackTranscoding": true,
  "EnablePlaybackRemuxing": true,
  "EnableContentDeletion": false,
  "EnableContentDownloading": false,
  "SimultaneousStreamLimit": 2
}
```
`SimultaneousStreamLimit: 0` means unlimited.

### Success response
`204 No Content` — no body returned.

---

## Fetch pattern (browser JS)
```js
// Step 1: create user
const res = await fetch(`${CONFIG.serverUrl}/Users/New`, {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "X-Emby-Authorization": `MediaBrowser Token="${CONFIG.apiKey}"`,
  },
  body: JSON.stringify({ Name: username, Password: password }),
});

if (!res.ok) throw new Error(`Failed to create user: ${res.status}`);
const { Id: userId } = await res.json();

// Step 2: apply policy
await fetch(`${CONFIG.serverUrl}/Users/${userId}/Policy`, {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
    "X-Emby-Authorization": `MediaBrowser Token="${CONFIG.apiKey}"`,
  },
  body: JSON.stringify(CONFIG.newUserPolicy),
});
```

---

## CORS
Browser requests to Jellyfin are subject to CORS. If you see a CORS error:
- Serve the invite page **from the Jellyfin server** (drop in `/web/` folder)
- Or add your hosting origin to Jellyfin: Dashboard → Networking → allowed origins
- `file://` origins are blocked by default — don't open the HTML file directly from disk

## Full API docs
https://api.jellyfin.org
