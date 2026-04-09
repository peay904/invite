#!/bin/sh
set -e

TOKEN=$(cat /proc/sys/kernel/random/uuid)

: "${INVITE_BASE_URL:?INVITE_BASE_URL is required}"
: "${JELLYFIN_URL:?JELLYFIN_URL is required}"
: "${SITE_URL:?SITE_URL is required}"

# Strip protocol from SITE_URL for display (e.g. https://example.com → example.com)
SITE_DISPLAY=$(echo "$SITE_URL" | sed 's|^https\?://||')

sed -i \
  -e "s|__TOKEN__|${TOKEN}|g" \
  -e "s|__JELLYFIN_URL__|${JELLYFIN_URL}|g" \
  -e "s|__SITE_URL__|${SITE_URL}|g" \
  -e "s|__SITE_DISPLAY__|${SITE_DISPLAY}|g" \
  /usr/share/nginx/html/invite.html

echo ""
echo "========================================="
echo "  Invite URL:"
echo "  ${INVITE_BASE_URL}/invite.html?token=${TOKEN}"
echo "========================================="
echo ""

exec nginx -g 'daemon off;'
