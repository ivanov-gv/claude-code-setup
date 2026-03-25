#!/bin/sh
set -e

# Initialize firewall if installed
if [ -x /usr/local/bin/init-firewall.sh ]; then
  sudo /usr/local/bin/init-firewall.sh
fi

# Chain through docker-init.sh if DinD is installed
if [ -x /usr/local/share/docker-init.sh ]; then
  exec /usr/local/share/docker-init.sh "$@"
fi

# Default to sleep infinity if no command given
if [ $# -eq 0 ]; then
  exec sleep infinity
fi

exec "$@"
