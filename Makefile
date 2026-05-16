MARKETPLACES := ivanov-gv/agents https://github.com/anthropics/claude-code anthropics/claude-plugins-official
PLUGINS := agents@ivanov-gv gopls-lsp@claude-plugins-official pr-review-toolkit@claude-plugins-official ralph-loop@claude-plugins-official code-simplifier@claude-plugins-official feature-dev@claude-plugins-official

-include .env
export

clean-build: delete-images build

.PHONY: build
build: build-dind build-golang build-golang-dind

.PHONY: build-dind
build-dind:
	devcontainer build --no-cache --workspace-folder $(CURDIR) --config $(CURDIR)/.devcontainer/dind/devcontainer.json --image-name cc-dind

.PHONY: build-golang
build-golang:
	devcontainer build --no-cache --workspace-folder $(CURDIR) --config $(CURDIR)/.devcontainer/golang/devcontainer.json --image-name cc-golang

.PHONY: build-golang-dind
build-golang-dind:
	devcontainer build --no-cache --workspace-folder $(CURDIR) --config $(CURDIR)/.devcontainer/golang-dind/devcontainer.json --image-name cc-golang-dind

delete-images:
	docker rmi -f cc-dind cc-golang cc-golang-dind

up:
	docker compose up -d

down:
	docker compose down

purge: delete-images
	docker compose down --volumes

setup: sync install-plugins

.PHONY: connect
connect:
	@./connect.sh

.PHONY: sync
sync:
	@for id in $$(docker compose ps -q); do \
		name=$$(docker inspect --format '{{.Name}}' $$id | tr -d '/'); \
		echo "syncing $$name..."; \
		echo "agents"; \
		docker exec -u root $$id bash -c 'rm -rf /home/vscode/.claude/agents'; \
		docker cp ./.claude/agents/. $$id:/home/vscode/.claude/agents/; \
		docker exec -u root $$id bash -c 'chown -R root:root /home/vscode/.claude/agents && chmod -R a+rX /home/vscode/.claude/agents'; \
		echo "shared"; \
		docker exec -u root $$id bash -c 'rm -rf /home/vscode/.claude/shared'; \
		docker cp ./.claude/shared/. $$id:/home/vscode/.claude/shared/; \
		docker exec -u root $$id bash -c 'chown -R root:root /home/vscode/.claude/shared && chmod -R a+rX /home/vscode/.claude/shared'; \
		echo "skills"; \
		docker exec -u root $$id bash -c 'rm -rf /home/vscode/.claude/skills'; \
		docker cp ./.claude/skills/. $$id:/home/vscode/.claude/skills/; \
		docker exec -u root $$id bash -c 'chown -R root:root /home/vscode/.claude/skills && chmod -R a+rX /home/vscode/.claude/skills'; \
		echo "claude.md"; \
		docker exec -u root $$id bash -c 'rm -f /home/vscode/.claude/CLAUDE.md'; \
		docker cp ./.claude/CLAUDE.md $$id:/home/vscode/.claude/CLAUDE.md; \
		docker exec -u root $$id bash -c 'chown root:root /home/vscode/.claude/CLAUDE.md && chmod 444 /home/vscode/.claude/CLAUDE.md'; \
		echo "settings.json"; \
		docker cp ./.claude/settings.json $$id:/tmp/cc-settings.json; \
		docker exec -u root $$id bash -c 'jq -s ".[0] * .[1]" /home/vscode/.claude/settings.json /tmp/cc-settings.json > /tmp/cc-settings-merged.json && mv /tmp/cc-settings-merged.json /home/vscode/.claude/settings.json && chown vscode:vscode /home/vscode/.claude/settings.json'; \
		echo "private-key.pem"; \
		docker exec -u root $$id bash -c 'mkdir -p /home/vscode/.config/contribute && chown vscode:vscode /home/vscode/.config/contribute'; \
		docker exec -u root $$id bash -c 'rm -f /home/vscode/.config/contribute/private-key.pem'; \
		docker cp "${GH_CONTRIBUTE_PRIVATE_KEY_PATH}" $$id:/home/vscode/.config/contribute/private-key.pem; \
		docker exec -u root $$id bash -c 'chown root:root /home/vscode/.config/contribute/private-key.pem && chmod 444 /home/vscode/.config/contribute/private-key.pem'; \
	done

.PHONY: install-plugins
install-plugins:
	@for id in $$(docker compose ps -q); do \
		name=$$(docker inspect --format '{{.Name}}' $$id | tr -d '/'); \
		echo "installing plugins in $$name..."; \
		for mp in $(MARKETPLACES); do \
			docker exec -u vscode $$id bash -lc "claude plugin marketplace add $$mp"; \
		done; \
		for pl in $(PLUGINS); do \
			docker exec -u vscode $$id bash -lc "claude plugin install $$pl"; \
		done; \
	done

.PHONY: test
test:
	@for id in $$(docker compose ps -q); do \
		name=$$(docker inspect --format '{{.Name}}' $$id | tr -d '/'); \
		echo "testing $$name..."; \
		docker cp test-sandbox.sh $$id:/home/vscode/test-sandbox.sh; \
        docker exec -u vscode $$id sh /home/vscode/test-sandbox.sh; \
	done
