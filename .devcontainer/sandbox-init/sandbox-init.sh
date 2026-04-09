#!/bin/sh
set -e

LOCK="/var/run/sandbox-init.done"

if [ -f "$LOCK" ]; then
  echo "Sandbox already initialized, skipping"
  [ $# -eq 0 ] && exec sleep infinity
  exec "$@"
fi

# Protect root-owned files in .claude from deletion by vscode
sudo chown root:root /home/vscode/.claude
sudo chmod 1777 /home/vscode/.claude

# Restrict sudo to only the commands needed by this init process
sudo tee /etc/sudoers.d/vscode > /dev/null <<'SUDOERS'
vscode ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh, /usr/local/bin/init-firewall-orig.sh, /usr/local/share/docker-init.sh, /usr/local/share/docker-init-orig.sh, /usr/bin/tee, /usr/bin/touch
SUDOERS

# Skip Claude Code onboarding
cat > ~/.claude.json <<'CJSON'
{
  "hasCompletedOnboarding": true,
  "theme": "dark"
}
CJSON

# Initialize firewall if installed.
if [ -x /usr/local/bin/init-firewall.sh ]; then
  sudo /usr/local/bin/init-firewall.sh
fi

# Start Docker daemon if DinD is installed
if [ -x /usr/local/share/docker-init.sh ]; then
  sudo /usr/local/share/docker-init.sh sleep infinity &
  timeout=30; while [ $timeout -gt 0 ] && [ ! -f /var/run/docker-init.done ]; do
    sleep 1; timeout=$((timeout - 1))
  done
fi

sudo touch "$LOCK"

[ $# -eq 0 ] && exec sleep infinity
exec "$@"
