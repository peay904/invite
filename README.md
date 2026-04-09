# jellyfin-invite

> **Heads up:** This repo is built around my specific personal setup — hardcoded server URLs, my branding, my Docker/Caddy stack, and my own Jellyfin instance. It is published publicly for reference, but it will not work for you without meaningful changes. Treat it as a starting point, not a drop-in solution.

A single-file invite page for a self-hosted [Jellyfin](https://jellyfin.org) server. An admin sends someone a link; they open it, pick a username and password, and an account is created instantly — no backend, no database, no email flow.

---

## How it works

1. The Docker container starts, generates a random UUID token, and injects it into `invite.html` at startup.
2. The container prints the full invite URL (with token) to stdout.
3. Admin copies that URL and sends it to the new user.
4. User opens the link, fills in the form — the page calls the Jellyfin API directly from the browser to create the account and apply a permission policy.
5. The token is marked used in `localStorage` so the link can't be reused on the same device.

## Stack

- `invite.html` — the entire UI and API logic, plain HTML/CSS/JS, no build step
- `nginx:alpine` — serves the file
- Docker + Docker Compose — runs the container
- Caddy (optional) — sits in front as a reverse proxy with automatic HTTPS

## Config

Before building, edit the `CONFIG` block near the top of `invite.html`:

```js
const CONFIG = {
  serverUrl: "JELLYFIN_SERVER_URL_HERE",  // e.g. https://jelly.example.com
  apiKey:    "JELLYFIN_API_KEY_HERE",      // Dashboard → API Keys
  singleUse: true,
  singleUseToken: "__TOKEN__",             // injected at container startup — leave as-is
  newUserPolicy: { /* ... */ }
};
```

Also update `INVITE_BASE_URL` in `docker-compose.yml` to match where the container is reachable.

## Running

```bash
docker compose up -d --build
docker compose logs jellyfin-invite   # prints the invite URL
```

The invite URL looks like:

```
https://invite.example.com/invite.html?token=<uuid>
```

Send that to whoever you're adding. Each container restart regenerates a new token, invalidating any previously sent links.

## Security notes

- The API key is embedded in the served HTML — anyone who opens DevTools can see it. The key should only have the permissions needed to create users. Don't reuse an admin key with broader access.
- Single-use enforcement is `localStorage`-based and per-device only. It prevents accidental double-submission but is not a hard server-side control.
- Gate the invite URL behind a secret token (the default) and don't post it publicly.
