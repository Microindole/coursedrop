#!/usr/bin/env bash
set -euo pipefail

APP_USER="${COURSEDROP_USER:-cd}"
APP_HOME="${COURSEDROP_HOME:-/home/${APP_USER}/coursedrop}"
DOMAIN="${COURSEDROP_HOST:-coursedrop.microindole.me}"
APP_PORT="${COURSEDROP_PORT:-9090}"

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this script as root or with sudo." >&2
  exit 1
fi

id "${APP_USER}" >/dev/null
mkdir -p "${APP_HOME}/app" "${APP_HOME}/uploads" "${APP_HOME}/logs" "${APP_HOME}/releases"
chown -R "${APP_USER}:${APP_USER}" "${APP_HOME}"

if [ -d "/etc/letsencrypt/live/${DOMAIN}" ]; then
  install -m 0644 deploy/nginx/coursedrop.microindole.me.conf "/etc/nginx/sites-available/${DOMAIN}"
else
  install -m 0644 deploy/nginx/coursedrop.microindole.me.bootstrap.conf "/etc/nginx/sites-available/${DOMAIN}"
fi
ln -sfn "/etc/nginx/sites-available/${DOMAIN}" "/etc/nginx/sites-enabled/${DOMAIN}"

loginctl enable-linger "${APP_USER}"

install -d -o "${APP_USER}" -g "${APP_USER}" "/home/${APP_USER}/.config/systemd/user"
install -m 0644 -o "${APP_USER}" -g "${APP_USER}" deploy/systemd/coursedrop-user.service "/home/${APP_USER}/.config/systemd/user/coursedrop.service"

nginx -t
systemctl reload nginx

echo "Root initialization completed."
echo "Next steps:"
echo "1. Ensure DNS A record ${DOMAIN} points to this server."
echo "2. Issue certificate: certbot --nginx -d ${DOMAIN}"
echo "3. Deploy jar as ${APP_USER}, then run: systemctl --user enable --now coursedrop"
echo "4. App will listen on 127.0.0.1:${APP_PORT} through nginx."
