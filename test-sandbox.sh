#!/bin/sh
set -u

pass=0
fail=0

check() {
  desc="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "✅ $desc"
    pass=$((pass + 1))
  else
    echo "❌ $desc"
    fail=$((fail + 1))
  fi
}

check_fail() {
  desc="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    echo "❌ $desc (should have failed)"
    fail=$((fail + 1))
  else
    echo "✅ $desc"
    pass=$((pass + 1))
  fi
}

echo "=== Sandbox Tests ==="
echo ""

# Firewall
echo "-- Firewall --"
check_fail "blocked: curl to docker.com" curl -so /dev/null --connect-timeout 5 https://docker.com
check "allowed: curl to api.anthropic.com" curl -so /dev/null --connect-timeout 5 https://api.anthropic.com
check "allowed: curl to proxy.golang.org" curl -so /dev/null --connect-timeout 5 https://proxy.golang.org
check "allowed: curl to github.com" curl -so /dev/null --connect-timeout 5 https://github.com
echo ""

# Root access
echo "-- No Root --"
check_fail "sudo denied" sudo whoami
check_fail "cannot write /etc/claude/CLAUDE.md" sh -c 'echo test >> /etc/claude/CLAUDE.md'
check_fail "cannot chown home claude dir" chown vscode:vscode /home/vscode/.claude/CLAUDE.md
echo ""

# Docker
echo "-- Docker --"
check "docker daemon running" docker info
check "docker run hello-world" docker run --rm hello-world
echo ""

# Go
echo "-- Go --"
check "go installed" go version
check "go build works" sh -c 'cd $(mktemp -d) && go mod init test && echo "package main; func main() {}" > main.go && go build .'
check "go install works" sh -c 'cd $(mktemp -d) && go mod init test && echo "package main; func main() {}" > main.go && go install .'
echo ""

# gopls
echo "-- gopls --"
check "gopls installed" gopls version
echo ""

# Claude Code
echo "-- Claude Code --"
check "claude installed" /home/vscode/.local/bin/claude --version
check_fail "CLAUDE.md is protected" rm -rf /home/vscode/.claude/CLAUDE.md
echo ""

echo "=== Results: $pass passed, $fail failed ==="
[ "$fail" -eq 0 ] && exit 0 || exit 1