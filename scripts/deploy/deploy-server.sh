#!/usr/bin/env bash
set -euo pipefail

APP_HOME="${COURSEDROP_HOME:-${HOME}/coursedrop}"
JAR_SOURCE="${1:-apps/server/target/coursedrop-server-0.1.0-SNAPSHOT.jar}"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
RELEASE_JAR="${APP_HOME}/releases/coursedrop-server-${TIMESTAMP}.jar"
CURRENT_JAR="${APP_HOME}/app/coursedrop-server.jar"

if [ ! -f "${JAR_SOURCE}" ]; then
  echo "Jar not found: ${JAR_SOURCE}" >&2
  exit 1
fi

mkdir -p "${APP_HOME}/app" "${APP_HOME}/uploads" "${APP_HOME}/logs" "${APP_HOME}/releases"
cp "${JAR_SOURCE}" "${RELEASE_JAR}"
ln -sfn "${RELEASE_JAR}" "${CURRENT_JAR}.next"
mv -Tf "${CURRENT_JAR}.next" "${CURRENT_JAR}"

if command -v systemctl >/dev/null 2>&1; then
  export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
  systemctl --user daemon-reload
  systemctl --user enable coursedrop >/dev/null
  systemctl --user restart coursedrop
  systemctl --user --no-pager status coursedrop || true
else
  echo "systemctl not found; jar deployed to ${CURRENT_JAR}, restart manually."
fi
