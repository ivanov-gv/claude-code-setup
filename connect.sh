#!/usr/bin/env bash
set -e

DTACH_DIR="/tmp/dtach-sessions"

mapfile -t names < <(docker compose ps --format '{{.Name}}')
[ "${#names[@]}" -eq 0 ] && echo "No running containers." && exit 1

PS3="Select container [#]: "
select name in "${names[@]}"; do
    [ -n "$name" ] && break
    echo "Invalid selection."
done

docker exec -u vscode "$name" mkdir -p "$DTACH_DIR"

mapfile -t sessions < <(docker exec -u vscode "$name" find "$DTACH_DIR" -maxdepth 1 -type s -printf '%f\n' 2>/dev/null || true)

options=("${sessions[@]}" "[new session]")
[ "${#sessions[@]}" -gt 0 ] && options+=("[stop all]")

PS3="Select session [#]: "
select session in "${options[@]}"; do
    [ -n "$session" ] && break
    echo "Invalid selection."
done

if [ "$session" = "[stop all]" ]; then
    # Kill all dtach processes — takes their child processes with them
    docker exec -u vscode "$name" bash -c 'pkill -U "$(id -u)" dtach' 2>/dev/null || true
    sleep 1
    docker exec -u vscode "$name" find "$DTACH_DIR" -maxdepth 1 -type s -delete 2>/dev/null || true
    echo "All sessions stopped."
    exit 0
elif [ "$session" = "[new session]" ]; then
    session="claude-$(date +%s)"
    exec docker exec -it -e TERM="$TERM" -u vscode "$name" \
            dtach -A "$DTACH_DIR/$session" -z bash -lc 'claude --dangerously-skip-permissions'
else
    exec docker exec -it -e TERM="$TERM" -u vscode "$name" \
        dtach -a "$DTACH_DIR/$session" -z
fi