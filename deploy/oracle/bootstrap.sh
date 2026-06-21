#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script with sudo." >&2
  exit 1
fi

DEPLOY_USER="${SUDO_USER:-ubuntu}"

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates \
  curl \
  docker.io \
  docker-compose-v2 \
  fail2ban \
  ufw \
  unattended-upgrades

systemctl enable --now docker
usermod -aG docker "${DEPLOY_USER}"

install -d -m 0750 -o "${DEPLOY_USER}" -g "${DEPLOY_USER}" /opt/ciso-assistant

ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 443/udp
ufw --force enable

systemctl enable --now fail2ban

echo "Oracle VM bootstrap complete. Sign out and back in before running Docker as ${DEPLOY_USER}."
