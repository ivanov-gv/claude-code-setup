# Claude Code Sandboxes

Firewalled devcontainer-based sandboxes for running Claude Code. Each sandbox runs as a non-root user with iptables-based network restrictions, allowing access only to required services (Anthropic API, GitHub, package registries) while blocking everything else.

## Sandboxes

| Service | Image | Docker | Go | Enabled by default |
|---|---|---|---|---|
| `dind` | `cc-dind` | yes | no | no |
| `golang` | `cc-golang` | no | yes | no |
| `golang-dind` | `cc-golang-dind` | yes | yes | yes |

`golang-dind` is the active sandbox. `dind` and `golang` are defined in `docker-compose.yaml` but commented out. To enable them, uncomment the relevant service and volume entries.

All sandboxes include: Claude Code, GitHub CLI, tmux, git, and common utilities.

## Requirements

- Docker with Compose V2
- [devcontainer CLI](https://github.com/devcontainers/cli) (`npm install -g @devcontainers/cli`)
- A `.env` file (see [Configuration](#configuration))

## Configuration

Copy `.env.example` to `.env` and fill in the values:

```bash
cp .env.example .env
```

| Variable | Description |
|---|---|
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth token for Claude Code authentication |
| `DOCKER_HOST` | Remote Docker host (optional; leave empty to use local Docker) |
| `GH_CONTRIBUTE_PRIVATE_KEY_PATH` | Path to private key for `gh-contribute` (optional) |

The `.env` file is gitignored. The Makefile auto-exports all variables from it into the environment.

## Quick start

```bash
# Build the image
make build-golang-dind

# Start the sandbox
make up

# Sync Claude configuration and install plugins
make setup

# Run tests
make test

# Stop and remove persistent volumes
make purge
```

## Makefile targets

| Target | Description |
|---|---|
| `build` | Build all images |
| `build-dind` / `build-golang` / `build-golang-dind` | Build individual images |
| `clean` | Remove all built images |
| `clean-build` | `clean` + `build` |
| `up` | `docker compose up -d` |
| `purge` | Remove images and persistent volumes |
| `setup` | `sync` + `install-plugins` |
| `sync` | Push `.claude/` config into running containers |
| `install-plugins` | Install Claude Code plugins in running containers |
| `test` | Run `test-sandbox.sh` in each running container |

## Project structure

```
.claude/
  agents/                          # Claude Code agent definitions (synced to containers)
  shared/guidelines/               # Shared guidelines (synced to containers)
  skills/                          # Claude Code skills (synced to containers)
  CLAUDE.md                        # Injected into each container as read-only
.devcontainer/
  sandbox-init/                    # Local devcontainer feature
    devcontainer-feature.json      #   PATH, entrypoint, install ordering
    install.sh                     #   Copies sandbox-init.sh into image
    sandbox-init.sh                #   Entrypoint: firewall init + DinD chain
  dind/devcontainer.json           # Docker-in-Docker sandbox config
  golang/devcontainer.json         # Go sandbox config
  golang-dind/devcontainer.json    # Go + Docker-in-Docker sandbox config
.env.example                       # Template for required environment variables
docker-compose.yaml                # Runtime config (user, entrypoint, volumes)
Makefile                           # Build and management targets
test-sandbox.sh                    # Smoke tests run inside the sandbox
```

## How it works

### Image build

`devcontainer build` takes a base image (`mcr.microsoft.com/devcontainers/base:bookworm`) and layers devcontainer features on top:

- **firewall** installs `init-firewall.sh` (configures network restrictions per the firewall feature settings)
- **docker-in-docker** installs Docker CE and `docker-init.sh` (DinD sandboxes only)
- **sandbox-init** (local feature) installs the entrypoint script and fixes the PATH

### Container startup

The `sandbox-init.sh` entrypoint runs at container start:

1. Sets `.claude` directory ownership to root with a sticky bit, preventing the `vscode` user from deleting root-owned files inside it (e.g. the injected `CLAUDE.md`)
2. Restricts `sudo` to only the commands needed during init (firewall, docker-init, tee, touch)
3. Skips the Claude Code first-run onboarding prompt
4. Initializes the firewall via `init-firewall.sh` (configures iptables rules per the firewall feature settings)
5. If Docker-in-Docker is installed, chains to `docker-init.sh` (starts `dockerd`)
6. Falls through to `sleep infinity` to keep the container alive

### Claude configuration sync

The `.claude/` directory in this repo contains agents, skills, shared guidelines, and a `CLAUDE.md` that are pushed into running containers via `make sync`. These files are owned by root inside the container and made read-only, so the `vscode` user cannot modify them.

`make install-plugins` installs Claude Code plugins from configured marketplaces into each running container.

`make setup` runs both `sync` and `install-plugins`.

### Firewall

Network access is controlled per-sandbox via the firewall feature. The feature supports two allowlisting mechanisms: IP-range-based flags (e.g., `cloudflareIps`, `googleCloudIps`) and domain-based allowlisting via the `hosts` parameter. Each sandbox allows:

- Anthropic API (for Claude Code)
- GitHub (IPs and domains)
- Debian/Ubuntu package repositories
- Claude Code update servers

Additional access per sandbox type:

| Access | `dind` | `golang` | `golang-dind` |
|---|---|---|---|
| Docker Hub registry | yes | no | yes |
| Cloudflare IPs | yes | no | yes |
| Google Cloud IPs | no | yes | yes |
| Go module proxy | no | yes | yes |

DinD sandboxes also allowlist `cloudflarestorage.com` and `download.docker.com` via the `hosts` parameter. Go sandboxes allowlist `proxy.golang.org`, `sum.golang.org`, `storage.googleapis.com`, and `golang.org`.

### Persistence

Each sandbox has a named Docker volume mounted at `/home/vscode`. Files in the home directory persist across container restarts. Use `make purge` to wipe volumes.

## Adding a new sandbox

1. Create `.devcontainer/<name>/devcontainer.json`:

```json
{
  "name": "cc-<name>",
  "image": "mcr.microsoft.com/devcontainers/base:bookworm",
  "shutdownAction": "none",
  "features": {
    "ghcr.io/stu-bell/devcontainer-features/claude-code:0": {},
    "ghcr.io/devcontainers/features/common-utils:2": {},
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/w3cj/devcontainer-features/firewall:latest": {
      "githubIps": true,
      "githubDomains": true,
      "anthropicIps": true,
      "anthropicApi": true,
      "debianPackages": true,
      "ubuntuPackages": true,
      "claudeCode": true,
      "dockerRegistry": false
    },
    "ghcr.io/devcontainers-extra/features/tmux-apt-get:1": {},
    "../sandbox-init": {}
  }
}
```

2. Add the service to `docker-compose.yaml`:

```yaml
  <name>:
    <<: *default
    image: cc-<name>
    cap_add:
      - NET_ADMIN
    volumes:
      - <name>-home:/home/vscode
```

Use `privileged: true` instead of `cap_add: [NET_ADMIN]` if the sandbox needs Docker-in-Docker. DinD sandboxes also need a tmpfs mount for `/var/lib/docker`.

3. Add the volume to the `volumes:` section and a build target to the `Makefile`.

## Docker-in-Docker notes

- DinD sandboxes require `privileged: true` (superset of `NET_ADMIN`, so `cap_add` is unnecessary)
- `/var/lib/docker` must be a tmpfs mount — overlayfs-on-overlayfs is not supported
- Docker state inside DinD does not persist across restarts (tmpfs is ephemeral)
- DinD sandboxes need `cloudflareIps: true` in the firewall config because Docker Hub serves image layers from Cloudflare R2 (`*.r2.cloudflarestorage.com`)
- DinD sandboxes need `download.docker.com` in the firewall `hosts` parameter (e.g., `"hosts": "cloudflarestorage.com,download.docker.com"`) for Docker CE apt repository access

## Caveats

- **Firewall granularity**: IP-range-based flags like `cloudflareIps` and `googleCloudIps` allow access to all services hosted on those networks, not just the intended ones (e.g., Docker Hub or Go proxy). The `hosts` parameter provides finer-grained domain-based allowlisting but is subject to DNS rotation. Both approaches involve trade-offs.
- **Startup delay**: Firewall initialization takes up to 60 seconds on first boot while it fetches current IP ranges for GitHub, Cloudflare, Google Cloud, etc. During this window, network access is unrestricted.
- **No Dockerfile**: Images are built entirely from devcontainer features. The `entrypoint`, `user`, and `command` are set at runtime via `docker-compose.yaml` because devcontainer features cannot bake these into the image. The `x-default` YAML anchor keeps this DRY.
- **JetBrains settings**: The `golang` and `golang-dind` configs include JetBrains/GoLand IDE customizations. These are ignored when running via `docker compose` and only apply when connecting through a JetBrains Gateway.
