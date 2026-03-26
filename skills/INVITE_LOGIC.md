# SKILL: Invite Control Patterns

Patterns for controlling who can use the invite page and how many times.
All of these are client-side only — no backend required, but also not tamper-proof.
For a personal server, they're more than sufficient.

---

## Pattern 1: Expiry Date
Disable the form after a certain date/time.

```js
// In CONFIG:
expiresAt: "2025-12-31T23:59:59",  // ISO string, or null to disable

// On page load:
if (CONFIG.expiresAt && new Date() > new Date(CONFIG.expiresAt)) {
  showExpiredState(); // hide form, show message
}
```
Simple and reliable. The date is visible in the source, but for a personal invite that's fine.

---

## Pattern 2: Single-Use Token
Append a token to the URL. Once used, it's marked in `localStorage` so it won't work again **on the same device**.

```js
// In CONFIG:
singleUse: true,
singleUseToken: "some-random-string",  // put this same value in the URL: ?token=some-random-string

// On page load:
const params = new URLSearchParams(window.location.search);
const token = params.get("token");
const usedKey = "jf_used_" + CONFIG.singleUseToken;

if (token !== CONFIG.singleUseToken || localStorage.getItem(usedKey)) {
  showExpiredState();
}

// After successful registration:
localStorage.setItem(usedKey, "1");
```

**Limitation**: localStorage is per-device/browser. Someone on a different device could reuse the link. Good enough for trusted personal invites; not suitable for untrusted recipients.

To make the token harder to guess, generate a random string:
```js
// Run once in browser console to generate a token:
crypto.randomUUID()  // e.g. "f47ac10b-58cc-4372-a567-0e02b2c3d479"
```

---

## Pattern 3: Invite Code / Secret Phrase
Show an extra input field. The user must know a secret phrase to proceed.

```js
// In CONFIG:
requireInviteCode: true,
inviteCode: "pineapple-express",  // tell your friend this separately

// On submit, before API call:
if (CONFIG.requireInviteCode && enteredCode !== CONFIG.inviteCode) {
  showError("Incorrect invite code.");
  return;
}
```

Useful if you're sharing the link in a semi-public place and want an extra barrier.

---

## Pattern 4: Combining Patterns
You can stack all three. A typical secure-ish personal setup:
- `expiresAt` set to a week from now
- `requireInviteCode` with a phrase you text separately
- `singleUse` with a token in the URL

This means the link only works: within the time window, with the right code, and only once per device.

---

## Showing an expired/invalid state
When any check fails, hide the form and show a message instead of letting the user attempt registration:

```js
function showExpiredState() {
  document.getElementById("form").style.display = "none";
  document.getElementById("expired-message").style.display = "block";
}
```

Always check all conditions **on page load**, before the user interacts with anything.
