#!/bin/sh
set -e

TOKEN=$(cat /proc/sys/kernel/random/uuid)

sed -i "s/__TOKEN__/${TOKEN}/g" /usr/share/nginx/html/invite.html

echo ""
echo "========================================="
echo "  Invite URL:"
echo "  ${INVITE_BASE_URL}/invite.html?token=${TOKEN}"
echo "========================================="
echo ""

exec nginx -g 'daemon off;'
