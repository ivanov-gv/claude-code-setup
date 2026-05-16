#!/usr/bin/env bash
set -e

mapfile -t names < <(docker compose ps --format '{{.Name}}')
[ "${#names[@]}" -eq 0 ] && echo "No running containers." && exit 1

PS3="Select container [#]: "
select name in "${names[@]}"; do
    [ -n "$name" ] && break
    echo "Invalid selection."
done

mapfile -t sessions < <(docker exec -u vscode "$name" screen -ls 2>/dev/null | grep -oE '[0-9]+\.[^[:space:]]+' || true)

PS3="Select session [#]: "
select session in "${sessions[@]}" "[new session]"; do
    [ -n "$session" ] && break
    echo "Invalid selection."
done

if [ "$session" = "[new session]" ]; then
    exec docker exec -it -e TERM="$TERM" -u vscode "$name" bash -lc 'screen -U -S claude claude --dangerously-skip-permissions'
else
    exec docker exec -it -e TERM="$TERM" -u vscode "$name" screen -U -d -r "$session"
fi