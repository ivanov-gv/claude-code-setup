#!/bin/sh
set -e

cp sandbox-init.sh /usr/local/bin/sandbox-init.sh
chmod +x /usr/local/bin/sandbox-init.sh

# Wrap init-firewall.sh to skip redundant re-runs.
if [ -x /usr/local/bin/init-firewall.sh ]; then
  mv /usr/local/bin/init-firewall.sh /usr/local/bin/init-firewall-orig.sh
  cat > /usr/local/bin/init-firewall.sh <<'WRAPPER'
#!/bin/sh
LOCK="/var/run/init-firewall.done"
if [ -f "$LOCK" ]; then
  echo "Firewall already initialized, skipping"
  exit 0
fi
iptables -P OUTPUT ACCEPT 2>/dev/null || true
/usr/local/bin/init-firewall-orig.sh "$@"
status=$?
[ $status -eq 0 ] && touch "$LOCK"
exit $status
WRAPPER
  chmod +x /usr/local/bin/init-firewall.sh
fi

#The same for docker-init.sh
if [ -x /usr/local/share/docker-init.sh ]; then
  mv /usr/local/share/docker-init.sh /usr/local/share/docker-init-orig.sh
  cat > /usr/local/share/docker-init.sh <<'WRAPPER'
#!/bin/sh
/usr/local/share/docker-init-orig.sh "$@" &
PID=$!
wait $PID
touch /var/run/docker-init.done
# Keep alive if called with sleep infinity
[ "$1" = "sleep" ] && exec sleep infinity
WRAPPER
  chmod +x /usr/local/share/docker-init.sh
fi
