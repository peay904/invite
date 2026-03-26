# SKILL: Hosting the Invite Page

The invite page makes browser-side API calls to Jellyfin, so where you host it determines whether CORS will be a problem. These are your options from simplest to most involved.

---

## Option 1: Serve from Jellyfin itself (recommended)
Drop `invite.html` into Jellyfin's web root folder. Since the page and the API are on the same origin, CORS is a non-issue.

**Where is the web folder?**
| Install method | Path |
|---|---|
| Linux package / Docker | `/usr/share/jellyfin/web/` |
| Windows installer | `C:\Program Files\Jellyfin\Server\jellyfin-web\` |
| Jellyfin Docker image | `/jellyfin/jellyfin-web/` (mount a volume or copy in) |

After copying:
```
http://YOUR_SERVER:8096/invite.html
```
That's the link you send people.

**Docker example** — copy the file into a running container:
```bash
docker cp invite.html jellyfin:/jellyfin/jellyfin-web/invite.html
```

---

## Option 2: Nginx on the same machine
If you're already running Nginx (e.g. as a reverse proxy in front of Jellyfin), serve the file as a static asset and proxy to Jellyfin.

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # Serve the invite page
    location /invite {
        root /var/www/jellyfin-invite;
        try_files /invite.html =404;
    }

    # Proxy Jellyfin API (same origin = no CORS)
    location / {
        proxy_pass http://localhost:8096;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Invite link: `https://your-domain.com/invite`

---

## Option 3: Any static host + configure Jellyfin CORS
Host the file on GitHub Pages, Netlify, Caddy, or any static server. Then tell Jellyfin to allow requests from that origin.

In Jellyfin: **Dashboard → Networking → Known Proxies / CORS hosts**
Add your hosting domain, e.g. `https://myinvite.netlify.app`

Restart Jellyfin after saving.

**GitHub Pages** (free, no server needed):
1. Create a repo, add `invite.html`, enable Pages in repo settings
2. Your invite link: `https://yourusername.github.io/repo-name/invite.html`
3. Add that URL to Jellyfin's CORS hosts

**Netlify drag-and-drop** (free, instant):
1. Go to netlify.com → drag your `invite.html` onto the deploy zone
2. You get a URL like `https://random-name.netlify.app`
3. Add that URL to Jellyfin's CORS hosts

---

## Option 4: Python one-liner (local testing only)
Not for real invites — just for testing the page locally without `file://` issues.

```bash
# Serve on port 8080 from the folder containing invite.html
python3 -m http.server 8080
```
Then open `http://localhost:8080/invite.html`. Still hits CORS if Jellyfin is on a different host/port, but useful for checking the UI.

---

## Checklist before sending the invite link

- [ ] Page loads without console errors
- [ ] API key is correct (test with curl — see CLAUDE.md)
- [ ] `serverUrl` in CONFIG has no trailing slash
- [ ] CORS is resolved (same origin, or Jellyfin CORS hosts configured)
- [ ] Invite expiry / single-use token / invite code tested if used
- [ ] Successful registration creates the user in Jellyfin Dashboard → Users
- [ ] Link works on mobile (test in a real browser, not just desktop)
