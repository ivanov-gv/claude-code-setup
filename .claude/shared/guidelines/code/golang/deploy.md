# Deploy

## Build

- `CGO_ENABLED=0` always — static binary, no shared lib dependencies
- Cross-compile explicitly: `GOOS=linux GOARCH=amd64`
- Strip debug info: `-ldflags="-s -w"`
- Remove local paths: `-trimpath`
- Inject version at build time via `-X` ldflags using `git describe` and `git rev-parse`

## Docker

- Multi-stage build — build in `golang:alpine`, copy binary to runtime image
- Prefer the tiniest image possible, a `scratch` image for example
- Only copy the binary into the final image
- Never install runtime dependencies — if you need them, question the approach first

## Deploy

- Expose `/healthz` (liveness) and `/readyz` (readiness) — they are not the same check
- Handle `SIGTERM` with graceful shutdown and a timeout context
- Set `GOMEMLIMIT` to ~85% of the container memory limit
- No config baked into the image — env vars or mounted files only
